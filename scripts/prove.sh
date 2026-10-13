#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
proof_dir=${EVALGATE_DEMO_PROOF_DIR:-"$root/proof"}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$proof_dir"
cp -R "$root/src" "$root/evals" "$work/"
cp "$root/package.json" "$root/package-lock.json" "$work/"
cd "$work"
npm ci --no-audit --no-fund > "$proof_dir/install.log" 2>&1
git init -q
git config user.name "EvalGate refund demo"
git config user.email "demo@evalgate.com"
printf 'node_modules/\n' > .gitignore
npx --no-install @evalgate/sdk init --local --apply --format json > "$proof_dir/init.json"
rm -rf evals/smart-init
npx --no-install @evalgate/sdk discover --manifest > "$proof_dir/discover.log"
git add -A
git commit -qm "review approval-before-refund behavior"
npx --no-install @evalgate/sdk baseline update > "$proof_dir/baseline-update.log"
git add -A
git commit -qm "accept passing reviewed baseline"
cp evals/baseline.json "$proof_dir/accepted-baseline.json"
check_gate() {
 local name=$1 expected=$2 code
 set +e
 npx --no-install @evalgate/sdk gate --format json > "$proof_dir/$name.json"
 code=$?
 set -e
 if [[ $code != "$expected" ]]; then
  echo "Unexpected $name exit $code; expected $expected" >&2
  cat "$proof_dir/$name.json" >&2
  exit 1
 fi
 node "$root/scripts/assert-verdict.cjs" "$proof_dir/$name.json" "$expected"
}
check_gate original 0
cp src/refund-agent.cjs "$work/original-agent.cjs"
node - <<'JS'
const fs = require('node:fs');
const file = 'src/refund-agent.cjs';
const source = fs.readFileSync(file, 'utf8');
const changed = source.split('\n').filter(line => !line.includes('// APPROVAL_GUARD')).join('\n');
if (changed === source) throw new Error('Approval guard was not removed');
fs.writeFileSync(file, changed);
JS
git add src/refund-agent.cjs
git commit -qm "intentional regression: remove human approval guard"
check_gate regression 2
cp "$work/original-agent.cjs" src/refund-agent.cjs
rm "$work/original-agent.cjs"
git add src/refund-agent.cjs
git commit -qm "restore human approval guard"
check_gate restored 0
printf 'Published @evalgate/sdk@3.13.0: PASS -> BLOCK -> PASS\n'
