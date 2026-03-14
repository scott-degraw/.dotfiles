#!/bin/bash

setup_directory=$HOME


dotfiles=(.vim .vimrc .gitconfig)

function rmsymlink() {
	if [ -L "$1" ]; then
		rm "$1"
	fi
}

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
