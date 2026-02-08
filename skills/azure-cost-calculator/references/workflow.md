# Workflow Reference — Script Parameters, Multi-Resource Estimates, Output Formats

## Get-AzurePricing.ps1 Parameters

PowerShell script that queries the Azure Retail Prices REST API (no auth required). Run it to get live, deterministic prices.

- `-ServiceName` (required) — Case-sensitive service name (e.g., `'Virtual Machines'`)
- `-Region` — Azure region, default `eastus`. Accepts multiple for comparison.
- `-ArmSkuName` — ARM SKU (used for VMs: `'Standard_D2s_v5'`)
- `-SkuName` — SKU name (e.g., `'P1 v3'`, `'Hot LRS'`)
- `-ProductName` — Product filter, case-sensitive
- `-MeterName` — Specific meter (e.g., `'vCore'`, `'100 RU/s'`)
- `-PriceType` — `Consumption` (default), `Reservation`, `DevTestConsumption`
- `-Currency` — Default `USD`. Supports: AUD, EUR, GBP, JPY, CAD, INR, etc.
- `-Quantity` — Usage multiplier (e.g., 4 for 400 RU/s Cosmos)
- `-HoursPerMonth` — Default 730
- `-InstanceCount` — Number of instances, default 1
- `-OutputFormat` — `Json` (default), `Table`, `Summary`

### Examples

```powershell
# VM monthly cost
.\Get-AzurePricing.ps1 -ServiceName 'Virtual Machines' -ArmSkuName 'Standard_D2s_v5'

# App Service Linux P1v3
.\Get-AzurePricing.ps1 -ServiceName 'Azure App Service' -SkuName 'P1 v3' -ProductName 'Azure App Service Premium v3 Plan - Linux'

# Compare VM price across 3 regions
.\Get-AzurePricing.ps1 -ServiceName 'Virtual Machines' -ArmSkuName 'Standard_D4s_v5' -Region 'eastus','australiaeast','westeurope' -OutputFormat Table

# Cosmos DB 400 RU/s
.\Get-AzurePricing.ps1 -ServiceName 'Azure Cosmos DB' -MeterName '100 RU/s' -SkuName 'RUs' -Quantity 4

# Storage: Blob Hot LRS per-GB
.\Get-AzurePricing.ps1 -ServiceName 'Storage' -SkuName 'Hot LRS' -ProductName 'Blob Storage' -MeterName 'Hot LRS Data Stored'
```

## Discovery Script: Explore-AzurePricing.ps1

Discovers available filter values for resource types not yet in the reference files. Returns distinct combinations of serviceName, productName, skuName, meterName, armSkuName, unitOfMeasure, and a sample price.

**Key parameters:**

- `-ServiceName` — Exact service name match
- `-SearchTerm` — Fuzzy search via OData `contains()` on productName
- `-Region` — Default `eastus`
- `-Currency` — Default `USD`. Pass user's preferred currency for localised sample prices.
- `-Top` — Max distinct results, default 20
- `-OutputFormat` — `Json` (default) or `Table`

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
