---
serviceName: SignalR
category: analytics
aliases: [Azure SignalR Service, Real-time Messaging]
---

# Azure SignalR Service

**Primary cost**: Per-unit daily rate (by tier) + messages per 1M/month

> **Trap (daily billing)**: Unit meters use `1/Day` billing, not hourly. For these meters, `Get-MonthlyMultiplier` returns `1`, so the script's `MonthlyCost` is actually the **daily** cost. To get a monthly estimate, run with `Quantity: 30` for unit meters, or manually multiply the reported cost by 30.

> **Trap (free tier rows)**: The `Standard Unit - Free` meter returns `$0.00`. This is a free-tier grant (1 unit with 20 concurrent connections and 20K messages/day). Its price does not inflate `totalMonthlyCost`, but including it adds noise — filter by `MeterName` to exclude free-tier rows when estimating paid usage.

## Query Pattern

### Standard tier — 1 unit monthly (billed per day, Quantity 30 = 1 month)

ServiceName: SignalR
SkuName: Standard
MeterName: Standard Unit
Quantity: 30
InstanceCount: 1

### Standard tier — messages (per 1M, use Quantity for monthly volume)

ServiceName: SignalR
SkuName: Standard
MeterName: Standard Message
Quantity: 10

### Premium tier — 1 unit monthly (billed per day, Quantity 30 = 1 month)

ServiceName: SignalR
SkuName: Premium
MeterName: Premium Unit
Quantity: 30
InstanceCount: 1

### Premium tier — messages (per 1M)

ServiceName: SignalR
SkuName: Premium
MeterName: Premium Message
Quantity: 10

## Key Fields

| Parameter     | How to determine           | Example values                                       |
| ------------- | -------------------------- | ---------------------------------------------------- |
| `serviceName` | Always `SignalR`           | `SignalR`                                            |
| `productName` | Single product             | `SignalR`                                            |
| `skuName`     | Tier selection             | `Standard`, `Premium`                                |
| `meterName`   | Unit (capacity) or Message | `Standard Unit`, `Standard Message`, `Premium Unit`  |

## Meter Names

| Meter                  | skuName    | unitOfMeasure | Notes                          |
| ---------------------- | ---------- | ------------- | ------------------------------ |
| `Standard Unit`        | `Standard` | `1/Day`       | Per-unit daily capacity charge |
| `Standard Message`     | `Standard` | `1M`          | Per 1M messages overage        |
| `Premium Unit`         | `Premium`  | `1/Day`       | Per-unit daily capacity charge |
| `Premium Message`      | `Premium`  | `1M`          | Per 1M messages overage        |
| `Standard Unit - Free` | `Standard` | `1/Day`       | Free tier — $0.00              |

## Cost Formula

```
Unit monthly       = unit_retailPrice × 30 × unitCount
Message monthly    = (messages / 1M) × message_retailPrice
Total monthly      = Unit monthly + Message monthly
```

## Notes

- **Free tier**: 1 free Standard unit — 20 concurrent connections and 20K messages/day; no SLA
- **Standard tier**: Each unit provides 1K concurrent connections and 1M messages/day; auto-scale up to 100 units
- **Premium tier**: Same connection/message capacity as Standard plus availability zones, private endpoints, and higher SLA
- Messages included per unit per day scale with unit count; overage charged per 1M messages above the daily included amount
- Reserved pricing is **not available** — `PriceType Reservation` returns 0 results
