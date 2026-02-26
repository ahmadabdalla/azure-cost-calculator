---
serviceName: SignalR
category: analytics
aliases: [Azure SignalR Service, Real-time Messaging]
primaryCost: "Per-unit daily rate (by tier) + messages per 1M/month"
hasFreeGrant: true
privateEndpoint: true
---

# SignalR

> **Trap (daily billing)**: Unit meters use `1/Day` billing. The script auto-multiplies by 30 for daily meters, so `MonthlyCost` is already the **monthly** cost. Do NOT pass `Quantity: 30` — that would overcount by 30×.

> **Trap (free tier rows)**: The `Standard Unit - Free` meter returns a zero price. This is a free-tier grant (1 unit with 20 concurrent connections and 20K messages/day). Its price does not inflate `totalMonthlyCost`, but including it adds noise — filter by `MeterName` to exclude free-tier rows when estimating paid usage.

## Query Pattern

### Standard tier — 1 unit monthly (script auto-multiplies daily rate × 30)

ServiceName: SignalR
SkuName: Standard
MeterName: Standard Unit
InstanceCount: 1

### Standard tier — messages (per 1M, use Quantity for monthly volume)

ServiceName: SignalR
SkuName: Standard
MeterName: Standard Message
Quantity: 10

### Premium tier — 1 unit monthly (script auto-multiplies daily rate × 30)

ServiceName: SignalR
SkuName: Premium
MeterName: Premium Unit
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
| `Standard Unit - Free` | `Standard` | `1/Day`       | Free tier — zero cost          |

## Cost Formula

```
Unit monthly       = unit_retailPrice × 30 × unitCount
Message monthly    = (messages / 1M) × message_retailPrice
Total monthly      = Unit monthly + Message monthly
```

## Notes

- **Free tier**: 1 free Standard unit — 20 concurrent connections and 20K messages/day; no SLA
- **Standard tier**: Each unit provides 1K concurrent connections and 1M messages/day; auto-scale up to 100 units
- **Premium tier**: Same connection/message capacity as Standard plus availability zones and higher SLA
- Private endpoints require Standard tier or higher
- Messages included per unit per day scale with unit count; overage charged per 1M messages above the daily included amount
