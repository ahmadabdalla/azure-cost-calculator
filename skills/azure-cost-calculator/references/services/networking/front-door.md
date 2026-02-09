---
serviceName: Azure Front Door Service
category: networking
aliases: [AFD, CDN, Azure CDN, Front Door Premium/Standard]
---

# Azure Front Door

**Primary cost**: Base fee (flat monthly per profile) + data transfer out per-GB + requests per-10K

> **Trap (Zone regions)**: Front Door uses **zone-based regions** (`Zone 1`, `Zone 2`, etc.), not ARM regions. Queries MUST use `-Region 'Zone 1'` — the default `eastus` returns zero results.
> **Trap (Two productNames)**: Standard/Premium profile meters use productName `Azure Front Door`. Classic WAF/routing meters use productName `Azure Front Door Service`. Always filter by `-ProductName` to avoid mixing them.

## Query Pattern

```powershell
# Standard profile — base fee (Zone 1 = US/Europe)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Front Door Service' `
    -ProductName 'Azure Front Door' `
    -SkuName 'Standard' `
    -MeterName 'Standard Base Fees' `
    -Region 'Zone 1'

# Premium profile — base fee
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Front Door Service' `
    -ProductName 'Azure Front Door' `
    -SkuName 'Premium' `
    -MeterName 'Premium Base Fees' `
    -Region 'Zone 1'

# Standard — data transfer out (use -Quantity for estimated monthly GB)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Front Door Service' `
    -ProductName 'Azure Front Door' `
    -SkuName 'Standard' `
    -MeterName 'Standard Data Transfer Out' `
    -Quantity 500 `
    -Region 'Zone 1'

# Standard — requests (per 10K)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Front Door Service' `
    -ProductName 'Azure Front Door' `
    -SkuName 'Standard' `
    -MeterName 'Standard Requests' `
    -Region 'Zone 1'
```

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `Standard Base Fees` | `Standard` | `1/Month` | Flat monthly per profile |
| `Standard Data Transfer Out` | `Standard` | `1 GB` | Tiered egress pricing |
| `Standard Data Transfer In` | `Standard` | `1 GB` | Ingress |
| `Standard Requests` | `Standard` | `10K` | Per 10K requests |
| `Premium Base Fees` | `Premium` | `1/Month` | Flat monthly per profile |
| `Premium Data Transfer Out` | `Premium` | `1 GB` | Tiered egress pricing |
| `Premium Data Transfer In` | `Premium` | `1 GB` | Ingress |
| `Premium Requests` | `Premium` | `10K` | Per 10K requests |

> WAF meters (Policy, Rule, Default Ruleset, Bot Protection) use productName `Azure Front Door Service` — query separately if WAF is enabled.

## Cost Formula

```
Monthly = baseFee_retailPrice
        + dataOut_retailPrice × estimatedOutGB
        + dataIn_retailPrice × estimatedInGB
        + requests_retailPrice × (estimatedRequests / 10,000)
```

## Notes

- **Zone mapping**: Zone 1 = US/Europe, Zone 2 = Asia Pacific/Japan/Australia, Zone 3 = South America/Africa/Middle East. Additional zones (4-8) exist for specific geographies
- **Standard vs Premium**: Premium adds Private Link origins, enhanced WAF with bot protection and managed rule sets, and Microsoft Threat Intelligence
- **Data transfer out is tiered** — the first 10 TB is the highest rate; volume discounts apply at 50 TB+
- Reserved pricing is not available for Azure Front Door
- Classic Front Door (productName `Azure Front Door Service`) has different meters: routing rules (hourly), per-request, WAF policies — being retired in favor of Standard/Premium
