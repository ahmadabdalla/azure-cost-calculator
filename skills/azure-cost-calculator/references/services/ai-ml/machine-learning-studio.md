---
serviceName: Machine Learning Studio
category: ai-ml
aliases: [ML Studio (classic), Classic ML]
primaryCost: "Daily plan × 30 + hourly/per-1K overage; Classic hourly × 730 + per-1K txns; workspace + experiment"
hasFreeGrant: true
---

# Machine Learning Studio (classic)

> **Warning**: Machine Learning Studio (classic) is a **legacy service being retired**. Use Azure Machine Learning for new workloads. Pricing meters remain in the API for existing deployments.

> **Trap (daily billing)**: Plan meters (S1, S2, S3) use `1/Day` units. The script auto-multiplies by 30, so `MonthlyCost` is already the **monthly** cost. Do NOT pass `Quantity: 30`; that would overcount by 30x.

> **Trap (regional gaps)**: This service has **no meters in `eastus`**. `eastus2` has Production Web API meters, but Standard workspace meters are missing there. Use `Region: Global` for the most complete commercial query coverage.

## Query Pattern

### S1 plan: 3 web API endpoints (script auto-multiplies daily rate × 30)

ServiceName: Machine Learning Studio
ProductName: Machine Learning Studio Production Web API
SkuName: S1
MeterName: S1 Plan
Region: Global
InstanceCount: 3

### S1 overage transactions: 500K transactions

ServiceName: Machine Learning Studio
ProductName: Machine Learning Studio Production Web API
SkuName: S1
MeterName: S1 Overage Transactions
Region: Global
Quantity: 500

### Classic hourly tier: 2 instances

ServiceName: Machine Learning Studio
ProductName: Machine Learning Studio Production Web API Classic
SkuName: Classic
MeterName: Classic
Region: Global
InstanceCount: 2

### Standard workspace: fee and experiment compute

ServiceName: Machine Learning Studio
ProductName: Machine Learning Studio
SkuName: Standard
MeterName: Standard Workspace fee
Region: Global

ServiceName: Machine Learning Studio
ProductName: Machine Learning Studio
SkuName: Standard
MeterName: Standard Experiment Compute
Region: Global

## Key Fields

| Parameter     | How to determine                          | Example values                                                                    |
| ------------- | ----------------------------------------- | --------------------------------------------------------------------------------- |
| `serviceName` | Always `Machine Learning Studio`          | `Machine Learning Studio`                                                         |
| `productName` | Workspace, Standard API, or Classic       | `Machine Learning Studio`, `...Production Web API`, `...Production Web API Classic` |
| `skuName`     | Plan tier or Classic                      | `S1`, `S2`, `S3`, `Classic`                                                       |
| `meterName`   | Plan, overage, or included quantity meter | `S1 Plan`, `S1 Overage Transactions`, `Standard Workspace fee`, `Classic`         |

## Meter Names

| Meter                              | skuName    | unitOfMeasure | Notes                              |
| ---------------------------------- | ---------- | ------------- | ---------------------------------- |
| `S1 Plan`                          | `S1`       | `1/Day`       | Daily plan fee                     |
| `S1 Overage Transactions`          | `S1`       | `1K`          | Per 1K transactions above included |
| `S1 Overage Compute`               | `S1`       | `1 Hour`      | Per hour above included compute    |
| `Included Quantity API Compute`    | `S1`       | `1 Hour`      | Included compute hours, free       |
| `Included Quantity API Transactions` | `S1`     | `1K`          | Included transactions, free        |
| `Classic`                          | `Classic`  | `1 Hour`      | Hourly compute, Classic tier       |
| `Classic Transactions`             | `Classic`  | `1K`          | Per 1K transactions, Classic tier  |
| `Standard Experiment Compute`      | `Standard` | `1 Hour`      | Workspace experiment compute       |
| `Standard Workspace fee`           | `Standard` | `1/Month`     | Monthly workspace subscription     |

> S2 and S3 tiers have equivalent Plan, Overage Transactions, Overage Compute, and Included Quantity meters; shown above for S1 only.

## Cost Formula

```
Plan Monthly      = plan_retailPrice × 30 × planCount
Overage Monthly   = (overage_compute_retailPrice × overageHours) + (overage_txn_retailPrice × (overageTransactions / 1000))
Classic Monthly   = (classic_retailPrice × 730 × instanceCount) + (classic_txn_retailPrice × (transactions / 1000))
Workspace Monthly = (workspace_fee_retailPrice × 1) + (experiment_retailPrice × 730 × experimentHours)
```

## Notes

- **Deprecated**: Machine Learning Studio (classic) is being retired. Migrate to Azure Machine Learning (`machine-learning.md`)
- Each plan tier includes free compute hours and transactions (meters return zero price); overage is billed per hour and per 1K transactions above the included quantities
- Use `Global` as the default commercial query region; `southcentralus`, `westcentralus`, `westeurope`, `japaneast`, `southeastasia`, and `eastus2` also have Web API meters
- Standard workspace product has `Standard Experiment Compute` (hourly) and `Standard Workspace fee` (monthly) meters separate from the Production Web API plans, and those workspace meters are not available in `eastus2`
