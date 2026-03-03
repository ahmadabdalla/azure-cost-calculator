# Plugin Agents

Standalone agent files shipped with the plugin for end-user cost estimation workflows. These are distinct from the [CI/ops custom agents](ops/custom-agents.md) that manage this repository.

## Overview

This repository has two separate agent systems serving different audiences:

| Aspect     | Plugin agents (`agents/`)                      | CI agents (`.github/agents/`)        |
| ---------- | ---------------------------------------------- | ------------------------------------ |
| Audience   | Plugin consumers                               | Repository maintainers               |
| Platform   | Copilot CLI + Claude Code                      | GitHub Copilot coding agent          |
| Purpose    | Azure cost estimation                          | Service reference authoring & review |
| Loaded via | `plugin.json` → `"agents": "./agents/"`        | GitHub default branch                |
| Invocation | Local terminal                                 | Hosted on GitHub infrastructure      |
| Context    | Plugin files only (skill, scripts, references) | Full repo access, issue/PR context   |

Plugin agents are **not** copies of the CI agents — they are purpose-built for consumers who install the plugin and need cost estimation help.

## Agent inventory

| File                            | Name          | Role                                                               |
| ------------------------------- | ------------- | ------------------------------------------------------------------ |
| `agents/cost-analyst.agent.md`  | cost-analyst  | Performs Azure cost assessments for architectures and requirements |
| `agents/cost-reviewer.agent.md` | cost-reviewer | Validates cost assessments for accuracy and completeness           |

### cost-analyst

The primary user-facing agent. Invoked when a user provides an architecture, deployment plan, or set of Azure resource requirements and needs a cost estimate. Uses the skill's pricing scripts (`Get-AzurePricing`, `Explore-AzurePricing`) to query the Azure Retail Prices API.

### cost-reviewer

A quality gate agent invoked by cost-analyst to validate an assessment before presenting it to the user. Checks arithmetic accuracy, completeness, and correct use of pricing data.

### Subagent spawning constraint

The cost-analyst → cost-reviewer dispatch relies on the `Agent` tool (Claude Code) or `task` tool (Copilot CLI). This works when cost-analyst is the **main agent** (e.g., `claude --agent cost-analyst`), but **not** when cost-analyst is itself running as a subagent — subagents cannot spawn other subagents in Claude Code.

| Invocation path                                     | cost-reviewer dispatch | Why                                       |
| --------------------------------------------------- | ---------------------- | ----------------------------------------- |
| `claude --agent cost-analyst`                       | Works                  | cost-analyst is the main thread           |
| User prompt auto-delegates to cost-analyst          | Works                  | cost-analyst is a top-level subagent      |
| Another agent dispatches cost-analyst as a subagent | **Fails silently**     | Nested subagent spawning is not supported |

**Design implication**: The system prompt for cost-analyst should handle the case where cost-reviewer dispatch fails — either by inlining review checks or by noting that review was skipped.

---

## File naming convention

| Platform        | Extension               | ID derivation                      | Example                                         |
| --------------- | ----------------------- | ---------------------------------- | ----------------------------------------------- |
| **Copilot CLI** | `*.agent.md` (required) | Strips `.agent.md` from filename   | `cost-analyst.agent.md` → ID `cost-analyst`     |
| **Claude Code** | `*.md` (any markdown)   | Uses `name` field from frontmatter | `cost-analyst.agent.md` → name from frontmatter |

**Cross-platform solution**: Always use `*.agent.md`.

- Copilot CLI requires it — the extension is how it discovers and identifies agents.
- Claude Code discovers agents via the `agents/**/*.md` glob pattern. Files ending in `.agent.md` match because they end in `.md`.

> **Validated**: Anthropic's own [`plugin-validator`](https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/agents/plugin-validator.md) agent uses `agents/**/*.md` for discovery. No extension-specific filtering — validation is on YAML frontmatter content, not filename pattern.

## File format

Agent files use YAML frontmatter followed by a Markdown body (the system prompt):

```yaml
---
name: agent-name
description: "Single-line description of when to invoke this agent."
---
You are an Azure cost analyst. Your system prompt goes here.
```

### YAML frontmatter reference

The full set of supported fields differs between platforms. Fields marked ✅ are supported; fields marked ❌ are not documented for that platform. Both platforms ignore unknown fields, so a superset frontmatter is safe.

