#!/usr/bin/bash

set -e
set -u
set -x
set -o pipefail
set -E
set -m

echo "Serving model API."
ollama serve &

sleep 3

echo "Pulling model '${OLLAMA_MODEL}'..."
ollama pull "${OLLAMA_MODEL}"

fg
