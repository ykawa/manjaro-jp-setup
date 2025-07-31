" Perl Development Optimized Vim Configuration
" マウスは使わないので完全に無効化
" Perl開発に特化した設定とスニペットを含む

" Basic vim configuration
syntax on
filetype on
filetype plugin on
filetype indent on

" Set encoding
set encoding=utf-8

" Line numbers
set number
set relativenumber

" Search settings
set hlsearch
set incsearch
set ignorecase
set smartcase

" Indentation (Perl style)
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" Visual settings
set showmatch
set ruler
set laststatus=2
set wildmenu
set cursorline
set colorcolumn=132

" Behavior
set backspace=indent,eol,start
set clipboard=unnamedplus

" Mouse settings - 完全に無効化
set mouse=
set ttymouse=

" Backup and swap files
set nobackup
set nowritebackup
set noswapfile

" Undo settings
set undofile
set undodir=~/.vim/undo

" Create undo directory if it doesn't exist
if !isdirectory($HOME."/.vim/undo")
    call mkdir($HOME."/.vim/undo", "p")
endif

" Color scheme (if available)
try
    colorscheme desert
catch
    " Fall back to default if desert is not available
endtry

" Key mappings
" Map jj to escape in insert mode
inoremap jj <Esc>

" Clear search highlighting
nnoremap <silent> <Space> :nohlsearch<CR>

" Easy split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Quick save
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" Quick quit
nnoremap <C-q> :q<CR>

" Perl specific settings
autocmd FileType perl setlocal tabstop=4 shiftwidth=4 expandtab
autocmd FileType perl setlocal textwidth=132
autocmd FileType perl setlocal comments=:#
autocmd FileType perl setlocal formatoptions=croql
autocmd FileType perl setlocal autoindent
autocmd FileType perl setlocal smartindent

" Other file type specific settings
autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType html setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType css setlocal tabstop=2 shiftwidth=2 expandtab

" Status line
set statusline=%f\ %m%r%h%w\ [%Y]\ [%{&ff}]\ [%{&fenc}]\ %=%l,%c\ %p%%

" =============================================================================
" Perl Development Enhancements
" =============================================================================

" Perl syntax checking
autocmd FileType perl nnoremap <buffer> <F5> :!perl -c %<CR>
autocmd FileType perl nnoremap <buffer> <F6> :!perl %<CR>

" Perl debugging
autocmd FileType perl nnoremap <buffer> <F7> :!perl -d %<CR>

" Perl tidy (if available)
autocmd FileType perl nnoremap <buffer> <F8> :%!perltidy<CR>

" Perl POD documentation
autocmd FileType perl nnoremap <buffer> <F9> :!perldoc <cword><CR>

" Perl module path completion
autocmd FileType perl setlocal path+=.,lib,/usr/share/perl5,/usr/lib/perl5

" Perl include expression for gf command
autocmd FileType perl setlocal includeexpr=substitute(v:fname,'::','/','g').'\.pm'

" Perl keyword program for K command
autocmd FileType perl setlocal keywordprg=perldoc

" =============================================================================
" Perl Code Snippets (Manual Implementation)
" =============================================================================

" Perl snippet function
function! InsertPerlSnippet(snippet)
    if a:snippet == 'sub'
        return "sub {\n    my () = @_;\n    \n    return;\n}"
    elseif a:snippet == 'if'
        return "if () {\n    \n}"
    elseif a:snippet == 'for'
        return "for my $ () {\n    \n}"
    elseif a:snippet == 'while'
        return "while () {\n    \n}"
    elseif a:snippet == 'use'
        return "use strict;\nuse warnings;\nuse v5.10;"
    elseif a:snippet == 'hash'
        return "my %hash = (\n    '' => '',\n);"
    elseif a:snippet == 'array'
        return "my @array = ();"
    elseif a:snippet == 'scalar'
        return "my $scalar = '';"
    elseif a:snippet == 'try'
        return "eval {\n    \n};\nif ($@) {\n    \n}"
    elseif a:snippet == 'open'
        return "open my $fh, '<', '' or die \"Cannot open file: $!\";"
    elseif a:snippet == 'regex'
        return "if (// ) {\n    \n}"
    elseif a:snippet == 'package'
        return "package ;\n\nuse strict;\nuse warnings;\n\n1;"
    elseif a:snippet == 'shebang'
        return "#!/usr/bin/env perl\nuse strict;\nuse warnings;\nuse v5.10;"
    endif
    return a:snippet
endfunction

