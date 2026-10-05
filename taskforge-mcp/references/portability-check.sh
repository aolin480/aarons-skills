#!/bin/sh
# Verify the portable skill text without depending on a developer checkout.
set -eu

skill_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
pattern='/Users/|/Volumes/|/home/[[:alnum:]_.-]+|localhost:[0-9]|127\.0\.0\.1:[0-9]|tf_agent_|gpt-[0-9]|aolin480|aaronolin'
matches=$(find "$skill_dir" -type f \( -name '*.md' -o -name '*.yaml' \) \
  -exec grep -En "$pattern" {} + || true)

if [ -n "$matches" ]; then
  printf '%s\n' "$matches" >&2
  echo "TaskForge skill portability check failed: machine-specific text found." >&2
  exit 1
fi

echo "TaskForge skill portability check passed."
