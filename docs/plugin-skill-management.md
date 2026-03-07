# Plugin and Skill Management

User guide for installing, managing, and troubleshooting plugins and skills in **GitHub Copilot CLI** and **Claude Code**.

> **`gh extension` ≠ plugin commands.** The `gh extension install` command manages GitHub CLI extensions — it has nothing to do with Copilot CLI or Claude Code plugins. All commands on this page use the `copilot` binary (Copilot CLI) or `claude` binary (Claude Code). Don't confuse them.

---

## Key concepts

| Concept | What it is |
| --- | --- |
| **Skill** | A `SKILL.md` file (with optional supporting files) that teaches the agent a new capability. |
| **Plugin** | A package that bundles one or more skills, agents, hooks, MCP servers, or LSP servers. |
| **Marketplace** | A catalog of plugins you can browse and install. Think of it like an app store. |
| **Scope** *(Claude Code only)* | Where a plugin is installed: `user` (all projects), `project` (shared via repo), or `local` (gitignored). |

> Skills installed via a plugin are managed through the plugin — use `plugin uninstall`, not `skills remove`.

---

## Command quick reference

Every command below works either **inside** an interactive session (prefix with `/`) or **from the terminal** (prefix with the binary name). Both are shown where applicable.

### Plugin commands

| Action | Copilot CLI (terminal) | Copilot CLI (session) | Claude Code (terminal) | Claude Code (session) |
| --- | --- | --- | --- | --- |
| List installed | `copilot plugin list` | `/plugin list` | `claude plugin list` | `/plugin` → Installed tab |
| Install from marketplace | `copilot plugin install NAME@MARKETPLACE` | `/plugin install NAME@MARKETPLACE` | `claude plugin install NAME@MARKETPLACE` | `/plugin install NAME@MARKETPLACE` |
| Install from GitHub | `copilot plugin install OWNER/REPO` | `/plugin install OWNER/REPO` | `claude plugin install OWNER/REPO` | `/plugin install OWNER/REPO` |
| Install from local path | `copilot plugin install ./path` | `/plugin install ./path` | `claude --plugin-dir ./path` | — |
| Update one | `copilot plugin update NAME` | `/plugin update NAME` | `claude plugin update NAME@MARKETPLACE` | `/plugin update NAME@MARKETPLACE` |
| Update all | `copilot plugin update --all` | — | — | `/plugin marketplace update NAME` |
| Disable (keep installed) | `copilot plugin disable NAME` | — | `claude plugin disable NAME@MARKETPLACE` | `/plugin disable NAME@MARKETPLACE` |
| Enable | `copilot plugin enable NAME` | — | `claude plugin enable NAME@MARKETPLACE` | `/plugin enable NAME@MARKETPLACE` |
| Uninstall | `copilot plugin uninstall NAME` | `/plugin uninstall NAME` | `claude plugin uninstall NAME@MARKETPLACE` | `/plugin uninstall NAME@MARKETPLACE` |
| Reload plugins | — | — | — | `/reload-plugins` |

### Marketplace commands

| Action | Copilot CLI (terminal) | Copilot CLI (session) | Claude Code (terminal) | Claude Code (session) |
| --- | --- | --- | --- | --- |
| List marketplaces | `copilot plugin marketplace list` | `/plugin marketplace list` | `claude plugin marketplace list` | `/plugin marketplace list` |
| Add marketplace | `copilot plugin marketplace add OWNER/REPO` | `/plugin marketplace add OWNER/REPO` | `claude plugin marketplace add OWNER/REPO` | `/plugin marketplace add OWNER/REPO` |
| Browse marketplace | `copilot plugin marketplace browse NAME` | `/plugin marketplace browse NAME` | — | `/plugin` → Discover tab |
| Update marketplace | — | — | `claude plugin marketplace update NAME` | `/plugin marketplace update NAME` |
| Remove marketplace | `copilot plugin marketplace remove NAME` | `/plugin marketplace remove NAME` | `claude plugin marketplace remove NAME` | `/plugin marketplace remove NAME` |

**Claude Code shortcuts**: `/plugin market` works in place of `/plugin marketplace`. `rm` works in place of `remove`.

### Skill commands (Copilot CLI only)

| Action | Terminal | Session |
| --- | --- | --- |
| List skills | — | `/skills list` |
| Toggle skills on/off | — | `/skills` |
| Skill info | — | `/skills info` |
| Reload skills | — | `/skills reload` |
| Add skill location | — | `/skills add` |
| Remove standalone skill | — | `/skills remove SKILL-DIRECTORY` |

---

## Install a plugin

There are two main paths: **marketplace install** (versioned, recommended) and **npx install** (pulls latest from `main` branch).

### Path 1 — Marketplace install (recommended)

Marketplace installs give you version pinning, changelogs, and controlled updates.

**Step 1 — Add the marketplace** (one-time setup):

