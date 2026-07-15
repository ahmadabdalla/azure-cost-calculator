---
serviceName: Azure Machine Learning
category: ai-ml
aliases: [Azure ML, AML, ML Workspace]
billingNeeds: [Virtual Machines, Storage, Key Vault, Application Insights]
primaryCost: "Managed endpoint capacity + ML surcharges + token and daily management fees; training compute billed under VMs."
privateEndpoint: true
---

# Azure Machine Learning

> **Trap (inflated totals)**: An unfiltered `ServiceName 'Azure Machine Learning'` query returns dozens of meters across multiple product families: legacy Enterprise Inferencing (all zero price), ML service surcharges, Managed Model Hosting endpoints, serverless token-billed models, and Model Management tiers. The `totalMonthlyCost` sums all of them, which is meaningless. Always filter by `ProductName`.

> **Trap (compute billing split)**: Managed endpoints are billed here under `Azure Machine Learning` (Managed Model Hosting Service). Training clusters and compute instances run on **Virtual Machines** and are billed separately under the `Virtual Machines` service. The meters in this service cover managed endpoint capacity and ML service surcharges only.

> **Trap (regional gaps)**: Llama-4 token meters require `Region: eastus2` or `swedencentral`; `Machine Learning Model Management` tiers are not returned in `eastus`. If you omit region filters for those queries, the API can return zero results even when the meter is active.

## Query Pattern

### Managed online endpoint: NC4asT4 v3 GPU instance (2 endpoints, East US 2)

ServiceName: Azure Machine Learning
ProductName: Managed Model Hosting Service
SkuName: NC4asT4 v3
Region: eastus2
InstanceCount: 2

### ML service surcharge: Standard GPU

ServiceName: Azure Machine Learning
ProductName: Machine Learning service
MeterName: Standard GPU Surcharge

### Serverless token-billed model: Llama-4-Scout input, 100K tokens

ServiceName: Azure Machine Learning
ProductName: Managed Model Hosting Service
MeterName: Llama-4-Scout-17B-16E-In Tokens
Region: eastus2
Quantity: 100

### Model Management: S1 Tier

ServiceName: Azure Machine Learning
ProductName: Machine Learning Model Management
SkuName: S1
MeterName: S1 Tier
Region: eastus2

### Safety evaluation tokens (input): 100K tokens

ServiceName: Azure Machine Learning
ProductName: Machine Learning service
MeterName: Evaluation Input Tokens
Quantity: 100

## Key Fields

| Parameter     | How to determine                                                                    | Example values                                                                                   |
| ------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `serviceName` | Always `Azure Machine Learning`                                                     | `Azure Machine Learning`                                                                         |
| `productName` | Component type                                                                      | `Managed Model Hosting Service`, `Machine Learning service`, `Machine Learning Model Management` |
| `region`      | Use `eastus2` or `swedencentral` for Llama-4 tokens; `eastus2` for Model Management | `eastus2`, `swedencentral`                                                                       |
| `skuName`     | VM size for endpoints; tier for surcharges/mgmt                                     | `NC4asT4 v3`, `NCadsA100v4`, `Standard`, `PB`, `S1`                                              |
| `meterName`   | Matches skuName + "Capacity Unit" or surcharge type                                 | `NC4asT4 v3 Capacity Unit`, `Standard GPU Surcharge`, `Llama-4-Scout-17B-16E-In Tokens`          |

## Meter Names

