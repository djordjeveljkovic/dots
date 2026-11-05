# Home configuration

This repository stores selected application configuration under `.config/`.
It keeps the active mise tool pins and the settings maintained for Alacritty,
Fuzzel, htop, Mako, Neovim, Sway, Swayimg, tmux, and Yazi.

Run `./install.sh` to link those application directories and the managed Bash
files (`.bashrc`, `.bashrc.d/`, `.inputrc`, and `.bash_profile`) into your home.
`${XDG_CONFIG_HOME:-$HOME/.config}`. Existing directories are moved to a
recoverable backup under `${XDG_STATE_HOME:-$HOME/.local/state}/` before a
link is created.

`./setup.sh` or `./setup.sh check` performs a read-only check by default. It
reports missing official packages from `packages.txt`, mise tool state,
configuration links, home folders and GTK bookmarks, failed system units, and
current-boot warnings. Run `./setup.sh setup` to install missing official
packages, install the tools declared in `.config/mise/config.toml`, link
configuration, and create the managed home folders and bookmarks. This expects
Arch Linux with `pacman` and administrator access. Git, OpenSSH, Sway, kernel,
firmware, microcode, and boot packages remain machine-specific.

`aur-packages.txt` lists AUR packages for manual review. In particular, review
the [anydesk-bin AUR page](https://aur.archlinux.org/packages/anydesk-bin) and
install it yourself with your preferred AUR helper; setup never builds AUR
packages. RustDesk is excluded from the shared inventory.

Run `./bin/organize-home` to create the home folder layout, add GTK file
chooser bookmarks, and report visible entries outside the managed folder
boundaries. Use `./bin/organize-home --check` for a read-only report.

Interactive Bash settings and helpers are in `.bashrc.d/`. Machine-specific
trusted environment fragments can be placed in `~/.config/bash/env.d/*.sh`;
keep secrets out of this repository. Use `eza --tree` for a directory tree,
`bat <file>` for highlighted file output, and `ff` to pick a file with a `bat`
preview. `ls` remains an eza alias; `cat` remains the standard command.

`.inputrc` maps Up/Down to prefix-based history search: type the beginning of a
command and press Up to find the latest matching history entry.

The imported shell helpers include `compress`, `decompress`, image and video
conversion, and music playback/download commands. `iso2sd` writes an ISO to a
whole disk, while `format-drive` creates a GPT disk with one ext4 partition.
Both display and validate the target, reject mounted/system disks, and require
typing its full `/dev/...` path before writing. They never overwrite converted
outputs. Review commands and target devices carefully before use.

`.bash_profile` starts Sway after login only on tty1 and only when no graphical
session is active. It starts Sway through `uwsm` when installed, so Sway runs
in `session.slice` and apps launched from Sway (`uwsm app --`) each get their
own scope in `app.slice`; use `systemd-cgls --user-unit` or `systemd-cgtop` to
see memory per app. Without uwsm it falls back to plain `sway`. To separately enable passwordless tty1 login, run
`sudo ./bin/tty-autologin setup`; this removes the tty1 password prompt. Use
`sudo ./bin/tty-autologin remove` to remove the helper's managed drop-in.
Ordinary `./setup.sh setup` does not enable autologin.

## Out-of-memory handling

After logging in through uwsm, run `sudo ./bin/oomd-setup setup` to enable
systemd-oomd with Fedora-style defaults: inside the user session it kills the
app scope under the most pressure once memory pressure stays above 50% for
20s, and system-wide it kills the largest swap user once swap is 90% full. It
refuses to run while Sway still lives in a login session scope, since killing
that would end the desktop. Check it with `oomctl` and
`journalctl -u systemd-oomd`. `sudo ./bin/oomd-setup remove` removes its
managed drop-ins and disables the service. Do not also run earlyoom.

## tmux

`.config/tmux/tmux.conf` keeps default keys plus a Rosé Pine status bar,
splits in the current directory, and Claude/Codex status bubbles; see
`.config/tmux/CHEATSHEET.md`. `./install.sh` clones tmux-resurrect and
tmux-continuum at pinned commits into the ignored `.config/tmux/plugins/`.

## Clipboard history

`Mod+Shift+V` opens a centered Alacritty window with recent clipboard entries
on the left and the selected entry's full text or static image on the right.
Type to fuzzy-search cliphist's snippets. With an empty query, entries stay
newest first. Navigate with arrows, Ctrl-J/K, or Ctrl-N/P; Enter copies the
original bytes and Escape cancels without changing the clipboard.

F3 switches between recent and pinned history. F5 pins a recent entry or
unpins a pinned entry. Both reload within the same picker and retain the query,
including when there are no matches. F4 toggles a larger preview panel; use
Shift-Up/Down to scroll long text. Images use ueberzugpp's Wayland renderer,
started only for the first highlighted image. Only highlighted entries are
decoded, with private caches removed on exit; opening never converts the whole
history. The renderer follows its terminal when switching workspaces.

`./install.sh` links `bin/clipboard-history` to
`~/Scripts/bin/clipboard-history`, backing up any old script alongside other
configuration backups. Reload Sway after installation (`Mod+Shift+C`).
`clipboard-history show`, `watch-text`, and `watch-image` remain available.
The watcher locks, 1000-entry recent retention, default cliphist database, and
`${XDG_DATA_HOME:-$HOME/.local/share}/cliphist/pinned.db` are preserved.
The shortcut consumes the press, uses physical key codes across configured
layouts, and disables auto-repeat launches.

The picker uses the declared packages `alacritty`, `fzf`, `cliphist`,
`wl-clipboard`, `ueberzugpp`, and `jq`, plus Arch's base `file` and `flock`
utilities. No custom build is needed. `./setup.sh check` checks its executable
link, dependencies, Bash syntax, and ShellCheck when installed.

For a desktop check, try the shortcut in all three configured keyboard layouts,
hold it, and vary the release order; no V should enter the previous app or the
search field. Check query retention across F3/F5, image-to-text and empty-result
transitions, F4, resizing, workspace changes, and Escape. Verify copying against
original files with `cmp`, including trailing newlines, whitespace, Unicode,
and PNG bytes. Time cold and warm opening separately from preview rendering;
the target is usable results within 200 ms on the target machine. Closing should
leave no extra picker, preview, or renderer processes or temporary directories.

## Local database containers

Create only the instances you need, using a distinct name for each one:

```sh
./bin/db-containers create mariadb shop
./bin/db-containers create postgres api 5433
./bin/db-containers create mariadb another-shop 3307
```

Each instance has its own container, persistent Podman volume, and randomly
generated credentials file under `~/.config/dot/db-containers/` (mode 600).
Keep the credentials file: the database volume retains its original password.
MariaDB and MySQL have separate `app` and `root` passwords. When you omit the
host port, Podman chooses an available port and the script prints it. Explicit
ports and automatic ports bind to localhost only, not the LAN. Applications
connect to `127.0.0.1:<printed-port>` with database and username `app`; the
create command prints the `app` password and saves it as `APP_PASSWORD` in that
instance's credentials file.

Use `./bin/db-containers list` to see instances, then
`./bin/db-containers stop shop`, `start shop`, or `status shop` to manage one.
`all` is optional for lifecycle commands; setup never starts every database.
`remove shop` removes its container while preserving its data volume and
credentials. Recreating that same name with the same database type reuses them.

For a browser interface that supports both databases, run
`./bin/db-containers tool adminer` once and open
<http://127.0.0.1:8080>. Choose the engine and use server `dot-db-shop` (replace
`shop` with your instance name), database/user `app`, and the `APP_PASSWORD`
from that instance's credentials file.
For a MariaDB or MySQL instance, you can instead run
`./bin/db-containers tool phpmyadmin shop` and open
<http://127.0.0.1:8080>; use a different **web host port** if Adminer is
already using it. The optional port on `tool phpmyadmin` selects the browser
interface's host port, not the MariaDB port. Set MariaDB's host port when you
create it, for example `./bin/db-containers create mariadb shop 3306`.
Both tools bind to localhost only.

