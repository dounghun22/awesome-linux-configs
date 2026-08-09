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
# | Last Modified| 2026-08-09 16:48:59                                      |
# |--------------|----------------------------------------------------------|
#
# Revision History
# |-------------------------------------------------------------------------|
# |      Date     |                    Revision Summary                     |
# |---------------|---------------------------------------------------------|
# |   2026-08-09  | Replace ripgrep dependency with standard grep.          |
# |   2026-08-09  | Preserve user Ctags config and verify wrapper consumers. |
# |   2026-08-09  | Verify preserved Ctags config is also backed up.         |
# |   2026-08-09  | Strengthen installer backup and generated-file contracts. |
# |   2026-08-09  | Add semantic Ctags profile regression fixtures.          |
# |   2026-08-09  | Protect external .vimrc symlink referents during install. |
# |   2026-08-09  | Migrate legacy runtime-owned Ctags selector links.       |
# |   2026-08-09  | Reject Ctags probe failures with a nonzero status.       |
# |   2026-08-09  | Cover doctor executable paths and Vim config isolation.  |
# |   2026-08-09  | Verify versioned backup listing and restoration.          |
# |   2026-08-09  | Verify doctor under the util hierarchy.                   |
# |   2026-08-09  | Verify the Ctags wrapper under the util hierarchy.        |
# |---------------|---------------------------------------------------------|
#
# TODO, FIXME, NOTE
#
# Codex Change:
# - MODIFIED 2026-08-09T14:23:35+09:00
# - Assert that missing Ctags probes cannot report success.
# - ADDED 2026-08-09T14:38:00+09:00
# - Lock doctor handling of spaced command paths and untrusted Vim config.
# - MODIFIED 2026-08-09T15:04:00+09:00
# - Use direct wrapper shebangs to avoid PATH recursion in doctor regressions.
# - MODIFIED 2026-08-09T15:06:00+09:00
# - Run all doctor command wrappers through the resolved Bash interpreter.
# - ADDED 2026-08-09T16:09:18+09:00
# - Verify backup versions, dry-run restoration, and pre-restore snapshots.
# - MODIFIED 2026-08-09T16:48:59+09:00
# - Move doctor fixtures and assertions from fun to util.
# - MODIFIED 2026-08-09T16:53:23+09:00
# - Move Ctags wrapper fixtures and assertions from fun to util.

###############################################################################

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd -P)"
TEST_ROOT="$(mktemp -d)"
RUNTIME_DIR="$TEST_ROOT/runtime with spaces"
HOME_DIR="$TEST_ROOT/home"
ORIGINALS_DIR="$TEST_ROOT/originals"
SCAN_ROOT="$TEST_ROOT/scan root"
CTAGS_BINARY="${CTAGS:-ctags}"

cleanup() {
    rm -rf -- "$TEST_ROOT"
}

trap cleanup EXIT

assert_ctags_kind() {
    local tag_file=$1
    local symbol=$2
    local expected_kind=$3

    awk -F '\t' -v symbol="$symbol" -v expected_kind="$expected_kind" \
        '$1 == symbol {
             matches++
             if ($4 == expected_kind) {
                 exact_matches++
             }
         }
         END { exit !(matches == 1 && exact_matches == 1) }' "$tag_file"
}

mkdir -p "$RUNTIME_DIR" "$HOME_DIR" "$ORIGINALS_DIR" "$SCAN_ROOT/.codegraph"

for runtime_entry in autoload ctags fun lang_plugin my_plugins sources_forked \
    sources_non_forked tmux_config util vimrcs; do
    ln -s "$ROOT_DIR/$runtime_entry" "$RUNTIME_DIR/$runtime_entry"
done

cp "$ROOT_DIR/my_bashrc.sh" "$RUNTIME_DIR/my_bashrc.sh"
cp "$ROOT_DIR/my_configs.vim" "$RUNTIME_DIR/my_configs.vim"
ln -s "$ROOT_DIR/install_awesome_configs.sh" "$RUNTIME_DIR/install_awesome_configs.sh"

bash -n "$ROOT_DIR/install_awesome_configs.sh"
bash -n "$ROOT_DIR/my_bashrc.sh"
bash -n "$ROOT_DIR/tests/run_tests.sh"
sh -n "$ROOT_DIR/fun/fun"

