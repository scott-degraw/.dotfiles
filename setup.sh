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
if [ ! -f $HOME/.oh-my-zsh ]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Prepend to zshrc to put global .zshrc.mine file in .zshrc
if [ ! -f $zshrc_path ]; then
	echo ".zshrc file not found" 1>&2
	return 1
fi

if [ ! "$(head -n1 $zshrc_path)" = $mine_zsh_comment ]; then
	echo "$mine_zsh_comment\n$add_mine_zshrc" | cat - $zshrc_path > .tmp
	mv .tmp $zshrc_path
fi

# Create the symbolic links
find . -maxdepth 1 -type f,d ! -regex '\.\|\./\(.*\.\(swp\|mine\)\|setup\.sh\)' -exec ln -sf $(realpath {}) $setup_directory/$(basename {}) \;

