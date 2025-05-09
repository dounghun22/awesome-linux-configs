function! MakeFileHeader(fc,mc,lc)
    exec "normal gg"
    set paste
    let s:author = ""
    let s:copyright = ""
    if exists('g:header_comment_author')
        let s:author = g:header_comment_author
    else
	echo "g:header_comment_author is not defined in .vimrc"
    end
    if exists('g:header_comment_copyright')
        let s:copyright = g:header_comment_copyright
    else
	echo "g:header_comment_copyright is not defined in .vimrc"
    end

    let s:comment  = a:fc . "\r"
    let s:comment .= a:mc . " Copyright (C) " . strftime("%Y") . " " . s:copyright . "\r"
    let s:comment .= a:mc . "\r"
    let s:comment .= a:mc . " File:    " . expand('%:t') . "\r"
    let s:comment .= a:mc . " Author:  " . s:author . "\r"
    let s:comment .= a:mc . " Created: " . strftime("%Y-%m-%d") . "\r"
    let s:comment .= a:lc . "\r\r"
    exec "normal i" . s:comment
    set nopaste
endfunction
