#!/usr/bin/bash

set -e
set -u
set -x
set -o pipefail
set -E

docker compose exec rust bash -c "$*"
