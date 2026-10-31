#!/usr/bin/env bash
# Shared by both devcontainer configurations. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."

# pnpm: honour the "packageManager" field once package.json exists.
pnpm_spec=pnpm@latest
if [[ -f package.json ]]; then
  pm=$(node -p 'require("./package.json").packageManager ?? ""')
  [[ $pm == pnpm@* ]] && pnpm_spec=${pm%%+*}
fi
npm install --global --no-fund --no-audit "$pnpm_spec"

[[ -f package.json ]] || { echo "No package.json yet; skipping install."; exit 0; }

if [[ -f pnpm-lock.yaml ]]; then
  pnpm install --frozen-lockfile
else
  pnpm install
fi

# Playwright browsers + system deps (uses sudo for apt).
if node -e 'const p=require("./package.json");process.exit(({...p.dependencies,...p.devDependencies})["@playwright/test"]?0:1)'; then
  pnpm exec playwright install --with-deps chromium
fi
