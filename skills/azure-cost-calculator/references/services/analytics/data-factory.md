---
serviceName: Azure Data Factory v2
category: analytics
aliases: [ADF, ADF v2, ETL, Data Pipeline, Azure Data Factory]
billingConsiderations: [Reserved Instances]
primaryCost: "Pipeline activity runs (per month) + data movement hours + inactive pipeline fees"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Data Factory

> **Trap (v1 vs v2)**: The API has two separate service names: `Azure Data Factory` (v1, legacy) and `Azure Data Factory v2` (current). Most deployments use v2. Always confirm which version the user has before querying.

> **Trap (inflated totals)**: Unfiltered `ServiceName 'Azure Data Factory v2'` returns hundreds of SSIS VM meters — `totalMonthlyCost` inflates by orders of magnitude. Always filter by `ProductName 'Azure Data Factory v2'` and `SkuName`.

## Query Pattern

### v2 Cloud — orchestration activity runs (per 1K runs, use Quantity for monthly volume)

ServiceName: Azure Data Factory v2
ProductName: Azure Data Factory v2
SkuName: Cloud
MeterName: Cloud Orchestration Activity Run
Quantity: 10000

### v2 Cloud — data movement (per hour; multiply retailPrice × estimated monthly hours)

ServiceName: Azure Data Factory v2
ProductName: Azure Data Factory v2
SkuName: Cloud
MeterName: Cloud Data Movement
InstanceCount: 4

### v2 Data Flow — General Purpose vCores (per hour; min 8 vCores per cluster)

ServiceName: Azure Data Factory v2
ProductName: Azure Data Factory v2 Data Flow - General Purpose
SkuName: vCore

### v2 Self Hosted — pipeline activity (per hour)

ServiceName: Azure Data Factory v2
ProductName: Azure Data Factory v2
SkuName: Self Hosted
MeterName: Self Hosted Pipeline Activity

## Key Fields

| Parameter     | How to determine               | Example values                                                               |
| ------------- | ------------------------------ | ---------------------------------------------------------------------------- |
| `serviceName` | v2 (current) or v1 (legacy)    | `Azure Data Factory v2`, `Azure Data Factory`                                |
| `productName` | Base service or Data Flow tier | `Azure Data Factory v2`, `Azure Data Factory v2 Data Flow - General Purpose` |
| `skuName`     | Runtime type or Data Flow      | `Cloud`, `Self Hosted`, `Azure Managed VNET`, `vCore`                        |
| `meterName`   | Billing dimension              | `Cloud Orchestration Activity Run`, `Cloud Data Movement`, `vCore`           |

## Meter Names

| Meter                              | skuName | unitOfMeasure | Notes                                |
| ---------------------------------- | ------- | ------------- | ------------------------------------ |
| `Cloud Orchestration Activity Run` | `Cloud` | `1K`          | Per 1,000 activity runs (v2)         |
| `Cloud Pipeline Activity`          | `Cloud` | `1 Hour`      | Execute pipeline activity hours (v2) |
| `Cloud Data Movement`              | `Cloud` | `1 Hour`      | Data movement runtime hours (v2)     |
| `Cloud Read Write Operations`      | `Cloud` | `50K`         | Entity read/write/monitoring (v2)    |
| `Inactive Pipeline`                | `Cloud` | `1/Month`     | Per inactive pipeline/month (v2)     |
| `vCore`                            | `vCore` | `1 Hour`      | Data Flow vCore hours (v2)           |

> Self Hosted and Azure Managed VNET meters follow the same pattern with prefixed names (e.g., `Self Hosted Data Movement`). v1 meters use `Cloud High Frequency Activity` and `Cloud Low Frequency Activity` (per month).

## Cost Formula

```
v2 Pipeline: Monthly = (activityRuns / 1000) × orchestration_retailPrice
               + pipelineActivityHours × pipeline_retailPrice
               + dataMovementHours × movement_retailPrice
               + inactivePipelines × inactive_retailPrice
               + max(0, readWriteOps - 1,000,000) / 50000 × readWrite_retailPrice
v2 Data Flow: Monthly = vCores × vcore_retailPrice × activeHours
```

## Notes

- **v2 is the current version** — v1 is legacy (`ServiceName 'Azure Data Factory' SkuName 'Cloud'`); new factories always deploy as v2
- Data Flow: General Purpose, Compute Optimized, Memory Optimized — each a separate `productName`. Min 8 vCores (GP); scale in 4-vCore increments
- **Managed Airflow** (Workflow Orchestration Manager): separate `ProductName 'Azure Data Factory v2 - Managed Airflow'` with Small and Large SKUs billed per vCore-hour
- SSIS Integration Runtime is billed as VMs under this service — query with `ProductName 'SSIS ...'` product names
- Orchestration billed per 1K; pipeline/external per hour; read/write and monitoring per 50K; first 1M operations/month free (tiered `Cloud Read Write Operations` meter)

## Reserved Instance Pricing

ServiceName: Azure Data Factory v2
ProductName: Azure Data Factory v2 Data Flow - General Purpose
SkuName: vCore
PriceType: Reservation

> RI is also available for `Azure Data Factory v2 Data Flow - Compute Optimized` (same `SkuName: vCore`). Memory Optimized has no RI pricing.
