---
serviceName: Cosmos DB Garnet Cache
category: databases
aliases: [Garnet Cache, Redis-compatible Cache, Cosmos DB Cache, vCore Cache]
apiServiceName: Azure Cosmos DB
primaryCost: "vCPU hourly rate × total vCPU count × 730 + Premium SSD GB-hours when persistence is enabled"
---

# Cosmos DB Garnet Cache

> **Trap (split-product)**: The API `serviceName` is `Azure Cosmos DB` (shared with 15+ products). Always filter with `ProductName: Azure Cosmos DB Garnet Cache` to isolate Garnet Cache meters. Omitting `ProductName` returns an inflated total mixing throughput, serverless, autoscale, and other Cosmos DB products.

## Query Pattern

### Compute: General Purpose v6 (e.g., 4 vCPUs)

ServiceName: Azure Cosmos DB
ProductName: Azure Cosmos DB Garnet Cache
SkuName: General Purpose v6
MeterName: General Purpose v6 vCore
Quantity: 4 # total vCPUs across all nodes

### Disk storage with persistence (e.g., 128 GB)

ServiceName: Azure Cosmos DB
ProductName: Azure Cosmos DB Garnet Cache
SkuName: Premium SSD Managed Disk
MeterName: Premium SSD Managed Disk
Quantity: 128 # total disk GB across all nodes

## Key Fields

| Parameter     | How to determine                                      | Example values                                                                    |
| ------------- | ----------------------------------------------------- | --------------------------------------------------------------------------------- |
| `serviceName` | Always `Azure Cosmos DB`                              | `Azure Cosmos DB`                                                                 |
| `productName` | Always `Azure Cosmos DB Garnet Cache`                 | `Azure Cosmos DB Garnet Cache`                                                    |
| `skuName`     | Tier + generation                                     | `General Purpose - Burstable`, `General Purpose v6`, `Compute Optimized`, `Storage Optimized` |
| `meterName`   | Compute: skuName + ` vCore`; disk: matches `skuName` | `General Purpose - Burstable vCore`, `Compute Optimized v6 vCore`, `Premium SSD Managed Disk` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `General Purpose - Burstable vCore` | `General Purpose - Burstable` | `1 Hour` | Burstable; lowest cost |
| `General Purpose vCore` | `General Purpose` | `1 Hour` | Standard general purpose tier |
| `General Purpose v6 vCore` | `General Purpose v6` | `1 Hour` | v6 generation |
| `Compute Optimized vCore` | `Compute Optimized` | `1 Hour` | Higher compute |
| `Compute Optimized v6 vCore` | `Compute Optimized v6` | `1 Hour` | v6 generation |
| `Memory Optimized vCore` | `Memory Optimized` | `1 Hour` | High-memory workloads |
| `Memory Optimized v6 vCore` | `Memory Optimized v6` | `1 Hour` | v6 generation |
| `Storage Optimized vCore` | `Storage Optimized` | `1 Hour` | Most expensive; no v6 variant |
| `Premium SSD Managed Disk` | `Premium SSD Managed Disk` | `1/Hour` | Per-GB disk; persistence only |

## Cost Formula

```
Compute  = compute_retailPrice × totalVCPUCount × 730
Storage  = disk_retailPrice × totalDiskSizeGB × 730 # if persistence is enabled
Monthly  = Compute + Storage
```

## Notes

- Redis-compatible caching layer in Azure Cosmos DB; uses the same `serviceName` as parent Cosmos DB
- Five vCore tiers: General Purpose - Burstable, General Purpose, Compute Optimized, Memory Optimized, Storage Optimized. Tier is a never-assume parameter
- General Purpose, Compute Optimized, and Memory Optimized have v6 variants; Burstable and Storage Optimized do not
- The disk meter (`Premium SSD Managed Disk`) applies when persistence is enabled; multiply by total GB × 730
- Scale by total nodes: shards × replication factor. Use total vCPUs and disk GB across all nodes
- No Reserved Instances, Spot, or DevTest pricing available for this product
- Parent service reference: see `databases/cosmos-db.md` for base Cosmos DB provisioned throughput and storage pricing
