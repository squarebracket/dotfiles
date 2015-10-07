syntax enable
filetype plugin on
filetype indent on
set sw=4
set expandtab
set tag=~/tags
set number
set omnifunc=syntaxcomplete#Complete
execute pathogen#infect()
filetype plugin indent on
set laststatus=2
let g:airline_powerline_fonts = 1
set background=dark
colorscheme solarized
set t_Co=256
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
