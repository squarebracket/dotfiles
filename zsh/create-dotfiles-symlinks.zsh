# Create the symlinks necessary for programs sourcing their dotfiles
# from the version'd, uh, version.
declare -A dotfiles
dotfiles[$HOME/.tmux.conf]="$HOME/dotfiles/tmux/tmux.conf"
dotfiles[$HOME/.vimrc]="$HOME/dotfiles/vim/vimrc"
dotfiles[$HOME/.vim]="$HOME/dotfiles/vim/"
dotfiles[$HOME/.bashrc]="$HOME/dotfiles/bashrc"
dotfiles[$HOME/.zshrc]="$HOME/dotfiles/zsh/zshrc"
dotfiles[$HOME/.dircolors]="$HOME/dotfiles/dircolors"
dotfiles[$HOME/.bash]="$HOME/dotfiles/bash"
dotfiles[$HOME/.oh-my-zsh]="$HOME/dotfiles/oh-my-zsh"
dotfiles[$HOME/.config/powerline]="$HOME/dotfiles/config/powerline"
for key in ${(k)dotfiles}; do
    [[ ! -f "$key" && ! -d "$key" ]] && ln -s "${dotfiles[$key]}" "$key"
done
unset dotfiles