if ! command -v grep >/dev/null 2>&1; then
    printf 'Error: grep is required to run repository tests.\n' >&2
    exit 1
fi

# CODEX ADDED: 2026-08-09 12:54:14 KST. Exclude local CodeGraph daemon paths.
printf '%s\n' '~/.vim_runtime' > "$SCAN_ROOT/.codegraph/daemon.sock"
scan_stderr="$TEST_ROOT/text-policy-scan.stderr"
if grep -RInE \
    --exclude-dir='.git' \
    --exclude-dir='.codegraph' \
    --exclude-dir='backup' \
    --exclude-dir='.omo' \
    --exclude-dir='tests' \
    --exclude-dir='sources_non_forked' \
    --exclude-dir='sources_forked' \
    --exclude-dir='my_plugins' \
    --exclude='README.md' \
    --exclude='AGENTS.md' \
    '~/.vim_runtime|depricated' "$ROOT_DIR" "$SCAN_ROOT" 2>"$scan_stderr"; then
    printf 'Error: maintained files contain a legacy runtime path.\n' >&2
    exit 1
fi
[[ ! -s "$scan_stderr" ]]

unrelated_bash_source="$(printf 'source %q' "$HOME_DIR/unrelated.sh")"
printf '%s\n' 'export UNRELATED_BASH_CONTENT=preserved' > "$HOME_DIR/unrelated.sh"
printf '%s\n' \
    '# Existing Bash configuration' \
    "$unrelated_bash_source" \
    'export UNRELATED_BASH_CONTENT=preserved' > "$ORIGINALS_DIR/.bashrc"
# CODEX ADDED: 2026-08-09 14:16:39 KST. Fixture an external .vimrc referent.
vimrc_referent="$TEST_ROOT/external vimrc"
printf '%s\n' '# Existing Vim configuration' > "$vimrc_referent"
ln -s "$vimrc_referent" "$ORIGINALS_DIR/.vimrc"
printf '%s\n' '# Existing Tmux configuration' > "$ORIGINALS_DIR/.tmux.conf"
printf '%s\n' \
    '# Existing local Tmux configuration' > "$ORIGINALS_DIR/.tmux.conf.local"
cp "$ORIGINALS_DIR/.bashrc" "$HOME_DIR/.bashrc"
ln -s "$vimrc_referent" "$HOME_DIR/.vimrc"
cp "$ORIGINALS_DIR/.tmux.conf" "$HOME_DIR/.tmux.conf"
cp "$ORIGINALS_DIR/.tmux.conf.local" "$HOME_DIR/.tmux.conf.local"
# CODEX MODIFIED: 2026-08-09 12:27:00 KST. Keep stale user Ctags options intact.
printf '%s\n' '--invalid-user-ctags-option' > "$ORIGINALS_DIR/.ctags"
cp "$ORIGINALS_DIR/.ctags" "$HOME_DIR/.ctags"
mkdir -p "$HOME_DIR/.ctags.d"
printf '%s\n' '--invalid-user-ctags-dir-option' > "$HOME_DIR/.ctags.d/ambient.ctags"

bashrc_before="$(sha256sum "$HOME_DIR/.bashrc")"
vimrc_before="$(sha256sum "$HOME_DIR/.vimrc")"
vimrc_referent_hash_before="$(sha256sum "$vimrc_referent" | awk '{print $1}')"
ctags_before="$(sha256sum "$HOME_DIR/.ctags")"
ctags_hash_before="$(sha256sum "$HOME_DIR/.ctags" | awk '{print $1}')"
ctags_dir_before="$(sha256sum "$HOME_DIR/.ctags.d/ambient.ctags")"

HOME="$HOME_DIR" VIM_RUNTIME="$RUNTIME_DIR" \
    "$ROOT_DIR/install_awesome_configs.sh" --dry-run >/dev/null 2>&1

[[ "$bashrc_before" == "$(sha256sum "$HOME_DIR/.bashrc")" ]]
[[ "$vimrc_before" == "$(sha256sum "$HOME_DIR/.vimrc")" ]]
[[ "$ctags_before" == "$(sha256sum "$HOME_DIR/.ctags")" ]]
[[ "$ctags_dir_before" == "$(sha256sum "$HOME_DIR/.ctags.d/ambient.ctags")" ]]

