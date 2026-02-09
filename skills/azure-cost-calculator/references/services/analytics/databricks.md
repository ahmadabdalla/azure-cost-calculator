---
serviceName: Azure Databricks
category: analytics
aliases: [DBX, Spark on Azure]
---

# Azure Databricks

**Primary cost**: DBU (Databricks Unit) hourly rate by workload type and tier (Standard/Premium) + underlying VM compute billed separately under Virtual Machines

> **Trap (inflated totals)**: An unfiltered `-ServiceName 'Azure Databricks'` query returns ~41 meters across classic and serverless workloads, POC, and free-trial SKUs. The `totalMonthlyCost` sums all of them which is meaningless. Always filter by `-SkuName` for a specific workload type.

> **Trap (VM compute split)**: DBU charges cover the Databricks platform fee only. The underlying cluster VMs are billed separately under the `Virtual Machines` service. Always price both components.

## Query Pattern

```powershell
# Premium Jobs Compute — e.g., 10 DBUs running full month
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Databricks' `
    -ProductName 'Azure Databricks' `
    -SkuName 'Premium Jobs Compute' `
    -Quantity 10
```

```powershell
# Premium All-purpose Compute — interactive clusters
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Databricks' `
    -ProductName 'Azure Databricks' `
    -SkuName 'Premium All-purpose Compute'
```

```powershell
# Premium Serverless SQL — serverless SQL warehouse
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Databricks' `
    -ProductName 'Azure Databricks Regional' `
    -SkuName 'Premium Serverless SQL'
```

## Key Fields

| Parameter     | How to determine                          | Example values                                                     |
| ------------- | ----------------------------------------- | ------------------------------------------------------------------ |
| `serviceName` | Always `Azure Databricks`                 | `Azure Databricks`                                                 |
| `productName` | Classic vs serverless workloads           | `Azure Databricks`, `Azure Databricks Regional`                    |
| `skuName`     | Tier + workload type                      | `Premium Jobs Compute`, `Standard All-purpose Compute`             |
| `meterName`   | Matches skuName + `DBU` suffix            | `Premium Jobs Compute DBU`, `Standard All-purpose Compute DBU`     |

## Meter Names

| Meter                                    | skuName                                  | unitOfMeasure | Notes                              |
| ---------------------------------------- | ---------------------------------------- | ------------- | ---------------------------------- |
| `Premium All-purpose Compute DBU`        | `Premium All-purpose Compute`            | `1 Hour`      | Interactive clusters (Premium)     |
| `Premium Jobs Compute DBU`               | `Premium Jobs Compute`                   | `1 Hour`      | Automated job clusters (Premium)   |
| `Premium Jobs Light Compute DBU`         | `Premium Jobs Light Compute`             | `1 Hour`      | Light jobs (Premium)               |
| `Standard All-purpose Compute DBU`       | `Standard All-purpose Compute`           | `1 Hour`      | Interactive clusters (Standard)    |
| `Standard Jobs Compute DBU`              | `Standard Jobs Compute`                  | `1 Hour`      | Automated job clusters (Standard)  |
| `Premium Serverless SQL DBU`             | `Premium Serverless SQL`                 | `1 Hour`      | Serverless SQL warehouse           |
| `Premium Interactive Serverless Compute DBU` | `Premium Interactive Serverless Compute` | `1 Hour`  | Serverless notebooks               |
| `Premium Automated Serverless Compute DBU`   | `Premium Automated Serverless Compute`   | `1 Hour`  | Serverless jobs                    |

## Cost Formula

```
DBU Monthly     = dbu_retailPrice × 730 × dbuCount
VM Monthly      = vm_retailPrice × 730 × nodeCount   (billed under Virtual Machines)
Total Monthly   = DBU Monthly + VM Monthly
```

## Notes

- **Two tiers**: Standard (data engineering) and Premium (adds RBAC, audit logs, Unity Catalog). Premium DBU rates are higher
- **Photon variants**: Photon-accelerated SKUs (e.g., `Premium All-Purpose Photon`) have the same DBU rate but process data faster, reducing total DBU-hours consumed
- **Delta Live Tables**: Separate DLT meters at Core, Pro, and Advanced levels (e.g., `Premium Pro Compute Delta Live Tables`)
- Underlying cluster VMs are priced via the `Virtual Machines` service — not included in Databricks meters
- Reserved pricing is **not available** for Azure Databricks DBU meters
- **14-day free trial**: Free Trial SKUs (`Premium - Free Trial *`) return $0.00 — ignore these for cost estimation
