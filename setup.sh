#!/bin/bash

cd "$(dirname "$0")"
setup_directory=$HOME

# Removes a symlink, or warns and exits if a regular file exists at that path
function rmsymlink() {
    if [ -L "$1" ]; then
        rm "$1"
    elif [ -e "$1" ]; then
        echo "Error: $1 already exists and is not a symlink. Remove it manually first."
        exit 1
    fi
}

# Pull in vim plugins and vendored bash tools (ble.sh)
git submodule init
git submodule update --recursive

# --- fish (optional, no longer the default shell) ---
if command -v fish &>/dev/null; then
    # Set up fish universal variables (vi bindings, clear greeting)
    fish fish_setup.fish

    # Install fisher, then plugins (fisher itself is excluded from fish_plugins to avoid double-install)
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
    fish -c "fisher install < $(pwd)/fish/fish_plugins"

    # Symlink fish functions
    fish_config_dir=$HOME/.config/fish
    mkdir -p "$fish_config_dir/functions"

    for fish_file in fish/functions/*.fish; do
        symlink="$fish_config_dir/functions/$(basename "$fish_file")"
        rmsymlink "$symlink"
        ln -s "$(realpath "$fish_file")" "$symlink"
    done
else
    echo "fish not found in PATH, skipping fish setup."
fi

# Appends $2 to file $1 once, wrapped in a marker so re-running is a no-op.
# Leaves everything else in the file (machine-specific customization) alone.
function ensure_block() {
    local file=$1 body=$2 marker="# >>> dotfiles bash config >>>"
    touch "$file"
    if ! grep -qF "$marker" "$file"; then
        {
            echo ""
            echo "$marker"
            echo "$body"
            echo "# <<< dotfiles bash config <<<"
        } >>"$file"
    fi
}

# --- bash ---
# Append (don't overwrite) so per-machine customization in ~/.bashrc survives
# re-running setup.sh or re-cloning on a different machine.
ensure_block "$setup_directory/.bashrc" "[ -r \"$(realpath bash/bashrc)\" ] && source \"$(realpath bash/bashrc)\""
ensure_block "$setup_directory/.bash_profile" "[ -f \"$setup_directory/.bashrc\" ] && . \"$setup_directory/.bashrc\""

# ble.sh: autosuggestions/syntax-highlighting for bash (pure make/awk, no compiler needed)
if [ ! -x "$setup_directory/.local/share/blesh/ble.sh" ]; then
    make -C bash/vendor/ble.sh install PREFIX="$setup_directory/.local"
fi

# fzf: fuzzy history search / completion (binary only, no shell-rc edits)
if [ ! -d "$setup_directory/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$setup_directory/.fzf"
fi
"$setup_directory/.fzf/install" --bin --no-update-rc --no-completion --no-key-bindings

# zoxide: fish-like smart cd/z (prebuilt static binary, no cargo build)
if ! command -v zoxide &>/dev/null && [ ! -x "$setup_directory/.local/bin/zoxide" ]; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash -s -- --bin-dir "$setup_directory/.local/bin"
fi

# starship: cross-shell prompt (prebuilt static binary, no compiler needed)
if ! command -v starship &>/dev/null && [ ! -x "$setup_directory/.local/bin/starship" ]; then
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$setup_directory/.local/bin" --yes
fi

# Installs $2 (binary name) from the latest static-linked Linux release
# tarball of GitHub repo $1. No cargo/compiler needed, works across HPC nodes
# with mismatched glibc versions. Defaults to a musl build; pass "gnu" as $3
# for tools that need glibc's NSS (e.g. eza resolving usernames via NIS/LDAP,
# which musl's static NSS can't do).
function install_gh_release_bin() {
    local repo=$1 binname=$2 libc=${3:-musl}
    command -v "$binname" &>/dev/null && return
    [ -x "$setup_directory/.local/bin/$binname" ] && return

    local tmp url
    tmp=$(mktemp -d)
    url=$(curl -sS "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oE "\"browser_download_url\": *\"[^\"]*x86_64-unknown-linux-$libc\.tar\.gz\"" \
        | head -1 | grep -oE 'https://[^"]+')
    if [ -z "$url" ]; then
        echo "Could not find a linux-$libc release asset for $repo, skipping $binname."
        rm -rf "$tmp"
        return
    fi

    curl -sSL "$url" -o "$tmp/asset.tar.gz"
    tar -xzf "$tmp/asset.tar.gz" -C "$tmp"
    local found
    found=$(find "$tmp" -type f -name "$binname" | head -1)
    if [ -z "$found" ]; then
        echo "Could not find binary '$binname' after extracting $repo release, skipping."
        rm -rf "$tmp"
        return
    fi

    mkdir -p "$setup_directory/.local/bin"
    install -m 755 "$found" "$setup_directory/.local/bin/$binname"
    rm -rf "$tmp"
}

if [[ $(uname -m) == x86_64 ]]; then
    install_gh_release_bin BurntSushi/ripgrep rg
    install_gh_release_bin sharkdp/fd fd
    install_gh_release_bin sharkdp/bat bat
    install_gh_release_bin eza-community/eza eza gnu
else
    echo "Non-x86_64 architecture detected, skipping rg/fd/bat/eza (only musl x86_64 releases are wired up)."
fi

dotfiles=(.vim .vimrc .gitconfig)

for dotfile in "${dotfiles[@]}"; do
    symlink="$setup_directory/$dotfile"
    rmsymlink "$symlink"
    ln -s "$(realpath "$dotfile")" "$symlink"
done

# Copy tmux with correct shell path and repo location baked in
shell_path=$(which bash)
dotfiles_dir=$(pwd)
export shell_path dotfiles_dir
envsubst < .tmux.conf > "$setup_directory/.tmux.conf"

# Symlink matplotlibrc
mkdir -p "$setup_directory/.config/matplotlib/"
symlink="$setup_directory/.config/matplotlib/matplotlibrc"
rmsymlink "$symlink"
ln -s "$(realpath matplotlibrc)" "$symlink"

# Add alacritty terminfo
tic -x alacritty.terminfo

# Make bash the default login shell. chsh isn't always usable on HPC/NIS
# systems, so fall back to printing manual instructions instead of failing.
if ! chsh -s "$shell_path" 2>/dev/null; then
    echo "Could not change login shell automatically."
    echo "Run 'chsh -s $shell_path' (or 'ypchsh -s $shell_path' on NIS systems) manually, or ask your sysadmin."
fi

# Verify every tool actually resolves on PATH in a real interactive shell
# (catches PATH-wiring mistakes in bash/bashrc, not just failed downloads).
echo ""
echo "=== Verifying tools are reachable from an interactive shell ==="
for t in fzf zoxide starship rg fd bat eza; do
    if bash -ic "command -v $t" </dev/null 2>/dev/null | grep -q "/$t\$"; then
        printf "  %-10s OK\n" "$t"
    else
        printf "  %-10s MISSING (check bash/bashrc PATH additions)\n" "$t"
    fi
done
if [ -r "$setup_directory/.local/share/blesh/ble.sh" ]; then
    printf "  %-10s OK\n" "ble.sh"
else
    printf "  %-10s MISSING\n" "ble.sh"
fi
