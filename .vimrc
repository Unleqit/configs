set nocompatible
set number
set tabstop=4
set shiftwidth=4
set noerrorbells
set visualbell
set t_vb=
set shell=/bin/bash

let g:term_buf = -1

inoremap <expr> <CR> (pumvisible() ? "\<C-y>" : "\<CR>")
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <silent> <F5> :call RunProgram()<CR>
nnoremap a i
nnoremap q <Nop>
tnoremap <Esc> <C-\><C-n>
tnoremap <silent> <F5> :call RunMakeAndWait()<CR>
vnoremap q <Nop>
command! -bang Q quitall<bang>
cnoreabbrev <expr> q getcmdtype() == ':' && getcmdline() ==# 'q' ? 'call ch_sendraw(term_getjob(g:term_buf), "exit\n") \| quitall!' : 'q'
cnoreabbrev <expr> wq getcmdtype() == ':' && getcmdline() ==# 'wq' ? 'wa \| call ch_sendraw(term_getjob(g:term_buf), "exit\n") \| quitall!' : 'wq'

autocmd VimEnter * NERDTree | wincmd L | vertical resize 30 | new | call s:OpenTerminalAndMap() | wincmd J | resize 18 | wincmd k | wincmd l | quit | resize 52 | wincmd h

let g:prevJob = 0
function! RunProgram() abort
  if &filetype ==# 'c'
    call ch_sendraw(term_getjob(g:term_buf), "make run\n")
    sleep 500m
    execute 'NERDTreeRefreshRoot'
  elseif &filetype ==# 'cs'
    let msgs = execute('messages')
	let l:match = matchlist(msgs, 'Loaded server for \zs\S\+\.sln')
	let l:sln_path = l:match[0]
	let l:sln_dir = fnamemodify(l:sln_path, ':h')
	let l:job = term_getjob(g:term_buf)
"	echo l:prevJob
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

function! s:OpenTerminalAndMap() abort
	let g:term_buf = term_start(&shell)
	execute g:term_buf . 'buffer'
	execute 'tnoremap <buffer> <CR> <CR><C-\><C-n>:NERDTreeRefreshRoot<CR>i'
endfunction


augroup CocHighlightOverride
	autocmd!
	autocmd ColorScheme * nested call Highlights()
augroup END


function! Highlights()
	highlight CocErrorSign       guifg=#ff0000
	highlight CocWarningSign     guifg=#ffaa00
	highlight CocInfoSign        guifg=#00ffff
	highlight CocHintSign        guifg=#00ff00
	"
	highlight CocErrorFloat      guifg=#ff0000
	highlight CocWarningFloat    guifg=#ffaa00
	highlight CocInfoFloat       guifg=#00ffff
	highlight CocHintFloat       guifg=#00ff00
	"
	highlight CocErrorHighlight    cterm=underline gui=underline guisp=#ff0000
	highlight CocWarningHighlight  cterm=underline gui=underline guisp=#ffaa00
	highlight CocInfoHighlight     cterm=underline gui=underline guisp=#00ffff
	highlight CocHintHighlight     cterm=underline gui=underline guisp=#00ff00
	"
	highlight CocErrorVirtualText    guifg=#ff0000
	highlight CocWarningVirtualText  guifg=#ffaa00
	highlight CocInfoVirtualText     guifg=#00ffff
	highlight CocHintVirtualText     guifg=#00ff00
	"
	autocmd ColorScheme * highlight CocMenuSel             guibg=#555555 guifg=#ffffff
	highlight CocMenu                guibg=#1a1a1a guifg=#ffffff
	highlight CocPumSearch           guifg=#00afff
	highlight CocPumDetail           guifg=#999999
	highlight CocPumShortcut         guifg=#aaaaaa
	highlight CocPumMenu             guifg=#888888
	highlight CocDeprecatedHighlight gui=strikethrough guifg=#666666
	"
	highlight CocFloating            guibg=#1c1c1c guifg=#ffffff
	highlight CocFloatBorder         guifg=#ffff00
	highlight CocFloatThumb          guibg=#5f5f5f
	highlight CocFloatSbar           guibg=#3a3a3a
	"
	highlight CocHighlightText       guibg=#264f78
	highlight CocFadeOut             guifg=#5c6370
	highlight CocSymbolHighlight     guibg=#3c3836
	highlight CocCodeLens            guifg=#999999
	"
	highlight CocSearch              guibg=#444444 guifg=#ffffff
	highlight CocListSearch          guibg=#5f00af guifg=#ffffff
	highlight CocListSearchLine      guibg=#444444 guifg=#ffffff
	highlight CocListLine            guibg=NONE guifg=#ffffff
	"
	highlight CocListFgWhite         guifg=#ffffff
	highlight CocListFgBlue          guifg=#5f87ff
	highlight CocListFgGreen         guifg=#5fff87
	highlight CocListFgYellow        guifg=#ffff87
	highlight CocListFgRed           guifg=#ff5f5f
	highlight CocListFgMagenta       guifg=#ff87ff
	highlight CocListFgCyan          guifg=#5fffff
	highlight CocListFgBlack         guifg=#000000
	highlight CocListFgGray          guifg=#888888
	highlight CocListFgDarkBlue      guifg=#0000af
	highlight CocListMode            guifg=#afff5f
endfunction

call Highlights()

call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-syntastic/syntastic'
Plug 'preservim/nerdtree'
Plug 'unkiwii/vim-nerdtree-sync'
Plug 'OmniSharp/omnisharp-vim'


call plug#end()

filetype plugin on
syntax on
autocmd FileType c,cpp setlocal omnifunc=CocActionAsync