HOME="$HOME_DIR" VIM_RUNTIME="$RUNTIME_DIR" \
    "$ROOT_DIR/install_awesome_configs.sh" --force >/dev/null 2>&1

[[ -L "$HOME_DIR/.tmux.conf" ]]
[[ -L "$HOME_DIR/.tmux.conf.local" ]]
[[ -f "$HOME_DIR/.vimrc" && ! -L "$HOME_DIR/.vimrc" ]]
grep -Fqx '" DO NOT EDIT THIS FILE' "$HOME_DIR/.vimrc"
[[ "$vimrc_referent_hash_before" == "$(sha256sum "$vimrc_referent" | awk '{print $1}')" ]]
[[ "$(readlink "$HOME_DIR/.tmux.conf")" == "$RUNTIME_DIR/tmux_config/.tmux.conf" ]]
[[ "$(readlink "$HOME_DIR/.tmux.conf.local")" == "$RUNTIME_DIR/tmux_config/.tmux.conf.local" ]]
[[ -f "$HOME_DIR/.ctags" && ! -L "$HOME_DIR/.ctags" ]]
[[ "$ctags_before" == "$(sha256sum "$HOME_DIR/.ctags")" ]]
[[ "$ctags_dir_before" == "$(sha256sum "$HOME_DIR/.ctags.d/ambient.ctags")" ]]
[[ -f "$RUNTIME_DIR/personalized.sh" ]]
[[ -f "$RUNTIME_DIR/personalized.vim" ]]
[[ -d "$RUNTIME_DIR/temp_dirs/undodir" ]]

# CODEX MODIFIED: 2026-08-09 12:54:14 KST. Verify exact installer backup contents.
backup_dir="$(find "$RUNTIME_DIR/backup" -mindepth 1 -maxdepth 1 -type d -print -quit)"
for backup_name in .bashrc .vimrc .tmux.conf .tmux.conf.local .ctags; do
    cmp -s "$ORIGINALS_DIR/$backup_name" "$backup_dir/$backup_name"
done
[[ -L "$backup_dir/.vimrc" ]]
[[ "$(readlink "$backup_dir/.vimrc")" == "$vimrc_referent" ]]
[[ "$ctags_hash_before" == "$(sha256sum "$backup_dir/.ctags" | awk '{print $1}')" ]]

# CODEX ADDED: 2026-08-09 14:25:00 KST. Migrate only the repository legacy link.
legacy_runtime_dir="$TEST_ROOT/legacy runtime"
legacy_home_dir="$TEST_ROOT/legacy home"
legacy_ctags_referent="$legacy_runtime_dir/ctags/.ctags"
mkdir -p "$legacy_runtime_dir" "$legacy_home_dir"
for runtime_entry in autoload ctags fun lang_plugin my_plugins sources_forked \
    sources_non_forked tmux_config util vimrcs; do
    ln -s "$ROOT_DIR/$runtime_entry" "$legacy_runtime_dir/$runtime_entry"
done
cp "$ROOT_DIR/my_bashrc.sh" "$legacy_runtime_dir/my_bashrc.sh"
cp "$ROOT_DIR/my_configs.vim" "$legacy_runtime_dir/my_configs.vim"
ln -s "$ROOT_DIR/install_awesome_configs.sh" \
    "$legacy_runtime_dir/install_awesome_configs.sh"
ln -s "$legacy_ctags_referent" "$legacy_home_dir/.ctags"
legacy_ctags_hash_before="$(sha256sum "$legacy_ctags_referent" | awk '{print $1}')"

HOME="$legacy_home_dir" VIM_RUNTIME="$legacy_runtime_dir" \
    "$ROOT_DIR/install_awesome_configs.sh" --force >/dev/null 2>&1

[[ ! -e "$legacy_home_dir/.ctags" && ! -L "$legacy_home_dir/.ctags" ]]
[[ "$legacy_ctags_hash_before" == "$(sha256sum "$legacy_ctags_referent" | awk '{print $1}')" ]]
legacy_backup_dir="$(find "$legacy_runtime_dir/backup" -mindepth 1 -maxdepth 1 \
    -type d -print -quit)"
