#!/bin/sh

cat << EOF > $HOME/.vimrc
" my vimrc (configuration file of vim)
"
" Modified date: 2012/04/13
"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Function
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Define global variable
"version
"echo "~:" expand('~')
"echo "HOME:" $HOME
"echo "VIM:" $VIM
"echo "VIMRUNTIME:" $VIMRUNTIME
"echo "MYVIMRC:" $MYVIMRC
"echo "MYGVIMRC:" $MYGVIMRC
"let home = system('echo $HOME')

" Define MySys
function! MySys()
  if has("win16") || has("win32") || has("win64")
    echo "OS: Windows"
    let g:vimrc_iswindows = 1
    return "win"
  elseif has("dos16") || has("dos32")
    echo "OS: DOS"
    return "dos"
  elseif has("unix")
    echo "OS: UNIX"
    return "unix"
  elseif has("mac") || has("macunix")
    echo "OS: OSX"
    return "mac"
  elseif has("win32")
    echo "OS: Cygwin"
    return "cygwin"
  elseif has("os2")
    echo "OS: OS2"
    return "os2"
  elseif has("vms")
    echo "OS: VMS"
    return "vms"
  else
    echo "Unknown OS"
    return "unknown"
  endif
endfunction

" Define Radom Colorscheme
function RandomColorscheme()
  let hour = strftime("%H")
  if hour < 6
    let colorScheme = "koehler"
  elseif hour < 12
    let colorScheme = "torte"
  elseif hour < 18
    let colorScheme  = "delek"
  else
    let colorScheme = "pablo"
  endif
  echo "set color to " . colorScheme
  execute "colorscheme " . colorScheme
endfunction

" Define return position when open file
function RecordPosition()
  if line("'\"") > 0
    if line("'\"") <= line("$")
      exe "norm '\""
    else
      exe "norm $"
    endif
  endif
endfunction

" Define check file tpye when create new file
function CheckFileType()
  if exists("b:countCheck") == 0
    let b:countCheck = 0
  endif

  let b:countCheck += 1

  if &filetype == "" && b:countCheck > 50 && b:countCheck < 200
    filetype detect
  elseif b:countCheck >= 200 || &filetype != ""
    autocmd! newFileDetection
  endif
endfunction

" Define dictionary file
function! SetDict(dictfile)
  if filereadable(a:dictfile)
    execute 'set dictionary+=' . a:dictfile
"    echo 'set dictionart: ' . a:dictfile
  endif
endfunction

" Setup Syntax switch
function! ToggleSyntax()
   if exists("g:syntax_on")
      syntax off
   else
      syntax enable
   endif
endfunction

" Define set up my vim python environment
function! VimPythonEnv()                                                                                                                                      
" set space and tab format
  set shiftwidth=4
  set tabstop=4
  set softtabstop=4
  set expandtab
  set autoindent
           
" set folding
" set folding column number -> set foldcolumn=0~12, set fdc
" set folding method -> set foldmethod= , set fdm
" manual, indent, expr, maker, syntax, diff, 
" enable folding -> set [no]foldenable, set [no]fen
  set foldcolumn=5 foldmethod=indent foldenable
           
" set line number
" enable line number -> set [no]number
  set number
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Get out of VI's compatible mode..
" set [no]compatible
set nocompatible

" Set shell to be bash
if MySys() == "unix" || MySys() == "mac"
    set shell=bash
endif

" Sets how many lines of history VIM har to remember
set history=1000

" Set to auto read when a file is changed from the outside
if exists("&autoread")
    set autoread
endif

" enable line number -> set [no]number
set nonumber

" Set help language and encode
" set helplang=cn
set encoding=utf-8
":e ++enc=big5
" set fileencoding=big5
set fileencodings=utf-8,big5

" enable visual bell -> set [no]visualbell
set visualbell

" Set syntax highlighting and color style
" default syntax at /usr/share/vim/vim72/syntax
" color scheme at /usr/share/vim/vim72/colors
" enable syntax highlightin -> syntax on|off
syntax on 
call RandomColorscheme()

" Set auto completion from dictionary file
"call SetDict('/usr/share/dict/words')

" Set search pattern option
set incsearch  " incremental searching
set hlsearch   " high light searching  

" enable cursor line -> set [no]cursorline, set [no]cul
set cursorline
" hi CursorLine term=underline cterm=none ctermbg=242
" enable cursor column-> set [no]cursorcolumn, set [no]cuc
set cursorcolumn
" set background, set bg=dark|light
set bg=dark

" enable auto wrap ->
set wrap

" Set folding
"set foldcolumn=5
"set foldmethod=indent
" enable folding -> set [no]foldenable, :zi
"set nofoldenable

