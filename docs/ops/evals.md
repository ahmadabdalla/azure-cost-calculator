# Skill Evaluations: Operations Guide

Automated evaluation of the Azure Cost Calculator skill using [Waza](https://github.com/microsoft/waza), a CLI for benchmarking AI agent skills.

| Item             | Detail                                           |
| ---------------- | ------------------------------------------------ |
| Workflow         | `.github/workflows/eval.yml`                     |
| Eval suite       | `evals/azure-cost-calculator/eval.yaml`          |
| Task files       | `evals/azure-cost-calculator/tasks/*.yaml`       |
| Project config   | `.waza.yaml`                                     |
| Auth secret      | `COPILOT_GITHUB_TOKEN`                           |
| Results artifact | Downloaded from Actions tab after a dispatch run |

## What it does

Runs structured test cases against the skill to validate behavior that deterministic tests (Pester, bats, YAML validation) cannot cover: prompt handling, disambiguation protocol adherence, service routing, and trigger specificity.

## Prerequisites

- [Waza CLI](https://github.com/microsoft/waza/releases) v0.23.0 or later
- `COPILOT_GITHUB_TOKEN`: fine-grained PAT with "Copilot Requests" permission (for `waza run`; not needed for `waza check`)
- `bash`, `curl` available locally or in the CI runner

## Evaluation tasks

| Category         | Task file                      | Validates                                                                                |
| ---------------- | ------------------------------ | ---------------------------------------------------------------------------------------- |
| Happy path       | `happy-path-app-service.yaml`  | Complete cost estimate with assumptions block, correct service name, currency formatting |
| Disambiguation   | `disambiguation-required.yaml` | Agent asks for never-assume parameters before estimating                                 |
| Alias routing    | `alias-routing.yaml`           | Resolves "CosmosDB" alias to "Azure Cosmos DB"                                           |
| Negative trigger | `should-not-trigger.yaml`      | Unrelated prompt does not activate the skill                                             |
| Adjacent topic   | `negative-adjacent-topic.yaml` | Azure-related non-pricing prompt does not activate                                       |

## How to run

```bash
# Install Waza (pinned version; see https://github.com/microsoft/waza/releases)
# Binary names: waza-darwin-arm64, waza-darwin-amd64, waza-linux-amd64
WAZA_VERSION="v0.23.0"
mkdir -p ~/bin
curl -fsSL "https://github.com/microsoft/waza/releases/download/${WAZA_VERSION}/waza-darwin-arm64" -o ~/bin/waza
chmod +x ~/bin/waza

# Validate eval YAML (no agent execution)
waza check

# Run with Copilot SDK (real AI model)
# Option 1: env var (headless, CI-compatible)
export COPILOT_GITHUB_TOKEN="<fine-grained-pat-with-copilot-requests>"
waza run --verbose --output results.json

# Option 2: interactive login (stores token in credential store)
copilot login
waza run --verbose --output results.json

# Run a specific tag
waza run --tag happy-path

# Compare results across models
waza run --model claude-sonnet-4.6 -o results-sonnet.json
waza run --model claude-opus-4.6 -o results-opus.json
waza compare results-sonnet.json results-opus.json

# Compare token budget against a baseline
waza tokens compare origin/dev HEAD --format table
```

## CI integration

Three jobs in `.github/workflows/eval.yml`:

| Trigger                                      | Job                    | Executor      | What runs                                                     |
| -------------------------------------------- | ---------------------- | ------------- | ------------------------------------------------------------- |
| PR to `dev`/`main` (evals or skills changed) | `validate-eval-schema` | n/a           | `waza check` (schema validation, no agent execution)          |
| PR to `dev`/`main` (after schema passes)     | `evaluate-mock`        | `mock`        | `waza run` with simulated responses (validates eval pipeline) |
| Manual dispatch                              | `run-evals`            | `copilot-sdk` | `waza run` with real AI model and optional tag filter         |

### Mock executor (PR checks)

The mock executor simulates agent responses without authentication. It validates eval YAML parsing, grader configuration, and the end-to-end pipeline. Positive tests (happy path, disambiguation, alias routing) fail under mock because the simulated response does not contain real AI output; this is expected. Negative tests (trigger mode: negative) pass because mock does not activate skills. The mock job uses `continue-on-error: true` so failures appear in the summary without blocking the PR.

### Copilot SDK executor (dispatch)

The Copilot SDK executor runs real AI model evaluations. Authentication uses the `COPILOT_GITHUB_TOKEN` secret: a fine-grained PAT with "Copilot Requests" permission (same secret used by the issue-triage and weekly-release workflows). The embedded Copilot CLI checks env vars in order of precedence: `COPILOT_GITHUB_TOKEN`, `GH_TOKEN`, `GITHUB_TOKEN`.

Results are uploaded as downloadable artifacts (retained 30 days) and displayed in the GitHub Actions Step Summary.

## Grader types in use

| Grader             | Purpose                              | Variance risk                                              |
| ------------------ | ------------------------------------ | ---------------------------------------------------------- |
| `text`             | String/regex matching on output      | None (deterministic)                                       |
| `prompt`           | LLM-as-judge for qualitative checks  | Non-deterministic; use `trials_per_task: 3` for production |
| `behavior`         | Required tools, max tool calls       | None if tool names are stable                              |
| `trigger`          | Skill activation/deactivation        | None (deterministic)                                       |
| `skill_invocation` | Verify correct skill is invoked      | None                                                       |
| `code` (planned)   | Python assertions for numeric checks | None; preferred over `prompt` for cost accuracy            |

## Adding a new eval task

1. Create a YAML file in `evals/azure-cost-calculator/tasks/`
2. Add the schema comment: `# yaml-language-server: $schema=https://raw.githubusercontent.com/microsoft/waza/main/schemas/task.schema.json`
3. Required fields: `id`, `name`, `inputs.prompt`
4. Add graders matching the validation need (see table above)
5. Run `waza check` to validate before committing

## Known limitations

| Limitation                                                                       | Impact                                 | Mitigation                                                                               |
| -------------------------------------------------------------------------------- | -------------------------------------- | ---------------------------------------------------------------------------------------- |
| Prompt grader timeout (default 60s) may be too short for judge model evaluation  | Tasks with long responses fail grading | Increase `timeout_seconds` in eval config or task-level overrides                        |
| Prompt grader variance on borderline cost values                                 | Flaky results on numeric assertions    | Use `code` grader for numeric checks; reserve `prompt` grader for qualitative assessment |
| SKILL.md exceeds Waza's 500-token agentskills.io recommendation (3800 tokens)    | `waza check` warns but does not block  | Intentional: skill carries domain-specific reference architecture                        |
| `argument-hint` and `compatibility` frontmatter diverge from agentskills.io spec | Spec compliance warnings               | Project convention; not blocking for evals                                               |

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `copilot is not authenticated` | `COPILOT_GITHUB_TOKEN` not set or missing permission | Create fine-grained PAT with "Copilot Requests" permission; add as repo secret |
| `waza check` schema errors | Missing required fields in task YAML | Verify `id`, `name`, `inputs.prompt` present; check `$schema` URL in file header |
| `waza run` permission denied | Token lacks Copilot Requests scope | Generate new fine-grained PAT with the correct permission |
| Prompt grader scores 0 unexpectedly | Grader criteria too strict or inverted | Run `waza run --tag <task-tag> --verbose` locally; review grader prompt wording |
| Tasks skipped or results empty | Tag filter mismatch or output path | Verify `--tag` matches task tags; check output directory is writable |
| No results artifact after dispatch | `waza run` failed before writing output | Check `waza run` exit code in Actions log; verify eval.yaml executor and paths |

## References

- [Waza documentation](https://microsoft.github.io/waza/)
- [Getting started guide](https://github.com/microsoft/waza/blob/main/docs/GETTING-STARTED.md)
- [CI/CD integration guide](https://github.com/microsoft/waza/blob/main/docs/SKILLS_CI_INTEGRATION.md)
- [Integration testing (Copilot SDK)](https://github.com/microsoft/waza/blob/main/docs/INTEGRATION-TESTING.md)
- [Eval schema](https://raw.githubusercontent.com/microsoft/waza/main/schemas/eval.schema.json)
- [Task schema](https://raw.githubusercontent.com/microsoft/waza/main/schemas/task.schema.json)