[[ -L "$legacy_backup_dir/.ctags" ]]
[[ "$(readlink "$legacy_backup_dir/.ctags")" == "$legacy_ctags_referent" ]]
legacy_doctor_output="$(
    HOME="$legacy_home_dir" VIM_RUNTIME="$legacy_runtime_dir" \
        "$legacy_runtime_dir/util/doctor"
)"
grep -Fqx 'doctor: all checks passed' <<< "$legacy_doctor_output"

bashrc_source="$(printf 'source %q' "$RUNTIME_DIR/my_bashrc.sh")"
grep -Fqx "$bashrc_source" "$HOME_DIR/.bashrc"
grep -Fqx "$unrelated_bash_source" "$HOME_DIR/.bashrc"
grep -Fqx 'export UNRELATED_BASH_CONTENT=preserved' "$HOME_DIR/.bashrc"

# CODEX ADDED: 2026-08-09 12:54:14 KST. Keep repository Vim defaults authoritative.
printf '%s\n' 'let g:personalized_vim_loaded = 1' 'set tabstop=8' \
    > "$RUNTIME_DIR/personalized.vim"

# CODEX ADDED: 2026-08-09 12:27:00 KST. Verify repository Ctags consumers.
alias_output="$(
    HOME="$HOME_DIR" VIM_RUNTIME="$RUNTIME_DIR" bash -c \
        'source "$1"; alias tags' _ "$RUNTIME_DIR/my_bashrc.sh"
)"
printf -v expected_alias_command '%q' "$RUNTIME_DIR/util/ctags-runtime"
[[ "$alias_output" == *"$expected_alias_command"* ]]
[[ "$alias_output" != *"='ctags "* ]]

HOME="$HOME_DIR" vim -Nu "$HOME_DIR/.vimrc" -n -es \
    -c "if !exists('Tlist_Ctags_Cmd') | cquit 11 | endif" \
    -c "let expected_ctags_command = shellescape('$RUNTIME_DIR/util/ctags-runtime')" \
    -c "if Tlist_Ctags_Cmd != expected_ctags_command | cquit 12 | endif" \
    -c "call system(Tlist_Ctags_Cmd . ' --version')" \
    -c "if v:shell_error != 0 | cquit 13 | endif" \
    -c "if !exists('g:personalized_vim_loaded') | cquit 14 | endif" \
    -c 'if &tabstop != 4 | cquit 15 | endif' \
    -c 'qa!'

# CODEX MODIFIED: 2026-08-09 15:06:00 KST. Use Bash wrappers for spaced paths.
doctor_bin_dir="$TEST_ROOT/doctor executables with spaces"
doctor_wrapper_shell="$(command -v -- bash)"
mkdir -p "$doctor_bin_dir"
for command_name in bash vim tmux ctags; do
    command_path="$(command -v -- "$command_name")"
    printf '#!%s\nexec %q "$@"\n' "$doctor_wrapper_shell" "$command_path" \
        > "$doctor_bin_dir/$command_name"
    chmod +x "$doctor_bin_dir/$command_name"
done
doctor_spaced_output="$(
    HOME="$HOME_DIR" VIM_RUNTIME="$RUNTIME_DIR" CTAGS=ctags \
        PATH="$doctor_bin_dir:$PATH" "$RUNTIME_DIR/util/doctor"
)"
grep -Fqx 'doctor: all checks passed' <<< "$doctor_spaced_output"

# CODEX ADDED: 2026-08-09 14:38:00 KST. Keep untrusted user Vim code unexecuted.
doctor_sentinel="$TEST_ROOT/doctor external sentinel"
printf "call writefile(['unsafe'], '%s')\n" "$doctor_sentinel" \
    >> "$RUNTIME_DIR/my_configs.vim"
doctor_mutated_output="$(
    HOME="$HOME_DIR" VIM_RUNTIME="$RUNTIME_DIR" CTAGS=ctags \
        PATH="$doctor_bin_dir:$PATH" "$RUNTIME_DIR/util/doctor"
)"
grep -Fqx 'doctor: all checks passed' <<< "$doctor_mutated_output"
if [[ -e $doctor_sentinel ]]; then
    printf 'Error: doctor executed untrusted my_configs.vim code.\n' >&2
    exit 1
