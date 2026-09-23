# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal dotfiles repo that sets up a bash environment on HPC/Slurm clusters — no root or compiler required.

## Setup

Run once on a new machine:

```bash
bash setup.sh
```

`setup.sh` is idempotent. It:
- Initializes git submodules (vim plugins, ble.sh, tmux plugins)
- Appends a sourcing block into `~/.bashrc` / `~/.bash_profile` (idempotent via a sentinel marker)
- Builds ble.sh from source (`bash/vendor/ble.sh`) into `~/.local/share/blesh/`
- Installs fzf, zoxide, starship as prebuilt binaries into `~/.local/bin` or `~/.fzf/`
- Installs rg, fd, bat, eza from GitHub release tarballs (x86\_64 musl static builds — no glibc dependency)
- Symlinks `.vim`, `.vimrc`, `.gitconfig` into `$HOME`
- Processes `.tmux.conf` through `envsubst` (bakes in `$shell_path` and `$dotfiles_dir`) and writes to `~/.tmux.conf`
- Symlinks `matplotlibrc` into `~/.config/matplotlib/`
- Symlinks `starship.toml` into `~/.config/`
- Registers the alacritty terminfo entry

After running, verify all tools are on PATH with the check printed at the end of setup.

## Architecture

### bash/bashrc
The main interactive shell config sourced from `~/.bashrc`. It:
1. Guards against non-interactive shells (returns early for scripts/job wrappers)
2. Sources `ble.sh` first (must precede any `bind` calls) with catppuccin-mocha color scheme
3. Wires up fzf key bindings and completion
4. Initializes zoxide (`z` command) and starship prompt
5. Sources all `bash/functions/*.sh` files

### tmux/.tmux.conf
Template processed by `envsubst` at install time — uses `$shell_path` and `$dotfiles_dir` literals that get replaced. Prefix is `C-a`. Plugins (catppuccin, tmux-fzf) are loaded via `run` directives pointing into `tmux/vendor/`.

### vim
Plugins managed as git submodules under `.vim/pack/` (vim8 native package loading — no plugin manager needed). Themes: gruvbox, catppuccin. Plugins: nerdcommenter, nerdtree, vim-airline, vim-oscyank.

### bash/functions/
- `yank.sh` / `nyank.sh`: OSC 52 clipboard helpers (copy to system clipboard over SSH/tmux)
- `py.sh`: prints the realpath of a file, piped through nyank (clipboard copy)
- `memwatch.sh`: polls RSS of a process tree at a configurable interval (useful for Slurm jobs)

## Key constraints

- All tool installs in `setup.sh` are no-sudo, no-compiler. Use static/musl binaries from GitHub releases for new tools on x86\_64; add a non-x86\_64 fallback message for other architectures.
- `~/.bashrc` is never overwritten — only appended to via `ensure_block()` so per-machine customizations survive re-runs.
- `.tmux.conf` is **not** symlinked; it is copied via `envsubst` because it contains shell variables that must be resolved at install time.
- Adding a new bash function: drop a `.sh` file in `bash/functions/` — it is sourced automatically.
