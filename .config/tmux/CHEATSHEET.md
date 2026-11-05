# tmux cheatsheet

Vanilla tmux: prefix **Ctrl-B** and default keys. Only the additions are listed
here; `Ctrl-B ?` shows every binding.

| Action | Keys / command |
| --- | --- |
| Start or switch to a session named after this directory | `t` |
| New session in the current pane's directory | `Ctrl-B N` |
| Make the pane's directory the session's and rename the session after it | `Ctrl-B Ctrl-D` |
| Split side by side / top and bottom (in current directory) | `Ctrl-B v` / `Ctrl-B a` (or `%` / `"`) |
| Move between panes | `Ctrl-B h/j/k/l` |
| Resize pane by 5 | `Ctrl-B H/J/K/L` |
| Previous / next window (repeatable) | `Ctrl-B Ctrl-H` / `Ctrl-L` |
| Close pane (no confirmation) | `Ctrl-B x` |
| Copy mode: start selection / copy | `v` / `y` |
| Reload config | `Ctrl-B r` |
| Save a snapshot now | `Ctrl-B S` or `Ctrl-B Ctrl-S` |
| Pick a snapshot to restore (Enter restore, Ctrl-D delete) | `Ctrl-B Ctrl-R` |

`t` names sessions after the directory. A second directory with the same name
gets its parent as a prefix, e.g. `work-api`.

## Snapshots

tmux-resurrect and tmux-continuum live in `~/.config/tmux/plugins/` (plain git
clones; update with `git pull`). Continuum saves every 15 minutes; nothing is
restored automatically. Snapshots older than 30 days are pruned by resurrect.

## Agent status

Claude Code and Codex hooks call `~/.local/bin/tmux-agent-state`, which flags
the pane. The right side of the status bar shows one bubble per flagged pane in
any session: `C` Claude / `X` Codex, then `@session`. Gold ● = working, pink ● =
waiting for input, pink ✗ = error, teal ● = finished.

When an agent needs input, finishes or errors, a sound plays
(`~/.config/tmux/sounds/`) unless you are looking at that pane. If your
terminal isn't focused, a desktop notification is sent as well.
