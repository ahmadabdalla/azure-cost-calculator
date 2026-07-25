# Skill Evaluations: Operations Guide

Automated evaluation of the Azure Cost Calculator skill using [Waza](https://github.com/microsoft/waza), a CLI for benchmarking AI agent skills. Validates behavior that deterministic tests (Pester, bats, YAML validation) cannot cover: prompt handling, disambiguation, service routing, and trigger specificity.

| Item             | Detail                                                                                                                                                                                                      |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Waza version     | `v0.38.0` — see "Upgrading Waza" in Known limitations for all files that must change on version bump                                                                                                        |
| Workflow         | `.github/workflows/eval.yml`                                                                                                                                                                                |
| Composite action | `.github/actions/install-waza/action.yml`                                                                                                                                                                   |
| Eval suite       | `tests/evals/azure-cost-calculator/eval.yaml` (copilot-sdk), `tests/evals/azure-cost-calculator/eval-mock.yaml` (mock)                                                                                      |
| Task files       | `tests/evals/azure-cost-calculator/tasks/*/*.yaml` and `tests/evals/azure-cost-calculator/tasks/*/*/*.yaml`                                                                                                 |
| Project config   | `.waza.yaml`                                                                                                                                                                                                |
| Auth secret      | `COPILOT_GITHUB_TOKEN` (fine-grained PAT, "Copilot Requests" permission)                                                                                                                                    |
| External API     | [Azure Retail Prices API](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices) (public, unauthenticated; called by `get-azure-pricing.sh` during happy-path tasks) |

## Quick start

Install Waza for your platform, then run evaluations locally.

```bash
WAZA_VERSION="v0.38.0"
mkdir -p ~/bin

# macOS (Apple Silicon)
curl -fsSL "https://github.com/microsoft/waza/releases/download/${WAZA_VERSION}/waza-darwin-arm64" -o ~/bin/waza

# Linux (amd64)
# curl -fsSL "https://github.com/microsoft/waza/releases/download/${WAZA_VERSION}/waza-linux-amd64" -o ~/bin/waza

chmod +x ~/bin/waza

# Validate YAML (no LLM calls)
waza check

# Run evals with real AI
export COPILOT_GITHUB_TOKEN="<your-pat>"
waza run --verbose --output results/results.json

# Run a specific service
waza run --tags "service:virtual-machines" --output results/results.json
```

## Task structure

Tasks mirror the skill's service reference hierarchy. One prompt per file; one directory per service.

**Path conventions:**
- Service tasks: `tasks/<category>/<service>/<scenario>.yaml`
- Smoke tests: `tasks/smoke/<scenario>.yaml`

**IDs** follow `eval:<category>/<service>/<scenario>` (e.g. `eval:compute/virtual-machines/windows-d4s-v5`). Smoke tests use `eval:smoke/<scenario>`.

**Tags** drive CI targeting:

| Tag type         | Example                             | Purpose                                         |
| ---------------- | ----------------------------------- | ----------------------------------------------- |
| `smoke`          | `smoke`                             | Core skill tests; runs on broad changes         |
| `service:<name>` | `service:virtual-machines`          | Per-service; matches service reference filename |
| Category         | `compute`, `databases`              | Grouping                                        |
| Test type        | `happy-path`, `negative`, `routing` | Filtering by scenario kind                      |

## CI pipeline

Three jobs in `.github/workflows/eval.yml` run on PRs to `dev`; one additional job is manual dispatch:

| Job                           | Executor      | What it does                                                                          | LLM calls |
| ----------------------------- | ------------- | ------------------------------------------------------------------------------------- | --------- |
| `validate-eval-schema`        | n/a           | `waza check` (schema validation only) + eval coverage check for changed service files | 0         |
| `evaluate-mock`               | `mock`        | Runs `--tags negative` only; validates trigger grader wiring                          | 0         |
| `evaluate-critical`           | `copilot-sdk` | Real AI evals; only tasks matching changed files                                      | varies    |
| `run-evals` (manual dispatch) | `copilot-sdk` | All tasks by default; optional comma-separated tag filter                             | varies    |

### How `evaluate-critical` targets tasks

The workflow uses [dorny/paths-filter](https://github.com/dorny/paths-filter) to detect which files changed, then maps them to Waza tags:

| Changed file                                                        | Tag triggered | Tasks run                    |
| ------------------------------------------------------------------- | ------------- | ---------------------------- |
| `skills/azure-cost-calculator/SKILL.md`, `agents/**`, `commands/**` | `smoke`       | All smoke tasks              |
| `skills/azure-cost-calculator/references/shared.md`                 | `smoke`       | All smoke tasks              |
| `skills/azure-cost-calculator/references/service-routing.md`        | `routing`     | alias-routing                |
| `skills/azure-cost-calculator/references/services/**/X.md`          | `service:X`   | All tasks tagged `service:X` |
| `skills/azure-cost-calculator/scripts/**`                           | `smoke`       | All smoke tasks              |
| `tests/evals/**`                                                    | `smoke`       | All smoke tasks              |

Service names are extracted from filenames dynamically (`basename virtual-machines.md .md` becomes `--tags service:virtual-machines`). Multiple tags are OR'd.

The job requires `COPILOT_GITHUB_TOKEN`; skips with a notice if not configured. `continue-on-error: true` prevents eval failures from blocking PRs while graders are being tuned.

**To extend:** add a filter in the `Detect critical file changes` step and map it to tags in `Build eval scope`. New tasks are picked up automatically if their tags match.

### Manual dispatch (workflow_dispatch)

The `run-evals` job triggers a real-model eval on any branch without opening a PR. Useful for:

- Verifying a scoped subset before merging (see "Scoping recipe" below).
- Comparing behavior across models: `claude-sonnet-4.6`, `claude-sonnet-4.5`, `claude-opus-4.6`, `gpt-5.3-codex`.
- Full-suite assessments not tied to a code change.

**Dispatch from the CLI:**

```bash
# Scoped: 4 smoke tasks + 1 cosmos-db happy path. ~90s wall clock.
gh workflow run eval.yml \
  --ref my-branch \
  -f model=claude-sonnet-4.6 \
  -f tag="smoke,service:cosmos-db"

# Full suite: all 92 tasks. Multi-model comparisons should scope down first.
gh workflow run eval.yml -f model=claude-sonnet-4.6
```

Inputs (`.github/workflows/eval.yml`):

| Input   | Type   | Default             | Meaning                                                                              |
| ------- | ------ | ------------------- | ------------------------------------------------------------------------------------ |
| `model` | choice | `claude-sonnet-4.6` | One of `claude-sonnet-4.6`, `claude-sonnet-4.5`, `claude-opus-4.6`, `gpt-5.3-codex`  |
| `tag`   | string | (empty runs all)    | Comma-separated tag filter, e.g. `smoke,service:cosmos-db`. Tags are OR'd, not AND'd |

**Retrieve and inspect results:**

```bash
# Find the run ID (most recent first)
gh run list --workflow=eval.yml --limit 5

# Download artifacts
gh run download <run-id> --dir ./eval-out
# results.json lands at ./eval-out/eval-results-<model>/results.json

# Quick summary
python3 -c "
import json, glob
r = json.load(open(glob.glob('./eval-out/*/results.json')[0]))
s = r['summary']
print(f\"aggregate={s['aggregate_score']:.3f}  passed={s['succeeded']}/{s['total_tests']}\")
for t in r['tasks']:
    print(f\"  {t['test_id']:60s} status={t['status']:10s} avg={t['stats']['avg_score']:.3f}\")
"
```

**Scoping recipe for verification runs.** Use `tag="smoke,service:<one-service>"` to run the 4 smoke tests plus one service happy path. This exercises trigger behavior, disambiguation, alias routing, and the pricing script path in ~90 seconds. It is the minimum footprint that surfaces most regressions; use it to verify skill/config changes before requesting review.

### Mock executor

Runs only `--tags negative` tasks. Negative tests pass deterministically under mock because the mock executor never activates skills. Positive tests are excluded: they require real AI output and always fail under mock, producing no actionable signal. `waza check` (run in `validate-eval-schema`) already covers schema and grader config validation.

The mock executor is configured in `eval-mock.yaml` alongside `eval.yaml`. Both files share the same task globs; the only difference is `executor: mock`. This avoids mutating `eval.yaml` in CI.

### Copilot SDK executor

Runs real AI evaluations. Auth priority: `COPILOT_GITHUB_TOKEN` > `GH_TOKEN` > `GITHUB_TOKEN`. Results are uploaded as artifacts (30-day retention) and displayed in the Actions Step Summary.

## Execution architecture

Each `copilot-sdk` eval trial runs in two phases. Understanding both is essential for diagnosing timeouts, interpreting token costs, and reasoning about grader behavior.

### Skill execution phase

The Copilot SDK opens a fresh session per trial, loads the entire `skills/azure-cost-calculator/` directory as system context, sends the user prompt, and runs the agent to completion. No state carries forward between trials.

The skill directory is approximately 677 KB (~170K tokens). This context is prepended to every LLM call within a trial. A clean trial (e.g., a disambiguation task where the agent asks a question and stops) makes 3 LLM calls across 3 tool-use turns. A full estimation trial (agent runs `get-azure-pricing.sh`, builds a price table) makes 6-11 tool calls, each compounding the conversation history from prior turns.

The Azure Retail Prices API is called during this phase via `get-azure-pricing.sh`. It is public and requires no authentication, but it is an external network dependency. If the API is down or the CI runner restricts outbound HTTPS, happy-path tasks will fail.

### Grading phase

After execution completes, each grader runs in sequence. Deterministic graders (`text`, `tool_constraint`, `trigger`, `skill_invocation`) evaluate the response locally with no additional LLM calls.

Prompt graders (`prompt` type) make a separate LLM call using the model specified by `judge_model` in the eval config. When `continue_session: true` is set, the judge reattaches to the existing skill session via `ResumeSessionWithOptions()` and sees the full conversation exchange, not just the final output. The judge scores by invoking one of two Waza-intercepted tools: `set_waza_grade_pass` or `set_waza_grade_fail`.

Both execution and grading calls go through the same Copilot API, authenticated by the same token, and billed identically. Premium request counts in results include both phases combined. There is currently no breakdown of execution vs. grading cost in the results JSON.

### Model resolution for judging

Judge model priority (highest to lowest):

1. Per-grader `model` field in `promptGraderConfig`
2. Eval-level `judge_model`
3. Fallback to `config.model`

Both `model` and `judge_model` are set to `claude-sonnet-4.6` in the current eval configs.

## Cost and resource budget

Runs consume [AI Credits (AIC)](https://docs.github.com/en/copilot/concepts/billing/usage-based-billing-for-organizations-and-enterprises), billed per token (input, output, and cached). The token footprint is dominated by the 677 KB skill directory loaded as system context on every LLM call, not by the task prompt itself.

### Per-task cost (empirical, claude-sonnet-4.6)

| Scenario                                    | Premium requests | Input tokens | Notes                                 |
| ------------------------------------------- | ---------------- | ------------ | ------------------------------------- |
| Clean disambiguation (agent asks and stops) | ~9               | ~194K        | 3 execution turns + grading           |
| Full estimation (agent runs pricing script) | 15-23            | 370K-600K    | Multi-turn tool use compounds history |

These numbers are from controlled experiments with `trials_per_task: 3` (issue [#632](https://github.com/ahmadabdalla/azure-cost-calculator/issues/632)), taken before GitHub Copilot's June 2026 transition to AI Credits; the "Premium requests" unit is retained as historical footprint data. Divide by 3 for a rough single-trial estimate at `trials_per_task: 1`.

### Scoping runs

Use `--tags` filtering to scope runs to what you actually need:

```bash
# Run only the service you changed
waza run --tags "service:virtual-machines" --output results/results.json

# Run smoke tests only
waza run --tags smoke --output results/results.json
```

The CI workflow (`evaluate-critical`) already does this automatically: it detects which files changed and maps them to tags so only relevant tasks run. Unfiltered runs should only happen via manual `workflow_dispatch` when a full suite assessment is needed.

## Graders

| Grader             | Purpose                                              | Deterministic                                                                       |
| ------------------ | ---------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `text`             | String/regex matching on output                      | Yes                                                                                 |
| `behavior`         | Required tools by name, max tool calls               | Yes; do NOT use for script invocation: tool name is `bash`, not the script filename |
| `tool_constraint`  | Tool name + optional command pattern (regex on args) | Yes; use for pricing script invocation (see snippet below)                          |
| `trigger`          | Skill activation/deactivation                        | Yes                                                                                 |
| `skill_invocation` | Correct skill invoked                                | Yes                                                                                 |
| `prompt`           | LLM-as-judge for qualitative checks                  | No                                                                                  |
| `code` (planned)   | Python assertions for numeric accuracy               | Yes                                                                                 |

### Standard graders for happy-path tasks

Happy-path tasks use the following graders. The first two and `uses-pricing-script` are required in every task. `{parameter}-acknowledged` and `complete-estimate-quality` are service-specific; include at least one of the two.

**1. correct-service-name**: verifies the agent names the service correctly. Set the regex to the primary display name and its most common alias (pipe-separated):

```yaml
- type: text
  name: correct-service-name
  config:
    regex_match:
      - "Azure App Service|App Service"
  weight: 1.0
```

**2. currency-format**: verifies a formatted dollar amount is present. Copy verbatim; do not change the regex:

```yaml
- type: text
  name: currency-format
  config:
    regex_match:
      - "\\$[\\d,]+\\.\\d{2}"
  weight: 1.0
```

This grader assumes USD output. Use a USD-billed region in the task prompt (East US is the default); see Known limitations if a service is unavailable there.

**3. {parameter}-acknowledged**: verifies the agent echoed back the key quantity from the prompt (instance count, throughput, tier). Name the grader after the parameter (e.g., `instance-count-acknowledged`, `throughput-acknowledged`). Use `contains`, not `regex_match`. Format numbers with thousands separator where applicable (`"1,000"` not `"1000"`):

```yaml
- type: text
  name: instance-count-acknowledged
  config:
    contains:
      - "2"
  weight: 0.5
```

**4. complete-estimate-quality**: LLM-as-judge grader that checks Assumptions section, correct billing model, and key parameter. The prompt must repeat `inputs.prompt` verbatim in its opening line. Criteria (3) must reference the specific quantity from the prompt:

```yaml
- type: prompt
  name: complete-estimate-quality
  config:
    continue_session: true
    prompt: >
      You are evaluating an AI agent's response to: "{verbatim copy of inputs.prompt}"

      The agent's response is in the conversation above. Check it for these criteria:
      (1) Includes an Assumptions section disclosing safe-default parameters.
      (2) Shows a monthly total cost using the correct billing model for {Service Display Name}.
      (3) Accounts for {key quantity, e.g., "2 instances as specified"}.

      Score 1.0 if all three criteria are met. Score 0.5 if two are met. Score 0.0 if fewer than two are met.

      Return ONLY a decimal number between 0.0 and 1.0 with no other text.
  weight: 1.5
```

**5. uses-pricing-script**: verifies the agent called the pricing script. The Bash tool reports as `bash` in session tool names, not as the script filename. `behavior.required_tools` cannot match script names and silently passes without asserting anything. Copy verbatim; do not substitute `behavior.required_tools`:

```yaml
- type: tool_constraint
  name: uses-pricing-script
  config:
    expect_tools:
      - tool: bash
        command_pattern: "get-azure-pricing\\.sh"
  weight: 1.0
```

**Exception:** services with `hasMeters: false` in their reference YAML have no pricing API data and are not happy-path pricing flows. Do not tag these tasks `happy-path`. Use a `text` grader verifying the agent communicates that no API pricing data is available, and omit `uses-pricing-script`.

## Authoring pattern

Use a pack-based pattern so new service tests are consistent and easy to extend.

### Core scenario packs

| Pack                      | Required intent                                                                    | Minimum tags                                 |
| ------------------------- | ---------------------------------------------------------------------------------- | -------------------------------------------- |
| `smoke-routing`           | Alias or route resolves to the right service; prompt omits never-assume parameters | `smoke`, `routing`, `service:<name>`         |
| `smoke-disambiguation`    | Missing "never-assume" parameters trigger a clarification question                 | `smoke`, `disambiguation`                    |
| `happy-path-single-meter` | One primary meter estimate with assumptions and monthly output                     | `<category>`, `service:<name>`, `happy-path` |
| `happy-path-multi-meter`  | Multi-component estimate with component breakdown and total                        | `<category>`, `service:<name>`, `happy-path` |
| `negative-trigger`        | Non-pricing prompt does not activate the skill                                     | `smoke`, `negative`                          |

### Exception packs

Use these only when a service reference documents the corresponding trap.

| Exception pack              | When to use                                                    | Typical assertion                             |
| --------------------------- | -------------------------------------------------------------- | --------------------------------------------- |
| `cross-service-name`        | API `serviceName` is shared across multiple products           | `ProductName` filter is present and correct   |
| `global-region-only`        | Meters bill only in `Global` region                            | Query includes `Region: Global`               |
| `daily-meter-normalization` | Meters bill per-day instead of per-hour                        | Daily meter is normalized to monthly once     |
| `no-retail-meters`          | Service has no retail API meters and depends on `billingNeeds` | Skill does not fabricate direct meter pricing |

### Routing task design

A routing smoke test verifies that an alias or informal service name resolves to the correct service reference. Two decisions determine whether it is reliable.

**Use a parameter-free prompt.** Supplying all required parameters triggers a full estimation run, which can produce very long responses and exhaust the 300s session timeout. Omitting never-assume parameters triggers the disambiguation flow instead: the agent reads the routing file, finds the reference, and asks for missing parameters, completing quickly with a short, predictable response.

**Do not use text graders to check the service name.** In a disambiguation response the agent may echo the alias the user typed, use a variant spelling, or drop the service name entirely. The exact wording is non-deterministic across runs; no substring or regex reliably matches all forms.

Routing is proven indirectly through the agent's knowledge of the service's never-assume parameters. An agent that asks for the correct service-specific parameters must have read the right reference file. Use a prompt grader (LLM judge) that names those parameters in its scoring criteria:

```yaml
- type: prompt
  name: asks-before-estimating
  config:
    continue_session: true
    prompt: >
      You are evaluating an AI agent's response to the question: "{verbatim copy of inputs.prompt}"

      The agent's response is in the conversation above. {Service Name} requires the following
      parameters before a price can be calculated: {never-assume parameter list for this service}.
      These are "never-assume" parameters the agent must not guess.

      Review the agent response and score it:
      - Score 1.0 if the agent asks for at least one of the listed never-assume parameters and does NOT provide a cost estimate.
      - Score 0.5 if the agent asks for at least one of the listed never-assume parameters but also includes a cost estimate.
      - Score 0.0 if the agent provides a cost estimate without asking for any of the listed never-assume parameters.

      Return ONLY a decimal number between 0.0 and 1.0 with no other text.
  weight: 2.0
```

Pair this with `skill_invocation` to confirm activation. No text graders are needed. A routing smoke test and a happy-path task for the same service are complementary: one tests alias resolution, the other tests estimation correctness.

### Task contract

Every task must satisfy:

1. Path: `tasks/<category>/<service>/<scenario>.yaml` or `tasks/smoke/<scenario>.yaml`
2. ID: `eval:<category>/<service>/<scenario>` or `eval:smoke/<scenario>`
3. Tags: `service:<service-name>` for service tasks; category and scenario tags at minimum
4. At least one deterministic grader (`text`, `tool_constraint`, `trigger`, or `skill_invocation`); do not use `behavior` for script invocation (see [Graders](#graders))
5. Happy-path tasks: include the standard `uses-pricing-script` `tool_constraint` grader
6. `waza check` passes before PR submission

### Coverage contract

A service reference file is **covered** when at least one eval task is tagged `happy-path` and `service:<service-name>` (where `<service-name>` matches the reference filename without `.md`) and passes `waza check`.

The `validate-eval-schema` job enforces this: if a PR changes a service reference file with no matching `happy-path` task, the coverage check fails and lists the missing services with the path where the task should be added. Run `bash tests/check-eval-coverage.sh <file>` locally before pushing.

### PR checklist

1. Task files added or updated under `tests/evals/azure-cost-calculator/tasks/`
2. IDs and tags follow the contract (`service:<name>` matches reference filename)
3. Required scenario and exception packs are present
4. Every happy-path task includes the `uses-pricing-script` `tool_constraint` grader
5. `waza check` passes locally
6. Targeted eval run completed for changed service tags
7. CI artifacts reviewed (`eval-results-mock`, `eval-results-critical` when applicable)

## Known limitations

| Limitation                                                                                 | Mitigation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Prompt grader (judge LLM) may time out on long responses                                   | Override the session timeout per task with the top-level `timeout_seconds` field if a specific task consistently times out                                                                                                                                                                                                                                                                                                                                                                                     |
| Prompt grader variance on borderline values                                                | Use `code` grader for numeric checks                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `**` glob not supported recursively as of waza v0.38.0: tasks at depth 2+ silently skipped | Use explicit depth patterns: `tasks/*/*.yaml` and `tasks/*/*/*.yaml`                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Upgrading Waza: the version is pinned in a handful of files; a partial update breaks CI    | Update all of these together: `.github/actions/install-waza/action.yml` (version + checksum), `.devcontainer/Dockerfile` (curl URL + checksum), `docs/ops/evals.md` (version row + schema links in References), `docs/ops/dev-container.md` (table row), `.vscode/settings.json` (the three `yaml.schemas` URLs). YAML files (`.waza.yaml`, `eval.yaml`, `eval-mock.yaml`, all task files) intentionally do not carry per-file `$schema` URLs: `waza check` validates against the bundled schema in whichever binary is installed, and IDE validation is pinned centrally in `.vscode/settings.json` |
| `currency-format` regex (`\$[\d,]+\.\d{2}`) assumes USD output                             | Tasks targeting non-USD regions (e.g. West Europe returns EUR) will fail this grader; use a USD region in the prompt, or update the regex to match the expected currency symbol                                                                                                                                                                                                                                                                                                                                |
| SKILL.md exceeds Waza 500-token recommendation (3800 tokens)                               | Intentional; skill carries domain reference architecture                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `argument-hint` frontmatter diverges from agentskills.io spec                              | Project convention; not blocking for evals                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `waza suggest` diverges from project conventions and fails intermittently                  | Do not use `waza suggest`; author tasks directly following the task contract and exemplars in this doc                                                                                                                                                                                                                                                                                                                                                                                                         |

## Results interpretation

Eval results are saved as JSON artifacts (30-day retention in CI) and can be generated locally with `--output results.json`.

### Score calculation

Each task produces a score from 0.0 to 1.0. The score is the weighted average across all graders on that task. The aggregate score across the full run is the unweighted average of all task scores.

A task with three graders scoring (0, 1, 1) with equal weights produces a task score of 0.67, not 0.00. This means a single critical grader scoring 0 can be masked by passing graders that test unrelated properties. When diagnosing a score, always check per-grader results, not just the aggregate.

### Key fields in results JSON

| Field                               | What it tells you                                                           |
| ----------------------------------- | --------------------------------------------------------------------------- |
| `summary.aggregate_score`           | Overall pass rate across all tasks                                          |
| `tasks[].stats.avg_score`           | Average score for a specific task across trials                             |
| `tasks[].stats.std_dev_score`       | Score variance across trials (zero when `trials_per_task: 1`)               |
| `tasks[].stats.ci95_lo` / `ci95_hi` | 95% confidence interval bounds (only meaningful with `trials_per_task > 1`) |
| `tasks[].graders[].score`           | Per-grader score for each trial                                             |

### Reading per-grader results

When a task score is unexpected, check which grader moved:

1. Look at `tasks[].graders[]` for the task in question.
2. Identify which grader scored 0 or below threshold.
3. Check whether that grader is testing the behavior you care about or an unrelated property.

Global graders (defined in `eval.yaml` under `graders:`) apply to every task. If a global grader tests something irrelevant to a specific task, it adds noise to that task's score. The current global grader `no-summary-format` checks that the response does not contain "Summary format"; this is unrelated to most task behaviors and can inflate scores when paired with a failing critical grader.

### Comparing results

`waza compare <before.json> <after.json>` shows score deltas between two runs. Limitations: it does not surface confidence interval bands, does not flag whether a delta is within noise, and exits 0 on success regardless of whether scores improved or regressed. With `trials_per_task: 1`, any score delta between two runs could be signal or LLM variance; there is no way to distinguish them from a single trial.

## Troubleshooting

| Symptom                                                                 | Fix                                                                                                                                                                                                  |
| ----------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `copilot is not authenticated`                                          | Create fine-grained PAT with "Copilot Requests" permission; add as repo secret                                                                                                                       |
| `waza check` schema errors                                              | Verify required fields are present (task: `id`, `name`, `inputs.prompt`); waza validates against its bundled schema, so upgrading the pinned binary can change what fails                            |
| Prompt grader scores 0 unexpectedly                                     | Run `waza run --tags <tag> --verbose` locally; review grader prompt wording                                                                                                                          |
| `uses-pricing-script` scores 0                                          | The task used `behavior.required_tools` instead of `tool_constraint`; replace with the standard grader (see [Standard graders](#standard-graders-for-happy-path-tasks))                              |
| Tasks skipped or results empty                                          | Verify `--tags` matches task tags; check `results/` directory is writable                                                                                                                            |
| Routing smoke task hits session timeout (`context deadline exceeded`)   | Prompt includes all parameters and triggers full estimation; switch to a parameter-free prompt so the task enters the disambiguation flow instead (see [Routing task design](#routing-task-design))  |
| Text grader on service name fails non-deterministically in routing task | Agent wording in disambiguation responses is non-deterministic; replace with a prompt grader checking for service-specific never-assume parameters (see [Routing task design](#routing-task-design)) |

## Maintenance routine

### Per PR

1. Ensure changed service references map to corresponding `service:<name>` eval tags.
2. Confirm at least one deterministic grader remains in each changed task.
3. Keep new task files aligned with the pack pattern instead of one-off grader logic.

### Monthly

1. Recheck Waza pin and checksum in `.github/actions/install-waza/action.yml`.
2. If upgrading Waza, follow the "Upgrading Waza" row in [Known limitations](#known-limitations).
3. Review `Known limitations` and remove stale mitigations.
4. Review flaky prompt graders and convert high-value checks to deterministic graders where possible.

## Experiments

Historical record of research, experiments, and design decisions. Issues and PRs are linked for full context.

| Issue                                                                                                                          | PR                                                                     | Status    | Summary                                                                                                                                                                                                                                                            |
| ------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [#632: Disciplined skill experimentation using waza compare](https://github.com/ahmadabdalla/azure-cost-calculator/issues/632) | [#635](https://github.com/ahmadabdalla/azure-cost-calculator/pull/635) | Discarded | Investigated applying the Karpathy autoresearch pattern (autonomous mutate-measure-keep/revert) to iterative `SKILL.md` improvement. Built `eval-experiment.yaml` with `trials_per_task: 3` and a `compare-experiment.sh` script for ci95 band overlap comparison. |

## References

- [Waza documentation](https://microsoft.github.io/waza/)
- [Getting started guide](https://github.com/microsoft/waza/blob/main/docs/GETTING-STARTED.md)
- [CI/CD integration guide](https://github.com/microsoft/waza/blob/main/docs/SKILLS_CI_INTEGRATION.md)
- [Integration testing (Copilot SDK)](https://github.com/microsoft/waza/blob/main/docs/INTEGRATION-TESTING.md)
- [Eval schema](https://raw.githubusercontent.com/microsoft/waza/v0.38.0/schemas/eval.schema.json)
- [Task schema](https://raw.githubusercontent.com/microsoft/waza/v0.38.0/schemas/task.schema.json)
