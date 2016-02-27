#!/bin/sh
export REMOTE_USER=$1
export LAUNCH_SHELL=$2
cd ~
if [ ! -d ".dotfiles-$REMOTE_USER" ]; then
    echo "Getting the dotfiles"
    git clone https://squarebracket@bitbucket.org/squarebracket/dotfiles.git .dotfiles-$REMOTE_USER
    echo "Making links"
    ln -s ~/.dotfiles-$REMOTE_USER/vim/vimrc ~/.vimrc-$REMOTE_USER
    ln -s ~/.dotfiles-$REMOTE_USER/tmux/tmux.conf ~/.tmux.conf-$REMOTE_USER
    ln -s ~/.dotfiles-$REMOTE_USER/screen/.screenrc ~/.screenrc-$REMOTE_USER
    ln -s ~/.dotfiles-$REMOTE_USER/dircolors ~/.dircolors-$REMOTE_USER
    ln -s ~/.dotfiles-$REMOTE_USER/bash/bashrc ~/.bashrc-$REMOTE_USER
    echo "Installing public key"
    cat ~/.dotfiles-$REMOTE_USER/public-key >> ~/.ssh/known_hosts
    # if you need to install software or do anything else before launching
    # your fancy new environment, add it to ./required.sh
    if [ -f .dotfiles-$REMOTE_USER/required.sh ]; then
        echo "Performing required pre-environment actions"
        bash .dotfiles-$REMOTE_USER/required.sh
    fi
    # Test to see if we have ssh keys set up for remote copying back to host
    ssh -q -o PasswordAuthentication=no -p 5555 $REMOTE_USER@localhost -t 'echo "success!"'
    if [ $? != 0 ]; then
        # If we don't, exit with status 13
        exit 13
    fi
fi
if [ "$LAUNCH_SHELL" = "screen" ]; then
    screen -c ~/.screenrc-$REMOTE_USER
elif [ "$LAUNCH_SHELL" = "tmux" ]; then
    tmux has-session -t $REMOTE_USER && tmux attach -t $REMOTE_USER || tmux -f ~/.tmux.conf-$REMOTE_USER new-session -s $REMOTE_USER
fi

