<center> <h1> Awesome Linux Environment Configurations! </h1> </center>

Hello~! I am working as a SoC design engineer.
I have been using Linux environment for several years for development.
The Linux environment is essential and useful for both hardware and software developers.
However, many people feel puzzled when they first encounter it.
It operates on a CLI basis, and many actions are performed solely using the keyboard, which can be unfamiliar to generations accustomed to GUI. Moreover, the basic environment is quite raw, and it might feel inconvenient to use.

However, Linux offers the ability to configure a wide range of settings, resulting in an environment that can be incredibly beautiful, convenient, and useful.
This repository provides a foundational setup for a Linux environment that is useful for basic usage.
It includes configurations for vim, bash, tmux, and ctags.
The basic setup can be used in various ways, and since I am an RTL designer, it includes environment configurations related to SystemVerilog.

## Configs & Dependencies

**(1) VIM**

Vim is the most powerful editor available for use on Linux.
I have added more settings and plugins based on [amix/vimrc][1] to enhance its functionality.  
To fully utilize the features of this repository, [Vim][2] version 8.4 or higher is required. Without it, some functionalities might not work properly.

[1]: https://github.com/amix/vimrc  
[2]: https://github.com/vim/vim.git

**(2) BASH**

There are many shells available for linux, with one of the most widely used being bash.
This repository provied useful and awesomw bashrc configurations.

**(3) CTAGS**

Ctags is an essential program that developers cannot do without.
This program automatically organizes the information necessary for analyzing complex code.
However, for writing SystemVerilog, certain options are necessary, and I have applied those options.

If ctags is not installed in your system, install the ctags before installing configuration.

    sudo apt update
    sudo apt install ctags

**(4) TMUX**

[Tmux][3] is an optimized program for launching and navigating multiple shells in the Linux terminal.
I write configuration for tmux based on [gpakosz/.tmux][4].

If tmux is not installed tmux in your system, install the tmux before installing confiugration.

    sudo apt update
    sudo apt install tmux

[3]: https://github.com/tmux/tmux.git
[4]: https://github.com/gpakosz/.tmux.git

## How to install the awesome configurations?

You can simply install it using the following commands.

    git clone --depth=1 https://github.com/dounghun22/awesome-linux-configs.git ~/.vim_runtime
    cd ~/.vim_runtime
    chmod +x ~/.vim_runtime/install_awesome_configs.sh
    ./install_awesome_configs.sh #Do not use sh ./install_awesome_configs.sh
    source ~/.bashrc #source bash configurations

After the installation is complete, you will be able to observe changes in your environment.
If your terminal was originally composed of a black background and white text, you will feel the presence of colors in the terminal above all else.
Next, when you type 'tmux', you will be able to see a colorful status bar.
Lastly, when you open your code using Vim, you will encounter a different screen than the Vim you knew before.

## Optimize and personalize to your own environment

I have optimized and tailored the provided configuration from the repository to suit your environment.

### VIM

Vim is the program that allows you to change the most aspects.
On a smaller scale, you can begin with colorscheme configuration, and on a larger scale, you can proceed to installing plugins.

#### **(1) Add amd Modify Configurations**

You just write your own configuration to ~/.vim_runtime/personalized.vim file.

#### **(2) Install Plugins**

This configuration helps you install vim plugins easily. You just clone plugin repository to ~/.vim_runtime/my_plugins.
If you are managing your own Git branch and operating a remote repository, it's recommended to remove the Git attributes of cloned plugins and then push.

#### **(3) Colorschme**
You can replace 'tender' with your desired colorscheme in ~/.vim_runtime/my_configs.vim, around line 6 where the colorscheme 'tender' is mentioned.

The below table lists pre-installed colorschemes. (from [rafi/awesome-vim-colorschemes])

[rafi/awesome-vim-colorschemes]: https://github.com/rafi/awesome-vim-colorschemes.git

