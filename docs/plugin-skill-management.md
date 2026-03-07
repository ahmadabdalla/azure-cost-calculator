# Plugin Management

User guide for installing, updating, and removing plugins in **GitHub Copilot CLI** and **Claude Code**.

All commands on this page are **session commands** — run them inside an interactive `copilot` or `claude` session, prefixed with `/`.

> **Looking for standalone skills?** See [Standalone Skill Management](standalone-skill-management.md) for installing skills without a plugin.

---

## Key concepts

| Concept         | Description                                                                                    |
| --------------- | ---------------------------------------------------------------------------------------------- |
| **Plugin**      | A package that bundles one or more skills, agents, hooks, MCP servers, or LSP servers.         |
| **Marketplace** | A catalog of plugins you can browse and install — like an app store.                           |
| **Scope**       | Where a plugin or skill is available. Both platforms support **personal** (all projects) and **project** (shared via repo) scopes. Claude Code adds a **local** scope (project-only, gitignored). |

---

<details>
<summary><h2>GitHub Copilot CLI</h2></summary>

### Command reference

#### Plugin commands

| Action              | Command                            |
| ------------------- | ---------------------------------- |
| List installed      | `/plugin list`                     |
| Install (marketplace) | `/plugin install NAME@MARKETPLACE` |
| Install (GitHub)    | `/plugin install OWNER/REPO`       |
| Update one          | `/plugin update NAME`              |
| Update all          | `/plugin update --all`             |
| Disable             | `/plugin disable NAME`             |
| Enable              | `/plugin enable NAME`              |
| Uninstall           | `/plugin uninstall NAME`           |

> Copilot CLI uses just the plugin **name** (from `plugin.json`) — no marketplace suffix needed for most commands.

#### Marketplace commands

| Action    | Command                                |
| --------- | -------------------------------------- |
| Add       | `/plugin marketplace add OWNER/REPO`   |
| List      | `/plugin marketplace list`             |
| Browse    | `/plugin marketplace browse NAME`      |
| Remove    | `/plugin marketplace remove NAME`      |

> When **adding** a marketplace you use `OWNER/REPO`. When **removing** you use the marketplace **name** (as shown in the list).

### Install a plugin

#### Option A — Marketplace install (recommended)

**Step 1 — Add the marketplace** (one-time):

```bash
/plugin marketplace add ahmadabdalla/azure-cost-calculator
```

**Step 2 — Install the plugin:**

```bash
/plugin install azure-cost-calculator@acc-plugin
```

**Step 3 — Restart the session** to load the new plugin, then verify:

```bash
/skills list     # should show azure-cost-calculator
/agent           # should show cost-analyst
```

#### Option B — Direct install from GitHub

Copilot CLI can install a plugin directly from a GitHub repo without a marketplace:

```bash
/plugin install ahmadabdalla/azure-cost-calculator
```

This looks for `plugin.json` in `.github/plugin/` or `.claude-plugin/` at the repo root.

### Update a plugin

```bash
/plugin update azure-cost-calculator
```

Or update all installed plugins:

```bash
/plugin update --all
```

### Disable / Enable

Temporarily disable a plugin without removing it:

```bash
/plugin disable azure-cost-calculator
/plugin enable azure-cost-calculator    # re-enable later
```

A disabled plugin stays on disk but its skills, agents, hooks, and MCP servers are not loaded.

### Uninstall a plugin

The uninstall command requires the **exact plugin name** as shown by `/plugin list`.

```bash
/plugin list                              # find the exact name
/plugin uninstall azure-cost-calculator   # use that name
```

Verify it's gone:

```bash
/plugin list     # plugin should be absent
/skills list     # skill should be gone
/agent           # agent should be gone
```

### Remove a marketplace

```bash
/plugin marketplace remove acc-plugin
```

> If plugins from that marketplace are still installed, the command fails. Add `--force` to remove the marketplace and uninstall all its plugins.

### Where plugins are stored

| Item              | Path                                                        |
| ----------------- | ----------------------------------------------------------- |
| Marketplace installs | `~/.copilot/state/installed-plugins/MARKETPLACE/PLUGIN/` |
| Direct installs   | `~/.copilot/state/installed-plugins/PLUGIN/`               |
| Marketplace cache | `~/.copilot/state/marketplace-cache/`                      |

### Troubleshooting

**`/plugin` not recognised** — Upgrade: `brew upgrade copilot-cli` or re-run the install script.

**Plugin installed but skill/agent not appearing:**

1. **Restart the session.** Skills and agents are loaded at session start.
2. **Check the plugin is enabled:** `/plugin list` — look for a "disabled" indicator.
3. **Name conflicts.** Project-level skills override plugin skills with the same name. Use `/skills info` to see which is active.
4. **Re-install to refresh cache:** `/plugin install azure-cost-calculator@acc-plugin`

**Uninstall fails with "plugin not found":**

| What you typed | Why it failed | Correct command |
| -------------- | ------------- | --------------- |
| `/plugin uninstall ahmadabdalla/azure-cost-calculator` | Used repo path, not plugin name | `/plugin uninstall azure-cost-calculator` |
| `/plugin uninstall Azure-Cost-Calculator` | Name is case-sensitive | `/plugin uninstall azure-cost-calculator` |

### Further reading

