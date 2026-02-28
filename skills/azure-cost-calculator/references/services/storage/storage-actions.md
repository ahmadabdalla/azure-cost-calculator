---
serviceName: Storage
category: storage
aliases: [Storage Data Processing, Storage Task Automation, Serverless Storage Processing]
primaryCost: "Per task execution + per million objects targeted + per million operations invoked"
---

# Storage Actions

> **Trap**: `serviceName: Storage` is shared across Blob, Files, Queue, Table, Managed Disks, Data Lake, File Sync, and Container Storage. Always filter by `ProductName: Storage Actions` to isolate meters.

> **Trap (multi-meter)**: Storage Actions has three independent billing dimensions. Query each meter separately with explicit `MeterName` and set `Quantity` to actual monthly usage. Do not rely on `totalMonthlyCost` from an unfiltered query — it sums all meters which is meaningless for independent dimensions.

## Query Pattern

### Task execution — 100 runs/month

ServiceName: Storage
ProductName: Storage Actions
SkuName: Azure Storage Tasks
MeterName: Azure Storage Tasks Task Execution
Quantity: 100 # task executions per month

### Objects targeted — 5M objects scanned

ServiceName: Storage
ProductName: Storage Actions
SkuName: Azure Storage Tasks
MeterName: Azure Storage Tasks Objects Targeted
Quantity: 5 # millions of objects targeted per month

### Operations invoked — 2M operations performed

ServiceName: Storage
ProductName: Storage Actions
SkuName: Azure Storage Tasks
MeterName: Azure Storage Tasks Operations Invoked
Quantity: 2 # millions of operations invoked per month

## Key Fields

| Parameter     | How to determine                           | Example values                                |
| ------------- | ------------------------------------------ | --------------------------------------------- |
| `serviceName` | Always `Storage` (shared serviceName)      | `Storage`                                     |
| `productName` | Always `Storage Actions`                   | `Storage Actions`                             |
| `skuName`     | Always `Azure Storage Tasks`               | `Azure Storage Tasks`                         |
| `meterName`   | Billing dimension — see Meter Names        | `Azure Storage Tasks Task Execution`          |

## Meter Names

| Meter                                       | unitOfMeasure | Notes                          |
| ------------------------------------------- | ------------- | ------------------------------ |
| `Azure Storage Tasks Task Execution`        | `1`           | Per task execution instance    |
| `Azure Storage Tasks Objects Targeted`      | `1M`          | Per million objects evaluated  |
| `Azure Storage Tasks Operations Invoked`    | `1M`          | Per million operations on objects |

## Cost Formula

```
Monthly = (executions × exec_retailPrice)
        + (objectsTargeted / 1,000,000 × targeted_retailPrice)
        + (operationsInvoked / 1,000,000 × invoked_retailPrice)
```

## Notes

- Storage Actions is a serverless data processing layer — underlying Blob Storage operations (Set Blob Tags, Set Blob Tier, etc.) are billed separately at standard per-10K rates; see `storage.md`
- No charge for composing/saving task definitions or validating tasks via preview
- Prices are uniform across all regions for the three core meters; region choice does not affect Storage Actions cost (but underlying storage costs vary by region)
- Capacity planning: each task execution targets a set of objects (containers/blobs matching filter conditions) and invokes operations on matched objects — estimate all three dimensions
- The API returns a fourth meter (`Azure Storage Tasks Objects Operated On`) not listed on the pricing page; exclude it from estimates
