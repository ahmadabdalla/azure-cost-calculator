---
serviceName: Azure Analysis Services
category: analytics
aliases: [AAS, Tabular Model]
primaryCost: "Per-QPU hourly rate × 730 per SKU (Developer, Basic B1–B2, Standard S0–S9 v2)"
---

# Azure Analysis Services

> **Trap (multiple products)**: The serviceName spans four `productName` values (Developer, Basic, Standard, Standard v2). An unfiltered query sums all tiers — always filter by `ProductName` and `SkuName` to isolate a single meter.

> **Trap (v2 region limits)**: `Azure Analysis Services Standard v2` (S8 v2, S9 v2) is not available in all regions — eastus returns empty results. Use eastus2, westus2, or another supported region for v2 queries.

## Query Pattern

### Standard tier — S1 (100 QPUs)

ServiceName: Azure Analysis Services
ProductName: Azure Analysis Services Standard
SkuName: S1
MeterName: S1

### Standard tier — S2 with 3 scale-out replicas (InstanceCount = primary + replicas)

ServiceName: Azure Analysis Services
ProductName: Azure Analysis Services Standard
SkuName: S2
MeterName: S2
InstanceCount: 4

### Developer tier — dev/test only, no SLA

ServiceName: Azure Analysis Services
ProductName: Azure Analysis Services Developer
SkuName: Developer
MeterName: Developer

### Standard v2 — S8 v2 (limited regions, use eastus2)

ServiceName: Azure Analysis Services
ProductName: Azure Analysis Services Standard v2
SkuName: S8 v2
MeterName: S8 v2
Region: eastus2

## Key Fields

| Parameter | How to determine | Example values |
| --- | --- | --- |
| `serviceName` | Always `Azure Analysis Services` | `Azure Analysis Services` |
| `productName` | Tier selection determines the product | `Azure Analysis Services Standard`, `...Basic`, `...Developer`, `...Standard v2` |
| `skuName` | SKU within the selected tier (never-assume) | `B1`, `S0`, `S1`, `S2`, `S4`, `S8 v2`, `Developer` |
| `meterName` | Matches `skuName` exactly | `S1`, `B2`, `S8 v2`, `Developer` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- |
| `Developer` | `Developer` | `1 Hour` | 10 QPUs; dev/test only, no SLA |
| `B1` | `B1` | `1 Hour` | 40 QPUs; Basic tier |
| `B2` | `B2` | `1 Hour` | 80 QPUs; Basic tier |
| `S0` | `S0` | `1 Hour` | 40 QPUs; Standard tier |
| `S1` | `S1` | `1 Hour` | 100 QPUs |
| `S2` | `S2` | `1 Hour` | 200 QPUs |
| `S4` | `S4` | `1 Hour` | 400 QPUs |
| `S8 v2` | `S8 v2` | `1 Hour` | 640 QPUs; Standard v2, limited regions |
| `S9 v2` | `S9 v2` | `1 Hour` | 1280 QPUs; Standard v2, limited regions |

Standard tier also has `{SKU} Scale-Out` meters (e.g., `S1 Scale-Out`) at the same rate — use for read-only query replicas.

## Cost Formula

```
Monthly = retailPrice × 730 × instanceCount
```

Where `instanceCount` = 1 for single server, or (1 + replicaCount) for Standard tier with scale-out replicas.

## Notes

- **Capacity planning**: QPU counts scale per tier — Developer 10, B1/S0 40, B2 80, S1 100, S2 200, S4 400, S8 v2 640, S9 v2 1280; memory scales proportionally
- **Tier limitations**: Developer has no SLA and no scale-out. Basic has no scale-out or DirectQuery. Standard supports up to 7 read-only scale-out replicas.
- **Pausing**: Billing stops entirely when a server is paused — no charges apply while paused
- **No separate storage billing**: Model data resides in-memory; storage is included in the compute price. Backups use the customer's own Azure Storage account (billed separately under Storage).
- **Scale-out replicas**: Standard tier only; each replica is billed at the same hourly rate as the primary instance
- **Deprecated SKUs**: S8 and S9 (non-v2) still appear in the API under `Azure Analysis Services Standard` but are deprecated — use S8 v2 and S9 v2 instead
