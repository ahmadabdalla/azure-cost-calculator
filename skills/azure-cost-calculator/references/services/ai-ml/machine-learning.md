---
serviceName: Azure Machine Learning
category: ai-ml
aliases: [Azure ML, AML, ML Workspace]
billingNeeds: [Storage, Key Vault, Application Insights]
primaryCost: "Managed online endpoint capacity (hourly × 730) + ML service surcharges. Training clusters billed under VMs."
privateEndpoint: true
---

# Azure Machine Learning

> **Trap (inflated totals)**: An unfiltered `ServiceName 'Azure Machine Learning'` query returns ~28 meters across three product families — legacy Enterprise Inferencing (all zero price), ML service surcharges, and Managed Model Hosting endpoints. The `totalMonthlyCost` sums all of them, which is meaningless. Always filter by `ProductName`.

> **Trap (compute billing split)**: Managed endpoints are billed here under `Azure Machine Learning` (Managed Model Hosting Service). Training clusters and compute instances run on **Virtual Machines** and are billed separately under the `Virtual Machines` service. The meters in this service cover managed endpoint capacity and ML service surcharges only.

## Query Pattern

### Managed online endpoint — e.g., NC4asT4 v3 GPU instance (2 endpoints)

ServiceName: Azure Machine Learning
ProductName: Managed Model Hosting Service
SkuName: NC4asT4 v3
InstanceCount: 2

### ML service surcharge — Standard GPU

ServiceName: Azure Machine Learning
ProductName: Machine Learning service
MeterName: Standard GPU Surcharge

### Safety evaluation tokens (input) — 100K tokens

ServiceName: Azure Machine Learning
ProductName: Machine Learning service
MeterName: Evaluation Input Tokens
Quantity: 100

## Key Fields

| Parameter     | How to determine                                    | Example values                                              |
| ------------- | --------------------------------------------------- | ----------------------------------------------------------- |
| `serviceName` | Always `Azure Machine Learning`                     | `Azure Machine Learning`                                    |
| `productName` | Component type                                      | `Managed Model Hosting Service`, `Machine Learning service` |
| `skuName`     | VM size for endpoints; tier for surcharges          | `NC4asT4 v3`, `NCadsA100v4`, `Standard`, `PB`               |
| `meterName`   | Matches skuName + "Capacity Unit" or surcharge type | `NC4asT4 v3 Capacity Unit`, `Standard GPU Surcharge`        |

## Meter Names

| Meter                        | skuName                   | unitOfMeasure | Notes                           |
| ---------------------------- | ------------------------- | ------------- | ------------------------------- |
| `NC4asT4 v3 Capacity Unit`   | `NC4asT4 v3`              | `1 Hour`      | Managed endpoint — T4 GPU       |
| `NCadsA100v4 Capacity Unit`  | `NCadsA100v4`             | `1 Hour`      | Managed endpoint — A100 GPU     |
| `NCadsH100 v5 Capacity Unit` | `NCadsH100 v5`            | `1 Hour`      | Managed endpoint — H100 GPU     |
| `NDisrH100v5 Capacity Unit`  | `NDisrH100v5`             | `1 Hour`      | Managed endpoint — H100 multi   |
| `Standard GPU Surcharge`     | `Standard`                | `1 Hour`      | ML service GPU surcharge        |
| `PB vCPU Surcharge`          | `PB`                      | `1 Hour`      | ML service vCPU surcharge       |
| `Evaluation Input Tokens`    | `Evaluation Input Tokens` | `1K`          | Safety evaluation input tokens  |
| `Evaluation Ouput Tokens`    | `Evaluation Ouput Tokens` | `1K`          | Safety evaluation output tokens |

> Note: The spelling `Evaluation Ouput Tokens` matches the Retail Prices API meter name exactly and is intentional; do not change it to `Output` in queries or in this table.

> Additional Managed Model Hosting SKUs (NV-series, ND-series) are available — query with `ProductName 'Managed Model Hosting Service'` to list all.

## Cost Formula

```
Managed Endpoint Monthly = endpoint_retailPrice × 730 × instanceCount
Surcharge Monthly        = surcharge_retailPrice × 730 × numberOfSurchargeUnits   # e.g., GPUs or vCPUs
Evaluation Monthly       = token_retailPrice × (tokens / 1000)
Training Compute         = billed under Virtual Machines (see compute/virtual-machines.md)
```

## Notes

- Managed online endpoints (`Managed Model Hosting Service`) are the primary billable meters under this service
- Enterprise Inferencing products (`Azure Machine Learning Enterprise *`) and training surcharges (`Standard Training GPU/vCPU Surcharge`) return zero cost — these are legacy meters
- Storage for ML workspaces is billed under Azure Storage (Blob/File) separately
