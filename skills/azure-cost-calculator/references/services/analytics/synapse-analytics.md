---
serviceName: Azure Synapse Analytics
category: analytics
aliases: [Synapse, Synapse Workspace, Synapse SQL, Synapse Spark]
billingNeeds: [Data Lake Storage]
billingConsiderations: [Reserved Instances]
primaryCost: "Dedicated SQL Pool DWU hours + Serverless SQL per-TB + Spark vCore hours + Pipeline runs + storage per-GB"
privateEndpoint: true
---

# Azure Synapse Analytics

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

### Data Flow — Standard vCores (per hour; also Basic and Compute Optimized)

ServiceName: Azure Synapse Analytics
ProductName: Azure Synapse Analytics Data Flow - Standard

### Pipelines — orchestration activity runs (per 1K; Quantity = billable 1K-unit count)

ServiceName: Azure Synapse Analytics
ProductName: Azure Synapse Analytics Pipelines
SkuName: Azure Hosted IR
MeterName: Azure Hosted IR Orchestration Activity Run
Quantity: 10

### Storage — backup storage (use Quantity for GB)

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
| `Standard LRS Data Stored`                   | `Storage`                                         | `1 GB/Month`  | Backup storage (LRS)          |

## Cost Formula

```
Dedicated SQL     = dwu_retailPrice × 730 × instanceCount
Serverless SQL    = (dataProcessedTB) × serverless_retailPrice
Spark / Data Flow = vcore_retailPrice × activeHours × vCoreCount
Pipelines         = (activityRuns / 1000) × orchestration_retailPrice + movementHours × movement_retailPrice
Storage           = storage_retailPrice × sizeInGB
Total Monthly     = Dedicated SQL + Serverless SQL + Spark / Data Flow + Pipelines + Storage
```

## Notes

- **Dedicated SQL Pool**: Pausing stops compute billing but storage continues; pricing scales linearly per DWU (DW100c–DW30000c); **Serverless SQL**: Pay-per-query, no provisioning
- **Spark Pools**: Auto-pause, billed per vCore-hour; **Pipelines**: Mirror Data Factory v2 pricing; SSIS VMs filter by `ProductName` containing `SSIS`
- **PE sub-resources** (never-assume): `Sql`, `SqlOnDemand`, `Dev` — see `networking/private-link.md` for PE pricing

## Reserved Instance Pricing

ServiceName: Azure Synapse Analytics
ProductName: Azure Synapse Analytics Dedicated SQL Pool
SkuName: DW100c
PriceType: Reservation

> **Note (RI DW100c only)**: The API only returns RI pricing for `DW100c` (Dedicated SQL Pool only). For larger SKUs, multiply: `unitPrice × (targetDWU ÷ 100)`.
