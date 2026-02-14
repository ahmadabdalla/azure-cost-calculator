---
serviceName: Azure Synapse Analytics
category: analytics
aliases: [Synapse, Synapse Workspace, Synapse SQL, Synapse Spark]
billingNeeds: [Data Lake Storage]
billingConsiderations: [Reserved Instances]
---

# Azure Synapse Analytics

**Primary cost**: Dedicated SQL Pool DWU hours × 730 + Serverless SQL per-TB processed + Spark Pool vCore hours + Pipeline activity runs + storage per-GB/month

> **Trap (inflated totals)**: Unfiltered `ServiceName 'Azure Synapse Analytics'` returns ~127 meters including SSIS VM meters across multiple VM series. The `totalMonthlyCost` is meaningless. Always filter by `ProductName` for the specific component.
> **Trap (multi-component)**: Synapse has separate billing for Dedicated SQL Pool, Serverless SQL, Spark Pools, Pipelines, Data Flow, and Storage. Price each component individually.

## Query Pattern

### Dedicated SQL Pool — DW100c (smallest tier, hourly DWU charge)

ServiceName: Azure Synapse Analytics
ProductName: Azure Synapse Analytics Dedicated SQL Pool
SkuName: DW100c

### Serverless SQL Pool — per TB of data processed

ServiceName: Azure Synapse Analytics
ProductName: Azure Synapse Analytics Serverless SQL Pool

### Apache Spark Pool — Memory Optimized vCores

ServiceName: Azure Synapse Analytics
ProductName: Azure Synapse Analytics Serverless Apache Spark Pool - Memory Optimized

### Data Flow — Standard vCores (per hour)

ServiceName: Azure Synapse Analytics
ProductName: Azure Synapse Analytics Data Flow - Standard

### Pipelines — orchestration activity runs (per 1K; Quantity = billable 1K-unit count)

ServiceName: Azure Synapse Analytics
ProductName: Azure Synapse Analytics Pipelines
SkuName: Azure Hosted IR
MeterName: Azure Hosted IR Orchestration Activity Run
Quantity: 10

### Storage — workspace managed storage (use Quantity for GB)

ServiceName: Azure Synapse Analytics
ProductName: Azure Synapse Analytics Storage
SkuName: Standard LRS
Quantity: 100

## Key Fields

| Parameter     | How to determine                          | Example values                                                                               |
| ------------- | ----------------------------------------- | -------------------------------------------------------------------------------------------- |
| `serviceName` | Always `Azure Synapse Analytics`          | `Azure Synapse Analytics`                                                                    |
| `productName` | Component being priced                    | `Azure Synapse Analytics Dedicated SQL Pool`, `Azure Synapse Analytics Serverless SQL Pool`  |
| `skuName`     | Pool size (Dedicated) or tier (Pipelines) | `DW100c`, `DW1000c`, `Standard`, `Azure Hosted IR`, `vCore`                                  |
| `meterName`   | Specific billing meter for the component  | `100 DWUs`, `Standard Data Processed`, `vCore`, `Azure Hosted IR Orchestration Activity Run` |

## Meter Names

| Meter                                        | productName (suffix)                              | unitOfMeasure | Notes                         |
| -------------------------------------------- | ------------------------------------------------- | ------------- | ----------------------------- |
| `100 DWUs`                                   | `Dedicated SQL Pool`                              | `1/Hour`      | Dedicated SQL compute (×DWU)  |
| `Standard Data Processed`                    | `Serverless SQL Pool`                             | `1 TB`        | Serverless SQL per-TB scanned |
| `vCore`                                      | `Serverless Apache Spark Pool - Memory Optimized` | `1 Hour`      | Spark vCore hours             |
| `vCore`                                      | `Serverless Apache Spark Pool - GPU`              | `1 Hour`      | Spark GPU vCore hours         |
| `vCore`                                      | `Data Flow - Standard`                            | `1 Hour`      | Data Flow vCore hours         |
| `Azure Hosted IR Orchestration Activity Run` | `Pipelines`                                       | `1K`          | Per 1,000 pipeline runs       |
| `Standard LRS Data Stored`                   | `Storage`                                         | `1 GB/Month`  | Workspace managed storage     |

## Cost Formula

```
Dedicated SQL  = dwu_retailPrice × 730 × instanceCount
Serverless SQL = (dataProcessedTB) × serverless_retailPrice
Spark Pool     = vcore_retailPrice × activeHours × vCoreCount
Pipelines      = (activityRuns / 1000) × orchestration_retailPrice + movementHours × movement_retailPrice
Storage        = storage_retailPrice × sizeInGB
Total Monthly  = Dedicated SQL + Serverless SQL + Spark Pool + Pipelines + Storage
```

## Notes

- **Dedicated SQL Pool**: 16 SKUs from DW100c to DW30000c; pausing stops compute billing but storage continues
- **Serverless SQL Pool**: Pay-per-query at per-TB scanned; no provisioning needed
- **Spark Pools**: Auto-pause available; billed per vCore-hour while active; Memory Optimized and GPU variants
- **Pipelines**: Mirror Data Factory v2 pricing structure with Azure Hosted IR, Managed VNET IR, and Self-Hosted IR options. SSIS VMs filter by `ProductName` containing `SSIS`. Storage supports LRS, ZRS, RA-GRS, and RA-GZRS

## Reserved Instance Pricing

ServiceName: Azure Synapse Analytics
ProductName: Azure Synapse Analytics Dedicated SQL Pool
SkuName: DW100c
PriceType: Reservation

> **Trap (RI MonthlyCost)**: The script's `MonthlyCost` is wrong for Reservation items. Calculate: `unitPrice ÷ 12` (1-Year) or `unitPrice ÷ 36` (3-Year). RI is available for Dedicated SQL Pool only.
