---
serviceName: Azure Machine Learning
category: ai-ml
aliases: [Azure ML, AML, ML Workspace]
billingNeeds: [Storage, Key Vault, Application Insights]
primaryCost: "Managed endpoint capacity (hourly × 730) + ML surcharges + token fees. Training clusters billed under VMs."
privateEndpoint: true
---

# Azure Machine Learning

> **Trap (inflated totals)**: An unfiltered `ServiceName 'Azure Machine Learning'` query returns dozens of meters across multiple product families: legacy Enterprise Inferencing (all zero price), ML service surcharges, Managed Model Hosting endpoints, serverless token-billed models, and Model Management tiers. The `totalMonthlyCost` sums all of them, which is meaningless. Always filter by `ProductName`.

> **Trap (compute billing split)**: Managed endpoints are billed here under `Azure Machine Learning` (Managed Model Hosting Service). Training clusters and compute instances run on **Virtual Machines** and are billed separately under the `Virtual Machines` service. The meters in this service cover managed endpoint capacity and ML service surcharges only.

## Query Pattern

### Managed online endpoint: e.g., NC4asT4 v3 GPU instance (2 endpoints)

ServiceName: Azure Machine Learning
ProductName: Managed Model Hosting Service
SkuName: NC4asT4 v3
InstanceCount: 2

### ML service surcharge: Standard GPU

ServiceName: Azure Machine Learning
ProductName: Machine Learning service
MeterName: Standard GPU Surcharge

### Serverless token-billed model: Llama-4-Scout input, 100K tokens

ServiceName: Azure Machine Learning
ProductName: Managed Model Hosting Service
MeterName: Llama-4-Scout-17B-16E-In Tokens
Quantity: 100

### Model Management: S1 Tier

ServiceName: Azure Machine Learning
ProductName: Machine Learning Model Management
SkuName: S1
MeterName: S1 Tier

### Safety evaluation tokens (input): 100K tokens

ServiceName: Azure Machine Learning
ProductName: Machine Learning service
MeterName: Evaluation Input Tokens
Quantity: 100

## Key Fields

| Parameter     | How to determine                                    | Example values                                              |
| ------------- | --------------------------------------------------- | ----------------------------------------------------------- |
| `serviceName` | Always `Azure Machine Learning`                     | `Azure Machine Learning`                                    |
| `productName` | Component type                                      | `Managed Model Hosting Service`, `Machine Learning service`, `Machine Learning Model Management` |
| `skuName`     | VM size for endpoints; tier for surcharges/mgmt     | `NC4asT4 v3`, `NCadsA100v4`, `Standard`, `PB`, `S1`         |
| `meterName`   | Matches skuName + "Capacity Unit" or surcharge type | `NC4asT4 v3 Capacity Unit`, `Standard GPU Surcharge`, `Llama-4-Scout-17B-16E-In Tokens` |

## Meter Names

| Meter                        | skuName                   | unitOfMeasure | Notes                           |
| ---------------------------- | ------------------------- | ------------- | ------------------------------- |
| `NC4asT4 v3 Capacity Unit`   | `NC4asT4 v3`              | `1 Hour`      | Managed endpoint, T4 GPU        |
| `NCadsA100v4 Capacity Unit`  | `NCadsA100v4`             | `1 Hour`      | Managed endpoint, A100 GPU      |
| `NCadsH100 v5 Capacity Unit` | `NCadsH100 v5`            | `1 Hour`      | Managed endpoint, H100 GPU      |
| `NDisrH100v5 Capacity Unit`  | `NDisrH100v5`             | `1 Hour`      | Managed endpoint, H100 multi    |
| `Standard GPU Surcharge`     | `Standard`                | `1 Hour`      | ML service GPU surcharge        |
| `PB vCPU Surcharge`          | `PB`                      | `1 Hour`      | ML service vCPU surcharge       |
| `Evaluation Input Tokens`    | `Evaluation Input Tokens` | `1K`          | Safety evaluation input tokens  |
| `Evaluation Ouput Tokens`    | `Evaluation Ouput Tokens` | `1K`          | Safety evaluation output tokens |
| `Llama-4-Scout-17B-16E-In Tokens`  | `Llama-4-Scout-17B-16E-In Tokens`  | `1K` | Serverless model input tokens   |
| `Llama-4-Scout-17B-16E-Out Tokens` | `Llama-4-Scout-17B-16E-Out Tokens` | `1K` | Serverless model output tokens  |
| `Llama-4-Mvrck-17B-128E-FP8-In Tokens`  | `Llama-4-Mvrck-17B-128E-FP8-In Tokens`  | `1K` | Serverless model input tokens   |
| `Llama-4-Mvrck-17B-128E-FP8-Out Tokens` | `Llama-4-Mvrck-17B-128E-FP8-Out Tokens` | `1K` | Serverless model output tokens  |
| `S1 Tier`                    | `S1`                      | `1/Day`       | Model Management daily fee      |
| `S2 Tier`                    | `S2`                      | `1/Day`       | Model Management daily fee      |
| `S3 Tier`                    | `S3`                      | `1/Day`       | Model Management daily fee      |

> Note: The spelling `Evaluation Ouput Tokens` matches the Retail Prices API meter name exactly and is intentional; do not change it to `Output` in queries or in this table.

> Additional Managed Model Hosting SKUs (NV-series, ND-series) and serverless token-billed models are available. Query with `ProductName 'Managed Model Hosting Service'` to list all.

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
- Model Management (`Machine Learning Model Management`) provides S1/S2/S3 daily-billed tiers
- `Machine Learning Hardware Accelerated Models / Standard vCPU` and Enterprise Inferencing (`Azure Machine Learning Enterprise *`) are legacy meters (zero cost); include only if explicitly requested
- Storage for ML workspaces is billed under Azure Storage (Blob/File) separately
