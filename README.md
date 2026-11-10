# .dotfiles

My dotfiles, synced across my machines (a Mac and HPC clusters). Run `bash setup.sh` once per machine; it is idempotent and needs no sudo or compiler.

It sets up:

- **bash**: vi mode, [ble.sh](https://github.com/akinomyoga/ble.sh) (autosuggestions, syntax highlighting), the [starship](https://starship.rs) prompt, fzf, zoxide, and rg/fd/bat/eza as static binaries
- **vim**, **tmux** and **readline** (`.inputrc`) config
- **git**: `~/.gitconfig` includes the repo's `.gitconfig`, with machine-specific settings below it
- **matplotlib** style (`matplotlibrc`)
- **Claude Code**: shared `CLAUDE.md` and keybindings are symlinked, and the shared keys in `claude/settings.json` are merged into each machine's `~/.claude/settings.json`. Machine-specific instructions go in an untracked `~/.claude/CLAUDE.local.md`.

Existing files that setup would replace with a symlink are moved aside to a `.bak.<timestamp>` backup.
