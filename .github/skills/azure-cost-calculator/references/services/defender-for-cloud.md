````markdown
# Microsoft Defender for Cloud

**Multiple sub-products**, each with its own productName, pricing model, and unit. Query each sub-product separately.

> **Trap (separate queries required)**: Each Defender sub-product has its **own unique `productName`, `skuName`, and `meterName`**. You MUST run a separate query for each sub-product (Servers, SQL, Key Vault, Storage, etc.). A single unfiltered query for `serviceName = 'Microsoft Defender for Cloud'` returns ALL sub-products mixed together — the `summary.totalMonthlyCost` is meaningless.
> **Trap**: Defender plans appear hourly but are really **per-protected-resource** charges. There is no actual hourly scaling — a resource is either protected or not. To get monthly cost: multiply hourly rate × 730 × resource count.
> **Trap**: Different sub-products use different `unitOfMeasure` values (`1/Hour`, `1/Month`, `1 Hour`). Always check the unit before applying the formula.
> **Trap**: SQL has multiple pricing models for different deployment types (PaaS vs IaaS) — multiple meters may be returned. Use `Standard Instance` for PaaS (Flexible Server). Do not confuse with `Standard Node` (monthly flat) or `Standard vCore` (hourly per-vCore) which are for different deployment types.

## Query Pattern

```powershell
# Defender for Servers — Plan 1
.\Get-AzurePricing.ps1 `
    -ServiceName 'Microsoft Defender for Cloud' `
    -ProductName 'Microsoft Defender for Servers' `
    -SkuName 'Standard P1' `
    -MeterName 'Standard P1 Node'

# Defender for Servers — Plan 2
.\Get-AzurePricing.ps1 `
    -ServiceName 'Microsoft Defender for Cloud' `
    -ProductName 'Microsoft Defender for Servers' `
    -SkuName 'Standard P2' `
    -MeterName 'Standard P2 Node'

# Defender for SQL
.\Get-AzurePricing.ps1 `
    -ServiceName 'Microsoft Defender for Cloud' `
    -ProductName 'Microsoft Defender for SQL' `
    -SkuName 'Standard' `
    -MeterName 'Standard Instance'

# Defender for Key Vault
.\Get-AzurePricing.ps1 `
    -ServiceName 'Microsoft Defender for Cloud' `
    -ProductName 'Microsoft Defender for Key Vault' `
    -SkuName 'Per node Std' `
    -MeterName 'Per node Std Node'

# Defender for Storage
.\Get-AzurePricing.ps1 `
    -ServiceName 'Microsoft Defender for Cloud' `
    -ProductName 'Microsoft Defender for Storage' `
    -SkuName 'Standard' `
    -MeterName 'Standard Node'

# Defender for Storage — transaction-based component
.\Get-AzurePricing.ps1 `
    -ServiceName 'Microsoft Defender for Cloud' `
    -ProductName 'Microsoft Defender for Storage' `
    -SkuName 'Standard' `
    -MeterName 'Standard Transactions'

# Defender for Containers — vCore runtime protection (per vCore-hour)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Microsoft Defender for Cloud' `
    -ProductName 'Microsoft Defender for Containers' `
    -SkuName 'Standard vCore' `
    -MeterName 'Standard vCore vCore Pack'

# Defender for Containers — image scanning (per image scanned)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Microsoft Defender for Cloud' `
    -ProductName 'Microsoft Defender for Containers' `
    -SkuName 'Standard Images' `
    -MeterName 'Standard Images'
