#!/bin/sh
export REMOTE_USER=$1
export LAUNCH_SHELL=$2
cd ~
export DOTFILES="~/.dotfiles-$REMOTE_USER"
if [ ! -d ".dotfiles-$REMOTE_USER" ]; then
    echo "Getting the dotfiles"
    git clone https://squarebracket@bitbucket.org/squarebracket/dotfiles.git .dotfiles-$REMOTE_USER
    echo "Making links"
    ln -fs ~/.dotfiles-$REMOTE_USER/vim ~/.vim
    ln -fs ~/.vim/vimrc ~/.vimrc-$REMOTE_USER
    ln -fs ~/.dotfiles-$REMOTE_USER/tmux/tmux.conf ~/.tmux.conf-$REMOTE_USER
    ln -fs ~/.dotfiles-$REMOTE_USER/screen/.screenrc ~/.screenrc-$REMOTE_USER
    ln -fs ~/.dotfiles-$REMOTE_USER/dircolors ~/.dircolors-$REMOTE_USER
    ln -fs ~/.dotfiles-$REMOTE_USER/bash/bashrc ~/.bashrc-$REMOTE_USER
    ln -fs ~/.dotfiles-$REMOTE_USER/oh-my-zsh ~/.oh-my-zsh
    ln -fs ~/.dotfiles-$REMOTE_USER/zsh/zshrc ~/.zshrc-$REMOTE_USER
    ln -fs ~/.dotfiles-$REMOTE_USER/weechat ~/.weechat
    echo "Installing public key"
    for file in `ls ~/.dotfiles-$REMOTE_USER/keys/*`; do
        cat $file >> ~/.ssh/authorized_keys
    done
    # if you need to install software or do anything else before launching
    # your fancy new environment, add it to ./required.sh
    if [ -f .dotfiles-$REMOTE_USER/required.sh ]; then
        echo "Performing required pre-environment actions"
        bash .dotfiles-$REMOTE_USER/required.sh
    fi
    if [ -f .dotfiles-$REMOTE_USER/requirements.txt ]; then
        echo "PIP"
        pip install -r .dotfiles-$REMOTE_USER/requirements.txt
    fi
    # Test to see if we have ssh keys set up for remote copying back to host
    ssh -q -o PasswordAuthentication=no -p 5555 $REMOTE_USER@localhost -t 'echo "success!"'
    EXIT_CODE=$?
    if [ $EXIT_CODE != 0 ]; then
        # If we don't, exit with status 13
        exit 13
    fi
else
    cd .dotfiles-$REMOTE_USER
    git pull
    cd ~
fi
printf '\033]2;%s\033\\' "$LAUNCH_SHELL"
if [ "$LAUNCH_SHELL" = "screen" ]; then
    screen -c ~/.screenrc-$REMOTE_USER
elif [ "$LAUNCH_SHELL" = "tmux" ]; then
    tmux has-session -t $REMOTE_USER && tmux attach -t $REMOTE_USER || tmux -f ~/.tmux.conf-$REMOTE_USER new-session -s $REMOTE_USER
fi

