---
serviceName: Azure Batch
category: compute
aliases: [HPC Batch, Batch Compute]
---

# Azure Batch

**Primary cost**: No charge for the Batch service itself — pay for underlying VM compute, storage, and networking resources consumed by pool nodes.

> **Trap (no Batch meters)**: `serviceName eq 'Azure Batch'` returns **zero results** from the Retail Prices API. The Batch service is free; all cost comes from pool node VMs (priced as `Virtual Machines`), managed disks, and data egress. Do NOT query with `-ServiceName 'Azure Batch'`.
>
> **Agent instruction**: Always price Batch workloads by querying `Virtual Machines` for the node VM size. Use Low Priority or Spot SKUs when the user mentions interruptible/preemptible nodes.

## Query Pattern

### Pool nodes — price as Virtual Machines (e.g., 4-node D4s v5 pool)

ServiceName: Virtual Machines <!-- cross-service -->
ArmSkuName: Standard_D4s_v5
ProductName: Virtual Machines Dsv5 Series
InstanceCount: 4

> For **Spot** nodes (up to 90% discount, may be evicted), add `SkuName: {ArmSkuName} Spot` (e.g., `Standard_D4s_v5 Spot`). For **Low Priority** nodes (up to 80% discount), add `SkuName: {ArmSkuName} Low Priority`.

## Key Fields

| Parameter     | How to determine                               | Example values                                                   |
| ------------- | ---------------------------------------------- | ---------------------------------------------------------------- |
| `serviceName` | Always `Virtual Machines` (not `Azure Batch`)  | `Virtual Machines`                                               |
| `armSkuName`  | VM size chosen for the Batch pool              | `Standard_D4s_v5`, `Standard_HB120rs_v3`                         |
| `productName` | Series + OS (Linux omits suffix, Windows adds) | `Virtual Machines Dsv5 Series`, `… Series Windows`               |
| `skuName`     | Size + pricing tier suffix                     | `D4s v5`, `Standard_D4s_v5 Spot`, `Standard_D4s_v5 Low Priority` |

## Meter Names

| Meter                      | unitOfMeasure | Notes                                                                                                                                         |
| -------------------------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| _(VM size, e.g. `D4s v5`)_ | `1 Hour`      | Meter name mirrors ARM SKU without `Standard_` prefix; same meter for standard, Spot, and Low Priority — use `skuName` to select pricing tier |

> Additional costs: OS disk (Managed Disks), data egress (Bandwidth), and any mounted storage (Azure Files, Blob). Query each service separately.

## Cost Formula

```
Monthly = VM_retailPrice × 730 × nodeCount
```

For job-based (ephemeral) pools, estimate actual hours instead of 730:

```
Job cost = VM_retailPrice × hoursPerJob × nodeCount × jobsPerMonth
```

## Notes

- The Batch management service is free — no meters exist in the API
- Pool nodes are billed as standard Virtual Machines; see `virtual-machines.md` for full VM pricing details
- **Spot nodes** offer up to 90% discount but can be evicted at any time — best for fault-tolerant HPC and rendering workloads
- **Low Priority nodes** (classic pools) offer up to 80% discount with similar eviction risk
- Batch supports auto-scale pools — estimate average node count rather than peak for monthly cost
- Reserved VM Instances apply to dedicated Batch nodes; query with `-PriceType Reservation` against `Virtual Machines`
- Common HPC VM sizes: `Standard_HB120rs_v3` (HPC), `Standard_NC24ads_A100_v4` (GPU), `Standard_D16s_v5` (general)
- Capacity planning: 1 Batch node = 1 VM; node count × hours determines compute cost
