#!/bin/bash
# Kuntur: detect-local-llms.sh
# Copied verbatim from the code blocks published at https://kuntur.io/guides/detect-ollama-local-llms
# The code is unchanged; only comment lines (this header and the "# ---" markers) were added.
# MIT licence. See LICENSE in the repository root.

# --- Guide section: Check macOS and Linux manually
# processes
pgrep -fl 'ollama|LM Studio|lms|llama-server|vllm'

# listeners and the address they are bound to
lsof -nP -iTCP -sTCP:LISTEN | grep -E ':(11434|1234|8080)\b'     # macOS
ss -ltnp | grep -E ':(11434|1234|8080)\b'                       # Linux

# models on disk
du -sh ~/.ollama/models ~/.lmstudio/models /usr/share/ollama/.ollama/models 2>/dev/null

# installed version and models, if the API is up
curl -s http://127.0.0.1:11434/api/version
curl -s http://127.0.0.1:11434/api/tags | jq -r '.models[] | "\(.name)\t\(.size)"'
