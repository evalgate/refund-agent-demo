# EvalGate refund agent demo

Use AI for more of your work. Keep your standards.

Run an approval-before-refund check with the **published `@evalgate/sdk@3.13.0`**.
The gate executes two deterministic evaluations of a local agent and refund tool:

| Agent implementation | Expected gate outcome |
| --- | --- |
| Human approval required | PASS, exit 0 |
| Approval guard removed | BLOCK, exit 2 |
| Approval guard restored | PASS, exit 0 |

```bash
git clone https://github.com/evalgate/refund-agent-demo.git
cd refund-agent-demo
npm run demo
```

Requirements: Node.js 24+, npm, Git and Bash. Package installation needs npm
network access. Evaluations need no account, API key, model calls or payment
provider. The agent and tool are deterministic fixtures: they execute actual
code and capture synthetic tool side effects; no money is transferred.

The script creates an isolated checkout, installs the pinned published SDK,
initializes local evaluation, commits reviewed behavior, explicitly accepts its
passing baseline, removes the approval guard, then restores it. It asserts each
CLI exit and JSON verdict, including that the regression contains valid
execution evidence. It never converts an execution error into a successful demo.
Your source checkout and accepted baseline are not changed by this experiment.

The committed `evals/baseline.json` is a real accepted comparison captured by
that isolated run; its source identity points to the experiment's temporary Git
commit, not a hosted deployment. `evidence/*.json` records those actual local
runs. CI independently repeats the clean-install experiment and uploads its
fresh reports. No hand-authored verdicts or candidate SDK tarballs are used.

To check the unchanged source against the committed baseline:

```bash
npm ci
npx --no-install @evalgate/sdk discover --manifest
npm run gate
```

The scope is approval ordering in this fixture. It does not prove that a live
language model resists prompt injection or that a real payment integration is
safe. Add reviewed cases for your actual agent before using a gate in production.

EvalGate is an evaluation control plane for AI applications and agents. Test
behavior, catch regressions, and make release decisions with evidence.
[Documentation](https://www.evalgate.com/docs) · [Published SDK](https://www.npmjs.com/package/@evalgate/sdk)
