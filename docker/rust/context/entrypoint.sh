#!/usr/bin/bash

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