fi

ctags_version="$(
    HOME="$HOME_DIR" CTAGS="$CTAGS_BINARY" \
        "$RUNTIME_DIR/util/ctags-runtime" --version
)"
ctags_symbols=(top PARAM data ifc C task_f func_f alias_t DEF)
ctags_extensions=(v vh sv svh svi)
case "$ctags_version" in
    'Universal Ctags'*)
        ctags_kinds=(m c r I C t f T c)
        ;;
    'Exuberant Ctags'*)
        ctags_kinds=(m a v i c t f e d)
        ;;
    *)
        printf 'Error: unsupported Ctags version in semantic fixture.\n' >&2
        exit 1
        ;;
esac

ctags_fixture_root="$TEST_ROOT/ctags fixtures"
mkdir -p "$ctags_fixture_root"
ctags_macro="$(printf '\140define DEF 1')"
for extension in "${ctags_extensions[@]}"; do
    fixture="$ctags_fixture_root/sample.$extension"
    printf '%s\n' \
        'module top;' \
        'parameter int PARAM = 1;' \
        'logic data;' \
        'endmodule' \
        'interface ifc;' \
        'endinterface' \
        'class C;' \
        'task task_f;' \
        'endtask' \
        'function void func_f();' \
        'endfunction' \
        'endclass' \
        'typedef int alias_t;' \
        "$ctags_macro" > "$fixture"
    tags_file="$ctags_fixture_root/$extension.tags"
    HOME="$HOME_DIR" CTAGS="$CTAGS_BINARY" \
        "$RUNTIME_DIR/util/ctags-runtime" -f "$tags_file" "$fixture"
    [[ -s "$tags_file" ]]
    for kind_index in "${!ctags_symbols[@]}"; do
        assert_ctags_kind "$tags_file" "${ctags_symbols[$kind_index]}" \
            "${ctags_kinds[$kind_index]}"
    done
done

[[ "$ctags_before" == "$(sha256sum "$HOME_DIR/.ctags")" ]]
[[ "$ctags_dir_before" == "$(sha256sum "$HOME_DIR/.ctags.d/ambient.ctags")" ]]

unknown_ctags="$ctags_fixture_root/unknown-ctags"
printf '%s\n' \
    '#!/bin/sh' \
    'if [ "${CTAGS+x}" = x ]; then' \
    '    printf "%s\\n" "CTAGS selector leaked" >&2' \
    '    exit 42' \
    'fi' \
    'printf "%s\\n" "Unknown Ctags"' > "$unknown_ctags"
chmod +x "$unknown_ctags"
unknown_tags="$ctags_fixture_root/unknown.tags"
unknown_stdout="$ctags_fixture_root/unknown.stdout"
unknown_stderr="$ctags_fixture_root/unknown.stderr"
if HOME="$HOME_DIR" CTAGS="$unknown_ctags" \
    "$RUNTIME_DIR/util/ctags-runtime" -f "$unknown_tags" \
    "$ctags_fixture_root/sample.sv" >"$unknown_stdout" 2>"$unknown_stderr"; then
    printf 'Error: unknown Ctags implementation was accepted.\n' >&2
    exit 1
fi
[[ ! -e "$unknown_tags" ]]
[[ ! -s "$unknown_stdout" ]]
grep -Fq 'unsupported Ctags implementation' "$unknown_stderr"
if grep -Fq 'CTAGS selector leaked' "$unknown_stderr"; then
    printf 'Error: CTAGS selector leaked into the Ctags child.\n' >&2
    exit 1
fi

# CODEX ADDED: 2026-08-09 14:23:35 KST. Lock the failed Ctags probe status contract.
missing_ctags="$ctags_fixture_root/missing-ctags"
missing_tags="$ctags_fixture_root/missing.tags"
missing_stdout="$ctags_fixture_root/missing.stdout"
missing_stderr="$ctags_fixture_root/missing.stderr"
if HOME="$HOME_DIR" CTAGS="$missing_ctags" \
    "$RUNTIME_DIR/util/ctags-runtime" -f "$missing_tags" \
    "$ctags_fixture_root/sample.sv" >"$missing_stdout" 2>"$missing_stderr"; then
    printf 'Error: missing Ctags probe was accepted.\n' >&2
    exit 1
