````markdown
# Microsoft Defender for Cloud

**Multiple sub-products** — query each separately by its own productName/skuName/meterName.

> **Trap (separate queries)**: Each sub-product needs its **own query** — unfiltered `serviceName` query mixes all products, `summary.totalMonthlyCost` is meaningless.
> **Trap (hourly ≠ scaling)**: Hourly meters are per-protected-resource, not time-based. Monthly cost = rate × 730 × resourceCount.
> **Trap (unitOfMeasure varies)**: Sub-products use `1/Hour`, `1/Month`, or `1 Hour` — always check before applying formula.
> **Trap (SQL meters)**: SQL returns multiple meters — use `Standard Instance` for PaaS. `Standard Node` = monthly flat, `Standard vCore` = per-vCore hourly (different deployment types).

## Query Pattern

All sub-products use the same pattern — substitute values from the Meter Names table:

```powershell
.\Get-AzurePricing.ps1 `
    -ServiceName 'Microsoft Defender for Cloud' `
    -ProductName '<productName from table>' `
    -SkuName '<skuName from table>' `
    -MeterName '<meterName from table>'
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

- **Hourly meters**: `unitPrice × 730 × resourceCount`
- **Monthly meters**: `unitPrice × resourceCount`
- **Transaction meters**: `unitPrice × (transactions / 1,000,000)`

## Notes

- Containers has free trial tiers (Free vCore, Free Images at £0.00) — always use `Standard` SKU meters for estimation.
- Containers vCore pricing = total vCores across all protected AKS nodes (e.g., 6× E4s_v5 @ 4 vCPU = 24 vCores).
- App Service, DNS, and Resource Manager plans also exist — use `Explore-AzurePricing.ps1 -SearchTerm 'Defender'` to discover.

## Defender CSPM (Cloud Security Posture Management)

> **Trap (not in API)**: Defender CSPM has **no meter** in the Retail Prices API. Use the published rate below.

**Pricing**: $5.11 per billable resource/month ([Azure pricing page](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/)). Foundational CSPM is free (not estimated).

**Billable resource types**: VMs (excl. deallocated & Databricks), VMSS VMs, Storage accounts (with blob containers or file shares), OSS DBs (PostgreSQL/MySQL/MariaDB), SQL PaaS & Servers on Machines, Functions & Web Apps (billing starts Feb 27 2026).

**Formula**: `$5.11 × billableResourceCount` — count only eligible types above; use Azure Resource Graph to enumerate.
````
