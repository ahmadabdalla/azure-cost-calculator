---
serviceName: Container Registry
category: containers
aliases: [ACR, Docker Registry]
primaryCost: "Registry unit (daily) + excess storage (per-GB/month)"
hasFreeGrant: true
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
Quantity: 50 # excess GB beyond included tier quota

> **Note**: For geo-replication storage (Premium only), use `MeterName 'Premium GB Registry Replication Data Stored'`.

## Meter Names

| Meter                                         | unitOfMeasure | Notes                          |
| --------------------------------------------- | ------------- | ------------------------------ |
| `Basic Registry Unit`                         | `1/Day`       | Basic tier registry            |
| `Standard Registry Unit`                      | `1/Day`       | Standard tier registry         |
| `Premium Registry Unit`                       | `1/Day`       | Premium tier registry          |
| `Data Stored`                                 | `1 GB/Month`  | Excess storage beyond included |
| `Premium GB Registry Replication Data Stored` | `1 GB/Month`  | Per-replica geo-replication    |
| `Premium Registry Replication Unit`           | `1/Day`       | Per additional replica region  |
| `Premium Connected registry`                  | `1/Day`       | Per connected registry (edge)  |
| `Task vCPU Duration`                          | `1 Second`    | ACR Tasks build compute        |

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

## Notes

- Premium tier is required for geo-replication, content trust, and private endpoints
- ACR Tasks compute: first 6,000 vCPU-seconds/month free, then `retailPrice` per vCPU-second (tiered meter — ignore script's `totalMonthlyCost`)
- Geo-replication (Premium only): each replica region adds a `Premium Registry Replication Unit` daily charge + `Premium GB Registry Replication Data Stored` per GB
- Private endpoints require Premium tier
