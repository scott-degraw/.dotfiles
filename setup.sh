#!/bin/bash

cd "$(dirname "$0")"
setup_directory=$HOME

function rmsymlink() {
	if [ -L "$1" ]; then
		rm "$1"
	fi
}

# Set up fish universal variables (vi bindings, clear greeting)
fish fish_setup.fish

# Install fisher and plugins from fish_plugins list
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher && fisher install < fish/fish_plugins'

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
	symlink=$setup_directory/"$dotfile"
	rmsymlink "$symlink"
	ln -s $(realpath "$dotfile") "$symlink"
done

# Copy tmux with correct shell 
export shell_path=$(which fish)
# Use # instead of / for sed to deal with paths
envsubst < .tmux.conf > $setup_directory/.tmux.conf


# Copy matplotlibrc file
mkdir -p $setup_directory/.config/matplotlib/
symlink=$setup_directory/.config/matplotlib/matplotlibrc
rmsymlink "$symlink"
ln -s $(realpath matplotlibrc) "$symlink"

# Update the vim plugins
git submodule init
git submodule update

# Add alacritty terminfo 
tic -x alacritty.terminfo 
