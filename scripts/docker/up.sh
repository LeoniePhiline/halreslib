#!/usr/bin/zsh

set -e
set -u
set -x
set -o pipefail
set -E

docker compose up --pull always --build "$@"
