#!/usr/bin/bash

set -e
set -u
set -x
set -o pipefail
set -E

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "${SCRIPT_DIR}/../rust/exec.sh" \
  watchexec \
    --print-events \
    --watch-non-recursive 'Cargo.toml' \
    --watch-non-recursive 'Cargo.lock' \
    --watch 'crates/' \
    --restart \
    -- \
    cargo llvm-cov nextest --workspace "$*"
