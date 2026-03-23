# Skill Evaluations: Operations Guide

Automated evaluation of the Azure Cost Calculator skill using [Waza](https://github.com/microsoft/waza), a CLI for benchmarking AI agent skills. Validates behavior that deterministic tests (Pester, bats, YAML validation) cannot cover: prompt handling, disambiguation, service routing, and trigger specificity.

| Item             | Detail                                                      |
| ---------------- | ----------------------------------------------------------- |
| Workflow         | `.github/workflows/eval.yml`                                |
| Composite action | `.github/actions/install-waza/action.yml`                   |
| Eval suite       | `evals/azure-cost-calculator/eval.yaml`                     |
| Task files       | `evals/azure-cost-calculator/tasks/**/*.yaml` (nested dirs) |
| Project config   | `.waza.yaml`                                                |
| Auth secret      | `COPILOT_GITHUB_TOKEN` (fine-grained PAT, "Copilot Requests" permission) |

## Quick start

```bash
# One-time setup
WAZA_VERSION="v0.23.0"
mkdir -p ~/bin
curl -fsSL "https://github.com/microsoft/waza/releases/download/${WAZA_VERSION}/waza-darwin-arm64" -o ~/bin/waza
chmod +x ~/bin/waza

# Validate YAML (no LLM calls)
waza check

# Run evals with real AI
export COPILOT_GITHUB_TOKEN="<your-pat>"
waza run --verbose --output results.json

# Run a specific service
waza run --tags "service:virtual-machines"
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

| Tag type | Example | Purpose |
| --- | --- | --- |
| `smoke` | `smoke` | Core skill tests; runs on broad changes |
| `service:<name>` | `service:virtual-machines` | Per-service; matches service reference filename |
| Category | `compute`, `databases` | Grouping |
| Test type | `happy-path`, `negative`, `routing` | Filtering by scenario kind |

## CI pipeline

Four jobs in `.github/workflows/eval.yml`, triggered on PRs to `dev`:

| Job | Executor | What it does | LLM calls |
| --- | --- | --- | --- |
| `validate-eval-schema` | n/a | `waza check` (schema validation only) | 0 |
| `evaluate-mock` | `mock` | Validates eval pipeline with simulated responses | 0 |
| `evaluate-critical` | `copilot-sdk` | Real AI evals; only tasks matching changed files; 1 trial | 0-8 |
| `run-evals` (manual dispatch) | `copilot-sdk` | All tasks; 3 trials each | up to 24 |

### How `evaluate-critical` targets tasks

The workflow uses [dorny/paths-filter](https://github.com/dorny/paths-filter) to detect which files changed, then maps them to Waza tags:

| Changed file | Tag triggered | Tasks run |
| --- | --- | --- |
| `SKILL.md`, `agents/**`, `commands/**` | `smoke` | 4 smoke tasks |
| `references/shared.md` | `smoke` | 4 smoke tasks |
| `references/service-routing.md` | `routing` | alias-routing |
| `references/services/**/X.md` | `service:X` | All tasks tagged `service:X` |
| `scripts/**` | `smoke` | 4 smoke tasks |

Service names are extracted from filenames dynamically (`basename virtual-machines.md .md` becomes `--tags service:virtual-machines`). Multiple tags are OR'd.

**Cost examples:**

| PR scenario | LLM calls |
| --- | --- |
| Single service file (e.g. virtual-machines.md) | 2 |
| Docs-only change | 0 |
| SKILL.md + 1 service file | 5 |
| Manual dispatch (all 8 tasks x 3 trials) | 24 |

The job requires `COPILOT_GITHUB_TOKEN`; skips with a notice if not configured. `continue-on-error: true` prevents eval failures from blocking PRs while graders are being tuned.

**To extend:** add a filter in the `Detect critical file changes` step and map it to tags in `Build eval scope`. New tasks are picked up automatically if their tags match.

### Mock executor

Validates eval YAML parsing, grader config, and pipeline without authentication. Positive tests fail under mock (no real AI output); negative tests pass (mock does not activate skills). Uses `continue-on-error: true`.

### Copilot SDK executor

Runs real AI evaluations. Auth priority: `COPILOT_GITHUB_TOKEN` > `GH_TOKEN` > `GITHUB_TOKEN`. Results are uploaded as artifacts (30-day retention) and displayed in the Actions Step Summary.

## Graders

| Grader | Purpose | Deterministic |
| --- | --- | --- |
| `text` | String/regex matching on output | Yes |
| `behavior` | Required tools, max tool calls | Yes |
| `trigger` | Skill activation/deactivation | Yes |
| `skill_invocation` | Correct skill invoked | Yes |
| `prompt` | LLM-as-judge for qualitative checks | No (use `trials_per_task: 3`) |
| `code` (planned) | Python assertions for numeric accuracy | Yes |

## Adding a task

1. Create the file at `tasks/<category>/<service>/<scenario>.yaml`
2. Set `id: eval:<category>/<service>/<scenario>`
3. Add tags: `service:<service-name>` + category tag at minimum
4. Add `inputs.prompt` and graders
5. Run `waza check` to validate

For smoke tests: `tasks/smoke/<scenario>.yaml` with `id: eval:smoke/<scenario>` and the `smoke` tag.

Tip: copy an existing task in the same category as a starting template.

## Known limitations

| Limitation | Mitigation |
| --- | --- |
| Prompt grader timeout (60s default) too short for long responses | Increase `timeout_seconds` per task |
| Prompt grader variance on borderline values | Use `code` grader for numeric checks |
| SKILL.md exceeds Waza 500-token recommendation (3800 tokens) | Intentional; skill carries domain reference architecture |
| `argument-hint` frontmatter diverges from agentskills.io spec | Project convention; not blocking for evals |

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `copilot is not authenticated` | Create fine-grained PAT with "Copilot Requests" permission; add as repo secret |
| `waza check` schema errors | Verify `id`, `name`, `inputs.prompt` present; check `$schema` URL |
| Prompt grader scores 0 unexpectedly | Run `waza run --tags <tag> --verbose` locally; review grader prompt wording |
| Tasks skipped or results empty | Verify `--tags` matches task tags; check output directory is writable |

## References

- [Waza documentation](https://microsoft.github.io/waza/)
- [Getting started guide](https://github.com/microsoft/waza/blob/main/docs/GETTING-STARTED.md)
- [CI/CD integration guide](https://github.com/microsoft/waza/blob/main/docs/SKILLS_CI_INTEGRATION.md)
- [Integration testing (Copilot SDK)](https://github.com/microsoft/waza/blob/main/docs/INTEGRATION-TESTING.md)
- [Eval schema](https://raw.githubusercontent.com/microsoft/waza/main/schemas/eval.schema.json)
- [Task schema](https://raw.githubusercontent.com/microsoft/waza/main/schemas/task.schema.json)
