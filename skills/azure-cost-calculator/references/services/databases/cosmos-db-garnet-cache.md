---
serviceName: Cosmos DB Garnet Cache
category: databases
aliases: [Garnet Cache, Redis-compatible Cache, Cosmos DB Cache, vCore Cache]
apiServiceName: Azure Cosmos DB
primaryCost: "vCPU-hours per tier × 730 + Premium SSD disk per GB × 730"
---

# Cosmos DB Garnet Cache

> **Trap (split-product)**: The API `serviceName` is `Azure Cosmos DB` (shared with 15+ products). Always filter with `ProductName: Azure Cosmos DB Garnet Cache` to isolate Garnet Cache meters — omitting `ProductName` returns an inflated total mixing throughput, serverless, autoscale, and other Cosmos DB products.

## Query Pattern

### Compute — General Purpose v6 (e.g., 4 vCPUs)

ServiceName: Azure Cosmos DB <!-- cross-service -->
ProductName: Azure Cosmos DB Garnet Cache
SkuName: General Purpose v6
MeterName: General Purpose v6 vCore
Quantity: 4 # number of vCPUs

### Disk storage (e.g., 128 GB)

ServiceName: Azure Cosmos DB <!-- cross-service -->
ProductName: Azure Cosmos DB Garnet Cache
SkuName: Premium SSD Managed Disk
MeterName: Premium SSD Managed Disk
Quantity: 128 # disk size in GB

## Key Fields

| Parameter     | How to determine                                      | Example values                                                                    |
| ------------- | ----------------------------------------------------- | --------------------------------------------------------------------------------- |
| `serviceName` | Always `Azure Cosmos DB`                              | `Azure Cosmos DB`                                                                 |
| `productName` | Always `Azure Cosmos DB Garnet Cache`                 | `Azure Cosmos DB Garnet Cache`                                                    |
| `skuName`     | Tier + generation                                     | `General Purpose`, `General Purpose v6`, `Compute Optimized`, `Storage Optimized` |
| `meterName`   | Compute: skuName + ` vCore`; disk: matches `skuName` | `General Purpose vCore`, `Compute Optimized v6 vCore`, `Premium SSD Managed Disk` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `General Purpose vCore` | `General Purpose` | `1 Hour` | Cheapest vCore tier |
| `General Purpose v6 vCore` | `General Purpose v6` | `1 Hour` | v6 generation |
| `Compute Optimized vCore` | `Compute Optimized` | `1 Hour` | Higher compute |
| `Compute Optimized v6 vCore` | `Compute Optimized v6` | `1 Hour` | v6 generation |
| `Memory Optimized vCore` | `Memory Optimized` | `1 Hour` | High-memory workloads |
| `Memory Optimized v6 vCore` | `Memory Optimized v6` | `1 Hour` | v6 generation |
| `Storage Optimized vCore` | `Storage Optimized` | `1 Hour` | Most expensive; no v6 variant |
| `Premium SSD Managed Disk` | `Premium SSD Managed Disk` | `1/Hour` | Per-GB disk; sub-cent hourly rate |

## Cost Formula

```
Compute  = compute_retailPrice × vCPUCount × 730
Storage  = disk_retailPrice × diskSizeGB × 730
Monthly  = Compute + Storage
```

## Notes

- Redis-compatible caching layer in Azure Cosmos DB — uses the same `serviceName` as parent Cosmos DB
- Four vCore tiers: General Purpose, Compute Optimized, Memory Optimized, Storage Optimized — tier is a never-assume parameter
- Three tiers have v5 (no suffix) and v6 generations; Storage Optimized has v5 only
- The disk meter (`Premium SSD Managed Disk`) has a sub-cent hourly rate; multiply by GB × 730 for meaningful monthly cost
- Scale compute by adjusting vCPU count; each tier targets different workload profiles
- No Reserved Instances, Spot, or DevTest pricing available for this product
- Parent service reference: see `databases/cosmos-db.md` for base Cosmos DB provisioned throughput and storage pricing
