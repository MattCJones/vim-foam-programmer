# vim-foam-programmer
Helpful utilities for the OpenFOAM programmer.

## Author
Matthew C. Jones matt.c.jones.aoe@gmail.com

## Installation

Install using [vim-plug](https://github.com/junegunn/vim-plug),
    
```vim
Plug `vim-foam-programmer`
```

## Features

* Automatically searches OpenFOAM makefiles for linked header files and adds
  them Vim's path.
    - Allows for opening included header files inside Vim with `gf`
    - Allows for built-in Vim include and definition searching 
        * Use `[_CTRL-i`, `[_CTRL-d`, `CTRL-w_i`, `CTRL-w_d`, etc.
        * See `:help include-search definition-search`
* Convenient command to build Ctags that references custom user files as well
  as OpenFOAM source code.
    - Run `:FoamCtags` to generate tags file
    - Use `g]` `Ctrl-]` and `Ctrl-t` to navigate through functions and
      variables of interest
    - See `:help tag-matchlist`
    - Requires external dependency:
      [exuberant-ctags](http://ctags.sourceforge.net/) or
      [universal-ctags](https://ctags.io/)
* Automatically set OpenFOAM files to cpp filetype for better readability.
  This is disabled by default. To enable, place the following line in your
  vimrc file.

```vim
let g:foam#programmer#syntax = 'true'
```


## See Also

* [Vim-Foam](https://github.com/lervag/vim-foam) for syntax highlighting.

* [YouCompleteMe](https://github.com/ycm-core/YouCompleteMe) and
  [YCM-Generator](https://github.com/rdnetto/YCM-Generator) for text
  completion.  Use the following command in the project base directory.

```vim
:YcmGenerateConfig -verbose --preserve-environment --force
```


## License

Copyright (c) 2020 Matthew C. Jones.  Distributed under The MIT License (MIT).
See LICENSE file.
