#!/bin/bash

cd "$(dirname "$0")"
setup_directory=$HOME

if ! command -v fish &>/dev/null; then
    echo "Error: fish not found in PATH. Please install fish first."
    exit 1
fi

# Removes a symlink, or warns and exits if a regular file exists at that path
function rmsymlink() {
    if [ -L "$1" ]; then
        rm "$1"
    elif [ -e "$1" ]; then
        echo "Error: $1 already exists and is not a symlink. Remove it manually first."
        exit 1
    fi
}

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

dotfiles=(.vim .vimrc .gitconfig)

for dotfile in "${dotfiles[@]}"; do
    symlink="$setup_directory/$dotfile"
    rmsymlink "$symlink"
    ln -s "$(realpath "$dotfile")" "$symlink"
done

# Copy tmux with correct shell path baked in
shell_path=$(which fish)
export shell_path
envsubst < .tmux.conf > "$setup_directory/.tmux.conf"

# Symlink matplotlibrc
mkdir -p "$setup_directory/.config/matplotlib/"
symlink="$setup_directory/.config/matplotlib/matplotlibrc"
rmsymlink "$symlink"
ln -s "$(realpath matplotlibrc)" "$symlink"

# Install vim plugins
git submodule init
git submodule update

# Add alacritty terminfo
tic -x alacritty.terminfo
