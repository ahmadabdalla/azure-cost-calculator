# Plugin and Skill Management

User guide for installing, managing, and troubleshooting plugins and skills in **GitHub Copilot CLI** and **Claude Code**.

All commands on this page are **session commands** — run them inside an interactive `copilot` or `claude` session, prefixed with `/`.

---

## Key concepts

| Concept         | What it is                                                                                                 |
| --------------- | ---------------------------------------------------------------------------------------------------------- |
| **Skill**       | A `SKILL.md` file (with optional supporting files) that teaches the agent a new capability.                |
| **Plugin**      | A package that bundles one or more skills, agents, hooks, MCP servers, or LSP servers.                     |
| **Marketplace** | A catalog of plugins you can browse and install. Think of it like an app store.                             |
| **Scope** *(Claude Code)* | Where a plugin is installed: `user` (all projects), `project` (shared via repo), or `local` (gitignored). |

> Skills installed via a plugin are managed through the plugin — use `/plugin uninstall`, not `/skills remove`.

---

## Command quick reference

### Plugin commands

| Action                         | Copilot CLI                        | Claude Code                          |
| ------------------------------ | ---------------------------------- | ------------------------------------ |
| List installed                 | `/plugin list`                     | `/plugin` → Installed tab            |
| Install from marketplace       | `/plugin install NAME@MARKETPLACE` | `/plugin install NAME@MARKETPLACE`   |
| Install from GitHub *(no marketplace)* | `/plugin install OWNER/REPO` | —  *(marketplace required)*          |
| Update one                     | `/plugin update NAME`              | `/plugin update NAME@MARKETPLACE`    |
| Update all                     | —                                  | `/plugin marketplace update MARKETPLACE` |
| Disable (keep installed)       | —                                  | `/plugin disable NAME@MARKETPLACE`   |
| Enable                         | —                                  | `/plugin enable NAME@MARKETPLACE`    |
| Uninstall                      | `/plugin uninstall NAME`           | `/plugin uninstall NAME@MARKETPLACE` |
| Reload after changes           | —                                  | `/reload-plugins`                    |

> **Claude Code** requires the `name@marketplace` format for most plugin commands. **Copilot CLI** uses just the plugin `name`.

### Marketplace commands

| Action             | Copilot CLI                          | Claude Code                          |
| ------------------ | ------------------------------------ | ------------------------------------ |
| Add marketplace    | `/plugin marketplace add OWNER/REPO` | `/plugin marketplace add OWNER/REPO` |
| List marketplaces  | `/plugin marketplace list`           | `/plugin marketplace list`           |
| Browse marketplace | `/plugin marketplace browse NAME`    | `/plugin` → Discover tab             |
| Update marketplace | —                                    | `/plugin marketplace update MARKETPLACE` |
| Remove marketplace | `/plugin marketplace remove NAME`    | `/plugin marketplace remove NAME`    |

**Claude Code shortcuts**: `/plugin market` works in place of `/plugin marketplace`. `rm` works in place of `remove`.

### Skill commands

| Action                  | Copilot CLI                      | Claude Code                    |
| ----------------------- | -------------------------------- | ------------------------------ |
| List skills             | `/skills list`                   | Type `/` and browse autocomplete, or ask *"What skills are available?"* |
| Toggle skills on/off    | `/skills`                        | —                              |
| Skill info              | `/skills info`                   | —                              |
| Reload skills           | `/skills reload`                 | `/reload-plugins`              |
| Add skill location      | `/skills add`                    | —                              |
| Remove standalone skill | `/skills remove SKILL-DIRECTORY` | Delete the skill directory     |
| Invoke a skill          | `/skill-name`                    | `/skill-name`                  |

---

## Install a plugin

There are two main paths: **marketplace install** (versioned, recommended) and **npx install** (pulls latest from `main` branch).

### Path 1 — Marketplace install (recommended)

Marketplace installs give you version pinning, changelogs, and controlled updates.

**Step 1 — Add the marketplace** (one-time setup):

```bash
/plugin marketplace add ahmadabdalla/azure-cost-calculator
```

**Step 2 — Install the plugin:**

```bash
/plugin install azure-cost-calculator@acc-plugin
```

> **Claude Code scope**: When installing via the interactive UI (`/plugin` → Discover tab), you can choose **User**, **Project**, or **Local** scope. The default is `user` (available in all projects).

**Step 3 — Verify:**

