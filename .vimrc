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
inoremap <silent><expr> <CR>  coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
inoremap <silent><expr> <Esc> coc#pum#visible() ? coc#pum#cancel() : "\<Esc>\<Right>" 
nnoremap <silent> <F5> :call RunProgram()<CR>
nnoremap q <Nop>
nnoremap a i 
nnoremap p :execute "normal! i" . @0<CR><Right>
nnoremap <silent> w :<C-U>call system('clip.exe', @")<CR>
nnoremap 2 :C2H<CR>
nnoremap x "+x
tnoremap <Esc> <C-\><C-n>
tnoremap <silent> <F5> :call RunProgram()<CR>
vnoremap q <Nop>
vnoremap <silent> w y:call system('clip.exe', @")<CR>
xnoremap x "+x
command! -bang Q quitall<bang>
cnoreabbrev <expr> q getcmdtype() == ':' && getcmdline() ==# 'q' ? 'call ch_sendraw(term_getjob(g:term_buf), "exit\n") \| quitall!' : 'q'
cnoreabbrev <expr> wq getcmdtype() == ':' && getcmdline() ==# 'wq' ? 'wa \| call ch_sendraw(term_getjob(g:term_buf), "exit\n") \| quitall!' : 'wq'
cnoreabbrev makefile Makefile
 

autocmd VimEnter * NERDTree | wincmd L | vertical resize 30 | new | call s:OpenTerminalAndMap() | wincmd J | resize 18 | wincmd k | wincmd l | quit | resize 52 | wincmd h
autocmd VimEnter * highlight NERDTreeDir       ctermfg=30
autocmd VimEnter * highlight NERDTreeDirSlash  ctermfg=30
autocmd BufEnter * highlight NERDTreeDir       ctermfg=30
autocmd BufEnter * highlight NERDTreeDirSlash  ctermfg=30
autocmd TextChanged,TextChangedI * silent! noh
autocmd CmdlineLeave : silent! noh
autocmd FileType cs hi clear


"create integrated terminal buffer
function! s:OpenTerminalAndMap() abort
	let g:term_buf = term_start(&shell)
	execute g:term_buf . 'buffer'
	execute 'tnoremap <buffer> <CR> <CR><C-\><C-n>:NERDTreeRefreshRoot<CR>i'
endfunction

"[C] pipe output from external job to integrated terminal
let g:termjob = term_getjob(g:term_buf)
function! SendToTerminal(...) abort
  if a:0 >= 2
    let data   = a:2
    if type(data) == type([])
      for line in data
        call ch_sendraw(g:termjob, line . "\n")
      endfor
    endif
  endif
endfunction

"[C] on exit of external job
function! OnExit(job_id, exit_code) abort
  execute 'NERDTreeRefreshRoot'
  call ch_sendraw(term_getjob(g:term_buf), "make run\n")
endfunction

let g:prevJob = 0
function! RunProgram() abort
  "[C] handle .c files
    if &filetype ==# 'c'
    call job_start(['make'], {
          \ 'out_cb': function('SendToTerminal'),
          \ 'err_cb': function('SendToTerminal'),
          \ 'exit_cb': function('OnExit')
          \ })
  "[C#] handle .cs files
  elseif &filetype ==# 'cs'
    let msgs = execute('messages')
	let l:match = matchlist(msgs, 'Loaded server for \zs\S\+\.sln')
	let l:sln_path = l:match[0]
	let l:sln_dir = fnamemodify(l:sln_path, ':h')
	let l:job = term_getjob(g:term_buf)
	if !empty(g:prevJob)
	  call ch_sendraw(l:job, "\x03")
	  let g:prevJob = 0
	  sleep 1250m
	endif
	let g:prevJob = l:job
	call ch_sendraw(l:job, "cd " . l:sln_dir . "\n")
	call ch_sendraw(l:job, "./build.sh\n")
  endif
endfunction

augroup makeheaders_auto
    autocmd!
    autocmd BufWritePost *.c call system('makeheaders ' . shellescape(expand('%'))) | NERDTreeRefreshRoot
augroup END

" automatically create Makefile
command! Makefile call CreateMakefile()

function! CreateMakefile() abort
  if filereadable("Makefile")
    return
  endif

let l:cflags = "-std=c99 -Wall -pedantic -Ofast"
let l:cDefaultBinaryName = "app"
call system("echo -e 'CC = gcc\nCFLAGS = ".l:cflags."\n\nSRCS = $(wildcard *.c)\nOBJS = $(SRCS:.c=.o)\nBIN = ".l:cDefaultBinaryName."\n\nall: $(BIN)\n\n$(BIN): $(OBJS)\n\t$(CC) $(OBJS) -o \$@\n\n%.o: %.c\n\t$(CC) $(CFLAGS) -c $< -o $@\n\nclean:\n\trm -f $(OBJS) $(BIN)\n\nrun: $(BIN)\n\t@./$(BIN)\n' > Makefile") | NERDTreeRefreshRoot 
endfunction


" installed vim plugins
call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-syntastic/syntastic'
Plug 'preservim/nerdtree'
Plug 'unkiwii/vim-nerdtree-sync'
Plug 'OmniSharp/omnisharp-vim'
Plug 'linluk/vim-c2h'

call plug#end()



filetype plugin on
syntax on

hi Comment ctermfg=LightBlue
 
autocmd FileType c,cpp setlocal omnifunc=CocActionAsync
 
"[C] Completion menu
highlight CocMenu ctermbg=61 ctermfg=15
highlight CocMenuSel ctermbg=15 ctermfg=0

"[C] Floating windows
highlight CocFloating ctermbg=61 ctermfg=15
highlight CocFloatingText ctermbg=61 ctermfg=15
highlight CocFloatingType ctermfg=15 ctermbg=61

"[C] PUM (popup menu)
highlight CocPum ctermbg=61 ctermfg=15
highlight CocPumSel ctermbg=15 ctermfg=0
highlight CocPumMatch ctermfg=2 ctermbg=61

let g:OmniSharp_highlighting = 0

" make a behave as i in normal mode
autocmd VimEnter * nnoremap a i

