#!/usr/bin/env python3
"""Integration checks using real cliphist/fzf and an isolated clipboard/renderer.

Run: python3 tests/clipboard-history.py
Requires the picker's dependencies, but does not require a graphical session or
read/change the desktop clipboard. All databases and captured bytes are private
temporary fixtures.
"""

import errno
import fcntl
import json
import os
from pathlib import Path
import pty
import select
import shutil
import signal
import socket
import struct
import subprocess
import tempfile
import termios
import time
import zlib


SCRIPT = Path(__file__).resolve().parents[1] / "bin/clipboard-history"
F3, F4, F5 = b"\x1bOR", b"\x1bOS", b"\x1b[15~"


def test_image():
    def chunk(kind, data):
        return struct.pack("!I", len(data)) + kind + data + struct.pack("!I", zlib.crc32(kind + data))
    width, height = 240, 160
    pixels = b"".join(b"\x00" + b"".join(
        bytes((196, 167, 231) if (x // 20 + y // 20) % 2 else (49, 116, 143))
        for x in range(width)) for y in range(height))
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack("!2I5B", width, height, 8, 2, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(pixels)) + chunk(b"IEND", b""))


class Fixture:
    def __init__(self, root):
        self.root = root
        self.bin = root / "bin"
        self.bin.mkdir()
        self.log = root / "events"
        self.output = root / "clipboard"
        self.sock = root / "fzf.sock"
        self.history = root / "history.db"
        self.pinned = root / "data/cliphist/pinned.db"
        self.pinned.parent.mkdir(parents=True)
        self.env = dict(os.environ, HOME=str(root), XDG_DATA_HOME=str(root / "data"),
                        XDG_CACHE_HOME=str(root / "cache"), XDG_CONFIG_HOME=str(root / "config"),
                        XDG_RUNTIME_DIR=str(root), TMPDIR=str(root), TERM="xterm-256color",
                        FIXTURE_ROOT=str(root), FIXTURE_CLIPHIST=shutil.which("cliphist"),
                        FIXTURE_FZF=shutil.which("fzf"), PATH=f"{self.bin}:{os.environ['PATH']}")
        self.wrapper("cliphist", '''#!/bin/bash
printf 'cliphist %s\\n' "$*" >> "$FIXTURE_ROOT/events"
exec "$FIXTURE_CLIPHIST" -db-path "$FIXTURE_ROOT/history.db" "$@"
''')
        self.wrapper("fzf", '''#!/bin/bash
exec "$FIXTURE_FZF" --listen "$FIXTURE_ROOT/fzf.sock" "$@"
''')
        self.wrapper("wl-copy", '''#!/bin/bash
cat > "$FIXTURE_ROOT/clipboard"
''')
        self.wrapper("ueberzugpp", '''#!/usr/bin/env python3
import json, os, sys, time
with open(os.environ["FIXTURE_ROOT"] + "/events", "a", buffering=1) as log:
    log.write("renderer start\\n")
    for line in sys.stdin:
        data = json.loads(line)
        data["received_at"] = time.monotonic()
        log.write("renderer " + json.dumps(data) + "\\n")
''')
        self.pid = None
        self.fd = None
        self.terminal_output = b""

    def wrapper(self, name, contents):
        path = self.bin / name
        path.write_text(contents)
        path.chmod(0o700)

    def store(self, data, pinned=False):
        subprocess.run([self.env["FIXTURE_CLIPHIST"], "-db-path",
                        str(self.pinned if pinned else self.history), "store"],
                       input=data, env=self.env, check=True, capture_output=True)

    def start(self):
        self.sock.unlink(missing_ok=True)
        started = time.monotonic()
        pid, fd = pty.fork()
        if pid == 0:
            os.execve(str(SCRIPT), [str(SCRIPT), "--picker"], self.env)
        self.pid, self.fd = pid, fd
        fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 36, 120, 0, 0))
        self.wait(lambda: self.state().get("totalCount", 0) > 0)
        return (time.monotonic() - started) * 1000

    def drain(self):
        while self.fd is not None and select.select([self.fd], [], [], 0)[0]:
            try:
                data = os.read(self.fd, 65536)
                self.terminal_output += data
                if not data:
                    break
                if b"\x1b[6n" in data:
                    os.write(self.fd, b"\x1b[1;1R" * data.count(b"\x1b[6n"))
                if b"\x1b[?2004$p" in data:
                    os.write(self.fd, b"\x1b[?2004;2$y")
            except OSError as exc:
                if exc.errno != errno.EIO:
                    raise
                break

    def state(self):
        self.drain()
        try:
            with socket.socket(socket.AF_UNIX) as client:
                client.settimeout(0.2)
                client.connect(str(self.sock))
                client.sendall(b"GET /?limit=100 HTTP/1.0\r\n\r\n")
                response = b""
                while chunk := client.recv(65536):
                    response += chunk
            return json.loads(response.split(b"\r\n\r\n", 1)[1])
        except (OSError, ValueError, IndexError):
            return {}

    def wait(self, predicate, timeout=4):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            self.drain()
            if predicate():
                return
            time.sleep(0.01)
        raise AssertionError(f"Timed out; fzf={self.state()}; log={self.events()}; terminal={self.terminal_output[-2000:]!r}")

    def keys(self, keys):
        os.write(self.fd, keys)

    def events(self):
        return self.log.read_text() if self.log.exists() else ""

    def renderer_actions(self):
        return [json.loads(line.removeprefix("renderer ")) for line in self.events().splitlines()
                if line.startswith("renderer {")]

    def close(self, key=b"\x1b", expected_status=0):
        descendants = self.descendants(self.pid)
        self.keys(key)
        deadline = time.monotonic() + 4
        while time.monotonic() < deadline:
            self.drain()
            pid, status = os.waitpid(self.pid, os.WNOHANG)
            if pid:
                self.pid = None
                os.close(self.fd)
                self.fd = None
                assert os.waitstatus_to_exitcode(status) == expected_status, status
                assert not list(self.root.glob("clipboard-history.*")), "Temporary data leaked"
                self.wait(lambda: not [pid for pid in descendants if self.alive(pid)])
                return
            time.sleep(0.01)
        raise AssertionError("Picker did not close")

    @staticmethod
    def descendants(pid):
        children = Path(f"/proc/{pid}/task/{pid}/children")
        if not children.exists():
            return set()
        result = set(map(int, children.read_text().split()))
        for child in list(result):
            result.update(Fixture.descendants(child))
        return result

    @staticmethod
    def alive(pid):
        try:
            return Path(f"/proc/{pid}/stat").read_text().split(") ", 1)[1][0] != "Z"
        except FileNotFoundError:
            return False

    def cleanup(self):
        if self.pid:
            os.kill(self.pid, signal.SIGTERM)
            os.waitpid(self.pid, 0)
        if self.fd is not None:
            os.close(self.fd)


