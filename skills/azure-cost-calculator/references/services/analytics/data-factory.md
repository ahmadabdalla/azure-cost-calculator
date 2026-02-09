---
serviceName: Azure Data Factory
category: analytics
aliases: [ADF, ETL, Data Pipeline]
---

# Azure Data Factory

**Primary cost**: Pipeline activity runs (per month) + data movement hours + inactive pipeline fees

> **Trap (v1 vs v2)**: The API has two separate service names: `Azure Data Factory` (v1, legacy) and `Azure Data Factory v2` (current). Most deployments use v2. Always confirm which version the user has before querying.

> **Trap (inflated totals)**: Unfiltered `-ServiceName 'Azure Data Factory v2'` returns hundreds of SSIS VM meters — `totalMonthlyCost` inflates by orders of magnitude. Always filter by `-ProductName 'Azure Data Factory v2'` and `-SkuName`.

## Query Pattern

```powershell
# v2 Cloud — orchestration activity runs (per 1K runs, use -Quantity for monthly volume)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Data Factory v2' `
    -ProductName 'Azure Data Factory v2' `
    -SkuName 'Cloud' -MeterName 'Cloud Orchestration Activity Run' `
    -Quantity 10000
```

```powershell
# v2 Cloud — data movement hours (use -InstanceCount for parallel copy units)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Data Factory v2' `
    -ProductName 'Azure Data Factory v2' `
    -SkuName 'Cloud' -MeterName 'Cloud Data Movement' `
    -InstanceCount 4 -HoursPerMonth 160
```

```powershell
# v2 Data Flow — General Purpose vCores (per hour, min 8 vCores per cluster)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Data Factory v2' `
    -ProductName 'Azure Data Factory v2 Data Flow - General Purpose' `
    -SkuName 'vCore' -HoursPerMonth 200
```

```powershell
# v2 Self Hosted — pipeline activity hours
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Data Factory v2' `
    -ProductName 'Azure Data Factory v2' `
    -SkuName 'Self Hosted' -MeterName 'Self Hosted Pipeline Activity' `
    -HoursPerMonth 160
```

```powershell
# v1 Cloud — activity runs and data movement (legacy)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Data Factory' `
    -SkuName 'Cloud'
```

## Key Fields

| Parameter | How to determine | Example values |
| --- | --- | --- |
| `serviceName` | v2 (current) or v1 (legacy) | `Azure Data Factory v2`, `Azure Data Factory` |
| `productName` | Base service or Data Flow tier | `Azure Data Factory v2`, `Azure Data Factory v2 Data Flow - General Purpose` |
| `skuName` | Runtime type or Data Flow | `Cloud`, `Self Hosted`, `Azure Managed VNET`, `vCore` |
| `meterName` | Billing dimension | `Cloud Orchestration Activity Run`, `Cloud Data Movement`, `vCore` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- |
| `Cloud Orchestration Activity Run` | `Cloud` | `1K` | Per 1,000 activity runs (v2) |
| `Cloud Pipeline Activity` | `Cloud` | `1 Hour` | Execute pipeline activity hours (v2) |
| `Cloud Data Movement` | `Cloud` | `1 Hour` | Data movement runtime hours (v2) |
| `Cloud Read Write Operations` | `Cloud` | `50K` | Entity read/write/monitoring (v2) |
| `Inactive Pipeline` | `Cloud` | `1/Month` | Per inactive pipeline/month (v2) |
| `vCore` | `vCore` | `1 Hour` | Data Flow vCore hours (v2) |

> Self Hosted and Azure Managed VNET meters follow the same pattern with prefixed names (e.g., `Self Hosted Data Movement`). v1 meters use `Cloud High Frequency Activity` and `Cloud Low Frequency Activity` (per month).

## Cost Formula

```
v2 Pipeline: Monthly = (activityRuns / 1000) × orchestration_retailPrice
               + pipelineActivityHours × pipeline_retailPrice
               + dataMovementHours × movement_retailPrice
               + inactivePipelines × inactive_retailPrice
v2 Data Flow: Monthly = vCores × vcore_retailPrice × activeHours
```

## Notes

- **v2 is the current version** — v1 is legacy; new factories always deploy as v2
- Data Flow clusters require a minimum of 8 vCores (General Purpose); scale in 4-vCore increments
- Data Flow types: General Purpose, Compute Optimized, Memory Optimized — each has a separate `productName`
- SSIS Integration Runtime is billed as VMs under this service — query with `-ProductName 'SSIS ...'` product names
- Reserved pricing available for Data Flow vCores only (Compute Optimized, General Purpose) — use `-PriceType Reservation`; the script's `MonthlyCost` is wrong for Reservation items — manually calculate as `unitPrice ÷ 12` (1-Year) or `unitPrice ÷ 36` (3-Year)
- Orchestration runs are billed per 1,000; pipeline/external activities are billed per hour of execution
- Monitoring operations billed per 50K; read/write operations billed per 50K