```

## Meter Names

| Sub-product         | productName                         | skuName           | meterName                   | unitOfMeasure | Formula               |
| ------------------- | ----------------------------------- | ----------------- | --------------------------- | ------------- | --------------------- |
| Servers P1          | `Microsoft Defender for Servers`    | `Standard P1`     | `Standard P1 Node`          | `1/Hour`      | × 730 × serverCount   |
| Servers P2          | `Microsoft Defender for Servers`    | `Standard P2`     | `Standard P2 Node`          | `1/Hour`      | × 730 × serverCount   |
| SQL                 | `Microsoft Defender for SQL`        | `Standard`        | `Standard Instance`         | `1 Hour`      | × 730 × instanceCount |
| Key Vault           | `Microsoft Defender for Key Vault`  | `Per node Std`    | `Per node Std Node`         | `1/Hour`      | × 730 × vaultCount    |
| Storage             | `Microsoft Defender for Storage`    | `Standard`        | `Standard Node`             | `1/Hour`      | × 730 × accountCount  |
| Storage (txns)      | `Microsoft Defender for Storage`    | `Standard`        | `Standard Transactions`     | `1M`          | × transactionMillions |
| Containers          | `Microsoft Defender for Containers` | `Standard vCore`  | `Standard vCore vCore Pack` | `1/Hour`      | × 730 × totalVCores   |
| Containers (images) | `Microsoft Defender for Containers` | `Standard Images` | `Standard Images`           | `1`           | × imageScansPerMonth  |

## Cost Formula

For hourly meters:

```
Monthly per resource = unitPrice × 730
Total = Monthly per resource × resourceCount
```

For monthly meters (if encountered):

```
Total = unitPrice × resourceCount
```

For transaction meters:

```
Total = unitPrice × (transactions / 1,000,000)
```

## Example (5 servers P2, 2 SQL instances, 3 Key Vaults, 2 Storage accounts)

```
Servers P2:  unitPrice × 730 × 5
SQL:         unitPrice × 730 × 2
Key Vault:   unitPrice × 730 × 3
Storage:     unitPrice × 730 × 2
Total: sum of above (query live prices)
```

## Notes

- SQL also has a `Standard Node` meter at $21.4332 per `1/Month` and a `Standard vCore` meter at $0.0214/hr — these are for different deployment types. Use `Standard Instance` for PaaS SQL.
- Defender for Containers has a **free trial** tier (Free vCore, Free Images at £0.00) plus paid tiers (Standard vCore, Standard Images). Always use the `Standard` SKU meters for cost estimation.
- Defender for Containers vCore pricing is based on the **total vCores across all protected AKS nodes**. For example, 6× E4s_v5 (4 vCPU each) = 24 vCores.
- Defender for App Service, DNS, and Resource Manager plans also exist — use `Explore-AzurePricing.ps1 -SearchTerm 'Defender'` to discover them.
- Free tier (CSPM) provides basic security recommendations at no cost.

## Defender CSPM (Cloud Security Posture Management)

> **Trap (not in Retail Prices API)**: Defender CSPM is **not available as a meter** in the Azure Retail Prices API. Queries for `serviceName = 'Microsoft Defender for Cloud'` do not return a CSPM-specific meter. The pricing must be estimated using the published rate from the Azure pricing page.

**Pricing**: $5.11 per billable resource per month (source: [Azure pricing page](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/))

**Billable resource types**:

- **Compute**: VMs (`Microsoft.Compute/virtualMachines`), VMSS VMs — excludes deallocated VMs and Databricks VMs
- **Storage**: Storage accounts — excludes accounts without blob containers or file shares
- **Databases**: OSS DBs (PostgreSQL, MySQL, MariaDB), SQL PaaS & Servers on Machines
- **Serverless**: Functions and Web Apps (billing starts February 27, 2026)

**Foundational CSPM vs Defender CSPM**:

- **Foundational CSPM**: Free. Provides secure score, basic recommendations, asset inventory, compliance with Microsoft cloud security benchmark.
- **Defender CSPM** (paid): Adds agentless vulnerability scanning, attack path analysis, data-aware security posture, cloud security explorer, governance, and regulatory compliance. Requires enablement per subscription.

### Cost Formula

```
Monthly = $5.11 × billableResourceCount
```

> **Note**: Count only billable resource types listed above. Deallocated VMs and storage accounts without blob containers/file shares are excluded. Use Azure Resource Graph or the portal to count eligible resources.
````