- [Plugin reference](https://docs.github.com/en/copilot/reference/cli-plugin-reference)
- [Finding and installing plugins](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-finding-installing)
- [Creating agent skills](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-skills)

</details>

---

<details>
<summary><h2>Claude Code</h2></summary>

### Command reference

#### Plugin commands

| Action              | Command                                    |
| ------------------- | ------------------------------------------ |
| List / manage       | `/plugin` → **Installed** tab              |
| Install             | `/plugin install NAME@MARKETPLACE`         |
| Update one          | `/plugin update NAME@MARKETPLACE`          |
| Update all (marketplace) | `/plugin marketplace update MARKETPLACE` |
| Disable             | `/plugin disable NAME@MARKETPLACE`         |
| Enable              | `/plugin enable NAME@MARKETPLACE`          |
| Uninstall           | `/plugin uninstall NAME@MARKETPLACE`       |
| Reload              | `/reload-plugins`                          |

> Claude Code uses the `name@marketplace` format for plugin commands. Direct install from GitHub (without a marketplace) is **not supported**.

**Shortcuts:** `/plugin market` works in place of `/plugin marketplace`. `rm` works in place of `remove`.

#### Marketplace commands

| Action    | Command                                       |
| --------- | --------------------------------------------- |
| Add       | `/plugin marketplace add OWNER/REPO`          |
| List      | `/plugin marketplace list`                    |
| Update    | `/plugin marketplace update MARKETPLACE`      |
| Remove    | `/plugin marketplace remove MARKETPLACE`      |

> Use `add` / `remove` for **marketplaces**. Use `install` / `uninstall` for **plugins**. The verbs are not interchangeable — `uninstall` silently fails on marketplaces.

### Install a plugin

#### Option A — Marketplace install via commands (recommended)

**Step 1 — Add the marketplace** (one-time):

```bash
/plugin marketplace add ahmadabdalla/azure-cost-calculator
```

**Step 2 — Update the marketplace index:**

```bash
/plugin marketplace update acc-plugin
```

**Step 3 — Install the plugin:**

```bash
/plugin install azure-cost-calculator@acc-plugin
```

**Step 4 — Reload and verify:**

```bash
/reload-plugins
/plugin              # → Installed tab — should show azure-cost-calculator
```

> **Scope:** When installing via the interactive UI, you can choose **User** (all projects, default), **Project** (shared via repo), or **Local** (gitignored). Command-line installs default to `user` scope.

#### Option B — Interactive UI

1. Run `/plugin`
2. Go to the **Discover** tab
3. Select a plugin and press **Enter**
4. Choose scope: **User**, **Project**, or **Local**

The plugin manager has four tabs: **Discover** (browse/install), **Installed** (manage), **Marketplaces** (add/remove sources), and **Errors** (loading issues).

### Update a plugin

Update a single plugin:

```bash
/plugin update azure-cost-calculator@acc-plugin
```

Update all plugins from a marketplace:

```bash
/plugin marketplace update acc-plugin
```

Or use the interactive UI: `/plugin` → **Installed** tab → select plugin → **Update**.

### Disable / Enable

```bash
/plugin disable azure-cost-calculator@acc-plugin
/plugin enable azure-cost-calculator@acc-plugin    # re-enable later
```

A disabled plugin stays on disk but its skills, agents, hooks, and MCP servers are not loaded.

### Uninstall a plugin

The uninstall command requires the **exact name including the `@marketplace` suffix**.

```bash
/plugin              # → Installed tab — note the exact name
/plugin uninstall azure-cost-calculator@acc-plugin
```

Verify it's gone:

```bash
/plugin              # → Installed tab — plugin should be absent
```

### Remove a marketplace

```bash
/plugin marketplace remove acc-plugin
```

> **Important:** `uninstall` does **not** work for marketplaces — it silently fails. Always use `remove`.

### Where plugins are stored

| Item         | Path                         |
| ------------ | ---------------------------- |
| Plugin cache | `~/.claude/plugins/cache/`   |

### Troubleshooting

**`/plugin` not recognised** — Update to v1.0.33+: `brew upgrade claude-code` or `npm update -g @anthropic-ai/claude-code`.

**Plugin installed but skill/agent not appearing:**

1. **Run `/reload-plugins`** to hot-reload without restarting.
2. **Restart the session** if reload doesn't help.
3. **Check the plugin is enabled** in the **Installed** tab.
4. **Name conflicts.** Project-level skills override plugin skills with the same name.
5. **Clear the cache** if reinstalling doesn't help:
   ```bash
   rm -rf ~/.claude/plugins/cache
   ```
   Then restart Claude Code and reinstall the plugin.

**Uninstall fails with "plugin not found":**

| What you typed | Why it failed | Correct command |
| -------------- | ------------- | --------------- |
| `/plugin uninstall azure-cost-calculator` | Missing `@marketplace` suffix | `/plugin uninstall azure-cost-calculator@acc-plugin` |
| `/plugin uninstall Azure-Cost-Calculator@acc-plugin` | Name is case-sensitive | `/plugin uninstall azure-cost-calculator@acc-plugin` |

**Marketplace not loading:**

- Verify the repo is accessible: `gh repo view ahmadabdalla/azure-cost-calculator`
- Check that `.claude-plugin/marketplace.json` exists in the repo
- Try `/plugin marketplace remove acc-plugin` then re-add it

### Further reading

- [Plugins reference](https://code.claude.com/docs/en/plugins-reference)
- [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Discover plugins](https://code.claude.com/docs/en/discover-plugins)
- [Skills documentation](https://code.claude.com/docs/en/skills)

</details>
