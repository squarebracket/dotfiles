execute pathogen#infect()
filetype plugin on
filetype indent on                      " turn on filetype detection and load filetype-specfic indent files
set tabstop=4                           " number of spaces per tab
set softtabstop=4                       " number of spaces in tab when editing
set shiftwidth=4                        " indents
set expandtab                           " make all tabs spaces
set tag=~/tags

" UI Section
set number                              " show line numbers
set showcmd                             " show command in bottom bar
set cursorline                          " highlight current line
set wildmenu                            " shows possible choices for command autocomplete
set showmatch                           " highlighting matching [{()}]

" Search stuff
set incsearch                           " search as characters are entered
set hlsearch                            " highlight matches
set ignorecase                          " case-insensitive searching

" Folding
set foldenable                          " enable code-folding
set foldlevelstart=10                   " open most folds by default
set foldnestmax=10                      " 10 nested folds max
" space open/closes folds
nnoremap <space> za
set foldmethod=indent                   " fold based on indent level


" stuff
" jk is escape
"inoremap <return> <esc>
" map for copy to X clipboard
vnoremap <leader>y "+y

" toggle gundo
nnoremap <leader>u :GundoToggle<CR>

" toggls nerdtree
nnoremap <leader>q :NERDTreeToggle<CR>

" edit vimrc/zshrc and load vimrc bindings
nnoremap <leader>ev :vsp $MYVIMRC<CR>
nnoremap <leader>ez :vsp ~/.zshrc<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" open ag.vim
nnoremap <leader>a :Ag

" CtrlP settings
let g:ctrlp_match_window = 'bottom,order:ttb'       " order stuff top-to-bottom
let g:ctrlp_switch_buffer = 0                       " always open found files in new buffers
let g:ctrlp_working_path_mode = 0                   " follows cwd's in vim
let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""' " uses ag as searcher
let g:ctrlp_custom_ignore = '\vbuild/|dist/|venv/|target/|\.(o|swp|pyc|egg)$'

" NERDTree ignores
let NERDTreeIgnore = ['\.pyc$', 'build', 'venv', 'egg', 'egg-info/', 'dist', 'docs']

" allows cursor change in tmux mode
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
" Delete trailing whitespace automatically
"autocmd BufWritePre * :%s/\s\+$//e

" automatically reload .vimrc when it's been edited
augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

set omnifunc=syntaxcomplete#Complete
filetype plugin indent on
set laststatus=2
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
set background=dark                     " darkness
colorscheme solarized
set t_Co=256                            " Make terminal vim compatible with solarized
syntax enable                           " enable syntax highlighting