| Scheme         | Description | Terminal | GUI |
| -------------- | ------------|:--------:|:---:|
| [256noir] | Dark minimal colors, to avoid distraction | ✓ | ✓ |
| [abstract] | Dark theme based on Abstract app | ✓ | ✓ |
| [afterglow] | Adaptation from Sublime Text | ✓ | ✓ |
| [alduin] | Dark rustic colors | ✓ | ✓ |
| [anderson] | Dark vim colorscheme based on colors from Wes Anderson films | ✓ | ✓ |
| [angr] | Pleasant, mild, dark theme | ✓ | ✓ |
| [ayu-vim] | Simple, bright and elegant theme |   | ✓ |
| [Apprentice] | Dark, low-contrast colorscheme | ✓ | ✓ |
| [Archery] | Vim colorscheme inspired by Arch Linux colors | ✓ | ✓ |
| [Atom] | Designed to be very readable in both light and dark environments |   | ✓ |
| [carbonized] | Inspired by the Carbon keycap set | ✓ (16) | ✓ |
| [challenger-deep] | FlatColor colorscheme | ✓ | ✓ |
| [deep-space] | Intergalactic friendly color scheme based off Hybrid | ✓ | ✓ |
| [deus] | For the late night coder | ✓ | ✓ |
| [dogrun] | Dark purple | ✓ | ✓ |
| [flattened] | Solarized, without the bullshit | ✓ (16) | ✓ |
| [focuspoint] | Maintain color coordination and important keyword focus |   | ✓ |
| [fogbell] | Minimal grey monotone with 3 variants | ✓ | ✓ |
| [github] | Based on Github's syntax highlighting | ✓ | ✓ |
| [gotham] | Very dark vim colorscheme | ✓ | ✓ |
| [gruvbox] | Retro groove color scheme | ✓ | ✓ |
| [happy hacking] | Fairly small set of colors instead of throwing rainbows at your face | ✓ | ✓ |
| [Iceberg] | Dark blue color scheme | ✓ | ✓ |
| [papercolor] | Light and Dark color schemes inspired by Google's Material Design | ✓ | ✓ |
| [parsec] | Color scheme for people tired of solarized  | ✓ (16) | ✓ |
| [scheakur] | A light/dark colorscheme  | ✓ | ✓ |
| [hybrid] | A dark colour scheme for Vim and gVim | ✓ | ✓ |
| [hybrid-material] | Material color scheme based on w0ng/vim-hybrid | ✓ | ✓ |
| [jellybeans] | Colorful, dark color scheme | ✓ | ✓ |
| [lightning] | Light vim colorscheme based on Apprentice | ✓ | ✓ |
| [lucid] | Vivid highlights and friendly, clear colors |   | ✓ |
| [lucius] | Lucius color scheme | ✓ | ✓ |
| [materialbox] | Light and dark material palette inspired based on Gruvbox |   | ✓ |
| [meta5] | Dark colorscheme, inspired by Tron | ✓ | ✓ |
| [minimalist] | Darker version of material theme inspired by Sublime Text | ✓ | ✓ |
| [molokai] | Molokai color scheme | ✓ | ✓ |
| [molokayo] | Very tweaked molokai based theme | ✓ | ✓ |
| [mountaineer] | A dark and adventurous theme | ✓ | ✓ |
| [nord] | An arctic, north-bluish clean and elegant theme | ✓ (16) | ✓ |
| [oceanicnext] | Oceanic Next theme | ✓ | ✓ |
| [oceanic-material] | Material dark colorscheme | ✓ | ✓ |
| [one] | Adaptation of one-light and one-dark | ✓ | ✓ |
| [onedark] | Inspired by Atom's One Dark syntax theme | ✓ | ✓ |
| [onehalf] | Clean, vibrant and pleasing color scheme | ✓ | ✓ |
| [orbital] | Dark blue base16 theme | ✓ | ✓ |
| [paramount] | Minimal colorscheme that only puts emphasis on the paramount | ✓ | ✓ |
| [pink-moon] | Dark pastel theme | ✓ | ✓ |
| [purify] | Clean & vibrant color schemes for Vim, Terminals... | ✓ | ✓ |
| [pyte] | Clean, light (nearly white) theme |   | ✓ |
| [rdark-terminal2] | Modified rdark-terminal to enhance visibility | ✓ |   |
| [seoul256] | Low-contrast color scheme based on Seoul Colors | ✓ | ✓ |
| [sierra] | Dark vintage colors | ✓ | ✓ |
| [solarized8] | Optimized Solarized colorschemes | ✓ (16) | ✓ |
| [sonokai] | Vivid and high contrast based on Monokai Pro | ✓ | ✓ |
| [space-vim-dark] | Dark magenta colors | ✓ | ✓ |
| [spacecamp] | Colors for the final frontier | ✓ | ✓ |
| [sunbather] | Minimal pink colorscheme | ✓ | ✓ |
| [tender] | 24bit colorscheme for Vim | ✓ | ✓ |
| [termschool] | Based on the "codeschool" theme, with lots of tweaks | ✓ | ✓ |
| [twilight256] | Imitates the Twilight theme for TextMate | ✓ | ✓ |
| [two-firewatch] | A blend between duotone light and firewatch (for atom) | ✓ | ✓ |
| [wombat256] | Wombat for 256 color xterms | ✓ | ✓ |
| [monokai] | Monokai is the lab of Wimer Hazenberg | ✓ | ✓ |

