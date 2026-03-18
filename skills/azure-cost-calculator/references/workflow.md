# Workflow Reference — Script Parameters, Multi-Resource Estimates, Output Formats

## Script Parameters

Both pricing scripts (Bash and PowerShell) query the Azure Retail Prices REST API (no auth required). Run them to get live, deterministic prices. Service reference files use declarative `Key: Value` parameters — translate to the detected runtime:

| Parameter      | Description                                                      | Default       |
| -------------- | ---------------------------------------------------------------- | ------------- |
| ServiceName    | Case-sensitive service name (e.g., `Virtual Machines`)           | _(required)_  |
| Region         | Azure region. Accepts multiple for comparison.                   | `eastus`      |
| ArmSkuName     | ARM SKU (used for VMs: `Standard_D2s_v5`)                        | —             |
| SkuName        | SKU name (e.g., `P1 v3`, `Hot LRS`)                              | —             |
| ProductName    | Product filter, case-sensitive                                   | —             |
| MeterName      | Specific meter (e.g., `vCore`, `100 RU/s`)                       | —             |
| PriceType      | `Consumption` (default), `Reservation`, `DevTestConsumption`     | `Consumption` |
| Currency       | Supports: USD, AUD, EUR, GBP, JPY, CAD, INR, etc.                | `USD`         |
| Quantity       | Usage multiplier (e.g., 4 for 400 RU/s Cosmos)                   | —             |
| HoursPerMonth  | Hours in billing month                                           | `730`         |
| InstanceCount  | Number of instances                                              | `1`           |
| OutputFormat   | `Json` (default), `Table`, `Summary`, `Compact`                  | `Json`        |
| IncludeMeterId | Include MeterId (GUID) in Json/Compact output for reconciliation | `false`       |

### Runtime Translation

- **Bash**: `--kebab-case` flags (e.g., `ServiceName: Virtual Machines` → `--service-name 'Virtual Machines'`)
- **PowerShell**: `-PascalCase` flags (e.g., `ServiceName: Virtual Machines` → `-ServiceName 'Virtual Machines'`)

> **PowerShell on Linux/macOS**: use `pwsh -File`, not `-Command` — shells strip OData quotes. See [pitfalls.md](pitfalls.md).

### Examples

# VM monthly cost

ServiceName: Virtual Machines
ArmSkuName: Standard_D2s_v5

# App Service Linux P1v3

ServiceName: Azure App Service
SkuName: P1 v3
ProductName: Azure App Service Premium v3 Plan - Linux

# Compare VM price across 3 regions in AUD

ServiceName: Virtual Machines
ArmSkuName: Standard_D4s_v5
Region: eastus,australiaeast,westeurope
Currency: AUD
OutputFormat: Table

# Cosmos DB 400 RU/s

ServiceName: Azure Cosmos DB
MeterName: 100 RU/s
SkuName: RUs
Quantity: 4

# Storage: Blob Hot LRS per-GB

ServiceName: Storage
SkuName: Hot LRS
ProductName: Blob Storage
MeterName: Hot LRS Data Stored

## Discovery Script

Discovers available filter values for resource types not yet in the reference files. Returns distinct combinations of serviceName, productName, skuName, meterName, armSkuName, unitOfMeasure, and a sample price.

**Key parameters:**

| Parameter      | Description                                                | Default  |
| -------------- | ---------------------------------------------------------- | -------- |
| ServiceName    | Exact service name match                                   | —        |
| SearchTerm     | Fuzzy search via OData `contains()` on productName         | —        |
| Region         | Azure region                                               | `eastus` |
| Currency       | Pass user's preferred currency for localised sample prices | `USD`    |
| Top            | Max distinct results                                       | `20`     |
| OutputFormat   | `Json` (default) or `Table`                                | `Json`   |
| IncludeMeterId | Include MeterId (GUID) in Json output for reconciliation   | `false`  |

## Multi-Resource Estimates

For architecture-level estimates:

1. List each resource needed
2. Look up each in the service reference file and run the script per-resource
3. Sum monthly costs
4. Present as a table: Resource | SKU | Monthly Cost
5. Add total with caveats about variable costs (bandwidth, operations, storage growth)

## Output Formats

The pricing and explore scripts support different format sets:

| Format      | Pricing script | Explore script | Notes                                                                                                                                                     |
| ----------- | :------------: | :------------: | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Json**    |      Yes       |      Yes       | Default for both. Pricing: query echo + results + summary. Explore: flat array of distinct combinations.                                                  |
| **Table**   |      Yes       |      Yes       | Tabular display for terminal viewing. Good for comparing regions side by side.                                                                            |
| **Compact** |      Yes       |       No       | Lightweight JSON with 9 fields for cost calculation (10 with `IncludeMeterId`). No query echo or summary. Recommended for batch estimates of 3+ services. |
| **Summary** |      Yes       |       No       | Human-readable text for interactive use. Not structured or parseable — use `Json` or `Compact` for agent-driven estimation.                               |
