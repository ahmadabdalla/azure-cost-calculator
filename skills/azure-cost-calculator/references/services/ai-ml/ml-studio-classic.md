---
serviceName: Machine Learning Studio
category: ai-ml
aliases: [ML Studio (classic), Classic ML]
primaryCost: "Plan tier daily rate × 30 + overage transactions per 1K"
hasFreeGrant: true
---

# Machine Learning Studio (classic)

> **Warning**: Machine Learning Studio (classic) is a **legacy service being retired**. Use Azure Machine Learning for new workloads. Pricing meters remain in the API for existing deployments.

> **Trap (daily billing)**: Plan meters (S1, S2, S3) use `1/Day` units. The script auto-multiplies by 30, so `MonthlyCost` is already the **monthly** cost. Do NOT pass `Quantity: 30` — that would overcount by 30x.

> **Trap (no eastus meters)**: This service has **no meters in `eastus`**. Use a region where meters exist (e.g., `southcentralus`, `westeurope`, `eastus2`) or query `Global` for S2/Classic pricing.

## Query Pattern

### S1 plan — daily rate (script auto-multiplies × 30)

ServiceName: Machine Learning Studio
ProductName: Machine Learning Studio Production Web API
SkuName: S1
MeterName: S1 Plan
Region: southcentralus

### S1 overage transactions — 500K transactions

ServiceName: Machine Learning Studio
ProductName: Machine Learning Studio Production Web API
SkuName: S1
MeterName: S1 Overage Transactions
Region: westeurope
Quantity: 500

### Classic hourly tier — 2 instances

ServiceName: Machine Learning Studio
ProductName: Machine Learning Studio Production Web API Classic
SkuName: Classic
Region: eastus2
InstanceCount: 2

## Key Fields

| Parameter     | How to determine                          | Example values                                                                    |
| ------------- | ----------------------------------------- | --------------------------------------------------------------------------------- |
| `serviceName` | Always `Machine Learning Studio`          | `Machine Learning Studio`                                                         |
| `productName` | Standard vs Classic deployment            | `Machine Learning Studio Production Web API`, `...Production Web API Classic`     |
| `skuName`     | Plan tier or Classic                      | `S1`, `S2`, `S3`, `Classic`                                                       |
| `meterName`   | Plan, overage, or included quantity meter | `S1 Plan`, `S1 Overage Transactions`, `Included Quantity API Compute`, `Classic`  |

## Meter Names

| Meter                              | skuName   | unitOfMeasure | Notes                              |
| ---------------------------------- | --------- | ------------- | ---------------------------------- |
| `S1 Plan`                          | `S1`      | `1/Day`       | Daily plan fee                     |
| `S1 Overage Transactions`          | `S1`      | `1K`          | Per 1K transactions above included |
| `Included Quantity API Compute`    | `S1`      | `1 Hour`      | Included compute hours — free      |
| `Included Quantity API Transactions`| `S1`     | `1K`          | Included transactions — free       |
| `S2 Plan`                          | `S2`      | `1/Day`       | Daily plan fee                     |
| `S2 Overage Transactions`          | `S2`      | `1K`          | Per 1K transactions above included |
| `S3 Plan`                          | `S3`      | `1/Day`       | Daily plan fee                     |
| `S3 Overage Transactions`          | `S3`      | `1K`          | Per 1K transactions above included |
| `Classic`                          | `Classic` | `1 Hour`      | Hourly compute — Classic tier      |

## Cost Formula

```
Plan Monthly     = plan_retailPrice × 30
Overage Monthly  = overage_retailPrice × (overageTransactions / 1000)
Classic Monthly  = classic_retailPrice × 730 × instanceCount
```

## Notes

- **Deprecated**: Machine Learning Studio (classic) is being retired — migrate to Azure Machine Learning (`ai-ml/machine-learning.md`)
- Each plan tier includes free compute hours and transactions (meters return zero price); overage is billed per 1K transactions above the included quantity
- S2 Plan and Classic pricing are available in the `Global` region — use `Region: Global` if no regional results are found
- Limited regional availability — key regions: `southcentralus`, `westcentralus`, `eastus2`, `westeurope`, `japaneast`