[256noir]: https://github.com/andreasvc/vim-256noir
[abstract]: https://github.com/jdsimcoe/abstract.vim
[afterglow]: https://github.com/danilo-augusto/vim-afterglow
[alduin]: https://github.com/AlessandroYorba/Alduin
[Apprentice]: https://github.com/romainl/Apprentice
[Archery]: https://github.com/Badacadabra/vim-archery
[anderson]: https://github.com/gilgigilgil/anderson.vim
[angr]: https://github.com/zacanger/angr.vim
[Atom]: https://github.com/gregsexton/Atom
[ayu-vim]: https://github.com/ayu-theme/ayu-vim
[carbonized]: https://github.com/nightsense/carbonized
[challenger-deep]: https://github.com/challenger-deep-theme/vim
[deep-space]: https://github.com/tyrannicaltoucan/vim-deep-space
[deus]: https://github.com/ajmwagar/vim-deus
[dogrun]: https://github.com/wadackel/vim-dogrun
[flattened]: https://github.com/romainl/flattened
[focuspoint]: https://github.com/chase/focuspoint-vim
[fogbell]: https://github.com/jaredgorski/fogbell.vim
[github]: https://github.com/endel/vim-github-colorscheme
[gotham]: https://github.com/whatyouhide/vim-gotham
[gruvbox]: https://github.com/morhetz/gruvbox
[happy hacking]: https://github.com/yorickpeterse/happy_hacking.vim
[papercolor]: https://github.com/NLKNguyen/papercolor-theme
[parsec]: https://github.com/keith/parsec.vim
[scheakur]: https://github.com/scheakur/vim-scheakur
[hybrid]: https://github.com/w0ng/vim-hybrid
[hybrid-material]: https://github.com/kristijanhusak/vim-hybrid-material
[Iceberg]: https://github.com/cocopon/iceberg.vim
[jellybeans]: https://github.com/nanotech/jellybeans.vim
[lightning]: https://github.com/wimstefan/Lightning
[lucid]: https://github.com/cseelus/vim-colors-lucid
[lucius]: https://github.com/jonathanfilip/vim-lucius
[materialbox]: https://github.com/mkarmona/materialbox
[meta5]: https://github.com/christophermca/meta5
[minimalist]: https://github.com/dikiaap/minimalist
[molokai]: https://github.com/tomasr/molokai
[molokayo]: https://github.com/fmoralesc/molokayo
[mountaineer]: https://github.com/TheNiteCoder/mountaineer.vim
[nord]: https://github.com/arcticicestudio/nord-vim
[oceanicnext]: https://github.com/mhartington/oceanic-next
[oceanic-material]: https://github.com/hardcoreplayers/oceanic-material
[one]: https://github.com/rakr/vim-one
[onedark]: https://github.com/joshdick/onedark.vim
[onehalf]: https://github.com/sonph/onehalf
[orbital]: https://github.com/fcpg/vim-orbital
[paramount]: https://github.com/owickstrom/vim-colors-paramount
[pink-moon]: https://github.com/sts10/vim-pink-moon
[purify]: https://github.com/kyoz/purify
[pyte]: https://github.com/vim-scripts/pyte
[rdark-terminal2]: https://github.com/vim-scripts/rdark-terminal2.vim
[seoul256]: https://github.com/junegunn/seoul256.vim
[sierra]: https://github.com/AlessandroYorba/Sierra
[solarized8]: https://github.com/lifepillar/vim-solarized8
[sonokai]: https://github.com/sainnhe/sonokai
[space-vim-dark]: https://github.com/liuchengxu/space-vim-dark
[spacecamp]: https://github.com/jaredgorski/SpaceCamp
[sunbather]: https://github.com/nikolvs/vim-sunbather
[tender]: https://github.com/jacoborus/tender.vim
[termschool]: https://github.com/marcopaganini/termschool-vim-theme
[twilight256]: https://github.com/vim-scripts/twilight256.vim
[two-firewatch]: https://github.com/rakr/vim-two-firewatch
[wombat256]: https://github.com/vim-scripts/wombat256.vimi
[monokai]: https://github.com/ku1ik/vim-monokai.git

You can also add your own colorschemes .vim file to ~/.vim_runtime/my_plugins/colorschemes/colors/.

## BASH

You just add your bash configuration to ~/.vim_runtime/personalized.sh file.

### TMUX

You just modify and add ~/.vim_runtime/tmux_config/.tmux.conf.local file.

### CTAGS

You just modify and add ~/.vim_runtime/ctags/.ctags file.

The MIT License (MIT)
=====================

Copyright © `2023` `Donghun Jeong`

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the “Software”), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

