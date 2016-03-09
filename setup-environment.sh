#!/bin/sh
# export arguments to script
export REMOTE_USER=$1
export LAUNCH_SHELL=${2:=$SHELL}
if [ "$3" = "--reset" ]; then RESET=1; fi
# set locally-used variables which get overridden by environment
REPO=${REPO:=https://github.com/squarebracket/dotfiles.git}
# export important environment variables
export LOOPBACK_PORT=$LOOPBACK_PORT
export POWERLINE_FONT=$POWERLINE_FONT
export ENVIRONMENT=$ENVIRONMENT
export LOCAL_DISPLAY=$LOCAL_DISPLAY
# make sure we're in ~
cd ~
# set and export $DOTFILES
if [ "$REMOTE_USER" = "LOCAL" ]; then
    export DOTFILES="dotfiles"
    TERMINATOR=''
else
    export DOTFILES=".dotfiles-$REMOTE_USER"
    TERMINATOR="-$REMOTE_USER"
fi

# detect installer
yum --version > /dev/null && [ $? = 0 ] && export INSTALLER=yum
apt-get --version > /dev/null && [ $? = 0 ] && export INSTALLER=apt-get
# Are we root?
if [ "$UID" != "0" ]; then
    # if not, set $SUDO
    export SUDO="sudo"
fi

# Tiny little function to install stuff if need it
# It's very error-prone considering some binaries (like pip) have
# a package name that differs from the binary name
_install_if_needed() {
    which $1 > /dev/null
    if [ $? = 1 ]; then
        $SUDO $INSTALLER install -y $1
    fi
}

# If we've been asked to reset the state, do a clean-up
if [ -n "$RESET" ]; then
    rm -rf $HOME/$DOTFILES/
fi

# Install git if it's not present
_install_if_needed git

# Do the dotfiles magic if the folder doesn't exist
if [ ! -d "$DOTFILES" ]; then
    echo "Getting the dotfiles"
    git clone $REPO $DOTFILES
    
    echo "Pulling any submodules"
    cd $DOTFILES
    git submodule update --init
    cd ..
    
    echo "Making links"
    ln -fs $DOTFILES/vim $HOME/.vim$TERMINATOR
    ln -fs $DOTFILES/tmux/tmux.conf $HOME/.tmux.conf$TERMINATOR
    ln -fs $DOTFILES/screen/screenrc $HOME/.screenrc$TERMINATOR
    ln -fs $DOTFILES/dircolors $HOME/.dircolors$TERMINATOR
    ln -fs $DOTFILES/bash/bashrc $HOME/.bashrc$TERMINATOR
    ln -fs $DOTFILES/oh-my-zsh $HOME/.oh-my-zsh
    ln -fs $DOTFILES/zsh/zshrc $HOME/.zshrc$TERMINATOR
    ln -fs $DOTFILES/weechat $HOME/.weechat$TERMINATOR

    # TODO: Change this to links?
    # Copy over custom termcaps
    [ ! -d $HOME/.terminfo ] && mkdir $HOME/.terminfo
    cd $HOME/$DOTFILES/terminfo
    for file in $(ls */*); do
        mkdir -p $HOME/.terminfo/${file%*/*}
        cp $file $HOME/.terminfo/$file
    done
    cd ~

    # Vim is fucking dumb and can't handle using alternate .vimrc files,
    # so we have to literally append some bullshit to ~/.vimrc just to make
    # it work
    VIMHACK="if exists('\$DOTFILES')
    source $HOME/$DOTFILES/vim/vimrc
endif"
    echo "Managing vimrc hack"
    if [ ! -f $HOME/.vimrc ]; then
        echo "$VIMHACK" > $HOME/.vimrc
    elif  [ -f $HOME/.vimrc ]; then
        grep "source $HOME/$DOTFILES/vim/vimrc" < ~/.vimrc > /dev/null || echo "$VIMHACK" >> ~/.vimrc
    fi

    echo "Installing public key"
    mkdir -p $HOME/.ssh
    for file in `ls $HOME/$DOTFILES/keys/*`; do
        cat $file >> $HOME/.ssh/authorized_keys
    done
    
    # Remote -> local copying requires the remote server having a public key
    # So check if we have a public key, and if not, generate it
    if [ ! -f $HOME/.ssh/id_rsa.pub ]; then
        ssh-keygen -t rsa -b 4096 -f $HOME/.ssh/id_rsa -N ''
    fi

    # If you need to install software or do anything else before launching
    # your fancy new environment, add it to $DOTFILES/required.sh
    # Remember that $INSTALLER and $SUDO are exported above -- you should
    # use those variables for installing software
    if [ -f $DOTFILES/required.sh ]; then
        echo "Performing required pre-environment actions"
        bash $DOTFILES/required.sh
    fi

    # Likewise, if you need to `pip install` anything, add it to the usual
    # requirements.txt file
    if [ -f $DOTFILES/requirements.txt ]; then
        echo "installing pip requirements..."
        # Custom test/install for pip
        pip --version > /dev/null
        if [ $? != 0 ]; then $SUDO $INSTALLER install -y python-pip; fi
        # Do the installing
        $SUDO pip install -r $DOTFILES/requirements.txt
    fi

# Update the repo(s) on every login
else
    # Update the dotfiles and all submodules to the latest version
    cd $DOTFILES
    git pull
    git submodule update --init
    cd $HOME
fi

# If we're remote and we've got a $LOOPBACK_PORT...
if [ "$REMOTE_USER" != "LOCAL" -a -n "$LOOPBACK_PORT" ]; then
    # ...test to see if we have ssh keys set up for remote copying back to host...
    ssh -q -o PasswordAuthentication=no -o StrictHostKeyChecking=no -p $LOOPBACK_PORT $REMOTE_USER@localhost -t 'echo "success!"'
    EXIT_CODE=$?
    if [ $EXIT_CODE != 0 ]; then
        # ...and if we don't, exit with status 13
        exit 13
    fi
fi

# Set the title of the pane for embedded screen/tmux
if [ "$REMOTE_USER" != "LOCAL" ]; then
    printf '\033]2;%s\033\\' "$LAUNCH_SHELL"
fi

# Your local and remote shell may be different, but you probably still want
# a customized environment. So here we set up a custom variable if needed.
case "$SHELL" in
/bin/bash)
    export CUSTOM_SHELL_OPTS="--rcfile $HOME/$DOTFILES/bash/bashrc"
    ;;
/bin/zsh)
    export ZDOTDIR="$HOME/$DOTFILES/zsh/"
    ;;
esac

echo "shell is: $SHELL"
_install_if_needed $LAUNCH_SHELL

# Some environment variables need to be set before launching a
# terminal multiplexer, so we source them here.
source $HOME/$DOTFILES/${LAUNCH_SHELL#/bin/*}/pre-init

if [ "$LAUNCH_SHELL" = "screen" ]; then
    screen -c $HOME/.screenrc$TERMINATOR $SHELL $CUSTOM_SHELL_OPTS
elif [ "$LAUNCH_SHELL" = "tmux" ]; then
    tmux has-session -t $REMOTE_USER && tmux attach -t $REMOTE_USER || tmux -f $HOME/.tmux.conf$TERMINATOR new-session -s $REMOTE_USER "$SHELL $CUSTOM_SHELL_OPTS"
else
    $LAUNCH_SHELL
fi

exit $?
