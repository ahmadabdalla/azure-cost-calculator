# Application Gateway
- **serviceName**: `Application Gateway`
- **category**: networking
- **aliases**: [app gateway, application gateway, appgw]

**Primary cost**: Gateway hours (fixed cost) + capacity units processed

> **Trap**: Product names do NOT have the "Azure" prefix — use `'Application Gateway WAF v2'`, not `'Azure Application Gateway WAF v2'`.
> **Trap**: You need TWO separate queries — one for the fixed hourly cost and one for capacity units. A single unfiltered query returns both meters mixed together.

## Query Pattern

```powershell
# WAF v2 — fixed cost (gateway hours)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Application Gateway' `
    -ProductName 'Application Gateway WAF v2' `
    -MeterName 'Standard Fixed Cost'

# WAF v2 — capacity units
.\Get-AzurePricing.ps1 `
    -ServiceName 'Application Gateway' `
    -ProductName 'Application Gateway WAF v2' `
    -MeterName 'Standard Capacity Units'

# Standard v2 — fixed cost
.\Get-AzurePricing.ps1 `
    -ServiceName 'Application Gateway' `
    -ProductName 'Application Gateway Standard v2' `
    -MeterName 'Standard Fixed Cost'

# Standard v2 — capacity units
.\Get-AzurePricing.ps1 `
    -ServiceName 'Application Gateway' `
    -ProductName 'Application Gateway Standard v2' `
    -MeterName 'Standard Capacity Units'

# Basic v2 — fixed cost
.\Get-AzurePricing.ps1 `
    -ServiceName 'Application Gateway' `
    -ProductName 'Application Gateway Basic v2' `
    -MeterName 'Basic Fixed Cost'

# Basic v2 — capacity units
.\Get-AzurePricing.ps1 `
    -ServiceName 'Application Gateway' `
    -ProductName 'Application Gateway Basic v2' `
    -MeterName 'Basic Capacity Units'
```

## Product Names

| Variant     | productName                       | Fixed Cost Meter      | CU Meter                  |
| ----------- | --------------------------------- | --------------------- | ------------------------- |
| WAF v2      | `Application Gateway WAF v2`      | `Standard Fixed Cost` | `Standard Capacity Units` |
| Standard v2 | `Application Gateway Standard v2` | `Standard Fixed Cost` | `Standard Capacity Units` |
| Basic v2    | `Application Gateway Basic v2`    | `Basic Fixed Cost`    | `Basic Capacity Units`    |

## Cost Formula

```
Monthly = (fixedCost_unitPrice × 730) + (capacityUnit_unitPrice × estimatedCUs × 730)
```

## Notes

- Capacity Units (CU) are consumption-based — estimate based on expected traffic
- A CU measures: ~2,500 concurrent connections, ~2.22 Mbps throughput, or ~1 compute unit
- For light workloads, estimate ~5-10 CU average; for moderate, ~10-30 CU
- WAF v2 fixed cost is ~1.8× Standard v2 fixed cost; CU price is also higher