```bash
# Copilot CLI
/skills list     # should show azure-cost-calculator
/agent           # should show cost-analyst

# Claude Code
/plugin          # → Installed tab — should show azure-cost-calculator
```

#### Direct install from GitHub (Copilot CLI only)

Copilot CLI can install a plugin directly from a GitHub repo without registering a marketplace first:

```bash
/plugin install ahmadabdalla/azure-cost-calculator
```

This looks for `plugin.json` in `.github/plugin/` or `.claude-plugin/` at the repo root.

> **Claude Code** requires a marketplace. Use the marketplace install path above.

#### Claude Code interactive UI

You can also install through the plugin manager:

1. Run `/plugin`
2. Go to the **Discover** tab
3. Select a plugin and press **Enter**
4. Choose installation scope: **User**, **Project**, or **Local**

The plugin manager has four tabs: **Discover** (browse and install), **Installed** (manage), **Marketplaces** (add/remove sources), and **Errors** (loading issues).

### Path 2 — npx install

The `npx` method uses the [skills.sh](https://skills.sh) ecosystem. It pulls the latest content from the `main` branch — no version pinning, no rollback.

```bash
npx skills add ahmadabdalla/azure-cost-calculator-skill
```

> **Don't have `npx`?** Install [Node.js](https://nodejs.org/) (which includes `npm` and `npx`), or run `npm install -g skills` first then use `skills add` directly.

Skills installed via `npx` land in your project's `.claude/skills/` or `.github/skills/` directory. They are not managed by the `/plugin` commands — they're standalone skill directories.

### Which install method should I use?

|                     | Marketplace plugin         | npx skills                    |
| ------------------- | -------------------------- | ----------------------------- |
| **Version pinning** | ✅ Versioned releases      | ❌ Latest from `main`         |
| **Update control**  | `/plugin update` command   | Re-run `npx skills add`       |
| **Rollback**        | Install a previous version | Not supported                 |
| **Works with**      | Copilot CLI, Claude Code   | Any agent with skills support |
| **Managed by**      | `/plugin` commands         | File system (manual)          |

---

## Update a plugin

### Copilot CLI

```bash
# Update a specific plugin
/plugin update azure-cost-calculator
```

### Claude Code

Update a single plugin:

```bash
/plugin update azure-cost-calculator@acc-plugin
```

Update all plugins from a marketplace:

```bash
/plugin marketplace update acc-plugin
```

Or use the interactive plugin manager:

```bash
/plugin    # → Installed tab → select the plugin → Update
```

### npx-installed skills

Re-run the install command to pull the latest:

```bash
npx skills add ahmadabdalla/azure-cost-calculator-skill
```

---

## Uninstall a plugin or skill

### Critical: use the exact installed name

The uninstall command requires the **exact name** as shown by the list command — not the repo path, not a nickname.

**Always list first, then copy the name:**

```bash
# Copilot CLI
/plugin list
# Look for the name in the output, then:
/plugin uninstall azure-cost-calculator

# Claude Code
/plugin    # → Installed tab — note the exact name including @marketplace suffix
/plugin uninstall azure-cost-calculator@acc-plugin
```

> **Copilot CLI** uses the `name` field from the plugin's `plugin.json` manifest.
> **Claude Code** uses the format `name@marketplace` for marketplace-installed plugins.

### Verify uninstall

After removing, confirm it's gone:

```bash
# Copilot CLI
/plugin list                 # should no longer show the plugin
/skills list                 # skill should be gone
/agent                       # agent should be gone

# Claude Code
/plugin                      # → Installed tab — plugin should be absent
```

### Uninstall npx-installed skills

Skills installed via `npx` are directories on disk. Remove them with the skills CLI:

```bash
npx skills remove azure-cost-calculator-skill
```

Or delete the directory manually:

```bash
rm -rf path/to/azure-cost-calculator-skill
```

Use `/skills info` (Copilot CLI) to find the skill's path.

---

## Disable vs uninstall

Both platforms let you **disable** a plugin without removing it. This is useful for troubleshooting or temporarily turning off functionality.

```bash
# Copilot CLI — not available as a session command; use terminal:
#   copilot plugin disable azure-cost-calculator

# Claude Code
/plugin disable azure-cost-calculator@acc-plugin
/plugin enable azure-cost-calculator@acc-plugin    # re-enable later
```

A disabled plugin remains installed on disk but its agents, skills, hooks, and MCP servers are not loaded.

---

## Installing skills directly (without a plugin)

Both platforms support installing skills as standalone files — no plugin or marketplace needed. You can use `npx` or copy the skill directory manually.

### Via npx

```bash
npx skills add ahmadabdalla/azure-cost-calculator-skill
```

This installs into your project's `.claude/skills/` or `.github/skills/` directory.

### Via manual directory placement

Each skill is a directory containing a `SKILL.md` file. Where you place it determines the scope:

| Scope    | Copilot CLI path                              | Claude Code path                           |
| -------- | --------------------------------------------- | ------------------------------------------ |
| Personal | `~/.copilot/skills/<skill-name>/SKILL.md`     | `~/.claude/skills/<skill-name>/SKILL.md`   |
| Project  | `.github/skills/<skill-name>/SKILL.md`        | `.claude/skills/<skill-name>/SKILL.md`     |

> Both platforms also recognise each other's paths — Copilot CLI reads `.claude/skills/` and Claude Code reads `.github/skills/`.

Example directory structure:

```text
.claude/skills/
  azure-cost-calculator/
    SKILL.md
    scripts/
    references/
```

### Invoking a skill

```bash
# Directly by name
/azure-cost-calculator

# With arguments
/azure-cost-calculator estimate costs for a D4s v5 VM
```

Both Copilot CLI and Claude Code can also invoke skills automatically when they match the current context (unless the skill has `disable-model-invocation: true` in its frontmatter).

---

## Where plugins are stored

| Platform    | Plugin cache location                                             |
| ----------- | ----------------------------------------------------------------- |
| Copilot CLI | `~/.copilot/state/installed-plugins/`                             |
| Claude Code | `~/.claude/plugins/cache/`                                        |

---

## Troubleshooting

### `/plugin` not recognised

| Platform    | Fix                                                                                          |
| ----------- | -------------------------------------------------------------------------------------------- |
| Copilot CLI | Reinstall or upgrade: `brew upgrade copilot-cli` or re-run the install script                |
| Claude Code | Update to v1.0.33+: `brew upgrade claude-code` or `npm update -g @anthropic-ai/claude-code` |

### Plugin installed but skill/agent not appearing

1. **Restart the session.** Skills and agents are loaded at session start. Start a new `copilot` or `claude` session.
2. **Claude Code**: Run `/reload-plugins` to reload without restarting.
3. **Check the plugin is enabled.** Run `/plugin list` (Copilot CLI) or check the Installed tab (Claude Code) and look for a "disabled" indicator.
4. **Name conflicts.** Project-level agents/skills override plugin agents/skills if they share the same name. Use `/skills info` (Copilot CLI) to see which location is active.
5. **Re-install to refresh cache.** Both platforms cache plugin contents. Re-run the install command to update the cache.
6. **Claude Code — clear the cache** if reinstalling doesn't help:
   ```bash
   rm -rf ~/.claude/plugins/cache
   ```
   Then restart Claude Code and reinstall the plugin.

### Uninstall fails with "plugin not found"

You must use the exact name. Common mistakes:

| What you typed                                     | Why it failed              | What to type instead                                 |
| -------------------------------------------------- | -------------------------- | ---------------------------------------------------- |
| `/plugin uninstall ahmadabdalla/azure-cost-calculator` | Used the repo path, not the plugin name | `/plugin uninstall azure-cost-calculator` (Copilot CLI) |
| `/plugin uninstall azure-cost-calculator` (Claude Code) | Missing marketplace suffix | `/plugin uninstall azure-cost-calculator@acc-plugin` |
| `/plugin uninstall Azure-Cost-Calculator`          | Name is case-sensitive     | `/plugin uninstall azure-cost-calculator`            |

### Marketplace not loading

- Verify the repo is accessible: `gh repo view ahmadabdalla/azure-cost-calculator`
- Check that `.claude-plugin/marketplace.json` or `.github/plugin/marketplace.json` exists in the repo
- Try removing and re-adding the marketplace
- Claude Code: validate syntax with `/plugin validate .` from the marketplace directory

---

## Further reading

### Copilot CLI

- [Plugin reference](https://docs.github.com/en/copilot/reference/cli-plugin-reference)
- [Finding and installing plugins](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-finding-installing)
- [Creating agent skills](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-skills)

### Claude Code

- [Skills documentation](https://code.claude.com/docs/en/skills)
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference)
- [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Discover plugins](https://code.claude.com/docs/en/discover-plugins)
