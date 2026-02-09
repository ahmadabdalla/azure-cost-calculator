---
serviceName: Azure Machine Learning
category: ai-ml
aliases: [Azure ML, AML, ML Workspace, Machine Learning Studio]
---

# Azure Machine Learning

**Primary cost**: Managed endpoint compute (hourly × 730) + ML service surcharges + underlying VM compute billed separately via Virtual Machines

> **Trap (inflated totals)**: An unfiltered `-ServiceName 'Azure Machine Learning'` query returns ~28 meters across three product families — legacy Enterprise Inferencing (all $0.00), ML service surcharges, and Managed Model Hosting endpoints. The `totalMonthlyCost` sums all of them (~$49K) which is meaningless. Always filter by `-ProductName`.

> **Trap (compute billing split)**: Training clusters and compute instances are billed as **Virtual Machines**, not under this service. Query `Virtual Machines` for the actual compute cost. The meters here are surcharges and managed endpoint fees only.

## Query Pattern

```powershell
# Managed online endpoint — e.g., NC4asT4 v3 GPU instance (2 endpoints)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Machine Learning' `
    -ProductName 'Managed Model Hosting Service' `
    -SkuName 'NC4asT4 v3' `
    -InstanceCount 2
```

```powershell
# ML service surcharge — Standard GPU
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Machine Learning' `
    -ProductName 'Machine Learning service' `
    -MeterName 'Standard GPU Surcharge'
```

```powershell
# Safety evaluation tokens (input) — 100K tokens
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Machine Learning' `
    -ProductName 'Machine Learning service' `
    -MeterName 'Evaluation Input Tokens' `
    -Quantity 100
```

## Key Fields

| Parameter     | How to determine                             | Example values                                                          |
| ------------- | -------------------------------------------- | ----------------------------------------------------------------------- |
| `serviceName` | Always `Azure Machine Learning`              | `Azure Machine Learning`                                                |
| `productName` | Component type                               | `Managed Model Hosting Service`, `Machine Learning service`             |
| `skuName`     | VM size for endpoints; tier for surcharges    | `NC4asT4 v3`, `NCadsA100v4`, `Standard`, `PB`                          |
| `meterName`   | Matches skuName + "Capacity Unit" or surcharge type | `NC4asT4 v3 Capacity Unit`, `Standard GPU Surcharge`              |

## Meter Names

| Meter                              | skuName              | unitOfMeasure | Notes                           |
| ---------------------------------- | -------------------- | ------------- | ------------------------------- |
| `NC4asT4 v3 Capacity Unit`         | `NC4asT4 v3`         | `1 Hour`      | Managed endpoint — T4 GPU       |
| `NCadsA100v4 Capacity Unit`        | `NCadsA100v4`        | `1 Hour`      | Managed endpoint — A100 GPU     |
| `NCadsH100 v5 Capacity Unit`       | `NCadsH100 v5`       | `1 Hour`      | Managed endpoint — H100 GPU     |
| `NDisrH100v5 Capacity Unit`        | `NDisrH100v5`        | `1 Hour`      | Managed endpoint — H100 multi   |
| `Standard GPU Surcharge`           | `Standard`           | `1 Hour`      | ML service GPU surcharge        |
| `PB vCPU Surcharge`                | `PB`                 | `1 Hour`      | ML service vCPU surcharge       |
| `Evaluation Input Tokens`          | `Evaluation Input Tokens`  | `1K`    | Safety evaluation input tokens  |
| `Evaluation Ouput Tokens`          | `Evaluation Ouput Tokens`  | `1K`    | Safety evaluation output tokens |

> Additional Managed Model Hosting SKUs (NV-series, ND-series) are available — query with `-ProductName 'Managed Model Hosting Service'` to list all.

## Cost Formula

```
Managed Endpoint Monthly = endpoint_retailPrice × 730 × instanceCount
Surcharge Monthly        = surcharge_retailPrice × 730
Evaluation Monthly       = token_retailPrice × (tokens / 1000)
Training Compute         = billed under Virtual Machines (see compute/virtual-machines.md)
```

## Notes

- Training clusters and compute instances use underlying VMs — price them via the `Virtual Machines` service, not this one
- Managed online endpoints (`Managed Model Hosting Service`) are the primary billable meters under this service
- Enterprise Inferencing products (`Azure Machine Learning Enterprise *`) return $0.00 — these are legacy meters
- Reserved pricing is **not available** for Azure Machine Learning meters
- Storage for ML workspaces is billed under Azure Storage (Blob/File) separately
