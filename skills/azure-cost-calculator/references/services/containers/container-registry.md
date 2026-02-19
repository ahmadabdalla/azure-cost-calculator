---
serviceName: Container Registry
category: containers
aliases: [ACR, container registry]
primaryCost: "Registry unit (daily) + excess storage (per-GB/month)"
privateEndpoint: true
---

# Container Registry (ACR)

> **Trap (daily billing)**: Registry Unit meters are priced **per day** (`1/Day` unit), NOT per hour. The script now auto-multiplies `1/Day` units by 30, so `MonthlyCost` is already the correct **monthly** cost. Do NOT manually multiply by 30 again.

## Query Pattern

Substitute `{Tier}` with `Basic`, `Standard`, or `Premium`:

### {Tier} registry unit (daily cost)

ServiceName: Container Registry
ProductName: Container Registry
MeterName: {Tier} Registry Unit

### Data stored (excess beyond included quota)

ServiceName: Container Registry
ProductName: Container Registry
MeterName: Data Stored

> **Note**: For geo-replication storage (Premium only), use `MeterName 'Premium GB Registry Replication Data Stored'`.

## Meter Names

| Meter                                         | unitOfMeasure | Notes                          |
| --------------------------------------------- | ------------- | ------------------------------ |
| `Basic Registry Unit`                         | `1/Day`       | Basic tier registry            |
| `Standard Registry Unit`                      | `1/Day`       | Standard tier registry         |
| `Premium Registry Unit`                       | `1/Day`       | Premium tier registry          |
| `Data Stored`                                 | `1 GB/Month`  | Excess storage beyond included |
| `Premium GB Registry Replication Data Stored` | `1 GB/Month`  | Per-replica geo-replication    |

## Included Storage by Tier

| Tier     | Included Storage |
| -------- | ---------------- |
| Basic    | 10 GB            |
| Standard | 100 GB           |
| Premium  | 500 GB           |

## Cost Formula

```
Monthly = registryUnitPrice × 30 + storagePrice × max(0, totalGB - includedGB)
```

> **Note**: The script auto-multiplies `1/Day` units by 30. `MonthlyCost` is already the monthly cost.

## Notes

- Premium tier is required for geo-replication, content trust, and private endpoints
- Build tasks (ACR Tasks) have separate compute-based pricing not covered here
- Supports private endpoints (Premium required) — see `networking/private-link.md` for PE and DNS zone pricing
