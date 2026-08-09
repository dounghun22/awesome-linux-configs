# PROJECT KNOWLEDGE BASE

<!-- CODEX MODIFIED: 2026-08-09 02:12:03 KST. Refreshed the root repository map,
     runtime contracts, verification commands, and maintenance boundaries. -->

**Generated:** 2026-08-09 02:06:21 KST
**Mode:** update
**Commit:** efca658
**Branch:** master

## OVERVIEW

Linux 환경에서 Vim, Bash, Tmux, Ctags를 함께 설치·운영하는 설정 저장소입니다.
핵심 동작은 Bash 설치 스크립트와 생성된 Vim 설정, Pathogen 기반 플러그인 runtime입니다.

## STRUCTURE

```text
.
├── install_awesome_configs.sh  # 홈 설정 백업·링크·생성 진입점
├── vimrcs/                     # Vim 기본·파일 형식·플러그인·확장 설정
├── lang_plugin/                # SystemVerilog, Tcl, log 연결 설정
├── my_plugins/                 # 로컬 플러그인·테마 모음
├── sources_non_forked/         # 외부 플러그인 원본 스냅샷
├── sources_forked/             # 별도 fork 또는 로컬 변형
├── tmux_config/                # upstream 본체와 .local override
├── ctags/                      # SystemVerilog tag 규칙
├── fun/                        # POSIX 셸 유틸리티와 터미널 아트
├── tests/                      # 설치 통합 테스트
└── other_configs/              # Windows Terminal JSON 설정
```

`personalized.*`, `secret.*`, `backup/`, `temp_dirs/`는 로컬 설정·생성물이며
`.gitignore` 대상입니다. `AGENTS.md`도 저장소 ignore 규칙에 포함됩니다.

## WHERE TO LOOK

| 작업 | 위치 | 핵심 메모 |
|---|---|---|
| 설치·백업·심볼릭 링크 | `install_awesome_configs.sh` | `VIM_RUNTIME`와 `HOME`을 기준으로 동작 |
| Vim 기본 동작 | `vimrcs/basic.vim` | filetype·indent 기반을 먼저 활성화 |
| 파일 형식·언어 연결 | `vimrcs/filetypes.vim` | 확장자와 `FileType` 이벤트의 단일 진입점 |
| 플러그인 로딩 | `vimrcs/plugins_config.vim` | Pathogen 경로와 plugin 전역 옵션 |
| 사용자 Vim 설정 | `my_configs.vim`, `personalized.vim` | 생성되는 `~/.vimrc`에 직접 쓰지 않음 |
| Bash 환경 | `my_bashrc.sh`, `personalized.sh`, `secret.sh` | 개인·비밀 설정은 선택적 source 경계 |
| Tmux 커스터마이즈 | `tmux_config/.tmux.conf.local` | `tmux_config/.tmux.conf`는 upstream 본체 |
| Ctags 규칙 | `ctags/.ctags` | SystemVerilog 정규식·tag kind 정의 |
| 설치 회귀 | `tests/run_tests.sh` | 공백 경로, dry-run, 백업, headless Vim 검증 |
| CI | `.github/workflows/validate.yml` | ShellCheck와 통합 테스트만 자동 실행 |

## CODE MAP

`codegraph_*` 도구는 제공되지 않았고 Vimscript LSP와 Bash LSP도 활성화되지 않았습니다.
아래 역할은 source·호출 흐름을 직접 확인한 결과이며, 참조 중심성은 측정하지 않았습니다.

| 심볼 또는 파일 | 유형 | 위치 | Refs | 역할 |
|---|---|---|---|---|
| `install_awesome_configs.sh` | shell entrypoint | root | 미측정 | 설치·백업·생성 전체 흐름 |
| `vimrcs/plugins_config.vim` | Vim load hub | `vimrcs/` | 미측정 | 네 runtime 영역을 Pathogen으로 등록 |
| `vimrcs/filetypes.vim` | Vim dispatch | `vimrcs/` | 미측정 | SystemVerilog·Tcl·log 이벤트 연결 |
| `my_configs.vim` | Vim user entrypoint | root | 미측정 | 테마·매핑·ctags·개인 설정 source |
| `my_bashrc.sh` | shell runtime entrypoint | root | 미측정 | `VIM_RUNTIME`와 개인·비밀 설정 처리 |
| `tests/run_tests.sh` | shell integration test | `tests/` | CI 호출 | 설치 결과와 Vim headless 시작 검증 |

