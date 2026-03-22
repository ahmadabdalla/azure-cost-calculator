# Skill Evaluations: Operations Guide

Automated evaluation of the Azure Cost Calculator skill using [Waza](https://github.com/microsoft/waza), a CLI for benchmarking AI agent skills.

## What it does

Runs structured test cases against the skill to validate behavior that deterministic tests (Pester, bats, YAML validation) cannot cover: prompt handling, disambiguation protocol adherence, service routing, and trigger specificity.

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
# Install Waza
curl -fsSL https://raw.githubusercontent.com/microsoft/waza/main/install.sh | bash

# Validate eval YAML (no agent execution)
waza check

# Run with mock executor (no auth required; validates eval pipeline)
sed 's/executor: copilot-sdk/executor: mock/' evals/azure-cost-calculator/eval.yaml \
  > /tmp/eval-mock.yaml && waza run /tmp/eval-mock.yaml --verbose --output results.json

# Run with Copilot SDK (use COPILOT_GITHUB_TOKEN or copilot login)
export COPILOT_GITHUB_TOKEN="<fine-grained-pat-with-copilot-requests>"
waza run --verbose --output results.json

# Run a specific tag
waza run --tag happy-path

# Compare token budget against a baseline
waza tokens compare origin/dev HEAD --format table
```

## CI integration

Three jobs in `.github/workflows/eval.yml`:

| Trigger                                      | Job                     | Executor | What runs                                                   |
| -------------------------------------------- | ----------------------- | -------- | ----------------------------------------------------------- |
| PR to `dev`/`main` (evals or skills changed) | `validate-eval-schema`  | n/a      | `waza check` (schema validation, no agent execution)        |
| PR to `dev`/`main` (after schema passes)     | `evaluate-mock`         | `mock`   | `waza run` with simulated responses (validates eval pipeline) |
| Manual dispatch                              | `run-evals`             | `copilot-sdk` | `waza run` with real AI model and optional tag filter  |

The mock executor simulates agent responses without authentication. It validates eval YAML parsing, grader configuration, and the end-to-end pipeline. Positive tests (happy path, disambiguation, alias routing) will fail under mock because the simulated response does not contain real AI output; this is expected. Negative tests (trigger mode: negative) pass because mock does not activate skills. The mock job uses `continue-on-error: true` so failures appear in the summary without blocking the PR.

The Copilot SDK executor (`run-evals`) uses the `COPILOT_GITHUB_TOKEN` secret (same fine-grained PAT with "Copilot Requests" permission used by issue-triage and weekly-release workflows). The embedded Copilot CLI reads this env var for headless authentication.

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

| Limitation                                                                       | Impact                                  | Mitigation                                                                               |
| -------------------------------------------------------------------------------- | --------------------------------------- | ---------------------------------------------------------------------------------------- |
| SKILL.md exceeds Waza's 500-token agentskills.io recommendation (3800 tokens)    | `waza check` warns but does not block   | Intentional: skill carries domain-specific reference architecture                        |
| `argument-hint` and `compatibility` frontmatter diverge from agentskills.io spec | Spec compliance warnings                | Project convention; not blocking for evals                                               |
| Prompt grader variance on borderline cost values                                 | Flaky results on numeric assertions     | Use `code` grader for numeric checks; reserve `prompt` grader for qualitative assessment |
| No workspace debugging for program graders                                       | Slow debugging for script-based graders | Emit diagnostic stdout before assertions                                                 |

## References

- [Waza docs](https://microsoft.github.io/waza/)
- [Waza getting started](https://github.com/microsoft/waza/blob/main/docs/GETTING-STARTED.md)
