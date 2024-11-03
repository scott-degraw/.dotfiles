#!/bin/bash

setup_directory=..

add_mine_zshrc="source $(pwd)/.zshrc.mine" 
mine_zsh_comment='# Sources global zshrc file'

zshrc_path=$setup_directory/.zshrc

if [ ! "$(basename $SHELL)" = "zsh" ]; then
	echo "zsh not set to default shell" 1>&2
	return 1
fi

# Install oh-my-zsh if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh
	source $zshrc_path
fi

zsh_custom_dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

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

if [ ! "$(head -n1 $zshrc_path)" = $mine_zsh_comment ]; then
	echo "$mine_zsh_comment\n$add_mine_zshrc" | cat - $zshrc_path > .tmp
	mv .tmp $zshrc_path
fi

# Create the symbolic links
find . -maxdepth 1 -type f,d ! -regex '\.\|\./\(.*\.\(swp\|mine\)\|setup\.sh\|\.git\|\.gitignore\)' -exec ln -sf $(realpath {}) $setup_directory/$(basename {}) \;

