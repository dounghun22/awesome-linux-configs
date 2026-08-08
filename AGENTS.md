# Repository Guidelines

## Project Structure & Module Organization

이 저장소는 Vim, Bash, Tmux, Ctags를 함께 구성하는 Linux 환경 설정 모음입니다.

- `vimrcs/`에는 기본 Vim 설정, 파일 형식별 설정, 플러그인 설정이 있습니다.
- `my_plugins/`, `sources_non_forked/`, `sources_forked/`에는 플러그인과 테마가 있습니다.
- `lang_plugin/`은 SystemVerilog, Tcl, 로그 등 추가 언어 설정을 담습니다.
- `my_configs.vim`, `my_bashrc.sh`, `tmux_config/`, `ctags/`는 사용자 설정 진입점입니다.
- `fun/`은 셸 유틸리티입니다. 레거시 스크립트 디렉터리는 현재 트리에 포함되지
  않습니다.

- `tests/`에는 저장소 설치 흐름을 검증하는 통합 테스트가 있습니다. 일부 플러그인은
  각자의 `test/`, `t/`, `spec/`에 추가 테스트를 제공합니다.

## Build, Test, and Development Commands

별도의 빌드 시스템은 없습니다. 다음 명령으로 변경을 확인합니다.

- `./install_awesome_configs.sh --dry-run`: 변경 없이 설치 대상과 의존성을 점검합니다.
- `./install_awesome_configs.sh --force`: 확인 질문 없이 설정을 설치하고 기존 파일을
  `backup/YYYYMMDD-HHMMSS/`에 보관합니다.
- `bash tests/run_tests.sh`: 경로에 공백이 있는 임시 환경에서 설치·백업·Vim 로딩을
  통합 검증합니다.
- `shellcheck install_awesome_configs.sh my_bashrc.sh fun/fun tests/run_tests.sh`: 셸
  스크립트의 정적 문제를 검사합니다.
- `vim -Nu NONE -n -es -c 'set rtp+=.' -c 'source vimrcs/basic.vim' -c 'source vimrcs/filetypes.vim' -c 'source vimrcs/plugins_config.vim' -c 'qa!'`: Vim 설정이 비대화식으로 로드되는지 확인합니다.
- 변경한 플러그인에 테스트가 있으면 해당 디렉터리의 테스트 스크립트를 직접 실행합니다.

## Coding Style & Naming Conventions

기존 Vimscript와 셸 파일의 4칸 들여쓰기와 Unix 줄바꿈을 유지합니다. Vim 설정 파일은
소문자 파일명과 `.vim` 확장자를 사용하고, 셸 스크립트는 `.sh`를 사용합니다. 새 사용자
설정은 생성되는 `~/.vimrc` 대신 `personalized.vim` 또는 `personalized.sh`에 추가하세요.
새 코드에는 저장소의 저작권 헤더와 영어 주석 스타일을 유지하고, 셸 경로는 인용합니다.

## Testing Guidelines

자동화된 커버리지 기준은 없습니다. 설정 변경은 문법 검사와 Vim 시작 검사를 모두 수행하고,
키 매핑·색상·플러그인 동작처럼 환경 의존적인 변경은 실제 Vim/Tmux 세션에서 확인하세요.

## Commit & Pull Request Guidelines

최근 커밋은 `large file`, `easy align`처럼 짧고 소문자인 요약을 사용합니다. 커밋은 한 가지
변경만 담고 영향 범위를 짧게 설명하세요. PR에는 변경 목적, 수정한 설정 경로, 실행한 검증
명령을 적고, 터미널 UI가 바뀌면 전후 스크린샷을 첨부하세요.

## Security & Configuration Tips

`.gitignore`는 `personalized.*`와 `secret.*`를 제외합니다. 토큰·비밀번호·호스트별 값은
추적 파일에 넣지 말고 로컬 `secret.sh`에만 보관하며, 설치 전 생성되는 심볼릭 링크와 백업을
확인하세요.
