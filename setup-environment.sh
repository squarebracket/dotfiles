#!/bin/sh
export REMOTE_USER=$1
export LAUNCH_SHELL=$2
export LOOPBACK_PORT=$3
REPO=
cd ~
if [ "$REMOTE_USER" = "LOCAL" ]; then
    export DOTFILES="dotfiles"
    TERMINATOR=''
else
    export DOTFILES=".dotfiles-$REMOTE_USER"
    TERMINATOR="-$REMOTE_USER"
fi
export ENVIRONMENT=$ENVIRONMENT

# detect installer
yum --version > /dev/null && [ $? = 0 ] && export INSTALLER=yum
apt-get --version > /dev/null && [ $? = 0 ] && export INSTALLER=apt-get

# Detect if we have git
git --version > /dev/null
if [ $? != 0 ]; then
    $INSTALLER install -y git
fi

# Do the dotfiles magic if the folder doesn't exist
if [ ! -d "$DOTFILES" ]; then
    echo "Getting the dotfiles"
    git clone https://github.com/squarebracket/dotfiles.git $DOTFILES
    
    echo "Pulling any submodules"
    cd $DOTFILES
    git submodule update --init --force
    cd ..
    
    echo "Making links"
    ln -fs $DOTFILES/vim ~/.vim$TERMINATOR
    ln -fs $DOTFILES/tmux/tmux.conf ~/.tmux.conf$TERMINATOR
    ln -fs $DOTFILES/screen/screenrc ~/.screenrc$TERMINATOR
    ln -fs $DOTFILES/dircolors ~/.dircolors$TERMINATOR
    ln -fs $DOTFILES/bash/bashrc ~/.bashrc$TERMINATOR
    ln -fs $DOTFILES/oh-my-zsh ~/.oh-my-zsh
    ln -fs $DOTFILES/zsh/zshrc ~/.zshrc$TERMINATOR
    ln -fs $DOTFILES/weechat ~/.weechat$TERMINATOR
    
    # Vim is fucking dumb and can't handle using alternate .vimrc files,
    # so we have to literally append some bullshit to ~/.vimrc just to make
    # it work
    echo "Verifying vimrc hack"
    if [ ! -f ~/.vimrc ]; then
       echo 'source ~/$DOTFILES/vim/vimrc' >> ~/.vimrc
    elif  [ -f ~/.vimrc ]; then
        grep "source ~/$DOTFILES/vim/vimrc" < ~/.vimrc > /dev/null || echo 'source ~/$DOTFILES/vim/vimrc' >> ~/.vimrc
    fi

    echo "Installing public key"
    for file in `ls ~/$DOTFILES/keys/*`; do
        cat $file >> ~/.ssh/authorized_keys
    done
    
    # Remote -> local copying requires the remote server having a public key
    # So check if we have a public key, and if not, generate it
    if [ ! -f ~/.ssh/id_rsa.pub ]; then
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ''
    fi

    # if you need to install software or do anything else before launching
    # your fancy new environment, add it to ./required.sh
    if [ -f $DOTFILES/required.sh ]; then
        echo "Performing required pre-environment actions"
        bash $DOTFILES/required.sh
    fi

    # Likewise, if you need to `pip install` anything, add it to the usual
    # requirements.txt file
    if [ -f $DOTFILES/requirements.txt ]; then
        echo "installing pip requirements..."
        pip --version > /dev/null
        if [ $? != 0 ]; then $INSTALLER install -y python-pip; fi
        pip install -r $DOTFILES/requirements.txt
    fi

    if [ "$REMOTE_USER" != "LOCAL" ]; then
        # Test to see if we have ssh keys set up for remote copying back to host
        ssh -q -o PasswordAuthentication=no -p 5555 $REMOTE_USER@localhost -t 'echo "success!"'
        EXIT_CODE=$?
        if [ $EXIT_CODE != 0 ]; then
            # If we don't, exit with status 13
            exit 13
        fi
    fi

else
    # Update the dotfiles and all submodules to the latest version
    cd $DOTFILES
    git pull
    git submodule update --init
    cd ~
fi

if [ "$REMOTE_USER" != "LOCAL" ]; then
    printf '\033]2;%s\033\\' "$LAUNCH_SHELL"
fi

case "$SHELL" in
/bin/bash)
    export CUSTOM_SHELL="$SHELL --rcfile ~/$DOTFILES/bash/bashrc"
    echo "shell is: $SHELL"
    ;;
/bin/zsh)
    export CUSTOM_SHELL="$SHELL"
    export ZDOTDIR="~/$DOTFILES/zsh/"
    ;;
esac

if [ "$LAUNCH_SHELL" = "screen" ]; then
    screen -c ~/.screenrc$TERMINATOR $CUSTOM_SHELL
elif [ "$LAUNCH_SHELL" = "tmux" ]; then
    tmux has-session -t $REMOTE_USER && tmux attach -t $REMOTE_USER || tmux -f ~/.tmux.conf$TERMINATOR new-session -s $REMOTE_USER "$CUSTOM_SHELL"
fi

