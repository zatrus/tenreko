#!/usr/bin/env bash
# Shared helpers for hooks. Hooks receive the event as JSON on stdin.

# json_field <json> <field>: print a top-level field of .tool_input (string value).
# Uses the first working JSON tool (jq, node, python), then a sed fallback,
# so hooks work without extra installs. (On Windows, `python` may be a Store stub, hence `-c ''` probes.)
json_field() {
  local json="$1" field="$2" py
  if command -v jq >/dev/null 2>&1 \
    && printf '%s' "$json" | jq -r --arg f "$field" '.tool_input[$f] // empty' 2>/dev/null; then
    return
  fi
  if command -v node >/dev/null 2>&1 \
    && printf '%s' "$json" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const v=(JSON.parse(s).tool_input||{})[process.argv[1]];process.stdout.write(v==null?"":String(v))})' "$field" 2>/dev/null; then
    return
  fi
  for py in python3 python py; do
    if command -v "$py" >/dev/null 2>&1 && "$py" -c '' 2>/dev/null \
      && printf '%s' "$json" | "$py" -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get(sys.argv[1],""))' "$field" 2>/dev/null; then
      return
    fi
  done
  # Last resort: grab the string value, honouring escaped quotes, then unescape \" and \\.
  printf '%s' "$json" \
    | sed -n "s/.*\"$field\"[[:space:]]*:[[:space:]]*\"\(\([^\"\\\\]\|\\\\.\)*\)\".*/\1/p" \
    | head -1 | sed -e 's/\\"/"/g' -e 's/\\\\/\\/g'
}

# Normalise Windows paths to forward slashes for matching.
norm_path() { printf '%s' "$1" | tr '\\' '/'; }

# block <reason>: exit code 2 tells Claude Code to block the tool call and show stderr to Claude.
block() { echo "BLOCKED by hook: $*" >&2; exit 2; }
