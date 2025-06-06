#!/bin/bash

setup_directory=$HOME

add_mine_zshrc="source $(pwd)/.zshrc.mine" 
mine_zsh_comment='# Sources global zshrc file'

zshrc_path=$setup_directory/.zshrc

if [ ! "$(basename $SHELL)" = "zsh" ]; then
	echo "zsh not set to default shell" 1>&2
	exit 1
fi

# Install oh-my-zsh if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh
	source $zshrc_path
fi

# Get the pure theme installed
theme_dir=$HOME/.zsh
if [ ! -d $theme_dir ]; then
	mkdir -p $theme_dir
	git clone https://github.com/sindresorhus/pure.git $theme_dir/pure
fi

if [ ! -d  ]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi 

zsh_custom_dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# All the zsh extensions
if [ ! -d $zsh_custom_dir/plugins/zsh-autosuggestions ]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi 

if [ ! -d $zsh_custom_dir/plugins/zsh-syntax-highlighting ]; then
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Prepend to zshrc to put global .zshrc.mine file in .zshrc
if [ ! -f "$zshrc_path" ]; then
	touch $zshrc_path
fi

if [ "$(head -n1 $zshrc_path)" != "$mine_zsh_comment" ]; then
	echo -e "$mine_zsh_comment\n$add_mine_zshrc" | cat - $zshrc_path > .tmp
	mv .tmp $zshrc_path
fi

# Create the symbolic links
find . -maxdepth 1 ! -regex '\.\|\./\(.*\.\(swp\|mine\)\|setup\.sh\|\.git\|\.gitignore\|\.gitmodules\|alacritty\.terminfo\|\.tmux\.conf\|README\.md\)' \
	-exec bash -c "ln -sfT $(realpath {}) $setup_directory/$(basename {})" \;

# Copy tmux with correct shell 
zsh_path=$(which zsh | sed 's/\//\\\//g') # Have to properly escape the /
sed 's/<SHELL>/'$zsh_path'/g' .tmux.conf > $setup_directory/.tmux.conf

# Copy matplotlibrc file
mkdir -p $setup_directory/.config/matplotlib/
ln -sfT $(realpath matplotlibrc) $setup_directory/.config/matplotlib/matplotlibrc

# Update the vim plugins
git submodule init
git submodule update

# Add alacritty terminfo 
tic -x alacritty.terminfo 
