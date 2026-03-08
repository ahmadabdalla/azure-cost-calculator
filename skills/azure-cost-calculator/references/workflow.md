# Workflow Reference — Script Parameters, Multi-Resource Estimates, Output Formats

## Script Parameters

Both pricing scripts (Bash and PowerShell) query the Azure Retail Prices REST API (no auth required). Run them to get live, deterministic prices. Service reference files use declarative `Key: Value` parameters — translate to the detected runtime:

| Parameter     | Description                                                  | Default       |
| ------------- | ------------------------------------------------------------ | ------------- |
| ServiceName   | Case-sensitive service name (e.g., `Virtual Machines`)       | _(required)_  |
| Region        | Azure region. Accepts multiple for comparison.               | `eastus`      |
| ArmSkuName    | ARM SKU (used for VMs: `Standard_D2s_v5`)                    | —             |
| SkuName       | SKU name (e.g., `P1 v3`, `Hot LRS`)                          | —             |
| ProductName   | Product filter, case-sensitive                               | —             |
| MeterName     | Specific meter (e.g., `vCore`, `100 RU/s`)                   | —             |
| PriceType     | `Consumption` (default), `Reservation`, `DevTestConsumption` | `Consumption` |
| Currency      | Supports: USD, AUD, EUR, GBP, JPY, CAD, INR, etc.            | `USD`         |
| Quantity      | Usage multiplier (e.g., 4 for 400 RU/s Cosmos)               | —             |
| HoursPerMonth | Hours in billing month                                       | `730`         |
| InstanceCount | Number of instances                                          | `1`           |
| OutputFormat  | `Json` (default), `Table`, `Summary`                         | `Json`        |

### Runtime Translation

- **Bash**: `--kebab-case` flags (e.g., `ServiceName: Virtual Machines` → `--service-name 'Virtual Machines'`)
- **PowerShell**: `-PascalCase` flags (e.g., `ServiceName: Virtual Machines` → `-ServiceName 'Virtual Machines'`)

> On Linux/macOS with PowerShell, always use `pwsh -File script.ps1 ...` — not `pwsh -Command '...'`. Bash strips OData quotes. See [pitfalls.md](pitfalls.md).

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

| Parameter    | Description                                                | Default  |
| ------------ | ---------------------------------------------------------- | -------- |
| ServiceName  | Exact service name match                                   | —        |
| SearchTerm   | Fuzzy search via OData `contains()` on productName         | —        |
| Region       | Azure region                                               | `eastus` |
| Currency     | Pass user's preferred currency for localised sample prices | `USD`    |
| Top          | Max distinct results                                       | `20`     |
| OutputFormat | `Json` (default) or `Table`                                | `Json`   |

## Multi-Resource Estimates

For architecture-level estimates:

1. List each resource needed
2. Look up each in the service reference file and run the script per-resource
3. Sum monthly costs
4. Present as a table: Resource | SKU | Monthly Cost
5. Add total with caveats about variable costs (bandwidth, operations, storage growth)

## Output Formats

- **Json** (default) — Structured output; use this for agent interactions. Agents capture stdout and Json ensures data is parseable.
- **Table** — Tabular display for terminal viewing. Good for comparing regions side by side.
- **Summary** — Uses `Write-Host`, which writes to the host console stream — agents capturing stdout will see **nothing**. Only use for human interactive use.
