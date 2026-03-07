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
| Uninstall           | `/plugin uninstall NAME`           |

> Copilot CLI uses just the plugin **name** (from `plugin.json`) — no marketplace suffix needed for most commands.

#### Marketplace commands

| Action    | Command                                |
| --------- | -------------------------------------- |
| Add       | `/plugin marketplace add OWNER/REPO`   |
| List      | `/plugin marketplace list`             |
| Remove    | `/plugin marketplace remove NAME`      |

> When **adding** a marketplace you use `OWNER/REPO`. When **removing** you use the marketplace **name** (as shown in the list).

### Install a plugin

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

### Update a plugin

```bash
/plugin update azure-cost-calculator
```

Or update all installed plugins:

```bash
/plugin update --all
```

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
| List installed      | `/plugin list`                             |
| Install             | `/plugin install NAME@MARKETPLACE`         |
| Update one          | `/plugin update NAME@MARKETPLACE`          |
| Update all (marketplace) | `/plugin marketplace update MARKETPLACE` |
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
/plugin list         # should show azure-cost-calculator
```

### Update a plugin

Update a single plugin:

```bash
/plugin update azure-cost-calculator@acc-plugin
```

Update all plugins from a marketplace:

```bash
/plugin marketplace update acc-plugin
```

### Uninstall a plugin

The uninstall command requires the **exact name including the `@marketplace` suffix**.

```bash
/plugin list         # find the exact name including @marketplace suffix
/plugin uninstall azure-cost-calculator@acc-plugin
```

Verify it's gone:

```bash
/plugin list         # plugin should be absent
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

### Further reading

- [Plugins reference](https://code.claude.com/docs/en/plugins-reference)
- [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Discover plugins](https://code.claude.com/docs/en/discover-plugins)
- [Skills documentation](https://code.claude.com/docs/en/skills)

</details>
