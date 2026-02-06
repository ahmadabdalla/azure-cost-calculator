````markdown
# Azure Firewall

**Multiple meters**: Fixed deployment cost (hourly) + variable data processing (per-GB)

> **Trap**: You need **TWO separate queries** per tier — one for the fixed deployment cost and one for data processing. A single unfiltered query returns both meters mixed together, and the `summary.totalMonthlyCost` is meaningless because it sums a per-hour rate with a per-GB rate.
> **Trap**: The deployment (fixed) cost is the **dominant expense** — typically 99%+ of the total for moderate traffic. Do not confuse the small data processing charge with the full cost.

## Query Pattern

```powershell
# Standard tier — fixed deployment cost
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Firewall' `
    -ProductName 'Azure Firewall' `
    -SkuName 'Standard' `
    -MeterName 'Standard Deployment'

# Standard tier — data processing
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Firewall' `
    -ProductName 'Azure Firewall' `
    -SkuName 'Standard' `
    -MeterName 'Standard Data Processed'

# Premium tier — fixed deployment cost
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Firewall' `
    -ProductName 'Azure Firewall' `
    -SkuName 'Premium' `
    -MeterName 'Premium Deployment'

# Premium tier — data processing
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Firewall' `
    -ProductName 'Azure Firewall' `
    -SkuName 'Premium' `
    -MeterName 'Premium Data Processed'

# Basic tier — fixed deployment cost
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Firewall' `
    -ProductName 'Azure Firewall' `
    -SkuName 'Basic' `
    -MeterName 'Basic Deployment'

# Basic tier — data processing
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Firewall' `
    -ProductName 'Azure Firewall' `
    -SkuName 'Basic' `
    -MeterName 'Basic Data Processed'
```

## Meter Names

| Tier     | skuName    | Deployment Meter      | Data Meter                |
| -------- | ---------- | --------------------- | ------------------------- |
| Standard | `Standard` | `Standard Deployment` | `Standard Data Processed` |
| Premium  | `Premium`  | `Premium Deployment`  | `Premium Data Processed`  |
| Basic    | `Basic`    | `Basic Deployment`    | `Basic Data Processed`    |

> **Note**: Secured Virtual Hub variants also exist with a different skuName (e.g., `'Standard Secure Virtual Hub'`). Query with `Explore-AzurePricing.ps1` if the firewall is deployed in a Virtual WAN hub.

## Cost Formula

```
Monthly = deploymentPrice × 730 + dataPrice × estimatedGB
```

## Example (Standard tier)

```
Deployment: deploymentPrice × 730
Data processed: dataPrice × estimatedGB
Total: sum of above — query live prices for current rates
```

## Notes

- The deployment (fixed) cost is the dominant expense — Azure Firewall is a premium service
- Data processing costs are typically small relative to the fixed cost for moderate traffic
- Standard → Premium adds IDPS, TLS inspection, URL filtering (higher fixed cost)
- Basic is a budget option with limited features and throughput
````