| Meter                                   | skuName                          | productName                         | unitOfMeasure | Notes                           |
| --------------------------------------- | -------------------------------- | ----------------------------------- | ------------- | ------------------------------- |
| `NC4asT4 v3 Capacity Unit`              | `NC4asT4 v3`                     | `Managed Model Hosting Service`     | `1 Hour`      | Managed endpoint, T4 GPU        |
| `NCadsA10v4 Capacity Unit`              | `NCadsA10v4`                     | `Managed Model Hosting Service`     | `1 Hour`      | Managed endpoint, A10 GPU       |
| `NCadsA100v4 Capacity Unit`             | `NCadsA100v4`                    | `Managed Model Hosting Service`     | `1 Hour`      | Managed endpoint, A100 GPU      |
| `NCadsH100 v5 Capacity Unit`            | `NCadsH100 v5`                   | `Managed Model Hosting Service`     | `1 Hour`      | Managed endpoint, H100 GPU      |
| `NCadisH100v5 Capacity Unit`            | `NCadisH100v5`                   | `Managed Model Hosting Service`     | `1 Hour`      | Distinct H100 SKU               |
| `NDasrA100v4 Capacity Unit`             | `NDasrA100v4`                    | `Managed Model Hosting Service`     | `1 Hour`      | Managed endpoint, A100 GPU      |
| `NDamsrA100v4 Capacity Unit`            | `NDamsrA100v4`                   | `Managed Model Hosting Service`     | `1 Hour`      | Managed endpoint, A100 multi    |
| `NDisrH100v5 Capacity Unit`             | `NDisrH100v5`                    | `Managed Model Hosting Service`     | `1 Hour`      | Managed endpoint, H100 multi    |
| `NDisrMI300Xv5 Capacity Unit`           | `NDisrMI300Xv5`                  | `Managed Model Hosting Service`     | `1 Hour`      | Managed endpoint, MI300X        |
| `NDsrH200v5 Capacity Unit`              | `NDsrH200v5`                     | `Managed Model Hosting Service`     | `1 Hour`      | Regional H200 SKU               |
| `Standard GPU Surcharge`                | `Standard`                       | `Machine Learning service`          | `1 Hour`      | ML service GPU surcharge        |
| `PB vCPU Surcharge`                     | `PB`                             | `Machine Learning service`          | `1 Hour`      | ML service vCPU surcharge       |
| `Evaluation Input Tokens`               | `Evaluation Input Tokens`        | `Machine Learning service`          | `1K`          | Safety evaluation input tokens  |
| `Evaluation Ouput Tokens`               | `Evaluation Ouput Tokens`        | `Machine Learning service`          | `1K`          | Safety evaluation output tokens |
| `Llama-4-Scout-17B-16E-In Tokens`       | `Llama-4-Scout-17B-16E-In`       | `Managed Model Hosting Service`     | `1K`          | Serverless model input tokens   |
| `Llama-4-Scout-17B-16E-Out Tokens`      | `Llama-4-Scout-17B-16E-Out`      | `Managed Model Hosting Service`     | `1K`          | Serverless model output tokens  |
| `Llama-4-Mvrck-17B-128E-FP8-In Tokens`  | `Llama-4-Mvrck-17B-128E-FP8-In`  | `Managed Model Hosting Service`     | `1K`          | Serverless model input tokens   |
| `Llama-4-Mvrck-17B-128E-FP8-Out Tokens` | `Llama-4-Mvrck-17B-128E-FP8-Out` | `Managed Model Hosting Service`     | `1K`          | Serverless model output tokens  |
| `Free Tier`                             | `Free`                           | `Machine Learning Model Management` | `1/Day`       | Model Management free tier      |
| `S1 Tier`                               | `S1`                             | `Machine Learning Model Management` | `1/Day`       | Model Management daily fee      |
| `S2 Tier`                               | `S2`                             | `Machine Learning Model Management` | `1/Day`       | Model Management daily fee      |
| `S3 Tier`                               | `S3`                             | `Machine Learning Model Management` | `1/Day`       | Model Management daily fee      |

> **Note**: The spelling `Evaluation Ouput Tokens` matches the Retail Prices API meter name exactly and is intentional; do not change it to `Output` in queries or in this table.

> **Note**: Additional NV-series capacity units are available under `Managed Model Hosting Service`; the rows above cover the common active GPU families and newer H100/H200/MI300X variants.

## Cost Formula

```
Managed Endpoint Monthly = endpoint_retailPrice × 730 × instanceCount
Surcharge Monthly        = surcharge_retailPrice × 730 × numberOfSurchargeUnits   # e.g., GPUs or vCPUs
Token Monthly            = token_retailPrice × (tokens / 1000)
Model Management Monthly = tier_retailPrice × 30                                   # 1/Day UoM
Training Compute         = billed under Virtual Machines (see compute/virtual-machines.md)
```

## Notes

- Managed online endpoints (`Managed Model Hosting Service`) are the primary billable meters; serverless token-billed models (e.g., Llama-4) also bill under this product with `1K` token UoM
- Llama-4 token meters are currently returned in `eastus2` and `swedencentral`; use API `retailPrice` directly because sub-cent rates can display as zero
- Model Management (`Machine Learning Model Management`) provides `Free`, `S1`, `S2`, and `S3` daily-billed tiers and is not returned in `eastus`
- `Machine Learning Hardware Accelerated Models` remains a separate non-zero product; `Azure Machine Learning Enterprise *` training/inferencing meters are legacy and zero cost
- Training clusters and compute instances are billed under `Virtual Machines`; workspace storage is billed under Azure Storage (Blob/File) separately