| Field                      | Copilot CLI                      | Claude Code                                           | Notes                                         |
| -------------------------- | -------------------------------- | ----------------------------------------------------- | --------------------------------------------- |
| `name`                     | ✅ Used                          | ✅ **Required**                                       | Unique identifier, kebab-case                 |
| `description`              | ✅ Used                          | ✅ **Required**                                       | When to delegate; used for inference matching |
| `tools`                    | ✅ JSON array `["bash", "edit"]` | ✅ Comma string `Read, Glob, Grep`                    | **Different format** — see below              |
| `model`                    | ✅ Supported                     | ✅ `sonnet`/`opus`/`haiku`/`inherit`                  |                                               |
| `user-invocable`           | ✅ Boolean                       | ❌                                                    | Copilot CLI only                              |
| `disable-model-invocation` | ✅ Boolean                       | ❌                                                    | Copilot CLI only                              |
| `metadata`                 | ✅ Object                        | ❌                                                    | Copilot CLI only                              |
| `disallowedTools`          | ❌                               | ✅ Optional                                           | Claude Code only                              |
| `permissionMode`           | ❌                               | ✅ `default`/`acceptEdits`/`bypassPermissions`/`plan` | Claude Code only                              |
| `maxTurns`                 | ❌                               | ✅ Integer                                            | Claude Code only                              |
| `skills`                   | ❌                               | ✅ Skill names array                                  | Claude Code only                              |
| `mcpServers`               | ❌                               | ✅ MCP server config                                  | Claude Code only                              |
| `hooks`                    | ❌                               | ✅ Lifecycle hooks                                    | Claude Code only                              |
| `memory`                   | ❌                               | ✅ `user`/`project`/`local`                           | Claude Code only                              |
| `background`               | ❌                               | ✅ Boolean                                            | Claude Code only                              |
| `isolation`                | ❌                               | ✅ `worktree`                                         | Claude Code only                              |

**Current approach**: Keep frontmatter to the shared subset (`name` + `description`). Add platform-specific fields only when needed and tested.

### Tool naming divergence

Copilot CLI and Claude Code use different names for the same tools:

| Concept         | Copilot CLI | Claude Code      |
| --------------- | ----------- | ---------------- |
| Run shell       | `bash`      | `Bash`           |
| Read files      | `view`      | `Read`           |
| Edit files      | `edit`      | `Edit` / `Write` |
| Search contents | `rg`        | `Grep`           |
| Find files      | `glob`      | `Glob`           |
| Dispatch agent  | `task`      | `Agent`          |

There is no single `tools` list that satisfies both platforms. Unknown tool names are silently ignored.

**Current approach**: Omit `tools` entirely — both platforms inherit all available tools when the field is absent. Tool scoping will be added when agents are fleshed out with full prompts, using platform-specific testing to validate.

**Intended tool scoping** (for future implementation):

- `cost-analyst`: shell execution (pricing scripts), file reading, file searching, agent dispatch (to cost-reviewer)
- `cost-reviewer`: file reading, file searching only (no shell, no edit — principle of least privilege)

### VS Code parser constraints

The VS Code agent parser is strict about formatting:

- **No YAML folded scalars** (`>` or `|`) — causes "Unexpected indentation" errors. Use single-line quoted strings instead.
- **Supported VS Code attributes**: `agents`, `argument-hint`, `description`, `disable-model-invocation`, `handoffs`, `model`, `name`, `target`, `tools`, `user-invokable`. Unknown fields produce warnings in the editor but are harmless at runtime.

---

## Loading precedence

Plugin agents have the lowest priority in both platforms. Project-level agents always override plugin agents if they share the same name.

### Copilot CLI

```
1. ~/.copilot/agents/           (user)
2. <project>/.github/agents/    (project)        ← CI agents live here
3. <parents>/.github/agents/    (inherited)
4. ~/.claude/agents/            (user, claude)
5. <project>/.claude/agents/    (project, claude)
6. <parents>/.claude/agents/    (inherited, claude)
7. PLUGIN: agents/              (plugin)          ← plugin agents live here
8. Remote org/enterprise agents (remote)
```

### Claude Code

