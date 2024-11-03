".vimrc - startup file for Vim

set mouse=a
set ttymouse=sgr
set number
autocmd FileType html,xml,xsl source ~/.vim/scripts/closetag.vim
set tabstop=4
set shiftwidth=4
set autoindent
set ignorecase
set smartcase

" Set autocomplete for command mode
set wildmenu
set wildmode=full
filetype plugin indent on
syntax on set viminfo='1000,f1,\"500,:100,/100

"set foldmethod=manual

" execute python script
nnoremap <F5> :w<CR> :! python %<CR>

" spell check
"set spelllang=en_gb
autocmd BufRead,BufNewFile *.tex setlocal spell

" custom mapping
nmap <C-Right> :tabnext<CR>
nmap <C-Left> :tabprevious<CR>
nmap <C-Z> :YcmCompleter FixIt<CR>

nnoremap <C-N> :NERDTree<CR>

" Open terminal in current window without adding to buffer list
nnoremap <leader>t :term ++curwin<CR><C-W>:setlocal nobuflisted<CR>

let g:vimtex_fold_manual = 1

" if !exists('g:ycm_semantic_triggers')
	" let g:ycm_semantic_triggers = {}
" endif
" au VimEnter * let g:ycm_semantic_triggers.tex=g:vimtex#re#youcompleteme

" to save as root 
" this is the keyboard shortcut
"nnoremap <> :w !sudo tee %<CR> 

command Saveasroot w !sudo tee %

" autoclose help ycmd help window after completion
let g:ycm_autoclose_preview_window_after_completion = 1
" disable asking to load ycm_confirm_extra_conf.py 
let g:ycm_confirm_extra_conf = 0

"split navigations
"nnoremap <C-J> <C-W><C-J>
"nnoremap <C-K> <C-W><C-K>
"nnoremap <C-L> <C-W><C-L>
"noremap <C-H> <C-W><C-H>

" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za

" Adds a new line with enter key
noremap <CR> o<esc>k

"" vimtex options
"let g:tex_flavor = 'latex'

"nnoremap <localleader>lw :VimtexCountWords!<CR>
"nnoremap <localleader>lz :! latexmk -C<CR>

" starts clientserver for vimtex """"needs work""""
"remote_startserver()
"if !exists('g:ycm_semantic_triggers')
"  let g:ycm_semantic_triggers = {}
"endif
"au VimEnter * let g:ycm_semantic_triggers.tex=g:vimtex#re#youcompleteme

" enables vim-plug
"call plug#begin('~/.vim/plugged')
"Plug 'lervag/vimtex'
"call plug#end()

" enables airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" This allows buffers to be hidden if you've modified a buffer.
" This is almost a must if you wish to use buffers in this way.
set hidden

" To open a new empty buffer
" This replaces :tabnew which I used to bind to this mapping
nnoremap <C-t> :enew<cr>

" Move to the next buffer
nnoremap <C-l> :bnext<CR>

" Move to the previous buffer
nnoremap <C-h> :bprevious<CR>

" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nnoremap <C-q> :bp <BAR> bd #<CR>

" enables gruvbox theme
 set background=dark
 "let g:gruvbox_contrast_dark='high'
 let g:gruvbox_guisp_fallback = 'bg' 
 let g:gruvbox_italic=1
 colorscheme gruvbox
"autocmd vimenter * ++nested colorscheme gruvbox

" enables dracula theme
"packadd! dracula-theme
"colorscheme dracula
"let g:dracula_colorterm = 0
"set termguicolors

" enables solarized theme
"syntax enable
"set background=dark
"colorscheme solarized
"set termguicolors 
"set g:solarized_termcolors=256
"let g:solarized_italic=1