Vim 생성 설정의 source 순서는 `basic.vim → filetypes.vim → plugins_config.vim →
extended.vim → my_configs.vim`입니다. 순서를 바꾸면 filetype 이벤트나 plugin 자동 로딩이
끊길 수 있습니다.

## CONVENTIONS

- 기존 Vimscript·셸은 4칸 들여쓰기와 Unix 줄바꿈을 유지합니다.
- 새 셸 경로는 인용하고, 새 코드의 저장소 저작권 헤더와 영어 주석을 유지합니다.
- 사용자 설정은 `personalized.vim`, `personalized.sh`, `.tmux.conf.local`,
  `ctags/.ctags`에 둡니다.
- `sources_non_forked/`와 `sources_forked/`는 Pathogen 로딩 경계가 다릅니다.
- 번들 plugin 내부의 README·test·spec·t는 해당 upstream의 규칙으로 취급합니다.
- 커밋 요약은 `large file`, `easy align`처럼 짧고 소문자로 작성합니다.

## ANTI-PATTERNS (THIS PROJECT)

- 생성되는 `~/.vimrc`와 `tmux_config/.tmux.conf`를 직접 수정하지 않습니다.
- 토큰·비밀번호·호스트별 값을 추적 파일에 넣지 않습니다. 로컬 `secret.sh`만 사용합니다.
- `sources_non_forked/`에 임의 포맷 변경이나 공통 헤더를 삽입하지 않습니다.
- 새 사용자 plugin은 `sources_non_forked/`가 아니라 `my_plugins/`에 둡니다.
- `my_configs.vim` 마지막의 `set keyprotocol=`와 terminal 재설정 줄을 이동하지 않습니다.
- `.tmux.conf.local`에 TPM 중복 초기화 설정을 추가하지 않습니다.

## UNIQUE STYLES

- Pathogen은 `sources_forked → sources_non_forked → lang_plugin/basic → my_plugins` 순으로
  runtime을 등록합니다. 중복 파일은 이 순서를 기준으로 조사합니다.
- `filetypes.vim`은 `systemverilog`를 사용하지만 일부 ftdetect 파일은
  `verilog_systemverilog`를 사용합니다. 언어 설정 변경 시 이 불일치를 먼저 확인합니다.
- `vimrcs/basic.vim`은 5 MiB 초과 파일을 로드하지 않으며, Vim backup·swap을 비활성화합니다.
- 설치 시 기존 홈 설정은 `backup/YYYYMMDD-HHMMSS/` 아래에 복사됩니다.

## COMMANDS

```bash
./install_awesome_configs.sh --dry-run
bash tests/run_tests.sh
shellcheck --severity=error install_awesome_configs.sh my_bashrc.sh fun/fun tests/run_tests.sh
vim -Nu NONE -n -es -c 'set rtp+=.' \
    -c 'source vimrcs/basic.vim' \
    -c 'source vimrcs/filetypes.vim' \
    -c 'source vimrcs/plugins_config.vim' \
    -c 'qa!'
```

`--force` 설치는 실제 홈 설정을 변경하므로 대상 `HOME`과 백업 경로를 먼저 확인합니다.
루트 CI는 plugin 내부 테스트, 실제 Tmux 세션, Ctags 실행을 보장하지 않습니다.

## NOTES

- 일반 설치 의존성은 `bash`, `vim`, `tmux`, `ctags`이며 Vim 8.4 이상과 Tmux 2.4 이상을
  전제로 합니다.
- `my_bashrc.sh`는 존재하는 `personalized.sh`와 `secret.sh`를 source하므로 checkout과
  비밀 설정의 신뢰 경계를 확인합니다.
- 환경 의존적인 key mapping·색상·Tmux 동작은 실제 세션에서 별도 확인합니다.