For PostgreSQL, run `./bin/db-containers tool pgadmin api` (replace `api` with
the instance name) and open <http://127.0.0.1:5050>. pgAdmin is preconfigured
with that instance's server name, database `app`, and user `app`; enter the
database password printed by `create` when pgAdmin prompts. The pgAdmin web
login is `admin@localhost`; its generated password is saved in
`~/.config/dot/db-containers/pgadmin/<name>/password`. Each instance gets a
separate pgAdmin container and persistent Podman data volume. The optional port selects the
pgAdmin web port, for example `tool pgadmin api 5051`.

The interactive shell adds `~/.dot/bin` to `PATH`. Its `lazydocker` command
points at Podman's Docker-compatible socket; start it once with
`systemctl --user enable --now podman.socket` if that socket is not active.

Run `./bin/script-manage-mariadb` for an interactive MariaDB workflow to
create or list MariaDB containers and register an existing MariaDB container
in an existing PHPMyAdmin container. New containers use the shared
`dot-databases` network and a Podman secret for the root password. Registered
PHPMyAdmin server configs are saved under
`~/.config/dot/db-containers/phpmyadmin/` so they can be copied into a
replacement PHPMyAdmin container.

Host terminal clients can connect with `psql -h 127.0.0.1 -p <port> -U app app`
or `mariadb -h 127.0.0.1 -P <port> -u app -p app`.
