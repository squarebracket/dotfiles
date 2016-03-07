Dotfiles and Environment Setup
==============================

This repository contains my dotfiles, as well as a method for setting up (arbitrary)
environments on freshly-provisioned machines, whether they're local development
machines or remote servers shared by many users. The setup methodology ensures that
each user's environment doesn't interfere with any other user's environment.

Most of the gruntwork is done by the `setup-environment.sh` script. It can be used
on its own, though it is meant to be used with the `start-remote-env` wrapper in
`shared-shell-scripts/auto-start-remote-env`. When used in this manner, remote-to-local
copy/paste functionality is setup automatically using SSH tunneling.

Features
--------

The files in this repo contain some very useful features, especially if you work
with multiple remote machines:
- Automatically source specific configuration files based on:
  - whether we're running locally or remotely
  - the "environment" that we've told the shell we're using
- Automatically set up remote->local copying, so you can seamlessly copy from
  a remote tmux session to your local tmux session and X clipboard
- Seamless window/pane management -- whether you're running a single tmux session,
  tmux-inside-tmux, or vim-inside-tmux-inside-tmux, the same hotkeys are used to
  create and navigate window splits
- Seamless buffer management -- `prefix PgUp` and `prefix [` operate on the most
  nested tmux

Setup Script
------------

The setup script takes care of installing and activating a complete environment
for you, as well as keeping it up to date with a remote repository.

### Invocation
```
[ENVIRONMENT VARIABLES] bash setup-environment.sh <remote_user> [shell_to_launch]
```

### Parameters and Environment Variables
The setup-environment script should be called with a `remote user` and an optional 
`shell_to_launch` that is called when the environment has been set up.

Several environment variables also affect the functionality of the script. With
the exception of `REPO`, they are all exported for use by the shell and other
programs. They are:
- `REPO`: The repository to clone from, and any options you want passed to git. If
          not given, defaults to my own repo.
- `LOOPBACK_PORT`: The local port on which reverse SSH tunneling to the source 
                   has been established. This is for setting up automatic 
                   remote->local copy/paste functionality. If this is given,
                   the script will attempt to use the tunnel, authenticating using
                   keys (so that you don't have to give your password each time).
                   If this fails, the script exits with error code 13 so that you
                   may automatically pull the public key from the remote machine
                   and install it locally (cuz you obviously store your public
                   key in your repo, right?).
- `POWERLINE_FONT`: Whether powerline fonts should be used; value of `1` enables.
- `ENVIRONMENT`: The environment to be used for the launched shell.
- `LOCAL_DISPLAY`: Your local X display (e.g. `:0`).

If `REMOTE_USER` is the special value `LOCAL`, the environment will be installed
and activated locally. NOTE THAT THIS MAY OVERWRITE YOUR EXISTING DOTFILES. In
every other case, the dotfiles are installed in a namespaced way that does not
affect any currently existing dotfiles (except for vim, cuz it sucks).

### Exported Environment Variables

In addition to the environment variables listed above, the following variables
are also exported:
- `DOTFILES`: The relative folder under which the dotfiles have been installed.
              Note that needs to used as `$HOME/$DOTFILES` if you want the full
              system path.
- `INSTALLER`: The system's installer (currently limited to apt-get or yum).
- `SUDO`: Has value `sudo` if `sudo` is needed for running priveleged commands,
          blank otherwise.
- `CUSTOM_SHELL_OPTS`: If the `$SHELL` of the system the setup script is running
                       on is `/bin/bash`, this will be the option required to
                       run bash with your customized `.bashrc`.
- `ZDOTDIR`: If the `$SHELL` of the system the setup script is running on is
             `/bin/zsh`, this will be `$HOME/$DOTFILES/zsh`.

### Adding Functionality

Any additional stuff that you want performed to setup your environment can be
dropped into the file `required.sh` in the base of your `$REPO`, which will
be executed by `bash` on setup. Note that all non-shell-specific environment
variables are exported at the time this file is run, so you can do things in
this file like `$SUDO $INSTALLER -y <some_program>` to do distro-independent
installation.

### Steps

For sake of verbosity, here are the steps the script performs when installing the
environment:
1. Detect and export (`$INSTALLER`) the system installer (i.e. apt-get versus yum)
2. Detect and export (`$SUDO`) whether we need sudo to execute priveleged commands
3. Install git if it's needed
4. Pull `$REPO` and all of its submodules
5. Make links to dotfiles in `$HOME`, namespaced if appropriate
6. Copy over any custom termcaps
7. Append a line to `$HOME/.vimrc` if it doesn't exist
8. Install any public keys in `$REPO/keys` to `$HOME/.ssh/authorized_keys`
9. Generate a (non-passphrase-protected) SSH key if one doesn't already exist
10. Execute `$REPO/required.sh` if it exists
11. Pip install anything in `requirements.txt`
12. If `$LOOPBACK_PORT` is provided, try to establish SSH connection back without
    password authentication; fail with code 13 if it doesn't work

If the dotfiles directory exists, the script simply pulls from the `$REPO`.

In all cases, it launches the `shell_to_launch`.

Autoloading
-----------

As it is currently configured, the programs contained in the repo autoload
configuration files based on the value of the environment variable `$ENVIRONMENT`,
as well as whether the machine is local or remote. The autoloading structure
works by sourcing all files in the program's directory whose name matches certain
globs:
- `auto*`: The file is always sourced.
- `local*`: The file is sourced if the program is running on the local machine.
- `remote*`: The file is sourced if the program is running in a shell that has
             been accessed through an SSH connection.
- `<environment>/auto*`: The file is sourced when `$ENVIRONMENT=<environment>`.
- `<environment>/local*`: The file is sourced when `$ENVIRONMENT=<environment>`
                          and the program is running on the local machine.
- `<environment>/remote*`: The file is sourced when `$ENVIRONMENT=<environment>`
                           and the program is running in a shell that has been
                           accessed through an SSH connection.

Useful Hotkeys
--------------

Here are some helpful non-standard keybindings:
- Tmux: `prefix |` -- split the window vertically
- Tmux: `prefix -` -- split the window horizontally
- Tmux: `prefix C-c` -- force window creation rather than sending new-window command
                        along to embedded thing
- Vim: `<leader>` in Vim for me is `\`.
- Vim: `<leader>y` -- yank to X clipboard, and your local tmux session if there is one
- Vim: `<leader>p` -- paste from tmux buffer
