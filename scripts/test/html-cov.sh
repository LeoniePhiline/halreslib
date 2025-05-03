#!/usr/bin/bash

set -e
set -u
set -x
set -o pipefail
set -E

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "${SCRIPT_DIR}/../rust/exec.sh" \
  cargo llvm-cov nextest \
    --html \
    --workspace \
    "$@"

# Mimic `llvm-cov`'s `--open` flag, launching the default web browser via `gio open`.
for arg in "$@"; do
    if [[ $arg == "--open" ]]; then
        gio open "file://$(realpath "${SCRIPT_DIR}")/../../docker/rust/target/llvm-cov/html/index.html"
    fi
done