```bash
# Both platforms — inside a session
/plugin marketplace add ahmadabdalla/azure-cost-calculator

# From the terminal
copilot plugin marketplace add ahmadabdalla/azure-cost-calculator   # Copilot CLI
claude plugin marketplace add ahmadabdalla/azure-cost-calculator     # Claude Code
```

**Step 2 — Install the plugin:**

```bash
# Both platforms — inside a session
/plugin install azure-cost-calculator@acc-plugin

# From the terminal
copilot plugin install azure-cost-calculator@acc-plugin              # Copilot CLI
claude plugin install azure-cost-calculator@acc-plugin               # Claude Code
```

> **Claude Code scope**: Add `--scope project` or `--scope local` to the terminal command to control where the plugin is installed. The default is `user` (available in all projects).

**Step 3 — Verify:**

```bash
# Copilot CLI
copilot plugin list
# Inside a Copilot CLI session:
/skills list     # should show azure-cost-calculator
/agent           # should show cost-analyst

# Claude Code
/plugin          # → Installed tab — should show azure-cost-calculator
```

#### Direct install from GitHub (no marketplace)

If you don't want to register a marketplace, install directly from the repo:

```bash
# Both platforms — inside a session
/plugin install ahmadabdalla/azure-cost-calculator

# From the terminal
copilot plugin install ahmadabdalla/azure-cost-calculator            # Copilot CLI
claude plugin install ahmadabdalla/azure-cost-calculator              # Claude Code
```

This looks for `plugin.json` in `.github/plugin/` or `.claude-plugin/` at the repo root.

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

| | Marketplace plugin | npx skills |
| --- | --- | --- |
| **Version pinning** | ✅ Versioned releases | ❌ Latest from `main` |
| **Update control** | `plugin update` command | Re-run `npx skills add` |
| **Rollback** | Install a previous version | Not supported |
| **Works with** | Copilot CLI, Claude Code | Any agent with skills support |
| **Managed by** | `/plugin` commands | File system (manual) |

---

## Update a plugin

### Copilot CLI

```bash
# Update a specific plugin
copilot plugin update azure-cost-calculator

# Update all installed plugins
copilot plugin update --all
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

```
/plugin    # → Installed tab → select the plugin → Update
```

#### Auto-updates (Claude Code)

- The **official Anthropic marketplace** has auto-updates enabled by default.
- Third-party marketplaces have auto-updates **disabled** by default.
- Toggle per-marketplace: `/plugin` → **Marketplaces** tab → select marketplace → **Enable/Disable auto-update**.

To disable all auto-updates (both Claude Code and plugins):

```bash
export DISABLE_AUTOUPDATER=true
```

To keep plugin auto-updates while disabling Claude Code auto-updates:

```bash
export DISABLE_AUTOUPDATER=true
export FORCE_AUTOUPDATE_PLUGINS=true
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
copilot plugin list
# Look for the name in the output, then:
copilot plugin uninstall azure-cost-calculator

# Claude Code
/plugin    # → Installed tab — note the exact name including @marketplace suffix
/plugin uninstall azure-cost-calculator@acc-plugin
```

> **Copilot CLI** uses the `name` field from the plugin's `plugin.json` manifest.
> **Claude Code** uses the format `name@marketplace` for marketplace-installed plugins.

#### Claude Code scope

If the uninstall seems to have no effect, you may be targeting the wrong scope:

```bash
# Uninstall from user scope (default)
claude plugin uninstall azure-cost-calculator@acc-plugin

# Uninstall from project scope
claude plugin uninstall azure-cost-calculator@acc-plugin --scope project

# Uninstall from local scope
claude plugin uninstall azure-cost-calculator@acc-plugin --scope local
```

### Verify uninstall

After removing, confirm it's gone:

```bash
# Copilot CLI
copilot plugin list          # should no longer show the plugin
# Inside a Copilot CLI session:
/skills list                 # skill should be gone
/agent                       # agent should be gone

# Claude Code
/plugin                      # → Installed tab — plugin should be absent
```

### Uninstall npx-installed skills

The `npx` path installs skills as directories on disk. Remove them manually:

```bash
# Find where the skill was installed
/skills info                 # note the path

# Remove the directory
rm -rf path/to/azure-cost-calculator-skill
```

Or if using the skills CLI:

```bash
npx skills remove azure-cost-calculator-skill
```

---

## Disable vs uninstall

Both platforms let you **disable** a plugin without removing it. This is useful for troubleshooting or temporarily turning off functionality.

```bash
# Copilot CLI
copilot plugin disable azure-cost-calculator
copilot plugin enable azure-cost-calculator    # re-enable later

# Claude Code
/plugin disable azure-cost-calculator@acc-plugin
/plugin enable azure-cost-calculator@acc-plugin
```

A disabled plugin remains installed on disk but its agents, skills, hooks, and MCP servers are not loaded.

---

## Installing skills directly (Claude Code)

Claude Code supports installing skills without the plugin system as standalone files.

### Personal skills (all projects)

Place them in `~/.claude/skills/<skill-name>/SKILL.md`:

```
~/.claude/skills/
  my-skill/
    SKILL.md
