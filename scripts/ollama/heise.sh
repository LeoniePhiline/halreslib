#!/usr/bin/bash

set -e
set -u
set -x
set -o pipefail
set -E

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

PROMPT_FILE="${SCRIPT_DIR}/prompt-heise-Linux-Handheld-Mecha-Comet-ausprobiert.json"

source "${SCRIPT_DIR}/file-prompt.sh" \
  "${PROMPT_FILE}"
