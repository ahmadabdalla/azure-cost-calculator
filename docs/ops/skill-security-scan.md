# Skill Security Scan: Operations Guide

Scans the `azure-cost-calculator` skill with [SkillSpector](https://github.com/NVIDIA/skillspector) on every pull request and blocks merge when the assessed severity is HIGH or CRITICAL. Findings are uploaded to GitHub code scanning so they appear inline on the PR diff and in the Security tab.

This runs as **two workflows**. The scan workflow runs in the untrusted PR context (no write scopes) and produces a SARIF artifact plus the blocking severity gate. A trusted companion workflow, triggered via `workflow_run`, holds the only `security-events: write` scope and publishes that artifact to code scanning. This split is what lets fork PRs receive inline annotations without ever granting write scope to fork-authored content. See [Two-workflow architecture](#two-workflow-architecture) for the rationale.

| Item              | Detail                                                                                                          |
| ----------------- | --------------------------------------------------------------------------------------------------------------- |
| Scan workflow     | `.github/workflows/skill-security-scan.yml` (PR context: scan + gate, no write scopes)                         |
| Upload workflow   | `.github/workflows/skill-security-scan-upload.yml` (trusted `workflow_run`: publishes SARIF)                   |
| Gate script       | `.github/scripts/security/check-skillspector-threshold.sh`                                                      |
| SARIF normaliser  | `.github/scripts/security/normalize-skillspector-sarif.sh`                                                      |
| Tests             | `tests/unit/bash/ci/check-skillspector-threshold.bats`, `tests/unit/bash/ci/normalize-skillspector-sarif.bats` |
| Scan target       | `skills/azure-cost-calculator/`                                                                                 |
| Trigger           | All pull requests to `dev` and `main`; scan only runs when files under `skills/azure-cost-calculator/**` change |
| Fail threshold    | `HIGH` or `CRITICAL` (configurable via `SKILLSPECTOR_FAIL_ON`)                                                  |
| SkillSpector pin  | `2eb844780ab163f01468ecf142c40a2ec0fcaec0` (2026-05-18)                                                         |
| LLM analysis      | Off in CI (`--no-llm`); use locally for triage                                                                  |

---

## What it does

SkillSpector is a static analyzer for AI agent skills. It scans `SKILL.md`, scripts, manifests, and reference data for 64 vulnerability patterns across 16 categories (prompt injection, data exfiltration, supply chain, excessive agency, MCP tool poisoning, dangerous AST patterns, taint flows, YARA signatures, and more). The README in the upstream repo lists every rule.

The scan workflow runs two passes per PR, both with LLM analysis disabled for reproducibility:

| Pass       | Format | Purpose                                                                       |
| ---------- | ------ | ----------------------------------------------------------------------------- |
| SARIF pass | SARIF  | Normalised, published as an artifact, then uploaded to code scanning by the upload workflow |
| JSON pass  | JSON   | Parsed by `check-skillspector-threshold.sh` to decide pass/fail (the required gate)         |

A separate JSON pass is required because SARIF does not carry SkillSpector's `risk_assessment` block, which is the source of truth for the gate.

### Two-workflow architecture

On a `pull_request` from a fork, `GITHUB_TOKEN` is read-only and `security-events: write` cannot be granted, so a single-workflow design cannot upload SARIF from fork PRs (the upload step fails and reddens otherwise-safe PRs). GitHub's documented pattern is to split the work:

| Workflow | Trigger | Permissions | Runs fork code? | Responsibility |
| -------- | ------- | ----------- | --------------- | -------------- |
| `skill-security-scan.yml` | `pull_request` | `contents: read`, `pull-requests: read` | Yes (scans it) | Scan, normalise SARIF, run the blocking gate, publish artifacts |
| `skill-security-scan-upload.yml` | `workflow_run` (completed) | adds `actions: read`, `security-events: write` | **No** | Download the SARIF artifact and upload it to code scanning |

The gate stays in the scan workflow, so it remains the required, blocking check on the PR. The upload workflow's result is not a PR status and does not gate; it only surfaces findings in the UI.

**Why this is safe.** The upload workflow holds write scope but is hardened against the artifact it consumes:

- It **never checks out or executes** PR/fork code; it only downloads the artifact and calls `upload-sarif`.
- The PR head sha comes from the authoritative `github.event.workflow_run.head_sha` (set by GitHub), never from the artifact, so it cannot be spoofed.
- The PR number is resolved from the commit-to-PRs API and strictly filtered (open, matching head sha, head repo, base repo, base branch). Ambiguous matches are skipped, never guessed, so a shared sha cannot redirect alerts onto another PR.
- The scan workflow publishes the SARIF artifact **only after** `normalize-skillspector-sarif.sh` validates every uri, so a poisoned SARIF is never produced for the upload workflow to consume.

### Why the SARIF needs normalising

SkillSpector records component paths relative to the scanned skill directory (`build_context.py`: `rel = item.relative_to(skill_dir)`). A finding in `skills/azure-cost-calculator/SKILL.md` is therefore emitted with `uri: "SKILL.md"`. GitHub code scanning resolves SARIF uris against the repository root, so without a rewrite the alert lands on a non-existent root-level `SKILL.md` (or is dropped). `normalize-skillspector-sarif.sh` prepends the skill path to each uri and **fails closed** (exit 3) on any uri that is absolute, a URL, contains a backslash, is percent-encoded, or contains a `..` traversal segment, since the uri is the only fork-influenced value that reaches code scanning.

### Why the scan checks out the PR head

The scan workflow checks out `github.event.pull_request.head.sha` rather than the default merge ref, so the scanned tree matches the `head_sha` the upload workflow associates results with (`ref: refs/pull/<n>/head` + `sha: head_sha`). This keeps ref and sha a consistent pairing and means the gate evaluates the actual proposed content, not a synthetic merge commit.


### Why scan all of `skills/azure-cost-calculator/**`

The threat model treats anything an agent reads or executes as in scope:

- `SKILL.md` and `USAGE.md`: instructions interpreted by the agent (prompt-injection surface)
- `scripts/`: code the agent executes (AST, taint, YARA surface)
- `references/`: data the agent reads (hidden-instruction and unicode-deception surface)

Filtering to scripts alone would leave the largest attack surface unscanned.

### Why static-only in CI

LLM-augmented analysis improves precision but adds:

- An API key to manage as a repo secret
- Per-PR cost
- Non-determinism that flakes a required check

The trade-off picked here is a deterministic gate in CI plus an explicit local workflow (below) for triaging findings with LLM context.

---

## Prerequisites

### CI

Nothing manual. The runner installs Python 3.12 and SkillSpector at the pinned SHA on every run. `jq` is already on `ubuntu-latest`.

### Local

| Tool         | Install                                                                                             |
| ------------ | --------------------------------------------------------------------------------------------------- |
| Python 3.12+ | [python.org](https://www.python.org/downloads/) or `brew install python@3.12` (macOS)               |
| pip          | bundled with Python                                                                                 |
| jq           | `brew install jq` (macOS) · `sudo apt install jq` (Ubuntu)                                          |
| SkillSpector | `pip install "git+https://github.com/NVIDIA/skillspector@2eb844780ab163f01468ecf142c40a2ec0fcaec0"` |
| bats-core    | `brew install bats-core` (macOS) · `npm i -g bats` (Ubuntu/CI) — only for running gate tests        |

> Use a virtual environment: `python3 -m venv .venv-skillspector && source .venv-skillspector/bin/activate`.

---

## Running locally

### Reproduce the CI scan

```bash
skillspector scan ./skills/azure-cost-calculator/ \
  --no-llm \
  --format json \
  --output skillspector.json

.github/scripts/security/check-skillspector-threshold.sh skillspector.json
```

Exit code 0 means the gate would pass; exit code 1 means HIGH or CRITICAL was found.

### Reproduce the SARIF normalisation

The CI upload path rewrites SARIF uris to be repo-relative and rejects hostile paths. To reproduce it locally:

```bash
skillspector scan ./skills/azure-cost-calculator/ \
  --no-llm \
  --format sarif \
  --output skillspector.sarif

.github/scripts/security/normalize-skillspector-sarif.sh skillspector.sarif skills/azure-cost-calculator
```

Exit 0 rewrites the file in place; exit 3 means an unsafe uri was found and nothing was written (CI would block the upload).

### Triage with LLM context

LLM analysis improves precision and explains findings in plain English. Pick a provider; see the SkillSpector README for the full list.

```bash
# Example: OpenAI
export SKILLSPECTOR_PROVIDER=openai
export OPENAI_API_KEY=sk-...

skillspector scan ./skills/azure-cost-calculator/ \
  --format markdown \
  --output skillspector-triage.md
```

### Run the gate-script tests

```bash
bash tests/unit/run-bats-tests.sh tests/unit/bash/ci/check-skillspector-threshold.bats
bash tests/unit/run-bats-tests.sh tests/unit/bash/ci/normalize-skillspector-sarif.bats
```

---

## Updating the SkillSpector pin

The pin is a commit SHA, not a tag. Bump only when there is a reason (new rule you want, false positive fix, security advisory). The pin lives only in the scan workflow.

1. Choose the new SHA from [NVIDIA/skillspector commits](https://github.com/NVIDIA/skillspector/commits/main).
2. Update three places in `.github/workflows/skill-security-scan.yml`:
   - `SKILLSPECTOR_REF` in the job `env:` block
   - `SKILLSPECTOR_REF_DATE` in the job `env:` block
   - The pinned SHA in the `Install SkillSpector` step (sourced from `SKILLSPECTOR_REF`)
3. Update the summary table at the top of this doc.
4. Open a PR. The first PR after a bump may surface new findings; triage before merging.

---

## Tuning the threshold

The gate fails on `HIGH` and `CRITICAL` by default. To change it, edit `SKILLSPECTOR_FAIL_ON` in the workflow `env:` block:

```yaml
SKILLSPECTOR_FAIL_ON: "CRITICAL"            # CRITICAL only; HIGH becomes advisory
SKILLSPECTOR_FAIL_ON: "MEDIUM,HIGH,CRITICAL" # strict; blocks on MEDIUM
```

The script normalises case and tolerates whitespace, so `"high , critical"` is equivalent to `"HIGH,CRITICAL"`.

Severity bands and recommendations come from SkillSpector's risk scoring (see upstream README):

| Score  | Severity | Recommendation |
| ------ | -------- | -------------- |
| 0-20   | LOW      | SAFE           |
| 21-50  | MEDIUM   | CAUTION        |
| 51-80  | HIGH     | DO NOT INSTALL |
| 81-100 | CRITICAL | DO NOT INSTALL |

---

## Interpreting findings in the PR UI

| Surface                  | Where to look                                                                |
| ------------------------ | ---------------------------------------------------------------------------- |
| Inline annotations on PR | "Files changed" tab; appear once `Skill Security Scan Upload` finishes (shortly after the scan check), for both same-repo and fork PRs |
| Aggregated view          | Repo → Security → Code scanning → filter by tool `SkillSpector`              |
| Raw JSON for scripting   | PR → Checks → `Skill Security Scan` → Artifacts → `skillspector-report`      |
| Pass/fail summary        | PR → Checks → `Skill Security Scan` → step summary panel (this is the blocking check) |

---

## Troubleshooting

| Symptom                                                               | Likely cause                                                                | Fix                                                                                                       |
| --------------------------------------------------------------------- | --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| Workflow runs on every PR even when the skill is untouched            | Top-level `paths:` filter was added                                         | Keep `paths:` off so branch protection always sees a status; rely on `dorny/paths-filter` for early exit  |
| Workflow always passes even with known-bad fixture                    | Threshold gate step missing or `--no-llm` JSON pass not running             | Confirm the `Run SkillSpector (JSON)` and `Check severity threshold` steps ran; check the JSON artifact for `risk_assessment.severity` |
| `SARIF upload failed: Resource not accessible by integration`         | The scan workflow is uploading SARIF directly instead of the upload workflow | The scan workflow must not call `upload-sarif` or hold `security-events: write`; that belongs only to `skill-security-scan-upload.yml` |
| Findings missing from code scanning on a fork PR                      | Upload workflow skipped or could not resolve the PR                          | Check the `Skill Security Scan Upload` run: it skips when no `skillspector-sarif` artifact exists or when the PR could not be unambiguously resolved from the head sha |
| `Skill Security Scan Upload` did nothing (`skip=true`)                | No SARIF artifact (scan path-skipped/blocked) or ambiguous PR match          | Expected for irrelevant PRs; otherwise confirm the scan workflow published `skillspector-sarif` and that exactly one open PR matches the head sha |
| Scan job fails at `Normalise SARIF paths` (exit 3)                    | SkillSpector emitted a uri that escapes the skill dir (absolute/URL/`..`)    | Treated as hostile and blocked by design; inspect the flagged uri in the step log before overriding |
| `pip install git+https://...` fails to resolve                        | Network restrictions on the runner, or the pinned SHA was force-pushed away | Re-run; if persistent, re-pin to a fresh SHA from the upstream commit log                                 |
| `jq: command not found` locally                                       | jq not installed                                                            | `brew install jq` (macOS) · `sudo apt install jq` (Ubuntu)                                                |
| Gate fails on a finding the team agrees is a false positive           | Static analysis lacks context                                               | Re-run locally with LLM analysis enabled; if still flagged, address the pattern or open an upstream issue |
| Threshold gate exits 2 in CI                                          | Report file missing or malformed (scan step likely failed earlier)          | Check earlier steps in the job; download the JSON artifact and re-run the script locally                  |
| SARIF appears in code scanning but PR check is green despite findings | Severity is below the fail threshold                                        | Expected; tune `SKILLSPECTOR_FAIL_ON` if MEDIUM should also block                                         |

---

## References

- [SkillSpector](https://github.com/NVIDIA/skillspector): upstream scanner, rule catalogue, JSON schema
- [OSV.dev](https://osv.dev): vulnerability database used by SkillSpector rule SC4
- [SARIF v2.1.0 spec](https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html): output format
- [GitHub code scanning with SARIF](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/sarif-support-for-code-scanning): how findings render in the UI
- [`github/codeql-action/upload-sarif`](https://github.com/github/codeql-action/tree/main/upload-sarif): action used to publish SARIF
- [`dorny/paths-filter`](https://github.com/dorny/paths-filter): in-job path filter used to keep the required check fast on irrelevant PRs
- [Uploading SARIF from forks with `workflow_run`](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/using-the-upload-sarif-action-with-third-party-analysis-tools#uploading-analysis-results-from-forks): the two-workflow pattern this implements
- [`actions/download-artifact`](https://github.com/actions/download-artifact): cross-run artifact download used by the upload workflow
