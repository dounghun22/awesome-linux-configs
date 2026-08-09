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
# | Last Modified| 2026-08-09 16:09:18                                      |
# |--------------|----------------------------------------------------------|
#
# Revision History
# |-------------------------------------------------------------------------|
# |      Date     |                    Revision Summary                     |
# |---------------|---------------------------------------------------------|
# |   2026-08-09  | Add safe, portable, and idempotent installation.         |
# |   2026-08-09  | Preflight generated Vim load-graph files.                 |
# |   2026-08-09  | Preflight the repository Ctags runtime wrapper.           |
# |   2026-08-09  | Back up user Ctags config without replacing it.            |
# |   2026-08-09  | Replace .vimrc symlinks without following their referents. |
# |   2026-08-09  | Remove only legacy runtime-owned Ctags selector links.    |
# |   2026-08-09  | Add versioned backup listing and restoration.             |
# |---------------|---------------------------------------------------------|
#
# TODO, FIXME, NOTE

###############################################################################

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: ./install_awesome_configs.sh [options]

Options:
  --dry-run  Show planned changes without modifying the home directory.
  --force    Skip the confirmation prompt for existing configuration files.
  --list-backups
             List available timestamped backup versions.
  --restore VERSION
             Restore a backup version after saving the current state.
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
LIST_BACKUPS=false
RESTORE_VERSION=''

