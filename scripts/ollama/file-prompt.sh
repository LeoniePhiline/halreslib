#!/usr/bin/bash

set -e
set -u
set -x
set -o pipefail
set -E

OLLAMA_HOST="$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "halreslib-ollama-1")"
PROMPT_FILE="${1}"

curl "http://${OLLAMA_HOST}:11434/api/generate" -d "@${PROMPT_FILE}" \
  | jq '.response' -r \
  | jq