def check(root):
    fixture = Fixture(root)
    multiline = "  first line\n\tСрпски · café · 😀\nlast line  \n\n".encode()
    image = test_image()
    try:
        fixture.store(image)
        fixture.store(b"a sparse f u z z y match")
        fixture.store(b"fuzzy")
        fixture.store(multiline)
        fixture.output.write_bytes(b"original clipboard")
        cold = fixture.start()
        assert "renderer start" not in fixture.events(), "Renderer started for text"
        assert fixture.state()["current"]["text"].endswith("first line Српски · café · 😀 last line"), fixture.state()
        assert fixture.events().count(" decode ") <= 1, "Bulk decoding during startup"
        fixture.keys(b"fuzzy")
        fixture.wait(lambda: fixture.state().get("query") == "fuzzy" and fixture.state().get("matchCount") == 2)
        assert fixture.state()["current"]["text"].endswith("\tfuzzy"), "Fuzzy ranking failed"
        fixture.keys(b"\x0e")  # Ctrl-N down, Ctrl-P back up.
        fixture.wait(lambda: "sparse" in fixture.state().get("current", {}).get("text", ""))
        fixture.keys(b"\x10")
        fixture.wait(lambda: fixture.state().get("current", {}).get("text", "").endswith("\tfuzzy"))
        fixture.keys(F5)
        fixture.wait(lambda: fixture.pinned.exists())
        fixture.keys(F3)
        fixture.wait(lambda: fixture.state().get("totalCount") == 1 and fixture.state().get("current", {}).get("text", "").startswith("pinned\t"))
        assert fixture.state()["query"] == "fuzzy", "F3 lost the query"
        fixture.keys(F5)
        fixture.wait(lambda: fixture.state().get("totalCount") == 0)
        assert fixture.state()["query"] == "fuzzy", "F5 lost the query"
        fixture.keys(F3)
        fixture.wait(lambda: fixture.state().get("matchCount") == 2)
        fixture.keys(b"\x15")  # Ctrl-U clears the query.
        fixture.wait(lambda: fixture.state().get("query") == "" and fixture.state().get("matchCount") == 4)
        fixture.close()
        assert fixture.output.read_bytes() == b"original clipboard", "Cancel changed clipboard"
        print(f"PASS: ranking, navigation, pins, query retention, empty pinned history, cancellation ({cold:.1f} ms cold results)")

        warm = fixture.start()
        fixture.close(b"\r")
        assert fixture.output.read_bytes() == multiline, "Multiline/whitespace/Unicode bytes changed"
        print(f"PASS: exact text copying ({warm:.1f} ms warm results)")

        fixture.start()
        fixture.keys(b"binary")
        fixture.wait(lambda: '"action": "add"' in fixture.events())
        start_count = fixture.events().count("renderer start")
        fixture.keys(F4)
        fixture.wait(lambda: fixture.events().count('"action": "add"') >= 2)
        adds = [json.loads(line.removeprefix("renderer ")) for line in fixture.events().splitlines()
                if line.startswith("renderer {") and '"action": "add"' in line]
        assert adds[-1]["max_width"] > adds[0]["max_width"], "F4 did not enlarge image"
        fcntl.ioctl(fixture.fd, termios.TIOCSWINSZ, struct.pack("HHHH", 40, 140, 0, 0))
        fixture.wait(lambda: fixture.events().count('"action": "add"') >= 3)
        fixture.keys(b"no-such-result")
        fixture.wait(lambda: fixture.state().get("matchCount") == 0)
        fixture.wait(lambda: fixture.renderer_actions()[-1]["action"] == "remove")
        actions = [json.loads(line.removeprefix("renderer "))["action"] for line in fixture.events().splitlines()
                   if line.startswith("renderer {")]
        assert actions[-1] == "remove", "Empty results left an overlay"
        fixture.keys(b"\x15binary")
        fixture.wait(lambda: fixture.state().get("matchCount") == 1)
        fixture.close(b"\r")
        assert fixture.output.read_bytes() == image, "Image bytes changed"
        assert fixture.events().count("renderer start") == start_count, "Renderer was restarted"
        print("PASS: lazy image renderer, F4 enlargement, resize, empty-result clearing, exact image copying")

        fixture.start()
        fixture.keys(b"binary")
        fixture.wait(lambda: fixture.renderer_actions()[-1]["action"] == "add")
        count = len(fixture.renderer_actions())
        changed = time.monotonic()
        fixture.keys(b"\x15")
        fixture.wait(lambda: any(action["action"] == "remove" for action in fixture.renderer_actions()[count:]))
        selection_delay = next(action["received_at"] for action in fixture.renderer_actions()[count:]
                               if action["action"] == "remove") - changed
        assert selection_delay < 0.2, f"Selection left an overlay for {selection_delay:.3f}s"
        fixture.keys(b"binary")
        fixture.wait(lambda: fixture.renderer_actions()[-1]["action"] == "add")
        count = len(fixture.renderer_actions())
        closed = time.monotonic()
        fixture.close()
        close_delay = next(action["received_at"] for action in fixture.renderer_actions()[count:]
                           if action["action"] == "remove") - closed
        assert close_delay < 0.2, f"Closing left an overlay for {close_delay:.3f}s"
        start_count = fixture.events().count("renderer start")
        print(f"PASS: overlay clears in {selection_delay*1000:.1f} ms on selection, {close_delay*1000:.1f} ms on Escape")

        fixture.wrapper("cliphist", '''#!/bin/bash
if [[ "$*" == *"decode 1"* ]]; then
    printf 'slow decode started\\n' >> "$FIXTURE_ROOT/events"
    sleep 1
fi
exec "$FIXTURE_CLIPHIST" -db-path "$FIXTURE_ROOT/history.db" "$@"
''')
        fixture.start()
        fixture.keys(b"binary")
        fixture.wait(lambda: "slow decode started" in fixture.events())
        fixture.keys(b"\x15fuzzy")
        fixture.wait(lambda: fixture.state().get("query") == "fuzzy")
        time.sleep(1.1)
        assert fixture.events().count("renderer start") == start_count, "Stale decode displayed an image"
        fixture.close()
        print("PASS: changing selection cancels a slow image preview")

        # A renderer failure and a failed decode must never copy partial data.
        fixture.wrapper("ueberzugpp", "#!/bin/bash\nexit 1\n")
        fixture.start()
        fixture.keys(b"binary")
        fixture.wait(lambda: fixture.state().get("matchCount") == 1)
        fixture.close()
        assert fixture.output.read_bytes() == image
        fixture.wrapper("cliphist", '''#!/bin/bash
if [[ "$*" == *decode* ]]; then printf 'partial'; exit 1; fi
exec "$FIXTURE_CLIPHIST" -db-path "$FIXTURE_ROOT/history.db" "$@"
''')
        fixture.start()
        fixture.close(b"\r", expected_status=1)
        assert fixture.output.read_bytes() == image
        print("PASS: renderer failure and partial decode failure leave clipboard untouched")
    finally:
        fixture.cleanup()


if __name__ == "__main__":
    with tempfile.TemporaryDirectory(prefix="clipboard-picker-tests.") as temporary:
        check(Path(temporary))
