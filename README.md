# Awesome Linux Environment Configurations

Build a focused Linux workstation from a readable, version-controlled starting point. This repository brings together Vim, Bash, Tmux, and Ctags configuration for a practical keyboard-driven environment that can be installed, inspected, and personalized safely.
Created and maintained by a SoC RTL design engineer, this repository includes Verilog/SystemVerilog-oriented environment configuration for RTL design work: Vim filetype detection for `.v`, `.vh`, and `.sv`, a SystemVerilog syntax and indent hook, Ctags profiles for `.v`, `.vh`, `.sv`, `.svh`, and `.svi`, and Pathogen/Taglist plugin configuration that routes tag navigation through `util/ctags-runtime`.

**Status:** Active configuration repository
**Presentation:** English, Markdown-first documentation
**Scope:** Documentation describes the existing runtime; it does not change the installer, Vim, Bash, Tmux, Ctags, plugins, tests, CI, or generated home configuration.

## ✨ Highlights

- **One coherent setup:** Vim, Bash, Tmux, and Ctags are managed from one checkout.
- **Safe first step:** Review the installer with a dry run before changing home files.
- **Keyboard-friendly workflow:** Navigate editors, panes, tags, and shell tools with consistent shortcuts.
- **Personal by design:** Keep local preferences and host-specific secrets at documented customization boundaries.
- **Markdown-first reference:** Use the navigation below to jump directly to a task.

**Status labels:** `Recommended` marks the normal path, `Optional` marks an enhancement, and `Reference` points to supporting detail.

### Contents

