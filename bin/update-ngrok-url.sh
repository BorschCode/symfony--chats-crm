#!/usr/bin/env bash
# Updates the APP_URL GitHub Environment variable with the current ngrok tunnel URL.
# Required env vars:
#   GH_TOKEN      — GitHub personal access token (repo scope)
#   GH_ENV_NAME   — GitHub environment name (e.g. "production")
# Optional:
#   NGROK_API_URL — defaults to http://127.0.0.1:4040/api/tunnels
set -euo pipefail

NGROK_API="${NGROK_API_URL:-http://127.0.0.1:4040/api/tunnels}"
GH_REPO="BorschCode/symfony--chats-crm"
GH_VAR="APP_URL"

# ── Validate required vars ────────────────────────────────────────────────────
if [ -z "${GH_TOKEN:-}" ]; then
    echo "ERROR: GH_TOKEN is not set" >&2
    exit 1
fi
if [ -z "${GH_ENV_NAME:-}" ]; then
    echo "ERROR: GH_ENV_NAME is not set (e.g. export GH_ENV_NAME=production)" >&2
    exit 1
fi

# ── Fetch current ngrok tunnel URL ────────────────────────────────────────────
response=$(curl -sf "$NGROK_API") || {
    echo "ERROR: Could not reach ngrok API at $NGROK_API" >&2
    exit 1
}

public_url=$(echo "$response" | python3 -c "
import sys, json
tunnels = json.load(sys.stdin).get('tunnels', [])
https = [t['public_url'] for t in tunnels if t.get('proto') == 'https']
result = https[0] if https else (tunnels[0]['public_url'] if tunnels else '')
print(result, end='')
")

if [ -z "$public_url" ]; then
    echo "ERROR: No active tunnels found in ngrok response" >&2
    exit 1
fi

# ── Check current value in GitHub ─────────────────────────────────────────────
gh_response=$(curl -sf \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/${GH_REPO}/environments/${GH_ENV_NAME}/variables/${GH_VAR}" 2>/dev/null || echo "{}")

current_value=$(echo "$gh_response" | python3 -c "
import sys, json
print(json.load(sys.stdin).get('value', ''), end='')
" 2>/dev/null || echo "")

if [ "$current_value" = "$public_url" ]; then
    echo "${GH_VAR} unchanged: $public_url"
    exit 0
fi

# ── Update GitHub Environment variable ───────────────────────────────────────
http_code=$(curl -s -o /dev/null -w "%{http_code}" \
    -X PATCH \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: application/json" \
    "https://api.github.com/repos/${GH_REPO}/environments/${GH_ENV_NAME}/variables/${GH_VAR}" \
    -d "{\"name\":\"${GH_VAR}\",\"value\":\"${public_url}\"}")

if [ "$http_code" = "204" ]; then
    echo "${GH_VAR} updated: ${current_value:-<not set>} → $public_url"
else
    echo "ERROR: GitHub API returned HTTP $http_code" >&2
    exit 1
fi
