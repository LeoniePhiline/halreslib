#!/usr/bin/bash

set -e
set -u
set -x
set -o pipefail
set -E

cargo cache --autoclean
echo "Caches cleaned."

echo

echo "Watching files..."
watchexec \
  --print-events \
  --watch-non-recursive 'Cargo.toml' \
  --watch-non-recursive 'Cargo.lock' \
  --watch 'crates/' \
  --restart \
  -- \
  cargo run -v
