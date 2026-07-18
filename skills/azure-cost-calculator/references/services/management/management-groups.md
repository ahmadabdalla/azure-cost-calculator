---
serviceName: Management Groups
category: management
aliases: [Management Group, Azure Management Groups, Subscription Organization]
primaryCost: "Free, no charges for creating or using management groups."
hasMeters: false
pricingRegion: api-unavailable
---

# Management Groups

> **Warning**: Management Groups has **no meters** in the Azure Retail Prices API. All queries return zero results.
>
> **Agent instruction**: Do NOT query the pricing scripts for Management Groups; they return zero results. Report zero cost per month regardless of quantity.

## Query Pattern

### No pricing meters exist: included for validation only

ServiceName: Management Groups
Quantity: 1

### Expected: 0 results; this service has no retail meters

## Key Fields

| Parameter     | How to determine              | Example values       |
| ------------- | ----------------------------- | -------------------- |
| `serviceName` | Always `Management Groups`    | `Management Groups`  |
| `productName` | N/A, no meters in API         | N/A                  |
| `skuName`     | N/A, no meters in API         | N/A                  |
| `meterName`   | N/A, no meters in API         | N/A                  |

## Cost Formula

```
Monthly = 0 (free service, no meters)
```

## Notes

- Management Groups are **completely free** with no usage-based charges
- Used to organize subscriptions into a hierarchy for governance, policy, and access management
- Each Microsoft Entra tenant gets a single root management group
- Supports up to six levels of depth (excluding the root and subscription level)
- Azure Policy and RBAC assignments applied at a management group scope cascade to child subscriptions
