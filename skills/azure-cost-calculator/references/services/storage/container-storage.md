---
serviceName: Storage
category: storage
aliases: [Container-native Storage, Kubernetes Storage]
billingNeeds: [Managed Disks]
primaryCost: "Per-GiB/month orchestration fee on provisioned pool capacity (v1 only; v2+ is free)"
pricingRegion: global
hasFreeGrant: true
---

# Azure Container Storage

> **Trap (version billing)**: v2.0.0+ has no orchestration fee — the API meter applies only to v1.x.x. For v2+, only the underlying storage costs (Managed Disks, Elastic SAN) apply.

> **Trap (free tier)**: v1 includes 5 TiB free per storage pool. The API returns a flat rate with no tier structure — manually deduct: `max(0, provisionedGiB - 5120) × retailPrice`.

> **Warning**: Global-only pricing — use `Region: Global`. Default region queries return zero results. Prices are USD-only.

## Query Pattern

### Orchestration fee (v1.x.x) — provisioned pool capacity

ServiceName: Storage
ProductName: Azure Container Storage
SkuName: Orchestration
MeterName: Provisioned Capacity Unit
Region: Global
Quantity: 10240 # provisioned GiB (e.g., 10 TiB pool)

## Key Fields

| Parameter     | How to determine                      | Example values              |
| ------------- | ------------------------------------- | --------------------------- |
| `serviceName` | Always `Storage` (shared serviceName) | `Storage`                   |
| `productName` | Always `Azure Container Storage`      | `Azure Container Storage`   |
| `skuName`     | Always `Orchestration`                | `Orchestration`             |
| `meterName`   | Always `Provisioned Capacity Unit`    | `Provisioned Capacity Unit` |

## Meter Names

| Meter                       | unitOfMeasure  | Notes                          |
| --------------------------- | -------------- | ------------------------------ |
| `Provisioned Capacity Unit` | `1 GiB/Month`  | Orchestration fee; v1.x.x only |

## Cost Formula

```
v1.x.x: Monthly = max(0, provisionedGiB - 5120) × retailPrice
v2.0.0+: No orchestration charge — estimate underlying storage only
Total = orchestration + underlying disk cost (see managed-disks.md)
```

## Notes

- Azure Container Storage is an AKS add-on — requires a running AKS cluster (billed separately)
- v1.x.x backing storage: Azure Disks, Ephemeral (NVMe/temp SSD), Elastic SAN
- v2.0.0+ backing storage: Local NVMe, Elastic SAN only (Azure Disks not supported)
- Orchestration meter covers management only — all data storage, IOPS, and throughput costs are billed through the underlying storage service
- Network isolation is handled through AKS cluster networking
