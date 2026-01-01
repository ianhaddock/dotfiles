" .vimrc

set nocompatible    " turn off vi compatiblity mode

" Base setup:
set number          " show line numbers 
set relativenumber  " show line numbers relateive to cursor row
set sw=4 ts=4       " shift width and tab width value 
set expandtab       " use spaces instead of tabs 
set scrolloff=8     " buffer cursor from end of window vertically

" Search, syntax, formatting:
set signcolumn=yes  " show plugin state icons
syntax on           " enable colored syntax
set hlsearch        " highlight found searches
set list            " show hidden characters with listchars
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:·

" Plugin management:
" Run PlugInstall if missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin()
Plug 'dense-analysis/ale'         " github.com/dense-analysis/ale
Plug 'pearofducks/ansible-vim'    " github.com/pearofducks/ansible-vim
call plug#end()

let b:ale_fixers = {
    \    '*': ['remove_trailing_lines', 'trim_whitespace'],
    \    }
