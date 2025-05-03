#!/usr/bin/bash

set -e
set -u
set -x
set -o pipefail
set -E

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "${SCRIPT_DIR}/exec.sh" \
  cargo clippy --workspace --all-targets "$@"