- [Quick Start](#zap-quick-start)
- [Prerequisites](#toolbox-prerequisites)
- [Installation](#package-installation)
- [Verify the Installation](#white_check_mark-verify-the-installation)
- [CI Checks](#ci-checks)
- [Daily Usage](#compass-daily-usage)
- [Personalization](#art-personalization)
- [Plugins and Language Support](#jigsaw-plugins-and-language-support)
- [Troubleshooting](#stethoscope-troubleshooting)
- [License](#page_facing_up-license)

## ⚡ Quick Start

**Status:** Recommended path

Set the checkout location, clone the repository, preview the changes, and install:

```bash
git clone --depth=1 https://github.com/dounghun22/awesome-linux-configs.git awesome-linux-configs
export VIM_RUNTIME="$PWD/awesome-linux-configs"
cd "$VIM_RUNTIME"
./install_awesome_configs.sh --dry-run
./install_awesome_configs.sh --force
source ~/.bashrc
```

The dry run is the review point. Read [Prerequisites](#toolbox-prerequisites) and [Installation](#package-installation) before using the installer on an existing workstation.

## 🧰 Prerequisites

**Status:** Required tools are checked by the installer

Install or make these commands available before running the installer: `bash`, `vim`, `tmux`, and `ctags`. The installer checks `bash`, `vim`, and `tmux`, then resolves the executable selected by `CTAGS` (or the default command `ctags`). It accepts a Ctags implementation only when the repository wrapper recognizes it.

Vim 8.4 or newer is a compatibility target for the configured features. It is not an installer-enforced minimum version.

The Ctags configuration supports both Universal Ctags and Exuberant Ctags through the version-specific profiles `ctags/ctags-universal.ctags` and `ctags/ctags-exuberant.ctags`. Choose the implementation available on your system and keep the `CTAGS` selection explicit when more than one Ctags command is installed.

```bash
# Ubuntu/Debian example: install Universal Ctags.
sudo apt update
sudo apt install bash vim tmux universal-ctags
```

The command above is an Ubuntu/Debian package example, not a universal package name. If your Ubuntu/Debian release provides Exuberant Ctags instead, this is the corresponding example:

```bash
# Ubuntu/Debian example: install Exuberant Ctags when provided by the release.
sudo apt install bash vim tmux exuberant-ctags
```

Use the package manager and Ctags implementation provided by your distribution. To select a particular executable, set `CTAGS` for the installer invocation, for example:

```bash
CTAGS="$(command -v ctags-universal)" ./install_awesome_configs.sh --dry-run
```

## 📦 Installation

**Status:** Review before applying home-directory changes

Clone the verified repository URL into the runtime directory you want to use:

```bash
git clone --depth=1 https://github.com/dounghun22/awesome-linux-configs.git awesome-linux-configs
export VIM_RUNTIME="$PWD/awesome-linux-configs"
cd "$VIM_RUNTIME"
```

When `VIM_RUNTIME` is unset, the installer defaults it to the directory containing `install_awesome_configs.sh`. When it is set, it must identify an existing checkout; the installer resolves that path before continuing. This makes an override useful when the clone is not in the default location.

Preview the installation without changing home files, then apply it:

```bash
cd "$VIM_RUNTIME"
./install_awesome_configs.sh --help
./install_awesome_configs.sh --dry-run
./install_awesome_configs.sh --force
```

With existing managed files, an interactive run without `--force` prints the replacement targets and asks `Continue? [y/N]`; only `y` or `Y` proceeds. In a non-interactive shell, replacement requires `--force`. The `--force` option skips that confirmation prompt. The `--dry-run` option makes no home-directory changes and is safe to use for review.

Backups cover exactly five managed targets and record each target's state in a manifest:

| Target | Installation behavior |
| --- | --- |
| `~/.bashrc` | Adds or updates the source line for `my_bashrc.sh`. |
| `~/.vimrc` | Replaces the generated Vim entrypoint. Do not edit it directly. |
| `~/.tmux.conf` | Replaces the link with a link to the repository Tmux config. |
| `~/.tmux.conf.local` | Replaces the link with the repository local override. |
| `~/.ctags` | A user file is backed up but preserved, not replaced. |

### Backups and manifests

Before replacement, existing targets are copied into a timestamped directory under `backup/YYYYMMDD-HHMMSS`. If that timestamp already exists, the installer adds a numeric suffix to keep the backup distinct. The `manifest` lists all five managed targets as `present` or `absent`, so restoration can also remove a target that did not exist in the saved version.

List available versions and their manifest entries without changing home files:

```bash
./install_awesome_configs.sh --list-backups
```

### Restoration

Use a version printed by `--list-backups` with `--restore VERSION`:

```bash
VERSION="YYYYMMDD-HHMMSS"  # Replace with a listed backup version.
./install_awesome_configs.sh --restore "$VERSION"
```

An interactive restore shows the entries and asks for confirmation. Non-interactive restoration requires `--force`:

```bash
./install_awesome_configs.sh --restore "$VERSION" --force
```

The installer validates the version format and backup directory, then creates a new timestamped pre-restore backup of the current state before restoring the selected version. Manifest entries marked `present` are restored; entries marked `absent` are removed from the home directory. A dry-run restore previews this process without changing home files:

```bash
./install_awesome_configs.sh --dry-run --restore "$VERSION"
```

An existing user `.ctags` file is included in the backup manifest and backup copy but is preserved during normal installation. The only exception is a legacy runtime-owned `~/.ctags` symlink whose target is exactly `$VIM_RUNTIME/ctags/.ctags`; the installer migrates this legacy Ctags link by removing that runtime-owned link. An unrelated user `.ctags` file or symlink is not replaced.

`--list-backups` and `--restore VERSION` cannot be combined. `--restore` must receive a valid version argument; an unknown option or missing argument exits with an error.

## ✅ Verify the Installation

**Status:** Verify locally after installation

Confirm that the repository's Markdown parses cleanly and use the repository checks when you need a broader regression signal:

```bash
pandoc --from=gfm --to=html5 README.md >/dev/null
bash tests/run_tests.sh
./util/doctor
```

For a minimal headless Vim load check, use:

```bash
vim -Nu NONE -n -es \
    -c 'set rtp+=.' \
    -c 'source vimrcs/basic.vim' \
    -c 'source vimrcs/filetypes.vim' \
    -c 'source vimrcs/plugins_config.vim' \
    -c 'qa!'
```

### CI checks

The `Validate` workflow runs on pushes to `main` or `master` and on pull requests. Its parallel Ctags matrix has two rows:

| Matrix row | Debian package | Declared binary |
| --- | --- | --- |
| Universal | `universal-ctags` | `ctags-universal` |
| Exuberant | `exuberant-ctags` | `ctags-exuberant` |

Each row installs ShellCheck, Vim, Tmux, and its Ctags package; requires the declared binary; runs ShellCheck with error severity; runs `CTAGS=<matrix binary> bash tests/run_tests.sh`; installs into a temporary home and runs `./util/doctor`; and checks missing or unknown Ctags diagnostics, including that the selector is not passed through to the child process.

## 🧭 Daily Usage

**Status:** Keyboard-driven workflow

Open a shell, start Tmux when you need persistent panes, edit with Vim, and use tags to jump through a codebase. The default workflow is intentionally composable: each tool can still be used on its own.

```bash
tmux
vim path/to/file
tags -R .
```

The configured prefix, pane navigation, clipboard behavior, tags workflow, and diagnostic utility are documented in the detailed reference sections below as this guide evolves.

### Tmux

The installer creates home symlinks for both `~/.tmux.conf` and `~/.tmux.conf.local`. The repository files behind those links are `tmux_config/.tmux.conf` and `tmux_config/.tmux.conf.local`. Treat `tmux_config/.tmux.conf.local` as the customization boundary: keep personal Tmux overrides there and leave the generated home symlinks and main configuration intact.

The configured GNU Screen-compatible prefix is `C-a`; the upstream `C-b` prefix remains available as well. Mouse mode is enabled by default. In copy mode, `<prefix> + Enter` enters selection mode and the vi-style `v` and `y` keys select and copy. The Linux `y` binding is conditional: `xsel` is used when available, `xclip` is used only when `xsel` is absent, and an independently checked `wl-copy` binding can override that binding when both X11 and Wayland helpers are present. Install whichever optional helper matches the session: `xsel`, `xclip`, or `wl-copy`. Without one of these commands, Tmux can still keep and paste its own buffer, but OS clipboard integration is not available. Automatic copy-on-selection is disabled by default by `tmux_conf_copy_to_os_clipboard=false`.

Useful everyday bindings include:

| Binding | Action |
| --- | --- |
| `<prefix> + r` | Reload the main Tmux configuration. |
| `<prefix> + e` | Open the `.tmux.conf.local` customization file and reload after editing. |
| `<prefix> + m` | Toggle mouse mode. |
| `<prefix> + -` / `<prefix> + _` | Split the current window vertically / horizontally. |
| `<prefix> + h`, `j`, `k`, `l` | Move between panes. |
| `<prefix> + C-c` | Create a new session. |

TPM plugin declarations belong in `tmux_config/.tmux.conf.local` and use this syntax, with the plugin name replaced as needed:

```tmux
set -g @plugin 'tmux-plugins/tmux-copycat'
```

The configuration provides its own TPM integration and bindings:

- `<prefix> + I` installs declared plugins.
- `<prefix> + u` updates declared plugins.
- `<prefix> + Alt + u` uninstalls plugins that are no longer declared.

Do not add the TPM initialization lines to any configuration file. In particular, do not add a `set -g @plugin` entry whose value is `tmux-plugins/tpm`, and do not invoke the TPM script at `~/.tmux/plugins/tpm/tpm`; the local configuration handles that initialization.

### Ctags and tag navigation

The repository keeps separate version-specific profiles:

| Implementation | Profile |
| --- | --- |
| Universal Ctags | `ctags/ctags-universal.ctags` |
| Exuberant Ctags | `ctags/ctags-exuberant.ctags` |

Use `util/ctags-runtime` as the Ctags entry point. It probes the executable selected by `CTAGS` (or the default `ctags` command), accepts Universal Ctags or Exuberant Ctags, and applies the matching profile without changing a user's `.ctags` file. For an explicit selection, use a command such as:

```bash
CTAGS="$(command -v ctags-universal)" ./util/ctags-runtime --version
```

The Bash setup provides a `tags` alias that uses this wrapper and recursive generation. From a project root, the practical form is:

```bash
tags -R .
```

Vim can then follow a tag with `<C-]>` and return with `<C-T>`. If multiple Ctags implementations are installed, set `CTAGS` explicitly before invoking `tags` or the wrapper and verify that the selected executable is supported.

### Runtime diagnostics

From the repository root, run the read-only health check before troubleshooting an installation or changing a customization file:

```bash
./util/doctor
```

`util/doctor` checks required repository files and executables, the two Tmux home symlinks, the generated Vim configuration, and Ctags wrapper/profile behavior. It only uses a temporary diagnostic fixture for its checks; it does not install or restore files. The successful result ends with the exact line `doctor: all checks passed`. Use `./util/doctor --help` or `./util/doctor --version` to inspect its supported interface.

## 🎨 Personalization

**Status:** Customize only the documented boundaries

Keep personal changes in `personalized.vim`, `personalized.sh`, and `tmux_config/.tmux.conf.local`. Add user plugins under `my_plugins/`, and keep optional host-specific values in the optional untracked `secret.sh` file. Do not commit credentials or machine-specific values from either local file.

### Bash

The installed `~/.bashrc` sources `my_bashrc.sh`, which resolves and exports `VIM_RUNTIME`. It sets the colored shell prompt in `PS1`, selects `TERM=xterm-256color`, and provides these representative aliases: `ls`, `ll`, `l1`, `python`, `grep`, `bgrep`, and `tags`. It also appends `$VIM_RUNTIME/fun` to `PATH` once, without duplicating the entry on subsequent shell loads.

Put interactive Bash preferences in `$VIM_RUNTIME/personalized.sh`:

```bash
# Example local Bash preferences.
export EDITOR=vim
alias croot='cd "$VIM_RUNTIME"'
```

`my_bashrc.sh` sources `personalized.sh` when that file exists. It then optionally sources `$VIM_RUNTIME/secret.sh` when present; `secret.sh` is an untracked, host-specific boundary for values that must not enter version control. Keep that file local and review its contents before sourcing the checkout on another machine.

### Vim and generated files

Installation creates or updates these runtime-facing files:

| File | Role | Personalization boundary |
| --- | --- | --- |
| `~/.vimrc` | Generated Vim entrypoint. | Do not edit this generated file. |
| `~/.bashrc` | Contains the source line for `my_bashrc.sh`. | Keep Bash changes in `personalized.sh`. |
| `~/.tmux.conf` and `~/.tmux.conf.local` | Links to the repository Tmux files. | Use `tmux_config/.tmux.conf.local`. |
| `$VIM_RUNTIME/personalized.vim` and `personalized.sh` | Created when missing for local settings. | Add your own settings here. |
| `$VIM_RUNTIME/temp_dirs/undodir` | Runtime directory for Vim undo data. | Do not replace it with generated config. |

The generated `~/.vimrc` contains the runtime path and sources the Vim configuration in this exact order:

```text
basic.vim -> filetypes.vim -> plugins_config.vim -> extended.vim -> my_configs.vim
```

The generated file begins with this boundary marker:

```text
DO NOT EDIT THIS FILE
```

Do not edit generated `~/.vimrc`; put Vim preferences in `$VIM_RUNTIME/personalized.vim`. `my_configs.vim` sources `personalized.vim` before its remaining repository defaults. Warning: Later defaults may override conflicting personalized options from `personalized.vim`. Personalized settings do not always win; verify the effective value in Vim after each change.

The Vim leader key is a comma. Representative mappings include:

| Mapping | Action |
| --- | --- |
| `<leader>w` | Save the current file with `:w!`. |
| `<leader>h` / `<leader>l` | Move to the previous / next buffer. |
| `<leader>tn` | Open a new tab. |
| `<leader>bd` | Close the current buffer and tab. |
| `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` | Move between Vim windows. |
| `<C-]>` | Jump to the tag under the cursor. |

For tags navigation, run `tags -R .` from the project root. Vim searches `./tags`, `tags`, and configured parent directories; `<C-]>` follows a matching tag and the normal Vim `<C-T>` command returns to the previous tag location.

The Vim editing colorscheme is `tender`, selected by Vim's `colorscheme tender` command. The Lightline status bar has its separate `wombat` colorscheme. These names have different roles: changing Lightline's `wombat` value does not select Vim's editor colorscheme. To try another installed Vim colorscheme, add a `colorscheme NAME` line to `personalized.vim`, then check the effective `:colorscheme` value after startup because later defaults can replace it.

## 🧩 Plugins and Language Support

**Status:** Existing repository support

Pathogen loads the runtime areas in this order:

```text
sources_forked -> sources_non_forked -> lang_plugin/basic -> my_plugins
```

The feature reference separates Vim filetype detection from Ctags parser extensions.

### Pathogen runtime and user plugins

Pathogen registers these runtime roots in this exact order:

```text
sources_forked -> sources_non_forked -> lang_plugin/basic -> my_plugins
```

The order controls which runtime files are found when names overlap. Put a user-managed plugin under `my_plugins/`; the directory is already included in the final Pathogen root. Do not add a second runtime root or duplicate plugin initialization just to install an existing plugin from this configuration.

| Configured plugin | Role in this runtime | Representative mapping or setting |
| --- | --- | --- |
| bufExplorer | Browse open buffers. | `<leader>o` runs `:BufExplorer`. |
| MRU | Open recently used files. | `<leader>f` runs `:MRU`. |
| YankStack | Reuse older or newer yanks. | `<C-p>` / `<C-n>` select the paste history. |
| CtrlP | Find files and buffers. | `<leader>j` opens files; `<leader>b` opens buffers. |
| ZenCoding | Expand HTML or markup abbreviations. | `g:user_zen_mode` is set to all modes. |
| snipMate | Expand snippets. | Insert-mode `<C-j>` triggers a snippet. |
| NERDTree | Browse the filesystem. | `<leader>nn` toggles; `<leader>nf` finds the current file. |
| vim-multiple-cursors | Select and edit repeated words. | `<C-s>` starts or advances; `<C-x>` skips. |
| surround.vim | Add or change surrounding characters. | Visual `Si` applies the configured surround action. |
| Lightline | Show mode, file, VCS, and line information. | Its status-bar colorscheme is `wombat`. |
| Goyo (Vimroom) | Enter a focused writing view. | `<leader>z` runs `:Goyo`. |
| ALE | Lint JavaScript, Python, and Go. | `<leader>a` goes to the next ALE item. |
| Git Gutter | Toggle Git diff signs. | `<leader>d` runs `:GitGutterToggle`. |
| EditorConfig | Apply project-specific EditorConfig rules. | Fugitive buffers are excluded. |
| Taglist | Display tags using the configured Ctags command. | The plugin uses `util/ctags-runtime`. |

These are configured plugins already present in this checkout. This table is a reference, not a recommendation to add more plugins.

### Vim filetype detection and language hooks

The following hooks are Vim filetype behavior. Filetype detection and syntax hooks are separate from the Ctags parser extension list below.

| Language or filetype | Detection or event | Configured behavior |
| --- | --- | --- |
| Python | `FileType python` | Python highlighting, indent folding via `F`, and insert abbreviations. |
| JavaScript | `FileType javascript` | Syntax folding, folding enabled, and JavaScript insert helpers. |
| TypeScript | `FileType typescript` | Shared JavaScript/TypeScript insert helpers for `console.log()` and `alert()`. |
| CoffeeScript | `FileType coffee` | Indent folding starts at level 1. |
| SystemVerilog | `*.v` and `*.sv` become `systemverilog`. | Loads the repository syntax hook and AutoPairs. |
| Tcl | `*.f`, `*.sdc`, and `*.tcl` become `tcl`. | Loads the repository Tcl hook. |
| Log | `*.log`, `*_log`, `*.LOG`, and `*_LOG` become `log`. | Loads the repository log hook. |

### Ctags parser extensions

This is a separate parser contract, used by the Taglist wrapper and tag generation. The SystemVerilog profile recognizes these extensions; the values below are Ctags extensions, not Vim filetype glob patterns:

| Ctags extension | Parser |
| --- | --- |
| `v` | SystemVerilog |
| `vh` | SystemVerilog |
| `sv` | SystemVerilog |
| `svh` | SystemVerilog |
| `svi` | SystemVerilog |

The Universal and Exuberant profiles both map `v`, `vh`, `sv`, `svh`, and `svi` to SystemVerilog. Vim's `*.v` and `*.sv` detection above is intentionally documented in a different table so the editor and parser contracts are not conflated.

### Colorscheme catalog

The catalog below preserves the existing scheme names and source links. `Terminal` and `GUI` indicate the environments covered by the original catalog; `—` means that the row describes the Lightline role rather than a Vim editor colorscheme.

Older guidance that pointed to a specific line in `my_configs.vim` is stale because line numbers move. Select a Vim editor scheme through `personalized.vim` and verify the effective `:colorscheme` value. In this configuration, Vim's editor scheme is `tender`, while Lightline's independent status-bar scheme is `wombat`.

| Scheme | Description | Terminal | GUI |
| --- | --- | :---: | :---: |
| [256noir] | Dark minimal colors. | ✓ | ✓ |
| [abstract] | Dark theme based on Abstract. | ✓ | ✓ |
| [afterglow] | Adaptation from Sublime Text. | ✓ | ✓ |
| [alduin] | Dark rustic colors. | ✓ | ✓ |
| [anderson] | Colors inspired by Wes Anderson films. | ✓ | ✓ |
| [angr] | Pleasant, mild, dark theme. | ✓ | ✓ |
| [ayu-vim] | Simple, bright, elegant theme. | — | ✓ |
| [Apprentice] | Dark, low-contrast colorscheme. | ✓ | ✓ |
| [Archery] | Colors inspired by Arch Linux. | ✓ | ✓ |
| [Atom] | Readable in light and dark environments. | — | ✓ |
| [carbonized] | Inspired by the Carbon keycap set. | ✓ (16) | ✓ |
| [challenger-deep] | FlatColor colorscheme. | ✓ | ✓ |
| [deep-space] | Intergalactic scheme based on Hybrid. | ✓ | ✓ |
| [deus] | Theme for late-night coding. | ✓ | ✓ |
| [dogrun] | Dark purple theme. | ✓ | ✓ |
| [flattened] | Solarized-inspired flat theme. | ✓ (16) | ✓ |
| [focuspoint] | Emphasizes coordinated highlights. | — | ✓ |
| [fogbell] | Minimal grey monotone with variants. | ✓ | ✓ |
| [github] | Based on GitHub syntax highlighting. | ✓ | ✓ |
| [gotham] | Very dark Vim colorscheme. | ✓ | ✓ |
| [gruvbox] | Retro groove color scheme. | ✓ | ✓ |
| [happy hacking] | Small, restrained color set. | ✓ | ✓ |
| [Iceberg] | Dark blue color scheme. | ✓ | ✓ |
| [papercolor] | Material-inspired light and dark scheme. | ✓ | ✓ |
| [parsec] | Scheme for people tired of Solarized. | ✓ (16) | ✓ |
| [scheakur] | Light and dark colorscheme. | ✓ | ✓ |
| [hybrid] | Dark color scheme for Vim and gVim. | ✓ | ✓ |
| [hybrid-material] | Material colors based on vim-hybrid. | ✓ | ✓ |
| [jellybeans] | Colorful, dark color scheme. | ✓ | ✓ |
| [lightning] | Light scheme based on Apprentice. | ✓ | ✓ |
| [lucid] | Vivid and clear colors. | — | ✓ |
| [lucius] | Lucius color scheme. | ✓ | ✓ |
| [materialbox] | Material palette inspired by Gruvbox. | — | ✓ |
| [meta5] | Dark colorscheme inspired by Tron. | ✓ | ✓ |
| [minimalist] | Dark material theme inspired by Sublime Text. | ✓ | ✓ |
| [molokai] | Molokai color scheme. | ✓ | ✓ |
| [molokayo] | Tweaked Molokai-based theme. | ✓ | ✓ |
| [mountaineer] | Dark and adventurous theme. | ✓ | ✓ |
| [nord] | Arctic, north-bluish clean theme. | ✓ (16) | ✓ |
| [oceanicnext] | Oceanic Next theme. | ✓ | ✓ |
| [oceanic-material] | Material dark colorscheme. | ✓ | ✓ |
| [one] | One-light and One-dark adaptation. | ✓ | ✓ |
| [onedark] | Atom One Dark-inspired theme. | ✓ | ✓ |
| [onehalf] | Clean, vibrant color scheme. | ✓ | ✓ |
| [orbital] | Dark blue base16 theme. | ✓ | ✓ |
| [paramount] | Minimal emphasis-focused colorscheme. | ✓ | ✓ |
| [pink-moon] | Dark pastel theme. | ✓ | ✓ |
| [purify] | Clean and vibrant Vim colors. | ✓ | ✓ |
| [pyte] | Clean, nearly white theme. | — | ✓ |
| [rdark-terminal2] | Visibility-focused terminal theme. | ✓ | — |
| [seoul256] | Low-contrast Seoul Colors scheme. | ✓ | ✓ |
| [sierra] | Dark vintage colors. | ✓ | ✓ |
| [solarized8] | Optimized Solarized colorschemes. | ✓ (16) | ✓ |
| [sonokai] | Vivid, high-contrast Monokai Pro style. | ✓ | ✓ |
| [space-vim-dark] | Dark magenta colors. | ✓ | ✓ |
| [spacecamp] | Colors for the final frontier. | ✓ | ✓ |
| [sunbather] | Minimal pink colorscheme. | ✓ | ✓ |
| [tender] | 24-bit colorscheme for Vim. | ✓ | ✓ |
| [wombat] | Lightline status role, not Vim's editor scheme. | — | — |
| [termschool] | Codeschool-inspired theme with tweaks. | ✓ | ✓ |
| [twilight256] | Twilight theme for TextMate. | ✓ | ✓ |
| [two-firewatch] | Duotone light and Firewatch blend. | ✓ | ✓ |
| [wombat256] | Wombat for 256-color xterms. | ✓ | ✓ |
| [monokai] | Monokai color scheme. | ✓ | ✓ |

The catalog source is [rafi/awesome-vim-colorschemes]. These links point to the existing scheme sources and do not add runtime dependencies.

[rafi/awesome-vim-colorschemes]: https://github.com/rafi/awesome-vim-colorschemes.git
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
[Iceberg]: https://github.com/cocopon/iceberg.vim
[papercolor]: https://github.com/NLKNguyen/papercolor-theme
[parsec]: https://github.com/keith/parsec.vim
[scheakur]: https://github.com/scheakur/vim-scheakur
[hybrid]: https://github.com/w0ng/vim-hybrid
[hybrid-material]: https://github.com/kristijanhusak/vim-hybrid-material
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
[wombat]: https://github.com/itchyny/lightline.vim
[termschool]: https://github.com/marcopaganini/termschool-vim-theme
[twilight256]: https://github.com/vim-scripts/twilight256.vim
[two-firewatch]: https://github.com/rakr/vim-two-firewatch
[wombat256]: https://github.com/vim-scripts/wombat256.vim
[monokai]: https://github.com/ku1ik/vim-monokai.git

## 🩺 Troubleshooting

**Status:** Diagnose from observable output

Start with `./util/doctor`, rerun the installer with `--dry-run`, and inspect the newest timestamped backup before restoring anything. Check the exact command, selected Ctags implementation, and active checkout path when behavior differs from this guide.

| Symptom | Diagnosis and next action |
| --- | --- |
| A command or dependency is missing | Install `bash`, `vim`, `tmux`, and a supported Ctags implementation; CI also requires ShellCheck. Rerun `./util/doctor`. |
| Ctags is unsupported | Run `./util/ctags-runtime --version`, then set `CTAGS` to a Universal Ctags or Exuberant Ctags executable and retry. |
| `--force` is required in a non-interactive shell | Existing files require confirmation interactively. In automation, review `--dry-run` output first, then use `./install_awesome_configs.sh --force` to skip the prompt. |
| Restore fails | Use `./install_awesome_configs.sh --list-backups`, pass an existing `YYYYMMDD-HHMMSS` version to `--restore`, and use `--dry-run` before `--force`. Check that no home target is a directory. |
| A generated file or source boundary is confusing | Do not edit generated `~/.vimrc`; put Vim settings in `$VIM_RUNTIME/personalized.vim`, Bash settings in `personalized.sh`, and Tmux overrides in `tmux_config/.tmux.conf.local`. |
| Tmux clipboard helpers are unavailable | Install the session-appropriate `xsel`, `xclip`, or `wl-copy`. Without them, Tmux's own buffer still works but OS clipboard integration does not. |
| A setting is not effective | Check source order and the documented personalization boundary; later defaults may override a personalized option. |
| Tags behave differently across systems | Check the `CTAGS` implementation and version-specific profile. |

## 📄 License

**Status:** Authoritative license reference

This project is distributed under the [MIT License](LICENSE). The repository's `LICENSE` file is the authoritative source for the complete terms.
