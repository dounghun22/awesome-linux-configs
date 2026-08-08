#!/usr/bin/env bash
###############################################################################
# Copyright (C) 2026 by Donghun Jeong. All right reserved.
#
# Basic Information
# |--------------|----------------------------------------------------------|
# | File Name    | install_awesome_configs.sh                              |
# |--------------|----------------------------------------------------------|
# | Description  | Install the runtime configuration safely.                |
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
# |   2026-08-09  | Add safe, portable, and idempotent installation.         |
# |---------------|---------------------------------------------------------|
#
# TODO, FIXME, NOTE

###############################################################################

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: ./install_awesome_configs.sh [--dry-run] [--force]

Options:
  --dry-run  Show planned changes without modifying the home directory.
  --force    Skip the confirmation prompt for existing configuration files.
  --help     Show this help message.
EOF
}

die() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

warn() {
    printf 'Warning: %s\n' "$1" >&2
}

DRY_RUN=false
FORCE=false

while (($# > 0)); do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            ;;
        --force)
            FORCE=true
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            die "Unknown option: $1"
            ;;
    esac
    shift
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
VIM_RUNTIME="${VIM_RUNTIME:-$SCRIPT_DIR}"
VIM_RUNTIME="$(cd -- "$VIM_RUNTIME" && pwd -P)" || \
    die "Runtime directory does not exist: $VIM_RUNTIME"
HOME_DIR="${HOME:?HOME must be set}"
BACKUP_ROOT="$VIM_RUNTIME/backup"
BACKUP_TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_TIMESTAMP"
BASHRC_FILE="$HOME_DIR/.bashrc"

required_files=(
    "tmux_config/.tmux.conf"
    "tmux_config/.tmux.conf.local"
    "ctags/.ctags"
    "my_configs.vim"
    "my_bashrc.sh"
)

for required_file in "${required_files[@]}"; do
    [[ -f "$VIM_RUNTIME/$required_file" ]] || \
        die "Required file is missing: $VIM_RUNTIME/$required_file"
done

missing_commands=()
for command_name in bash vim tmux ctags; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        missing_commands+=("$command_name")
    fi
done

if ((${#missing_commands[@]} > 0)); then
    missing_list="$(IFS=', '; printf '%s' "${missing_commands[*]}")"
    if [[ "$DRY_RUN" == true ]]; then
        warn "Missing commands: $missing_list"
    else
        die "Install these required commands before continuing: $missing_list"
    fi
fi

path_exists() {
    [[ -e "$1" || -L "$1" ]]
}

BASHRC_SOURCE_LINE="$(printf 'source %q' "$VIM_RUNTIME/my_bashrc.sh")"

bashrc_needs_update() {
    [[ ! -f "$BASHRC_FILE" ]] && return 0
    ! grep -Fqx "$BASHRC_SOURCE_LINE" "$BASHRC_FILE"
}

replacement_targets=()
for target in "$HOME_DIR/.tmux.conf" "$HOME_DIR/.tmux.conf.local" \
    "$HOME_DIR/.ctags" "$HOME_DIR/.vimrc"; do
    if path_exists "$target"; then
        replacement_targets+=("$target")
    fi
done

if bashrc_needs_update; then
    replacement_targets+=("$BASHRC_FILE")
fi

if [[ "$DRY_RUN" == false && "$FORCE" == false &&
    ${#replacement_targets[@]} -gt 0 ]]; then
    if [[ ! -t 0 ]]; then
        die "Existing configuration found; rerun with --force in non-interactive mode"
    fi

    printf 'The following files will be backed up and replaced or updated:\n'
    printf '  %s\n' "${replacement_targets[@]}"
    read -r -p 'Continue? [y/N] ' answer
    [[ "$answer" =~ ^[Yy]$ ]] || die "Installation cancelled"
fi

while [[ -e "$BACKUP_DIR" ]]; do
    BACKUP_DIR="$BACKUP_ROOT/$BACKUP_TIMESTAMP-${RANDOM}"
done

backup_target() {
    local target="$1"
    local backup_name="${target##*/}"

    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry-run] backup %s -> %s\n' "$target" "$BACKUP_DIR/$backup_name"
        return
    fi

    mkdir -p "$BACKUP_DIR"
    cp -a -- "$target" "$BACKUP_DIR/$backup_name"
}

backup_existing_targets() {
    local target

    for target in "${replacement_targets[@]}"; do
        if path_exists "$target"; then
            backup_target "$target"
        fi
    done
}

create_if_missing() {
    local target="$1"

    if [[ -e "$target" ]]; then
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry-run] create %s\n' "$target"
    else
        : > "$target"
    fi
}

ensure_directory() {
    local target="$1"

    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry-run] mkdir -p %s\n' "$target"
    else
        mkdir -p "$target"
    fi
}

replace_with_symlink() {
    local source="$1"
    local target="$2"

    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry-run] link %s -> %s\n' "$target" "$source"
    else
        ln -sfn -- "$source" "$target"
    fi
}

update_bashrc() {
    local temporary_file

    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry-run] update %s with: %s\n' "$BASHRC_FILE" "$BASHRC_SOURCE_LINE"
        return
    fi

    if [[ ! -f "$BASHRC_FILE" ]]; then
        printf '%s\n' "$BASHRC_SOURCE_LINE" > "$BASHRC_FILE"
        return
    fi

    temporary_file="$(mktemp "$HOME_DIR/.bashrc.vim-runtime.XXXXXX")"
    trap 'rm -f -- "$temporary_file"' RETURN
    grep -Ev '^[[:space:]]*(source|\.)[[:space:]].*/my_bashrc\.sh[[:space:]]*$' \
        "$BASHRC_FILE" > "$temporary_file" || true
    printf '%s\n' "$BASHRC_SOURCE_LINE" >> "$temporary_file"
    mv -- "$temporary_file" "$BASHRC_FILE"
    trap - RETURN
}

write_vimrc() {
    local escaped_runtime

    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry-run] write %s\n' "$HOME_DIR/.vimrc"
        return
    fi

    escaped_runtime="${VIM_RUNTIME//\'/\'\'}"
    cat > "$HOME_DIR/.vimrc" <<EOF
" DO NOT EDIT THIS FILE
" Add your own customizations in personalized.vim and personalized.sh.

let g:vim_runtime_path = '$escaped_runtime'
execute 'set runtimepath^=' . fnameescape(g:vim_runtime_path)
execute 'source ' . fnameescape(g:vim_runtime_path . '/vimrcs/basic.vim')
execute 'source ' . fnameescape(g:vim_runtime_path . '/vimrcs/filetypes.vim')
execute 'source ' . fnameescape(g:vim_runtime_path . '/vimrcs/plugins_config.vim')
execute 'source ' . fnameescape(g:vim_runtime_path . '/vimrcs/extended.vim')
execute 'source ' . fnameescape(g:vim_runtime_path . '/my_configs.vim')
EOF
}

printf 'Runtime directory: %s\n' "$VIM_RUNTIME"
printf 'Home directory: %s\n' "$HOME_DIR"

backup_existing_targets

create_if_missing "$VIM_RUNTIME/personalized.sh"
create_if_missing "$VIM_RUNTIME/personalized.vim"
ensure_directory "$VIM_RUNTIME/temp_dirs/undodir"

replace_with_symlink "$VIM_RUNTIME/tmux_config/.tmux.conf" "$HOME_DIR/.tmux.conf"
replace_with_symlink "$VIM_RUNTIME/tmux_config/.tmux.conf.local" \
    "$HOME_DIR/.tmux.conf.local"
replace_with_symlink "$VIM_RUNTIME/ctags/.ctags" "$HOME_DIR/.ctags"
update_bashrc
write_vimrc

if [[ "$DRY_RUN" == true ]]; then
    printf '[dry-run] chmod +x %s/fun/*\n' "$VIM_RUNTIME"
else
    chmod +x "$VIM_RUNTIME"/fun/*
fi

if [[ "$DRY_RUN" == true ]]; then
    printf 'Dry run completed; no files were modified.\n'
else
    printf 'Installation completed successfully.\n'
    printf 'Backups: %s\n' "$BACKUP_DIR"
fi