```
1. --agents CLI flag            (session, highest)
2. .claude/agents/              (project)
3. ~/.claude/agents/            (user)
4. PLUGIN: agents/              (plugin, lowest)  ← plugin agents live here
```

**Implication**: Maintainers working in this repository see the CI agents (`.github/agents/`, priority 2) rather than plugin agents (priority 7). External consumers who install the plugin only see the `agents/` files.

---

## Consumer runtime considerations

Plugin agents run in the consumer's environment after plugin installation. Two things differ from how agents behave during development in this repository.

### Path resolution

When a consumer installs the plugin, files land in a platform-managed plugin directory — not the consumer's project root. Agent system prompts must use **relative paths from the plugin root** to reference skill files:

| Resource           | Relative path from plugin root                                  |
| ------------------ | --------------------------------------------------------------- |
| Pricing scripts    | `skills/azure-cost-calculator/scripts/Get-AzurePricing.ps1`     |
| Discovery scripts  | `skills/azure-cost-calculator/scripts/Explore-AzurePricing.ps1` |
| Service references | `skills/azure-cost-calculator/references/services/`             |
| Shared context     | `skills/azure-cost-calculator/references/shared.md`             |
| Skill entry point  | `skills/azure-cost-calculator/SKILL.md`                         |

The agent system prompt should instruct the agent to discover these paths relative to its own location rather than assuming a fixed absolute path. Both platforms provide plugin-relative path resolution, but the exact mechanism should be validated during agent development.

### Permissions inheritance

Plugin agents inherit the **consumer's** permission settings, not this repository's. This has practical consequences:

- **Shell execution**: cost-analyst needs to run pricing scripts via `Bash` (for both `pwsh` and shell invocations). Consumers must allowlist the relevant commands — e.g., `Bash(pwsh -File */scripts/Get-AzurePricing.ps1 *)` for PowerShell or `Bash(*/scripts/get-azure-pricing.sh *)` for Bash. Without these, each script call will prompt for permission or be denied.
- **No plugin-level permission override**: Plugins cannot force-allow shell commands in the consumer's environment. The `permissionMode` frontmatter field controls the agent's _own_ permission behavior, not what the host allows.
- **First-run friction**: Consumers using cost-analyst for the first time will likely see permission prompts for script execution. The agent's system prompt (or plugin documentation) should anticipate this.

**Mitigation options** (to implement when agents are fleshed out):

1. **Document required permissions** in the plugin README so consumers can pre-configure their allowlist for their chosen runtime (`pwsh` or `bash`).
2. **Graceful degradation** in the system prompt — if script execution is denied, instruct the agent to explain what permissions are needed rather than failing silently.
3. **Runtime detection** — the agent system prompt should detect available runtimes (`pwsh` vs `bash`) and use whichever is present, falling back with a clear error if neither is available.

---

## How to make changes

1. Edit the agent file in `agents/`.
2. Keep frontmatter to the shared subset (`name`, `description`). Add `tools` or `model` only when needed for both platforms.
3. The Markdown body is the system prompt — keep it focused and under 30,000 characters.
4. Use single-line quoted strings for `description` (no YAML folded scalars).
5. Test locally by invoking the agent in both Copilot CLI and Claude Code (if available).
6. Push changes via PR targeting `dev`.

---

## Platform documentation

### GitHub Copilot (Copilot CLI)

- [Plugin Reference](https://docs.github.com/en/copilot/reference/cli-plugin-reference) — agent fields, loading order, full specification
- [Creating Plugins](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-creating) — agent file format and structure

### Claude Code

- [Sub-agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents) — full frontmatter reference, discovery, dispatch
- [Plugins](https://docs.anthropic.com/en/docs/claude-code/plugins) — plugin structure including agent directories

### GitHub Copilot coding agent (different system — for reference)

The CI agents in `.github/agents/` use the GitHub Copilot coding agent platform, which has its own specification:

- [Custom agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents)
- [Custom agents configuration](https://docs.github.com/en/copilot/reference/custom-agents-configuration)

---

## Related

- [CI/ops custom agents](ops/custom-agents.md) — repository governance agents in `.github/agents/`
- [Plugin manifest](../skills/azure-cost-calculator/SKILL.md) — skill entry point
- Issue [#441](https://github.com/ahmadabdalla/azure-cost-calculator/issues/441) — SKILL.md frontmatter alignment
