# Skill Evaluations: Operations Guide

Automated evaluation of the Azure Cost Calculator skill using [Waza](https://github.com/microsoft/waza), a CLI for benchmarking AI agent skills. Validates behavior that deterministic tests (Pester, bats, YAML validation) cannot cover: prompt handling, disambiguation, service routing, and trigger specificity.

| Item             | Detail                                                                                                      |
| ---------------- | ----------------------------------------------------------------------------------------------------------- |
| Workflow         | `.github/workflows/eval.yml`                                                                                |
| Composite action | `.github/actions/install-waza/action.yml`                                                                   |
| Eval suite       | `tests/evals/azure-cost-calculator/eval.yaml` (copilot-sdk), `tests/evals/azure-cost-calculator/eval-mock.yaml` (mock) |
| Task files       | `tests/evals/azure-cost-calculator/tasks/*/*.yaml` and `tests/evals/azure-cost-calculator/tasks/*/*/*.yaml` |
| Project config   | `.waza.yaml`                                                                                                |
| Auth secret      | `COPILOT_GITHUB_TOKEN` (fine-grained PAT, "Copilot Requests" permission)                                    |

## Read this first

Use this section order when working with evals:

1. **Run locally:** [Quick start](#quick-start)
2. **Understand CI behavior:** [CI pipeline](#ci-pipeline)
3. **Create or update tests:** [Adding a task](#adding-a-task) + [Authoring pattern](#authoring-pattern)
4. **Debug failures:** [Troubleshooting](#troubleshooting)
5. **Upgrade safely:** [Known limitations](#known-limitations)

### Contributor workflow (fast path)

1. Pick the service reference and identify traps (shared serviceName, global region, daily meters, no meters).
2. Select one core scenario pack and any needed exception pack.
3. Run `waza suggest` to scaffold a starting task YAML (see [Quick start](#quick-start)); review and adjust to project conventions before use.
4. Author the task with required tags (`service:<name>`, category, scenario).
5. Run `waza check`.
6. Run a targeted eval: `waza run --tags "service:<name>" --output results/results.json`.
7. Open PR and review CI artifacts for `evaluate-mock` and `evaluate-critical`.

## Quick start

Install Waza for your platform, then run evaluations locally.

```bash
WAZA_VERSION="v0.23.0"
mkdir -p ~/bin

# macOS (Apple Silicon)
curl -fsSL "https://github.com/microsoft/waza/releases/download/${WAZA_VERSION}/waza-darwin-arm64" -o ~/bin/waza

# macOS (Intel)
# curl -fsSL "https://github.com/microsoft/waza/releases/download/${WAZA_VERSION}/waza-darwin-amd64" -o ~/bin/waza

# Linux (amd64)
# curl -fsSL "https://github.com/microsoft/waza/releases/download/${WAZA_VERSION}/waza-linux-amd64" -o ~/bin/waza

chmod +x ~/bin/waza

# Validate YAML (no LLM calls)
waza check

# Scaffold a new task from SKILL.md (requires COPILOT_GITHUB_TOKEN; --dry-run is the default)
export COPILOT_GITHUB_TOKEN="<your-pat>"
waza suggest skills/azure-cost-calculator --dry-run

# Run evals with real AI
waza run --verbose --output results/results.json

# Run a specific service
waza run --tags "service:virtual-machines" --output results/results.json
```

## Task structure

Tasks mirror the skill's service reference hierarchy. One prompt per file; one directory per service.

```
tasks/
├── smoke/                              Core skill behavior (4 tasks)
│   ├── alias-routing.yaml
│   ├── disambiguation-sql.yaml
│   ├── negative-adjacent-topic.yaml
│   └── should-not-trigger.yaml
├── compute/
│   ├── app-service/
│   │   └── linux-p1-v3.yaml
│   └── virtual-machines/
│       ├── windows-d4s-v5.yaml
│       └── linux-b2s-multi-instance.yaml
└── databases/
    └── cosmos-db/
        └── provisioned-throughput.yaml
```

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

| Job                           | Executor      | What it does                                     | LLM calls |
| ----------------------------- | ------------- | ------------------------------------------------ | --------- |
| `validate-eval-schema`        | n/a           | `waza check` (schema validation only)            | 0         |
| `evaluate-mock`               | `mock`        | Runs `--tags negative` only; validates trigger grader wiring | 0         |
| `evaluate-critical`           | `copilot-sdk` | Real AI evals; only tasks matching changed files | 0-8       |
| `run-evals` (manual dispatch) | `copilot-sdk` | All tasks by default; optional comma-separated tag filter   | up to 8   |

### How `evaluate-critical` targets tasks

The workflow uses [dorny/paths-filter](https://github.com/dorny/paths-filter) to detect which files changed, then maps them to Waza tags:

| Changed file                                                        | Tag triggered | Tasks run                    |
| ------------------------------------------------------------------- | ------------- | ---------------------------- |
| `skills/azure-cost-calculator/SKILL.md`, `agents/**`, `commands/**` | `smoke`       | 4 smoke tasks                |
| `skills/azure-cost-calculator/references/shared.md`                 | `smoke`       | 4 smoke tasks                |
| `skills/azure-cost-calculator/references/service-routing.md`        | `routing`     | alias-routing                |
| `skills/azure-cost-calculator/references/services/**/X.md`          | `service:X`   | All tasks tagged `service:X` |
| `skills/azure-cost-calculator/scripts/**`                           | `smoke`       | 4 smoke tasks                |
| `tests/evals/**`                                                    | `smoke`       | 4 smoke tasks                |

Service names are extracted from filenames dynamically (`basename virtual-machines.md .md` becomes `--tags service:virtual-machines`). Multiple tags are OR'd.

**Cost examples:**

| PR scenario                                    | LLM calls |
| ---------------------------------------------- | --------- |
| Single service file (e.g. virtual-machines.md) | 2         |
| Docs-only change                               | 0         |
| SKILL.md + 1 service file                      | 6         |
| Eval task or grader change                     | 4         |
| Manual dispatch (all 8 tasks x 1 trial)        | 8         |

The job requires `COPILOT_GITHUB_TOKEN`; skips with a notice if not configured. `continue-on-error: true` prevents eval failures from blocking PRs while graders are being tuned.

**To extend:** add a filter in the `Detect critical file changes` step and map it to tags in `Build eval scope`. New tasks are picked up automatically if their tags match.

### Mock executor

Runs only `--tags negative` tasks. Negative tests pass deterministically under mock because the mock executor never activates skills. Positive tests are excluded: they require real AI output and always fail under mock, producing no actionable signal. `waza check` (run in `validate-eval-schema`) already covers schema and grader config validation.

The mock executor is configured in `eval-mock.yaml` alongside `eval.yaml`. Both files share the same task globs; the only difference is `executor: mock`. This avoids mutating `eval.yaml` in CI.

### Copilot SDK executor

Runs real AI evaluations. Auth priority: `COPILOT_GITHUB_TOKEN` > `GH_TOKEN` > `GITHUB_TOKEN`. Results are uploaded as artifacts (30-day retention) and displayed in the Actions Step Summary.

## Graders

| Grader             | Purpose                                               | Deterministic |
| ------------------ | ----------------------------------------------------- | ------------- |
| `text`             | String/regex matching on output                       | Yes |
| `behavior`         | Required tools by name, max tool calls                | Yes; do NOT use for script invocation — tool name is `bash`, not the script filename |
| `tool_constraint`  | Tool name + optional command pattern (regex on args)  | Yes; use for pricing script invocation (see snippet below) |
| `trigger`          | Skill activation/deactivation                         | Yes |
| `skill_invocation` | Correct skill invoked                                 | Yes |
| `prompt`           | LLM-as-judge for qualitative checks                   | No; set task-level `timeout_seconds: 30` to prevent mock hangs |
| `code` (planned)   | Python assertions for numeric accuracy                | Yes |

### Standard graders for happy-path tasks

Every happy-path task must include the `uses-pricing-script` grader. The Bash tool reports as `bash` in session tool names — not as the script filename. `behavior.required_tools` cannot match script names and silently passes without asserting anything. Use `tool_constraint` instead:

```yaml
- type: tool_constraint
  name: uses-pricing-script
  config:
    expect_tools:
      - tool: bash
        command_pattern: "get-azure-pricing\\.sh"
  weight: 1.0
```

This grader is intentionally identical across all happy-path tasks. Copy it verbatim. Do not substitute `behavior.required_tools`.

## Adding a task

1. Create the file at `tasks/<category>/<service>/<scenario>.yaml`
2. Set `id: eval:<category>/<service>/<scenario>`
3. Add tags: `service:<service-name>` + category tag at minimum
4. Add `inputs.prompt` and graders
5. Run `waza check` to validate

For smoke tests: `tasks/smoke/<scenario>.yaml` with `id: eval:smoke/<scenario>` and the `smoke` tag.

Tip: use `waza suggest skills/azure-cost-calculator --dry-run` to scaffold a starting task YAML from SKILL.md. Review the output and adjust to project conventions (ID format, tags, graders) before writing the file. See [Known limitations](#known-limitations) for what `waza suggest` does not generate correctly.

## Authoring pattern

Use a pack-based pattern so new service tests are consistent and easy to extend.

### Core scenario packs

| Pack                      | Required intent                                                    | Minimum tags                                 |
| ------------------------- | ------------------------------------------------------------------ | -------------------------------------------- |
| `smoke-routing`           | Alias or route resolves to the right service                       | `smoke`, `routing`, `service:<name>`         |
| `smoke-disambiguation`    | Missing "never-assume" parameters trigger a clarification question | `smoke`, `disambiguation`                    |
| `happy-path-single-meter` | One primary meter estimate with assumptions and monthly output     | `<category>`, `service:<name>`, `happy-path` |
| `happy-path-multi-meter`  | Multi-component estimate with component breakdown and total        | `<category>`, `service:<name>`, `happy-path` |
| `negative-trigger`        | Non-pricing prompt does not activate the skill                     | `smoke`, `negative`                          |

### Exception packs

Use these only when a service reference documents the corresponding trap.

| Exception pack              | When to use                                                    | Typical assertion                             |
| --------------------------- | -------------------------------------------------------------- | --------------------------------------------- |
| `cross-service-name`        | API `serviceName` is shared across multiple products           | `ProductName` filter is present and correct   |
| `global-region-only`        | Meters bill only in `Global` region                            | Query includes `Region: Global`               |
| `daily-meter-normalization` | Meters bill per-day instead of per-hour                        | Daily meter is normalized to monthly once     |
| `no-retail-meters`          | Service has no retail API meters and depends on `billingNeeds` | Skill does not fabricate direct meter pricing |

### Task contract

Every task should satisfy this contract:

1. Path: `tasks/<category>/<service>/<scenario>.yaml` or `tasks/smoke/<scenario>.yaml`
2. ID: `eval:<category>/<service>/<scenario>` or `eval:smoke/<scenario>`
3. Tags: always include `service:<service-name>` for service tasks plus category and scenario tags
4. Assertions: include at least one deterministic grader (`text`, `tool_constraint`, `trigger`, or `skill_invocation`); do not use `behavior` for script invocation (see [Graders](#graders))
5. Happy-path tasks: include the standard `uses-pricing-script` `tool_constraint` grader (see [Standard graders](#standard-graders-for-happy-path-tasks))
6. Validation: `waza check` must pass before PR submission

### Service mapping rule

For each service reference file:

1. Include at least one core happy-path pack
2. Include smoke coverage (`smoke-routing` or `smoke-disambiguation`) where applicable
3. Add exception packs only for documented traps in that service file
4. Add `negative-trigger` coverage for adjacent non-pricing prompts at the suite level

### Definition of done

A new or updated service is eval-ready when:

1. Required pack(s) are present and tagged correctly
2. `service:<name>` tag matches the service reference filename
3. `waza check` passes with no schema errors
4. The task set includes deterministic checks, not only prompt-judge checks
5. Every happy-path task includes the `uses-pricing-script` `tool_constraint` grader

### PR checklist (copy into description)

1. Added or updated task files under `tests/evals/azure-cost-calculator/tasks/**`
2. Task IDs and tags follow the contract (`service:<name>` matches filename)
3. Required scenario and exception packs are covered
4. Every happy-path task includes the `uses-pricing-script` `tool_constraint` grader
5. `waza check` passes locally
6. Targeted run completed for changed service tags
7. CI artifacts reviewed (`eval-results-mock`, `eval-results-critical` when applicable)

### Reference mappings

Examples from current service references:

| Service reference             | Core packs                       | Exception packs                                   |
| ----------------------------- | -------------------------------- | ------------------------------------------------- |
| `compute/app-service.md`      | `happy-path-single-meter`        | None                                              |
| `networking/ip-addresses.md`  | `happy-path-single-meter`        | `cross-service-name`                              |
| `storage/data-box-gateway.md` | `happy-path-single-meter`        | `cross-service-name`, `daily-meter-normalization` |
| `management/migrate.md`       | `negative-trigger` (suite-level) | `no-retail-meters`                                |

## Known limitations

| Limitation                                                                                                                              | Mitigation                                                                                                                                                                                         |
| --------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Prompt grader timeout too short for long responses (waza default is 60s; this project sets 300s globally)                               | Override per task with `config.timeout_seconds` if a specific task needs more or less                                                                                                              |
| Prompt grader variance on borderline values                                                                                             | Use `code` grader for numeric checks                                                                                                                                                               |
| `**` glob not supported recursively in waza v0.23.0: tasks at depth 2+ silently skipped                                                 | Use explicit depth patterns: `tasks/*/*.yaml` and `tasks/*/*/*.yaml`                                                                                                                               |
| `yaml-language-server: $schema` URLs and docs schema links are pinned to `v0.23.0`: editor validation will not reflect upstream changes | When upgrading waza, update the version in `.github/actions/install-waza/action.yml`, then update all `$schema` URLs in `eval.yaml`, `.waza.yaml`, and all task files to match the new release tag |
| `currency-format` regex (`\$[\d,]+\.\d{2}`) assumes USD output                                                                         | Tasks targeting non-USD regions (e.g. West Europe returns EUR) will fail this grader; use a USD region in the prompt, or update the regex to match the expected currency symbol                    |
| SKILL.md exceeds Waza 500-token recommendation (3800 tokens)                                                                            | Intentional; skill carries domain reference architecture                                                                                                                                           |
| `argument-hint` frontmatter diverges from agentskills.io spec                                                                           | Project convention; not blocking for evals                                                                                                                                                         |
| `waza suggest` output directory defaults to `<skill-path>/evals` (i.e. `skills/azure-cost-calculator/evals`)                            | Pass `--output-dir tests/evals/azure-cost-calculator` to place files in the correct location                                                                                                        |
| `waza suggest` generates task IDs, globs, and graders that diverge from project conventions                                             | Treat output as a scaffold only: rename IDs to `eval:<category>/<service>/<scenario>`, add correct tags, replace any prompt grader model references, and add the standard `uses-pricing-script` `tool_constraint` grader |

## Troubleshooting

| Symptom                             | Fix                                                                            |
| ----------------------------------- | ------------------------------------------------------------------------------ |
| `copilot is not authenticated`      | Create fine-grained PAT with "Copilot Requests" permission; add as repo secret |
| `waza check` schema errors          | Verify `id`, `name`, `inputs.prompt` present; check `$schema` URL              |
| Prompt grader scores 0 unexpectedly | Run `waza run --tags <tag> --verbose` locally; review grader prompt wording    |
| `uses-pricing-script` scores 0      | The task used `behavior.required_tools` instead of `tool_constraint`; replace with the standard grader (see [Standard graders](#standard-graders-for-happy-path-tasks)) |
| Tasks skipped or results empty      | Verify `--tags` matches task tags; check `results/` directory is writable      |

## Maintenance routine

Use this lightweight routine to keep the eval system easy to operate.

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
