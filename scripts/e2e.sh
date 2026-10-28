#!/usr/bin/env bash
# End-to-end check with a real OpenClaw in a throwaway HOME: install the packed plugin,
# list models, and run the agent (plain reply, then a file write through a tool).
# Makes a few cheap billable requests. Needs Node 24.22.1+ and OpenClaw on PATH.
# Usage: OBSCURIFY_API_KEY=sk-obs1_... scripts/e2e.sh
set -euo pipefail
: "${OBSCURIFY_API_KEY:?set OBSCURIFY_API_KEY}"
OPENCLAW=${OPENCLAW:-openclaw}
root=$(cd "$(dirname "$0")/.." && pwd)
export HOME=$(mktemp -d)
trap 'rm -rf "$HOME"' EXIT
tarball=$(cd "$root" && npm pack --silent --pack-destination "$HOME" | tail -1)
"$OPENCLAW" plugins install "npm-pack:$HOME/$tarball" --force --accept-capabilities >/dev/null
"$OPENCLAW" plugins inspect obscurify --runtime --json | grep -q '"status": "loaded"' && echo "PASS plugin loaded"
n=$("$OPENCLAW" models list --all --provider obscurify --plain --refresh 2>/dev/null | grep -c '^obscurify/')
[ "$n" -ge 200 ] && echo "PASS $n models listed" || { echo "FAIL only $n models"; exit 1; }
out=$("$OPENCLAW" agent --local --model obscurify/meta-llama/llama-3.3-70b-instruct --message "Reply with exactly: pong" 2>/dev/null)
grep -q pong <<<"$out" && echo "PASS plain reply" || { echo "FAIL plain reply"; exit 1; }
"$OPENCLAW" agent --local --model obscurify/deepseek/deepseek-v4-flash --thinking low \
  --message "Create a file named hello.txt in $HOME containing exactly: obscurify works. Then reply DONE." >/dev/null 2>&1
grep -q "obscurify works" "$HOME/hello.txt" && echo "PASS tool call (file written)" || { echo "FAIL tool call"; exit 1; }