```

### Project skills (shared with team)

Place them in `.claude/skills/<skill-name>/SKILL.md` in your project repo:

```
.claude/skills/
  my-skill/
    SKILL.md
```

### Invoking a skill

```bash
# Directly by name
/my-skill

# With arguments
/my-skill some-argument
```

Claude can also invoke skills automatically when they match the current context (unless the skill has `disable-model-invocation: true`).

---

## Where plugins are stored

| Platform | Marketplace install | Direct install |
| --- | --- | --- |
| Copilot CLI | `~/.copilot/state/installed-plugins/MARKETPLACE/PLUGIN-NAME/` | `~/.copilot/state/installed-plugins/PLUGIN-NAME/` |
| Claude Code | `~/.claude/plugins/cache/` | `~/.claude/plugins/cache/` |

---

## Troubleshooting

### "Command not found" / wrong command surface

| Symptom | Cause | Fix |
| --- | --- | --- |
| `gh: 'plugin' is not a gh command` | Using `gh plugin` instead of `copilot plugin` | Use `copilot plugin ...` — plugins are a Copilot CLI feature, not a GitHub CLI feature |
| `gh extension install` succeeded but no skill appeared | `gh extension` manages GitHub CLI extensions, not Copilot plugins | Use `copilot plugin install` instead |
| `/plugin` not recognized (Copilot CLI) | Copilot CLI version too old | Run `copilot /update` or reinstall via `brew upgrade copilot-cli` |
| `/plugin` not recognized (Claude Code) | Claude Code version too old | Update to v1.0.33+: `brew upgrade claude-code` or `npm update -g @anthropic-ai/claude-code` |

### Common command-surface confusion

| You want to... | Correct command | Wrong command (common mistake) |
| --- | --- | --- |
| Install a Copilot CLI plugin | `copilot plugin install name` | `gh extension install ...` |
| Install a Claude Code plugin | `/plugin install name@marketplace` | `gh extension install ...` |
| List installed plugins | `copilot plugin list` or `/plugin` | `gh extension list` |
| Install a GitHub CLI extension | `gh extension install owner/repo` | `copilot plugin install ...` or `/plugin install ...` |

`gh extension` manages GitHub CLI extensions. `copilot plugin` and `claude plugin` / `/plugin` manage Copilot CLI and Claude Code plugins respectively. They are entirely separate systems.

### Plugin installed but skill/agent not appearing

1. **Restart the session.** Skills and agents are loaded at session start. Start a new `copilot` or `claude` session.
2. **Claude Code**: Run `/reload-plugins` to reload without restarting.
3. **Check the plugin is enabled.** Run `/plugin list` (Copilot CLI) or check the Installed tab (Claude Code) and look for a "disabled" indicator.
4. **Name conflicts.** Project-level agents/skills override plugin agents/skills if they share the same name. Check `/skills info` to see which location is active.
5. **Re-install to refresh cache.** Both platforms cache plugin contents. Re-run the install command to update the cache.
6. **Claude Code**: Clear the cache and reinstall:
   ```bash
   rm -rf ~/.claude/plugins/cache
   ```
   Then restart Claude Code and reinstall the plugin.

### Uninstall fails with "plugin not found"

You must use the exact name. Common mistakes:

| What you typed | Why it failed | What to type instead |
| --- | --- | --- |
| `copilot plugin uninstall ahmadabdalla/azure-cost-calculator` | Used the repo path, not the plugin name | `copilot plugin uninstall azure-cost-calculator` |
| `/plugin uninstall azure-cost-calculator` (Claude Code) | Missing marketplace suffix | `/plugin uninstall azure-cost-calculator@acc-plugin` |
| `copilot plugin uninstall Azure-Cost-Calculator` | Name is case-sensitive | `copilot plugin uninstall azure-cost-calculator` |
| Uninstall has no effect (Claude Code) | Wrong scope targeted | Add `--scope project` or `--scope local` |

### "Executable not found in $PATH" (Claude Code LSP plugins)

LSP plugins require the language server binary to be installed separately. Check the **Errors** tab (`/plugin` → Errors) for details, then install the required binary (e.g., `pip install pyright` for the `pyright-lsp` plugin).

### Marketplace not loading

- Verify the repo is accessible: `gh repo view ahmadabdalla/azure-cost-calculator`
- Check that `.claude-plugin/marketplace.json` or `.github/plugin/marketplace.json` exists in the repo
- Try removing and re-adding the marketplace
- Claude Code: validate syntax with `/plugin validate .` from the marketplace directory

---

## Further reading

### Copilot CLI

- [GitHub Copilot CLI plugin reference](https://docs.github.com/en/copilot/reference/cli-plugin-reference)
- [Finding and installing plugins](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-finding-installing)
- [Creating agent skills](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-skills)

### Claude Code

- [Skills documentation](https://code.claude.com/docs/en/skills)
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference)
- [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Discover plugins](https://code.claude.com/docs/en/discover-plugins)
