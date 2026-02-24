# Service Routing Split - Operations Guide

Two-file structure separating agent-runtime routing from the pending service catalog for token optimization.

| Item              | Detail                                                       |
| ----------------- | ------------------------------------------------------------ |
| Agent routing     | `skills/azure-cost-calculator/references/service-routing.md` |
| Pending catalog   | `docs/service-catalog.md`                                    |
| Validation script | `tests/Validate-ServiceReference.ps1`                        |

---

## What it does

The split separates two concerns:

1. **Agent routing** (`service-routing.md`) - loaded at runtime by agents performing cost estimation. Contains only implemented services to minimize token consumption.

2. **Pending catalog** (`service-catalog.md`) - contributor-facing reference listing services that need implementation. Used for:
   - Contributor orientation (what needs to be built)
   - Agent orientation when adding new services (lookup exact `serviceName`, aliases, category)

When a service is implemented, it is removed from the catalog and added to the routing map.

### Why the split?

Agents previously loaded a single routing file containing both implemented and pending entries. Pending entries wasted tokens on unusable routing. The split:

- Reduces agent context by loading only implemented services
- Keeps pending catalog available for discovery and planning tasks
- Separates runtime needs from contributor documentation

---

## File structure

| File                                                         | Purpose                       | Loaded by agents? |
| ------------------------------------------------------------ | ----------------------------- | ----------------- |
| `skills/azure-cost-calculator/references/service-routing.md` | Runtime routing (implemented) | Yes               |
| `docs/service-catalog.md`                                    | Pending services only         | On demand         |

The routing file is self-contained and does not reference the catalog. Agents that need catalog data are instructed to read it separately via their agent configuration files.

---

## How to add a new service

When implementing a service from the catalog:

1. **Check the catalog** - look up the service in `docs/service-catalog.md` for:
   - Exact `serviceName` (service name before the colon)
   - Aliases (comma-separated values after the colon)
   - Category (section heading)

2. **Create the reference file** - add the `.md` file in the appropriate category folder under `skills/azure-cost-calculator/references/services/`.

3. **Add to agent routing** - add the entry to `skills/azure-cost-calculator/references/service-routing.md` under the correct category section.

4. **Remove from catalog** - delete the entry from `docs/service-catalog.md`.

5. **Run validation** - CI checks ensure routing and files stay in sync:
   ```bash
   pwsh tests/Validate-ServiceReference.ps1
   ```

---

## How to add a new service to the catalog (without implementation)

When tracking a service that does not have a reference file yet:

1. Add entry to `docs/service-catalog.md` under the appropriate category:

   ```
   - Service Name: Alias1, Alias2
   ```

2. **Do NOT add to agent routing** - the routing file only contains implemented services with existing files.

---

## Validation tests

CI runs these checks to enforce sync between routing and files:

| Test                         | What it checks                                                       |
| ---------------------------- | -------------------------------------------------------------------- |
| `Test-RoutingFileSync`       | Routing map entries and service files are bidirectionally in sync    |
| `Test-AliasRoutingSync`      | Aliases in service files match aliases declared in routing map       |
| `Test-AliasUniqueness`       | No two services claim the same alias                                 |
| `Test-BillingNeedsReference` | `billingNeeds` values in files reference valid routing service names |
| `Test-FileNaming`            | File names follow kebab-case convention derived from `serviceName`   |

All tests run via:

```bash
pwsh tests/Validate-ServiceReference.ps1
```

---

## Troubleshooting

| Symptom                          | Likely cause                                      | Fix                                                            |
| -------------------------------- | ------------------------------------------------- | -------------------------------------------------------------- |
| "File has no routing entry"      | Service file created but not added to routing map | Add entry to `service-routing.md`                              |
| "Routing entry has no file"      | Entry added to routing but file does not exist    | Create the service reference file, or remove the routing entry |
| "Alias collision"                | Two files claim the same alias                    | Resolve duplicate alias in one of the files                    |
| "Alias mismatch"                 | File aliases differ from routing map              | Sync aliases between file frontmatter and routing map          |
| "Service still in catalog"       | Service implemented but not removed from catalog  | Delete the entry from `docs/service-catalog.md`                |
| "billingNeeds invalid reference" | `billingNeeds` references non-existent service    | Use exact `serviceName` from routing map                       |

---

## References

- [service-routing.md](../../skills/azure-cost-calculator/references/service-routing.md) - agent runtime routing
- [service-catalog.md](../service-catalog.md) - pending service catalog
- [Validate-ServiceReference.ps1](../../tests/Validate-ServiceReference.ps1) - validation script
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - contributor guide