while (($# > 0)); do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            ;;
        --force)
            FORCE=true
            ;;
        --list-backups)
            LIST_BACKUPS=true
            ;;
        --restore)
            (($# >= 2)) || die "--restore requires a backup version"
            [[ -z "$RESTORE_VERSION" ]] || die "--restore may be used only once"
            RESTORE_VERSION="$2"
            shift
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

if [[ "$LIST_BACKUPS" == true && -n "$RESTORE_VERSION" ]]; then
    die "--list-backups and --restore cannot be combined"
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
VIM_RUNTIME="${VIM_RUNTIME:-$SCRIPT_DIR}"
VIM_RUNTIME="$(cd -- "$VIM_RUNTIME" && pwd -P)" || \
    die "Runtime directory does not exist: $VIM_RUNTIME"
HOME_DIR="${HOME:?HOME must be set}"
BACKUP_ROOT="$VIM_RUNTIME/backup"
BACKUP_TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_TIMESTAMP"
BASHRC_FILE="$HOME_DIR/.bashrc"
BACKUP_TARGET_NAMES=(.bashrc .vimrc .tmux.conf .tmux.conf.local .ctags)

backup_version_is_valid() {
    [[ "$1" =~ ^[0-9]{8}-[0-9]{6}(-[0-9]+)?$ ]]
}

list_backups() {
    local backup_dir version manifest state name
    local -a backup_dirs=()

    if [[ ! -d "$BACKUP_ROOT" ]]; then
        printf 'No backup versions found in %s\n' "$BACKUP_ROOT"
        return 0
    fi

    mapfile -t backup_dirs < <(
        find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -print | sort
    )
    for backup_dir in "${backup_dirs[@]}"; do
        version="${backup_dir##*/}"
        backup_version_is_valid "$version" || continue
        printf '%s\n' "$version"
        manifest="$backup_dir/manifest"
        if [[ -f "$manifest" ]]; then
            while IFS=$'\t' read -r state name; do
                case "$state" in
                    present|absent)
                        printf '  %s: %s\n' "$name" "$state"
                        ;;
                esac
            done < "$manifest"
        else
            find "$backup_dir" -mindepth 1 -maxdepth 1 \
                \( -type f -o -type l \) -printf '  %f: present\n' | sort
        fi
    done
}

if [[ "$LIST_BACKUPS" == true ]]; then
    list_backups
    exit 0
fi

required_files=(
    "tmux_config/.tmux.conf"
    "tmux_config/.tmux.conf.local"
    # CODEX MODIFIED: 2026-08-09 12:30:00 KST. Require isolated Ctags profiles.
    "ctags/ctags-universal.ctags"
    "ctags/ctags-exuberant.ctags"
    "fun/ctags-runtime"
    # CODEX MODIFIED: 2026-08-09 11:31:00 KST. Preflight generated Vim sources.
    "vimrcs/basic.vim"
    "vimrcs/filetypes.vim"
    "vimrcs/plugins_config.vim"
    "vimrcs/extended.vim"
    "my_configs.vim"
    "autoload/pathogen.vim"
    "lang_plugin/verilog_systemverilog/syntax/verilog_systemverilog.vim"
    "lang_plugin/tcl/tcl.vim"
    "lang_plugin/log/log.vim"
    "my_bashrc.sh"
)

for required_file in "${required_files[@]}"; do
    [[ -f "$VIM_RUNTIME/$required_file" ]] || \
        die "Required file is missing: $VIM_RUNTIME/$required_file"
done

missing_commands=()
for command_name in bash vim tmux; do
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

# CODEX ADDED: 2026-08-09 12:30:00 KST. Resolve and validate one Ctags executable.
CTAGS_COMMAND="${CTAGS:-ctags}"
CTAGS_PATH="$(type -P -- "$CTAGS_COMMAND" || true)"
if [[ -z "$CTAGS_PATH" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        warn "Ctags executable not found: $CTAGS_COMMAND (set CTAGS to its path)"
    else
        die "Ctags executable not found: $CTAGS_COMMAND (set CTAGS to its path)"
    fi
else
    export CTAGS="$CTAGS_PATH"
    if ! "$VIM_RUNTIME/fun/ctags-runtime" --version >/dev/null; then
        die "CTAGS must select Universal Ctags or Exuberant Ctags: $CTAGS_PATH"
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
# CODEX MODIFIED: 2026-08-09 12:30:00 KST. Preserve the user's .ctags file.
for target in "$HOME_DIR/.tmux.conf" "$HOME_DIR/.tmux.conf.local" \
    "$HOME_DIR/.vimrc"; do
    if path_exists "$target"; then
        replacement_targets+=("$target")
    fi
done

# CODEX MODIFIED: 2026-08-09 14:25:00 KST. Migrate only the legacy Ctags selector link.
legacy_ctags_link=false
backup_only_targets=()
if [[ -L "$HOME_DIR/.ctags" &&
    "$(readlink -- "$HOME_DIR/.ctags")" == "$VIM_RUNTIME/ctags/.ctags" ]]; then
    legacy_ctags_link=true
    replacement_targets+=("$HOME_DIR/.ctags")
elif path_exists "$HOME_DIR/.ctags"; then
    backup_only_targets+=("$HOME_DIR/.ctags")
fi

if bashrc_needs_update; then
    replacement_targets+=("$BASHRC_FILE")
fi

if [[ -z "$RESTORE_VERSION" && "$DRY_RUN" == false && "$FORCE" == false &&
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

    for target in "${replacement_targets[@]}" "${backup_only_targets[@]}"; do
        if path_exists "$target"; then
            backup_target "$target"
        fi
    done
}

# CODEX ADDED: 2026-08-09 16:09:18 KST. Record each managed target's backup state.
write_backup_manifest() {
    local manifest temporary_file name state version

    [[ -d "$BACKUP_DIR" ]] || return 0
    manifest="$BACKUP_DIR/manifest"
    version="${BACKUP_DIR##*/}"
    temporary_file="$(mktemp "$BACKUP_DIR/.manifest.XXXXXX")"
    trap 'rm -f -- "$temporary_file"' RETURN
    {
        printf 'version\t%s\n' "$version"
        for name in "${BACKUP_TARGET_NAMES[@]}"; do
            if path_exists "$HOME_DIR/$name"; then
                state=present
            else
                state=absent
            fi
            printf '%s\t%s\n' "$state" "$name"
        done
    } > "$temporary_file"
    mv -- "$temporary_file" "$manifest"
    trap - RETURN
}

backup_current_state() {
    local name target

    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry-run] create backup version %s\n' "${BACKUP_DIR##*/}"
    else
        mkdir -p "$BACKUP_DIR"
    fi

    for name in "${BACKUP_TARGET_NAMES[@]}"; do
        target="$HOME_DIR/$name"
        if path_exists "$target"; then
            backup_target "$target"
        fi
    done

    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry-run] write backup manifest %s/manifest\n' "$BACKUP_DIR"
    else
        write_backup_manifest
    fi
}

restore_state_for() {
    local name="$1" manifest="$RESTORE_DIR/manifest" source

    if [[ -f "$manifest" ]]; then
        if grep -Fqx $'present\t'"$name" "$manifest"; then
            printf 'present\n'
        elif grep -Fqx $'absent\t'"$name" "$manifest"; then
            printf 'absent\n'
        else
            die "Backup manifest is missing a valid state for $name"
        fi
        return
    fi

    source="$RESTORE_DIR/$name"
    if path_exists "$source"; then
        printf 'present\n'
    else
        printf 'unknown\n'
    fi
}

validate_restore_backup() {
    local name target source state
    RESTORE_DIR="$BACKUP_ROOT/$RESTORE_VERSION"
    backup_version_is_valid "$RESTORE_VERSION" || \
        die "Invalid backup version: $RESTORE_VERSION"
    [[ -d "$RESTORE_DIR" ]] || die "Backup version not found: $RESTORE_VERSION"

    RESTORE_ENTRIES=()
    for name in "${BACKUP_TARGET_NAMES[@]}"; do
        state="$(restore_state_for "$name")"
        target="$HOME_DIR/$name"
        source="$RESTORE_DIR/$name"
        case "$state" in
            present)
                [[ -f "$source" || -L "$source" ]] || \
                    die "Backup entry is not a file or symlink: $source"
                ;;
            absent|unknown)
                ;;
            *)
                die "Unsupported backup state for $name: $state"
                ;;
        esac
        if [[ -d "$target" && ! -L "$target" ]]; then
            die "Cannot restore over a directory: $target"
        fi
        [[ "$state" != unknown ]] || continue
        RESTORE_ENTRIES+=("$state:$name")
    done

    ((${#RESTORE_ENTRIES[@]} > 0)) || \
        die "Backup version contains no restorable managed files: $RESTORE_VERSION"
}

confirm_restore() {
    local entry state name

    [[ "$DRY_RUN" == true || "$FORCE" == true ]] && return 0
    if [[ ! -t 0 ]]; then
        die "Restoring a backup requires --force in non-interactive mode"
    fi

    printf 'The following backup version will be restored: %s\n' "$RESTORE_VERSION"
    for entry in "${RESTORE_ENTRIES[@]}"; do
        state="${entry%%:*}"
        name="${entry#*:}"
        printf '  %s %s\n' "$state" "$HOME_DIR/$name"
    done
    read -r -p 'Continue? [y/N] ' answer
    [[ "$answer" =~ ^[Yy]$ ]] || die "Restoration cancelled"
}

restore_backup_entry() {
    local entry="$1" state name source target temporary_file link

    state="${entry%%:*}"
    name="${entry#*:}"
    source="$RESTORE_DIR/$name"
    target="$HOME_DIR/$name"

    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry-run] restore %s -> %s (%s)\n' "$source" "$target" "$state"
        return
    fi

    if [[ "$state" == absent ]]; then
        if path_exists "$target"; then
            rm -- "$target"
        fi
        return
    fi

    if [[ -L "$source" ]]; then
        link="$(readlink -- "$source")"
        if path_exists "$target"; then
            rm -- "$target"
        fi
        ln -s -- "$link" "$target"
        return
    fi

    temporary_file="$(mktemp "$HOME_DIR/.vim-runtime-restore.XXXXXX")"
    trap 'rm -f -- "$temporary_file"' RETURN
    cp -a -- "$source" "$temporary_file"
    if path_exists "$target"; then
        rm -- "$target"
    fi
    mv -- "$temporary_file" "$target"
    trap - RETURN
}

restore_backup() {
    local entry

    backup_current_state
    for entry in "${RESTORE_ENTRIES[@]}"; do
        restore_backup_entry "$entry"
    done
}

migrate_legacy_ctags_link() {
    [[ "$legacy_ctags_link" == true ]] || return 0

    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry-run] remove legacy Ctags link %s\n' "$HOME_DIR/.ctags"
    else
        rm -- "$HOME_DIR/.ctags"
    fi
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
    local temporary_file

    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry-run] write %s\n' "$HOME_DIR/.vimrc"
        return
    fi

    escaped_runtime="${VIM_RUNTIME//\'/\'\'}"
    # CODEX MODIFIED: 2026-08-09 14:16:39 KST. Replace a .vimrc symlink path safely.
    temporary_file="$(mktemp "$HOME_DIR/.vimrc.vim-runtime.XXXXXX")"
    trap 'rm -f -- "$temporary_file"' RETURN
    cat > "$temporary_file" <<EOF
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
    mv -- "$temporary_file" "$HOME_DIR/.vimrc"
    trap - RETURN
}

printf 'Runtime directory: %s\n' "$VIM_RUNTIME"
printf 'Home directory: %s\n' "$HOME_DIR"

if [[ -n "$RESTORE_VERSION" ]]; then
    validate_restore_backup
    confirm_restore
    restore_backup
    if [[ "$DRY_RUN" == true ]]; then
        printf '[dry-run] Restore completed; no files were modified.\n'
    else
        printf 'Restoration completed successfully.\n'
        printf 'Pre-restore backup: %s\n' "$BACKUP_DIR"
    fi
    exit 0
fi

backup_existing_targets
write_backup_manifest
migrate_legacy_ctags_link

create_if_missing "$VIM_RUNTIME/personalized.sh"
create_if_missing "$VIM_RUNTIME/personalized.vim"
ensure_directory "$VIM_RUNTIME/temp_dirs/undodir"

replace_with_symlink "$VIM_RUNTIME/tmux_config/.tmux.conf" "$HOME_DIR/.tmux.conf"
replace_with_symlink "$VIM_RUNTIME/tmux_config/.tmux.conf.local" \
    "$HOME_DIR/.tmux.conf.local"
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
