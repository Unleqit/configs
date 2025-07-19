set nocompatible
set number
set tabstop=4
set shiftwidth=4
set noerrorbells
set visualbell
set t_vb=
set shell=/bin/bash

inoremap <expr> <CR> (pumvisible() ? "\<C-y>" : "\<CR>")
nnoremap <C-n> :NERDTreeToggle<CR>
tnoremap <Esc> <C-\><C-n>

function! CloseNERDTreeAndQuit()
	NERDTreeClose
    tabdo windo if &buftype ==# 'terminal' | execute 'q!' | endif
	tabdo if &buftype == '' | wq | endif
	quit
endfunction

function! CloseNERDTreeAndQuitNoSave()
	NERDTreeClose
	tabdo if &buftype == '' | quit | endif
	quit
endfunction

nnoremap wqc<CR> :call CloseNERDTreeAndQuit()<CR>
nnoremap qc<CR> :call CloseNERDTreeAndQuit()<CR>

autocmd VimEnter * NERDTree | wincmd L | vertical resize 30 | new | call term_start(&shell) | wincmd J | resize 18 | wincmd k | wincmd l | quit | resize 52 | wincmd h

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

call plug#end()

filetype plugin on
syntax on
autocmd FileType c,cpp,cs setlocal omnifunc=CocActionAsync

