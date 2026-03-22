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

# Run full evals (requires GITHUB_TOKEN with Copilot SDK permissions)
export GITHUB_TOKEN="<token>"
waza run

# Run a specific tag
waza run --tag happy-path

# Compare token budget against a baseline
waza tokens compare origin/dev HEAD --format table
```

## CI integration

Two jobs in `.github/workflows/eval.yml`:

| Trigger                                      | Job                  | What runs                                                 |
| -------------------------------------------- | -------------------- | --------------------------------------------------------- |
| PR to `dev`/`main` (evals or skills changed) | `validate-eval-yaml` | `waza check` (schema validation only, no agent execution) |
| Manual dispatch                              | `run-evals`          | `waza run` with model selection and optional tag filter   |

Full agent execution evals are manual-dispatch only to avoid rate-limit exposure and latency on every PR. Schema validation runs automatically.

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