fi
[[ ! -e "$missing_tags" ]]
[[ ! -s "$missing_stdout" ]]
grep -Fq "failed to probe Ctags executable '$missing_ctags'" "$missing_stderr"

runtime_from_bash="$(
    HOME="$HOME_DIR" VIM_RUNTIME= bash -c \
        'source "$1"; printf "%s" "$VIM_RUNTIME"' _ "$RUNTIME_DIR/my_bashrc.sh"
)"
[[ "$runtime_from_bash" == "$RUNTIME_DIR" ]]

# CODEX ADDED: 2026-08-09 16:09:18 KST. Verify versioned backup restoration.
initial_backup_version="${backup_dir##*/}"
list_backups_output="$TEST_ROOT/list-backups.output"
HOME="$HOME_DIR" VIM_RUNTIME="$RUNTIME_DIR" \
    "$ROOT_DIR/install_awesome_configs.sh" --list-backups > "$list_backups_output"
grep -Fqx "$initial_backup_version" "$list_backups_output"
grep -Fqx '  .bashrc: present' "$list_backups_output"
grep -Fqx '  .vimrc: present' "$list_backups_output"

printf '%s\n' 'RESTORE_MUTATION=1' >> "$HOME_DIR/.bashrc"
rm -- "$HOME_DIR/.vimrc" "$HOME_DIR/.tmux.conf" "$HOME_DIR/.tmux.conf.local"
printf '%s\n' '# Mutated Vim configuration' > "$HOME_DIR/.vimrc"
printf '%s\n' '# Mutated Tmux configuration' > "$HOME_DIR/.tmux.conf"
printf '%s\n' '# Mutated local Tmux configuration' > "$HOME_DIR/.tmux.conf.local"
printf '%s\n' '--mutated-user-ctags-option' > "$HOME_DIR/.ctags"

restore_dry_run_output="$TEST_ROOT/restore-dry-run.output"
HOME="$HOME_DIR" VIM_RUNTIME="$RUNTIME_DIR" \
    "$ROOT_DIR/install_awesome_configs.sh" --dry-run \
    --restore "$initial_backup_version" > "$restore_dry_run_output"
grep -Fq '[dry-run] Restore completed; no files were modified.' \
    "$restore_dry_run_output"
grep -Fq 'RESTORE_MUTATION=1' "$HOME_DIR/.bashrc"
[[ ! -L "$HOME_DIR/.vimrc" ]]

restore_output="$TEST_ROOT/restore.output"
HOME="$HOME_DIR" VIM_RUNTIME="$RUNTIME_DIR" \
    "$ROOT_DIR/install_awesome_configs.sh" --force \
    --restore "$initial_backup_version" > "$restore_output"
pre_restore_backup_dir="$(awk -F ': ' '/^Pre-restore backup:/ {print $2}' \
    "$restore_output")"
[[ -d "$pre_restore_backup_dir" ]]
[[ -f "$pre_restore_backup_dir/manifest" ]]
grep -Fqx 'present' <(awk -F '\t' '$2 == ".bashrc" {print $1}' \
    "$pre_restore_backup_dir/manifest")
grep -Fqx 'RESTORE_MUTATION=1' "$pre_restore_backup_dir/.bashrc"
grep -Fqx '# Mutated Vim configuration' "$pre_restore_backup_dir/.vimrc"
cmp -s "$ORIGINALS_DIR/.bashrc" "$HOME_DIR/.bashrc"
[[ -L "$HOME_DIR/.vimrc" ]]
[[ "$(readlink "$HOME_DIR/.vimrc")" == "$vimrc_referent" ]]
cmp -s "$ORIGINALS_DIR/.tmux.conf" "$HOME_DIR/.tmux.conf"
cmp -s "$ORIGINALS_DIR/.tmux.conf.local" "$HOME_DIR/.tmux.conf.local"
cmp -s "$ORIGINALS_DIR/.ctags" "$HOME_DIR/.ctags"

backup_count="$(find "$RUNTIME_DIR/backup" -mindepth 1 -maxdepth 1 -type d | wc -l)"
[[ "$backup_count" -ge 2 ]]

printf 'All repository tests passed.\n'
