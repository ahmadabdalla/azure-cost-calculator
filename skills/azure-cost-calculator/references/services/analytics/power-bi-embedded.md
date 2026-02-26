---
serviceName: Power BI Embedded
category: analytics
aliases: [PBI Embedded, Embedded Analytics]
primaryCost: "Per-node hourly rate (A-SKU) × 730 × nodeCount"
privateEndpoint: true
---

# Power BI Embedded

> **Trap (inflated totals)**: An unfiltered `ServiceName: Power BI Embedded` query returns all A-SKU sizes summed together — always include `SkuName` to isolate a single node type.

> **Trap (A7/A8 limited regions)**: A7 and A8 SKUs exist only in Global, germanynorth, germanywestcentral, and usgovvirginia. Querying standard commercial regions returns empty results — use `Region: Global` for reference pricing.

## Query Pattern

### A4 node — single capacity (8 vCores, 25 GB RAM)

ServiceName: Power BI Embedded
ProductName: Power BI Embedded
SkuName: A4
MeterName: A4 Node

### A4 node — 3-node deployment (InstanceCount = number of capacities)

ServiceName: Power BI Embedded
ProductName: Power BI Embedded
SkuName: A4
MeterName: A4 Node
InstanceCount: 3

### A7 node — limited region availability

ServiceName: Power BI Embedded
ProductName: Power BI Embedded
SkuName: A7
MeterName: A7 Node
Region: Global

## Key Fields

| Parameter | How to determine | Example values |
| --- | --- | --- |
| `serviceName` | Always `Power BI Embedded` | `Power BI Embedded` |
| `productName` | A-SKU nodes vs legacy Workspace Collection | `Power BI Embedded`, `Power BI Workspace Collection` |
| `skuName` | Node size selected by user (never-assume) | `A1`, `A2`, `A3`, `A4`, `A5`, `A6`, `A7`, `A8` |
| `meterName` | Matches SKU: `{SKU} Node` | `A1 Node`, `A4 Node`, `A8 Node` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- |
| `A1 Node` | `A1` | `1 Hour` | 1 vCore, 3 GB RAM |
| `A2 Node` | `A2` | `1 Hour` | 2 vCores, 5 GB RAM |
| `A3 Node` | `A3` | `1 Hour` | 4 vCores, 10 GB RAM |
| `A4 Node` | `A4` | `1 Hour` | 8 vCores, 25 GB RAM |
| `A5 Node` | `A5` | `1 Hour` | 16 vCores, 50 GB RAM |
| `A6 Node` | `A6` | `1 Hour` | 32 vCores, 100 GB RAM |
| `A7 Node` | `A7` | `1 Hour` | 64 vCores, 200 GB RAM; limited regions |
| `A8 Node` | `A8` | `1 Hour` | 128 vCores, 400 GB RAM; limited regions |

## Cost Formula

```
Monthly = retailPrice × 730 × nodeCount
```

## Notes

- **Capacity planning**: Each A-SKU doubles vCores from the previous (A1=1, A2=2, A3=4, A4=8, A5=16, A6=32, A7=64, A8=128); RAM scales proportionally
- **Paused capacity**: Billing stops entirely when capacity is paused — content is unavailable while paused
- **No reserved instances**: RI is not available; consider Microsoft Fabric F-SKUs (which support RI) for long-term commitments
- **Workspace Collection (legacy)**: `Power BI Workspace Collection` uses per-session tiered pricing and is deprecated — use A-SKU nodes for new deployments
- **Power BI Premium distinction**: EM/P-SKUs under serviceName `Power BI` are M365-licensed (API returns zero price) — do not mix with A-SKU queries
