#!/usr/bin/env bash
###############################################################################
# Copyright (C) 2026 by Donghun Jeong. All right reserved.
#
# Basic Information
# |--------------|----------------------------------------------------------|
# | File Name    | run_tests.sh                                            |
# |--------------|----------------------------------------------------------|
# | Description  | Run repository shell and Vim configuration checks.       |
# |--------------|----------------------------------------------------------|
# | Author       | Donghun Jeong(dounghun22)                                |
# |--------------|----------------------------------------------------------|
# | Created      | 2026-08-09                                               |
# |--------------|----------------------------------------------------------|
# | Last Modified| 2026-08-09 00:00:00                                      |
# |--------------|----------------------------------------------------------|
#
# Revision History
# |-------------------------------------------------------------------------|
# |      Date     |                    Revision Summary                     |
# |---------------|---------------------------------------------------------|
# |   2026-08-09  | Add portable installation and configuration tests.      |
# |---------------|---------------------------------------------------------|
#
# TODO, FIXME, NOTE

###############################################################################

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd -P)"
TEST_ROOT="$(mktemp -d)"
RUNTIME_DIR="$TEST_ROOT/runtime with spaces"
HOME_DIR="$TEST_ROOT/home"

cleanup() {
    rm -rf -- "$TEST_ROOT"
}

trap cleanup EXIT

mkdir -p "$RUNTIME_DIR" "$HOME_DIR"

for runtime_entry in autoload ctags fun lang_plugin my_plugins sources_forked \
    sources_non_forked tmux_config vimrcs; do
    ln -s "$ROOT_DIR/$runtime_entry" "$RUNTIME_DIR/$runtime_entry"
done

cp "$ROOT_DIR/my_bashrc.sh" "$RUNTIME_DIR/my_bashrc.sh"
cp "$ROOT_DIR/my_configs.vim" "$RUNTIME_DIR/my_configs.vim"

bash -n "$ROOT_DIR/install_awesome_configs.sh"
bash -n "$ROOT_DIR/my_bashrc.sh"
bash -n "$ROOT_DIR/tests/run_tests.sh"
sh -n "$ROOT_DIR/fun/fun"

if ! command -v rg >/dev/null 2>&1; then
    printf 'Error: rg is required to run repository tests.\n' >&2
    exit 1
fi

if rg -n --hidden \
    --glob '!.git/**' \
    --glob '!README.md' \
    --glob '!AGENTS.md' \
    --glob '!tests/**' \
    --glob '!sources_non_forked/**' \
    --glob '!sources_forked/**' \
    --glob '!my_plugins/**' \
    '~/.vim_runtime|depricated' "$ROOT_DIR"; then
    printf 'Error: maintained files contain a legacy runtime path.\n' >&2
    exit 1
fi

printf '# Existing Bash configuration\n' > "$HOME_DIR/.bashrc"
printf '# Existing Vim configuration\n' > "$HOME_DIR/.vimrc"
printf '# Existing Tmux configuration\n' > "$HOME_DIR/.tmux.conf"
printf '# Existing local Tmux configuration\n' > "$HOME_DIR/.tmux.conf.local"
printf '# Existing Ctags configuration\n' > "$HOME_DIR/.ctags"

bashrc_before="$(sha256sum "$HOME_DIR/.bashrc")"
vimrc_before="$(sha256sum "$HOME_DIR/.vimrc")"

HOME="$HOME_DIR" VIM_RUNTIME="$RUNTIME_DIR" \
    "$ROOT_DIR/install_awesome_configs.sh" --dry-run >/dev/null

[[ "$bashrc_before" == "$(sha256sum "$HOME_DIR/.bashrc")" ]]
[[ "$vimrc_before" == "$(sha256sum "$HOME_DIR/.vimrc")" ]]

HOME="$HOME_DIR" VIM_RUNTIME="$RUNTIME_DIR" \
    "$ROOT_DIR/install_awesome_configs.sh" --force >/dev/null

[[ -L "$HOME_DIR/.tmux.conf" ]]
[[ -L "$HOME_DIR/.tmux.conf.local" ]]
[[ -L "$HOME_DIR/.ctags" ]]
[[ "$(readlink "$HOME_DIR/.tmux.conf")" == "$RUNTIME_DIR/tmux_config/.tmux.conf" ]]
[[ "$(readlink "$HOME_DIR/.ctags")" == "$RUNTIME_DIR/ctags/.ctags" ]]

bashrc_source="$(printf 'source %q' "$RUNTIME_DIR/my_bashrc.sh")"
grep -Fqx "$bashrc_source" "$HOME_DIR/.bashrc"

HOME="$HOME_DIR" vim -Nu "$HOME_DIR/.vimrc" -n -es -c 'qa!'

runtime_from_bash="$(
    HOME="$HOME_DIR" VIM_RUNTIME= bash -c \
        'source "$1"; printf "%s" "$VIM_RUNTIME"' _ "$RUNTIME_DIR/my_bashrc.sh"
)"
[[ "$runtime_from_bash" == "$RUNTIME_DIR" ]]

backup_count="$(find "$RUNTIME_DIR/backup" -mindepth 1 -maxdepth 1 -type d | wc -l)"
[[ "$backup_count" -eq 1 ]]

printf 'All repository tests passed.\n'
