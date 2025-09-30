set nocompatible
set number
set tabstop=4
set shiftwidth=4
set noerrorbells
set visualbell
set t_vb=
set shell=/bin/bash
set incsearch
set hlsearch
set ignorecase
set smartcase
set autoindent
set smartindent
set expandtab

let g:term_buf = -1

inoremap <expr> <CR> (pumvisible() ? "\<C-y>" : "\<CR>")
inoremap <S-Tab> <C-d>
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <silent> <F5> :call RunProgram()<CR>
nnoremap a i
nnoremap q <Nop>
nnoremap <S-Tab> <<
tnoremap <Esc> <C-\><C-n>
tnoremap <silent> <F5> :call RunProgram()<CR>
vnoremap q <Nop>
vnoremap < <gv
vnoremap > >gv
command! -bang Q quitall<bang>
cnoreabbrev <expr> q getcmdtype() == ':' && getcmdline() ==# 'q' ? 'call ch_sendraw(term_getjob(g:term_buf), "exit\n") \| quitall!' : 'q'
cnoreabbrev <expr> wq getcmdtype() == ':' && getcmdline() ==# 'wq' ? 'wa \| call ch_sendraw(term_getjob(g:term_buf), "exit\n") \| quitall!' : 'wq'

function! s:SetupLayout()
    NERDTree | wincmd L | vertical resize 30 | new | call s:OpenTerminalAndMap() | wincmd J | resize 18 | wincmd k | wincmd l | quit | resize 52 | wincmd h
endfunction

autocmd VimEnter * call s:SetupLayout()
autocmd VimResized * call s:ResizeLayout()

function! s:ResizeLayout()
    let l:nerdtree_win = bufwinnr('NERD_tree_1')
    if l:nerdtree_win >= 0
        exec l:nerdtree_win . "wincmd w"
        wincmd L
        vertical resize 30
    endif

    for w in range(1, winnr('$'))
        if getwinvar(w, '&buftype') ==# 'terminal'
            exec w . 'wincmd w'
            wincmd J
            resize 18
        endif
    endfor

    wincmd k
    wincmd l
    resize 52
endfunction


autocmd VimEnter * highlight NERDTreeDir       ctermfg=30
autocmd VimEnter * highlight NERDTreeDirSlash  ctermfg=30

autocmd BufEnter * highlight NERDTreeDir       ctermfg=30
autocmd BufEnter * highlight NERDTreeDirSlash  ctermfg=30
autocmd TextChanged,TextChangedI * silent! noh
autocmd CmdlineLeave : silent! noh
autocmd FileType cs hi clear

let g:prevJob = 0
function! RunProgram() abort
  if &filetype ==# 'c'
    call ch_sendraw(term_getjob(g:term_buf), "make run\n")
    sleep 500m
    execute 'NERDTreeRefreshRoot'
  elseif &filetype ==# 'cs'
    let msgs = execute('messages')
	let l:match = matchlist(msgs, 'Loaded server for \zs.\+\.sln')
	let l:sln_path = l:match[0]
	let l:sln_dir = fnamemodify(l:sln_path, ':h')
	let l:job = term_getjob(g:term_buf)
	if !empty(g:prevJob)
	  call ch_sendraw(l:job, "\x03")
	  let g:prevJob = 0
	  sleep 1250m
	endif
	let g:prevJob = l:job
	call ch_sendraw(l:job, "cd '" . l:sln_dir . "'\n")
	call ch_sendraw(l:job, "./build.sh\n")
  endif
endfunction

function! s:OpenTerminalAndMap() abort
	let g:term_buf = term_start(&shell)
	execute g:term_buf . 'buffer'
	execute 'tnoremap <buffer> <CR> <CR><C-\><C-n>:NERDTreeRefreshRoot<CR>i'
endfunction

call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-syntastic/syntastic'
Plug 'preservim/nerdtree'
Plug 'unkiwii/vim-nerdtree-sync'
Plug 'OmniSharp/omnisharp-vim'
"Plug 'haya14busa/incsearch.vim'

call plug#end()

filetype plugin on
syntax on

autocmd FileType c,cpp setlocal omnifunc=CocActionAsync

let g:OmniSharp_highlighting = 0

