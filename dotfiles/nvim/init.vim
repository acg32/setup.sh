" -------------------------------
" Core behavior and encoding
" -------------------------------
set nocompatible
set encoding=utf-8
set fileencoding=utf-8

" -------------------------------
" UI and navigation
" -------------------------------
set number
set relativenumber
set cursorline
set showmatch
set colorcolumn=100
set splitright
set splitbelow
set wildmenu
set hlsearch
set incsearch
set ignorecase
set smartcase
set hidden
set scrolloff=5
set signcolumn=yes

if has('clipboard')
  set clipboard=unnamedplus
endif

if has('termguicolors')
  set termguicolors
endif

" -------------------------------
" Syntax and highlighting
" -------------------------------
syntax on
highlight Comment cterm=italic gui=italic

" Strip trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

filetype plugin indent on

" -------------------------------
" Indentation
" -------------------------------
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set foldmethod=indent

autocmd FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType json setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType sql setlocal shiftwidth=2 tabstop=2 softtabstop=2

" -------------------------------
" Filetype tweaks
" -------------------------------
let g:sql_type_default = 'pgsql'
autocmd FileType sql setlocal commentstring=--\ %s

au BufReadPost *.html set filetype=html
au! BufNewFile,BufRead *.s3cfg setf dosini
au! BufNewFile,BufRead env.dist* setf sh
au BufRead,BufNewFile *.ini.template set filetype=dosini
au BufRead,BufNewFile *.yml.template set filetype=yaml
au BufRead,BufNewFile *.aws/credentials set filetype=dosini
au BufRead,BufNewFile nginx*.conf set filetype=nginx
au BufRead,BufNewFile .X* set filetype=xdefaults
au BufRead,BufNewFile .ghci set filetype=haskell

" -------------------------------
" Neovim-only enhancements
" -------------------------------
if has('nvim')
  let s:undo_dir = stdpath('state') . '/undo'
  if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, 'p')
  endif
  set undodir^=s:undo_dir
  set undofile
  set inccommand=split
endif

" -------------------------------
" Keymaps
" -------------------------------
" Disable arrow keys
nnoremap <Up> <nop>
nnoremap <Down> <nop>
nnoremap <Left> <nop>
nnoremap <Right> <nop>

" Use jk to escape
inoremap jk <Esc>

" Jump through location list
nnoremap <F3> :lprev<CR>
nnoremap <F4> :lnext<CR>

" -------------------------------
" Statusline
" -------------------------------
set laststatus=2

hi StatusLineTime      ctermfg=75  ctermbg=236 cterm=bold
hi StatusLineStatus    ctermfg=172 ctermbg=236 cterm=bold
hi StatusLineFile      ctermfg=76  ctermbg=236 cterm=bold
hi StatusLineFormat    ctermfg=135 ctermbg=236 cterm=bold
hi StatusLineCoords    ctermfg=144 ctermbg=236 cterm=bold
hi StatusLineSplitter  ctermfg=254 ctermbg=236 cterm=bold

let g:lsplitter="\ \▶\ "

set statusline=%#StatusLineTime#
set statusline+=%{strftime('%a\ %d\ %b\ %Y,\ %H:%M\ %Z\ ')}
set statusline+=%#StatusLineSplitter#%{g:lsplitter}
set statusline+=%#StatusLineStatus#
set statusline+=Status:%h%m%r
set statusline+=\ Mode:[%{mode()}]
set statusline+=%#StatusLineSplitter#%{g:lsplitter}
set statusline+=%#StatusLineFile#
set statusline+=%y
set statusline+=\ %F
set statusline+=%=
set statusline+=%#StatusLineFormat#
set statusline+=\ Format:[%{&fileformat}]
set statusline+=\ Encoding:[%{&fileencoding?&fileencoding:'none'}]
set statusline+=%#StatusLineSplitter#%{g:lsplitter}
set statusline+=%#StatusLineCoords#
set statusline+=x:%3c,\ y:%3l/%L\ (%3p%%)

" -------------------------------
" Local overrides
" -------------------------------
let s:local = stdpath('config') . '/init.local.vim'
if filereadable(s:local)
  execute 'source' s:local
endif
