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
set clipboard=unnamed

" Set autocomplete for command mode
set wildmenu
set wildmode=full
filetype plugin indent on
syntax on
set viminfo='1000,f1,\"500,:100,/100

" execute python script
nnoremap <F5> :w<CR> :! python %<CR>

" spell check
autocmd BufRead,BufNewFile *.tex setlocal spell

" custom mapping
nmap <C-Right> :tabnext<CR>
nmap <C-Left> :tabprevious<CR>

nnoremap <C-N> :NERDTree<CR>

" Open terminal in current window without adding to buffer list
nnoremap <leader>t :term ++curwin<CR><C-W>:setlocal nobuflisted<CR>

nmap <leader>d <Plug>OSCYankOperator
nmap <leader>dd <leader>d_
vmap <leader>d <Plug>OSCYankVisual

" to save as root
command Saveasroot w !sudo tee %

" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za

" Insert blank line below; fall back to normal <CR> in special buffers
nnoremap <expr> <CR> &buftype ==# '' ? 'o\<esc>k' : '\<CR>'

" enables airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" This allows buffers to be hidden if you've modified a buffer.
set hidden

" To open a new empty buffer
nnoremap <C-t> :enew<cr>

" Move to the next buffer
nnoremap <C-l> :bnext<CR>

" Move to the previous buffer
nnoremap <C-h> :bprevious<CR>

" Close the current buffer and move to the previous one
nnoremap <C-q> :bp <BAR> bd #<CR>

" enables gruvbox theme
set background=dark
let g:gruvbox_guisp_fallback = 'bg'
let g:gruvbox_italic=1
colorscheme gruvbox