" Perl snippet mappings (in insert mode)
autocmd FileType perl inoremap <buffer> <C-s>sub <C-r>=InsertPerlSnippet('sub')<CR>
autocmd FileType perl inoremap <buffer> <C-s>if <C-r>=InsertPerlSnippet('if')<CR>
autocmd FileType perl inoremap <buffer> <C-s>for <C-r>=InsertPerlSnippet('for')<CR>
autocmd FileType perl inoremap <buffer> <C-s>while <C-r>=InsertPerlSnippet('while')<CR>
autocmd FileType perl inoremap <buffer> <C-s>use <C-r>=InsertPerlSnippet('use')<CR>
autocmd FileType perl inoremap <buffer> <C-s>hash <C-r>=InsertPerlSnippet('hash')<CR>
autocmd FileType perl inoremap <buffer> <C-s>array <C-r>=InsertPerlSnippet('array')<CR>
autocmd FileType perl inoremap <buffer> <C-s>scalar <C-r>=InsertPerlSnippet('scalar')<CR>
autocmd FileType perl inoremap <buffer> <C-s>try <C-r>=InsertPerlSnippet('try')<CR>
autocmd FileType perl inoremap <buffer> <C-s>open <C-r>=InsertPerlSnippet('open')<CR>
autocmd FileType perl inoremap <buffer> <C-s>regex <C-r>=InsertPerlSnippet('regex')<CR>
autocmd FileType perl inoremap <buffer> <C-s>package <C-r>=InsertPerlSnippet('package')<CR>
autocmd FileType perl inoremap <buffer> <C-s>shebang <C-r>=InsertPerlSnippet('shebang')<CR>

" =============================================================================
" Perl Development Utilities
" =============================================================================

" Show Perl version
command! PerlVersion !perl -v

" Show Perl include paths
command! PerlInclude !perl -V

" Perl module installation check
command! -nargs=1 PerlModule !perl -M<args> -e 'print "Module <args> is installed\n"'

" Perl critic (if available)
command! PerlCritic !perlcritic %

" Perl documentation for current word
nnoremap <buffer> <Leader>pd :!perldoc <cword><CR>

" Perl module documentation
nnoremap <buffer> <Leader>pm :!perldoc -m <cword><CR>

" =============================================================================
" Perl Folding
" =============================================================================

" Enable folding for Perl subroutines
autocmd FileType perl setlocal foldmethod=syntax
autocmd FileType perl setlocal foldlevel=1

" Custom fold text for Perl
function! PerlFoldText()
    let line = getline(v:foldstart)
    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')
    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
    return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction

autocmd FileType perl setlocal foldtext=PerlFoldText()

" =============================================================================
" Perl Template for New Files
" =============================================================================

" Auto-insert Perl template for new .pl files
autocmd BufNewFile *.pl 0r ~/.vim/templates/perl.pl
autocmd BufNewFile *.pm 0r ~/.vim/templates/perl.pm

" Create template directory and files if they don't exist
if !isdirectory($HOME."/.vim/templates")
    call mkdir($HOME."/.vim/templates", "p")
endif

" Create Perl script template
if !filereadable($HOME."/.vim/templates/perl.pl")
    call writefile([
        \ '#!/usr/bin/env perl',
        \ 'use strict;',
        \ 'use warnings;',
        \ 'use v5.10;',
        \ '',
        \ '# Description: ',
        \ '# Author: ',
        \ '# Created: ' . strftime('%Y-%m-%d'),
        \ '',
        \ 'my $0 = shift @ARGV;',
        \ '',
        \ 'main();',
        \ '',
        \ 'sub main {',
        \ '    ',
        \ '}',
        \ '',
        \ '__END__',
        \ '',
        \ '=head1 NAME',
        \ '',
        \ ' - ',
        \ '',
        \ '=head1 SYNOPSIS',
        \ '',
        \ '    perl  ',
        \ '',
        \ '=head1 DESCRIPTION',
        \ '',
        \ '',
        \ '=head1 AUTHOR',
        \ '',
        \ '',
        \ '=head1 LICENSE',
        \ '',
        \ 'This program is free software.',
        \ '',
        \ '=cut'
    \ ], $HOME."/.vim/templates/perl.pl")
endif

" Create Perl module template
if !filereadable($HOME."/.vim/templates/perl.pm")
    call writefile([
        \ 'package ;',
        \ '',
        \ 'use strict;',
        \ 'use warnings;',
        \ 'use v5.10;',
        \ '',
        \ '# Description: ',
        \ '# Author: ',
        \ '# Created: ' . strftime('%Y-%m-%d'),
        \ '',
        \ 'sub new {',
        \ '    my $class = shift;',
        \ '    my $self = {',
        \ '        @_',
        \ '    };',
        \ '    bless $self, $class;',
        \ '    return $self;',
        \ '}',
        \ '',
        \ '1;',
        \ '',
        \ '__END__',
        \ '',
        \ '=head1 NAME',
        \ '',
        \ ' - ',
        \ '',
        \ '=head1 SYNOPSIS',
        \ '',
        \ '    use ;',
        \ '    my $obj = ->new();',
        \ '',
        \ '=head1 DESCRIPTION',
        \ '',
        \ '',
        \ '=head1 METHODS',
        \ '',
        \ '=head2 new',
        \ '',
        \ 'Constructor.',
        \ '',
        \ '=head1 AUTHOR',
        \ '',
        \ '',
        \ '=head1 LICENSE',
        \ '',
        \ 'This program is free software.',
        \ '',
        \ '=cut'
    \ ], $HOME."/.vim/templates/perl.pm")
endif

" =============================================================================
" Help for Perl Development
" =============================================================================

" Show Perl development help
command! PerlHelp echo "Perl Development Commands:\n<F5> - Syntax check\n<F6> - Run script\n<F7> - Debug\n<F8> - Perl tidy\n<F9> - Perldoc for word\n<Leader>pd - Perldoc\n<Leader>pm - Module doc\n<C-s>* - Snippets (sub, if, for, while, use, hash, array, scalar, try, open, regex, package, shebang)"