" Set statusline
"set statusline=%<%F%h%m%r%h%w%y\ %{&ff}\ %{strftime(\"%Y/%m/%d-%H:%M\")}%=\ col:%c%V\ ascii:%b\ pos:%o\ lin:%l\,%L\ %P
"set statusline=%<%F%h%m%r%h%w%y\ %{&ff}\ %{strftime(\"%c\",getftime(expand(\"%:p\")))}%=\ lin:%l\,%L\ col:%c%V\ pos:%o\ ascii:%b\ %P
set statusline=%F%<%h%m%r%h%w%y\ %{&ff}\ %{strftime(\"%c\",getftime(expand(\"%:p\")))}\ %=%b\ %c%V\,%l\/%L(%o)\ %P
set laststatus=2

" Other
set backup    " keep backup file
set ruler     " show the cursor position all the time
set showcmd   " display incomplete commands
set showmode  " display mode INSERT/REPLACE/...
set mouse=h   " mouse works mode

" edit back last position
autocmd BufReadPost * call RecordPosition()
augroup newFileDetection
  autocmd CursorMovedI * call CheckFileType()
augroup end

" set my key mapping
"nmap <silent> ;s :call ToggleSyntax()<CR>
"nmap <silent> ;n :let &number = 1 - &number<CR>
"nmap <silent> ;n :if &number \| set nonumber \| else \| set number \| endif<CR>
"nmap <silent> ;n :set number!<CR>
nmap <silent> ;h1 :set number!<CR>
nmap <silent> ;h2 :call ToggleSyntax()<CR>
nmap <silent> ;h3 :set hlsearch!<CR>
nmap <silent> ;h4 :set ignorecase!<CR> 
nmap <silent> ;h5 :set cursorcolumn!<CR> 
nmap <silent> ;h6 :set cursorline!<CR> 
nmap <silent> ;h? :echo ";h? : help ;h operation\n
\;h1 : enable/disable line number\n
\;h2 : enable/disable syntax\n
\;h3 : enable/disable search highlight\n
\;h4 : enable/disable ignore case\n
\;h5 : enable/disable cursor column highlight\n
\;h6 : enable/disable cursor line highlight"<CR>
nmap <silent> ;a ggVG
nmap <silent> ]] :let &tabstop += 1<CR>:let &shiftwidth = &tabstop<CR>
nmap <silent> [[ :let &tabstop -= &tabstop > 1 ? 1 : 0<CR>:let &shiftwidth = &tabstop<CR>

" shiftwidth: sw, tabstop: ts, softtabstop: sts
" autoindent: ai, number:et, number:nu
" retab: ret
" For Perl Ruby
autocmd BufNewFile,BufRead *.pl,*.rb,*.erb set shiftwidth=2 tabstop=2 softtabstop=2 expandtab autoindent
" For Python
autocmd BufNewFile,BufRead *.py :call VimPythonEnv()
" For Fortran
autocmd BufNewFile,BufRead *.f,*.for,*f77,f90,f95,*.F,*.FOR,*F77,F90,F95 set shiftwidth=6 tabstop=6 expandtab ignorecase autoindent


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM plugin 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
EOF

# "set nomodeline
# 
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# " => VIM plugin TagList
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# "if findfile('taglist.vim', $HOME . "/.vim/plugin") == ".vim/plugin/taglist.vim"
# "if findfile('taglist.vim', $HOME . "/.vim/plugin") == ".vim/plugin/taglist.vim" || findfile('taglist.vim', $VIMRUNTIME . "/plugin") == "plugin/taglist.vim"
# "    echo "Loading: TagList"
# "    let Tlist_Auto_Open = 0
# "    let Tlist_Show_One_File = 1
# "    let Tlist_Exit_OnlyWindow = 1
# "    let Tlist_WinWidth = 20
# "    nmap <F8> :TlistToggle<CR> 
# ""    nmap <C-F8> :TlistToggle<CR> 
# "else
# "    echo "Unload:"
# "endif
# 
# 
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# " => VIM plugin WinManager
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# "if exists("$HOME/.vim/plugin/taglist.vim") || exists("$VIMRUNTIME/plugin/taglist.vim")
# "if findfile('taglist.vim', $HOME . "/.vim/plugin") == ".vim/plugin/taglist.vim" || findfile('taglist.vim', $VIMRUNTIME . "/plugin") == "plugin/taglist.vim"
# "    echo "Loading: WinManager"
# "    let g:winManagerWidth = 20
# "    nmap wm :WMToggle<cr>
# "
# ""    if exists("$HOME/.vim/plugin/taglist.vim") || exists("$VIMRUNTIME/plugin/taglist.vim")
# "    if findfile('taglist.vim', $HOME . "/.vim/plugin") == ".vim/plugin/taglist.vim" || findfile('taglist.vim', $VIMRUNTIME . "/plugin") == "plugin/taglist.vim"
# "        let g:winManagerWindowLayout='FileExplorer|TagList'
# "    else
# "        let g:winManagerWindowLayout='FileExplorer'
# "    endif
# "endif
# 
# 
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# " => VIM plugin PyDiction
# """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# "pydiction 1.2 python auto complete
# "filetype plugin on
# "let g:pydiction_location = '~/.vim/dict/complete-dict'
# "defalut g:pydiction_menu_height == 15
# "let g:pydiction_menu_height = 20 


# alias for sh/bash
cat << EOF >> $HOME/.alias
alias vi="vim"
EOF

# alias for csh/tcsh
cat << EOF >> $HOME/.aliases
alias vi "vim"
EOF
