# Skill Evaluations: Operations Guide

Automated evaluation of the Azure Cost Calculator skill using [Waza](https://github.com/microsoft/waza), a CLI for benchmarking AI agent skills. Validates behavior that deterministic tests (Pester, bats, YAML validation) cannot cover: prompt handling, disambiguation, service routing, and trigger specificity.

| Item             | Detail                                                                                                                 |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Waza version     | `v0.23.0` — see "Upgrading Waza" in Known limitations for all files that must change on version bump                   |
| Workflow         | `.github/workflows/eval.yml`                                                                                           |
| Composite action | `.github/actions/install-waza/action.yml`                                                                              |
| Eval suite       | `tests/evals/azure-cost-calculator/eval.yaml` (copilot-sdk), `tests/evals/azure-cost-calculator/eval-mock.yaml` (mock) |
| Task files       | `tests/evals/azure-cost-calculator/tasks/*/*.yaml` and `tests/evals/azure-cost-calculator/tasks/*/*/*.yaml`            |
| Project config   | `.waza.yaml`                                                                                                           |
| Auth secret      | `COPILOT_GITHUB_TOKEN` (fine-grained PAT, "Copilot Requests" permission)                                               |

## Quick start

Install Waza for your platform, then run evaluations locally.

```bash
WAZA_VERSION="v0.23.0"
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

### Mock executor

Runs only `--tags negative` tasks. Negative tests pass deterministically under mock because the mock executor never activates skills. Positive tests are excluded: they require real AI output and always fail under mock, producing no actionable signal. `waza check` (run in `validate-eval-schema`) already covers schema and grader config validation.

The mock executor is configured in `eval-mock.yaml` alongside `eval.yaml`. Both files share the same task globs; the only difference is `executor: mock`. This avoids mutating `eval.yaml` in CI.

### Copilot SDK executor

Runs real AI evaluations. Auth priority: `COPILOT_GITHUB_TOKEN` > `GH_TOKEN` > `GITHUB_TOKEN`. Results are uploaded as artifacts (30-day retention) and displayed in the Actions Step Summary.

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

**Exception:** services with `retired: true` in their reference YAML are fully decommissioned. They are exempt from the happy-path coverage requirement. Do not tag these tasks `happy-path`. The `check-eval-coverage.sh` script skips retired services automatically. If adding a task for a retired service, use a `text` grader verifying the agent communicates that the service is retired, and omit `uses-pricing-script`.

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

**Exception:** services with `retired: true` are exempt from happy-path coverage. The coverage check script skips them automatically.

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

| Limitation                                                                                               | Mitigation                                                                                                                                                                                                                                                                                                                                    |
| -------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Prompt grader (judge LLM) may time out on long responses                                                 | Override the session timeout per task with the top-level `timeout_seconds` field if a specific task consistently times out                                                                                                                                                                                                                    |
| Prompt grader variance on borderline values                                                              | Use `code` grader for numeric checks                                                                                                                                                                                                                                                                                                          |
| `**` glob not supported recursively in waza v0.23.0: tasks at depth 2+ silently skipped                  | Use explicit depth patterns: `tasks/*/*.yaml` and `tasks/*/*/*.yaml`                                                                                                                                                                                                                                                                          |
| Upgrading Waza: the version is pinned in multiple files; a partial update breaks schema validation or CI | Update all of these together: `.github/actions/install-waza/action.yml` (version + checksum), `.devcontainer/Dockerfile` (curl URL), `.waza.yaml` ($schema URL), `eval.yaml` and `eval-mock.yaml` ($schema URL), all task YAML files ($schema URL), `docs/ops/evals.md` (version row + schema links), `docs/ops/dev-container.md` (table row) |
| `currency-format` regex (`\$[\d,]+\.\d{2}`) assumes USD output                                           | Tasks targeting non-USD regions (e.g. West Europe returns EUR) will fail this grader; use a USD region in the prompt, or update the regex to match the expected currency symbol                                                                                                                                                               |
| SKILL.md exceeds Waza 500-token recommendation (3800 tokens)                                             | Intentional; skill carries domain reference architecture                                                                                                                                                                                                                                                                                      |
| `argument-hint` frontmatter diverges from agentskills.io spec                                            | Project convention; not blocking for evals                                                                                                                                                                                                                                                                                                    |
| `waza suggest` diverges from project conventions and fails intermittently                                | Do not use `waza suggest`; author tasks directly following the task contract and exemplars in this doc                                                                                                                                                                                                                                        |

## Troubleshooting

| Symptom                                                                 | Fix                                                                                                                                                                                                  |
| ----------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `copilot is not authenticated`                                          | Create fine-grained PAT with "Copilot Requests" permission; add as repo secret                                                                                                                       |
| `waza check` schema errors                                              | Verify `id`, `name`, `inputs.prompt` present; check `$schema` URL                                                                                                                                    |
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
2. If upgrading Waza, update all pinned schema URLs in eval docs and YAML files.
3. Review `Known limitations` and remove stale mitigations.
4. Review flaky prompt graders and convert high-value checks to deterministic graders where possible.

## References

- [Waza documentation](https://microsoft.github.io/waza/)
- [Getting started guide](https://github.com/microsoft/waza/blob/main/docs/GETTING-STARTED.md)
- [CI/CD integration guide](https://github.com/microsoft/waza/blob/main/docs/SKILLS_CI_INTEGRATION.md)
- [Integration testing (Copilot SDK)](https://github.com/microsoft/waza/blob/main/docs/INTEGRATION-TESTING.md)
- [Eval schema](https://raw.githubusercontent.com/microsoft/waza/v0.23.0/schemas/eval.schema.json)
- [Task schema](https://raw.githubusercontent.com/microsoft/waza/v0.23.0/schemas/task.schema.json)
