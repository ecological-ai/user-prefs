#!/bin/bash
# git-init-session.sh - Run at start of each claude.ai chat session.
# Usage: source git-init-session.sh <PAT> [bot-name] [bot-email]
#
# PAT:       Fine-grained GitHub Personal Access Token (required)
# bot-name:  Git committer name   (default: "claude-subagent")
# bot-email: Git committer email  (default: "claude-subagent@users.noreply.github.com")
#
# Auth note (2026-05-02): fine-grained PATs require oauth2 as git HTTPS username.
# x-access-token is incompatible with fine-grained PATs - returns 401 Bad credentials.
# Correct URL form: https://oauth2:${PAT}@github.com/owner/repo.git
# GIT_ASKPASS handles credential prompts: returns "oauth2" for username, token for password.

set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "ERROR: PAT required as first argument"
    echo "Usage: source git-init-session.sh <PAT> [bot-name] [bot-email]"
    return 1 2>/dev/null || exit 1
fi

# --- 1. Export PAT (session-scoped, not written to disk) ---
export GH_TOKEN="$1"

# --- 2. Disable interactive prompts (prevents agent hangs) ---
export GIT_TERMINAL_PROMPT=0

# --- 3. Configure bot identity ---
BOT_NAME="${2:-claude-subagent}"
BOT_EMAIL="${3:-claude-subagent@users.noreply.github.com}"

git config --global user.name  "$BOT_NAME"
git config --global user.email "$BOT_EMAIL"

# --- 4. Configure credential helper (in-memory, no disk write) ---
#    GIT_ASKPASS approach: token stays in env, never in ~/.git-credentials
#    Returns "oauth2" for username prompt; token for password prompt.
#    Fine-grained PATs require oauth2 as username; x-access-token is incompatible.
ASKPASS_SCRIPT="/tmp/.git-askpass-$$"
printf '#!/bin/sh\ncase "$1" in\n  *Username*) echo "oauth2" ;;\n  *) echo "$GH_TOKEN" ;;\nesac\n' > "$ASKPASS_SCRIPT"
chmod 700 "$ASKPASS_SCRIPT"
export GIT_ASKPASS="$ASKPASS_SCRIPT"

# --- 5. Prevent token leakage in git output ---
git config --global credential.helper ""
git config --global advice.detachedHead false

# --- 6. Verify ---
echo "--- git-init-session complete ---"
echo "Bot identity:  $(git config --global user.name) <$(git config --global user.email)>"
echo "GIT_TERMINAL_PROMPT: $GIT_TERMINAL_PROMPT"
echo "GIT_ASKPASS:         $GIT_ASKPASS"
echo "GH_TOKEN:            ${GH_TOKEN:0:10}... (truncated)"
echo ""

# Quick API auth check
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $GH_TOKEN" \
    https://api.github.com/user 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo "API auth:        PASS (HTTP 200)"
else
    echo "API auth:        FAIL (HTTP $HTTP_CODE) - check token validity/scopes"
fi
