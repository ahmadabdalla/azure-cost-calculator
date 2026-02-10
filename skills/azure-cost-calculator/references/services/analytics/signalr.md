---
serviceName: SignalR
category: analytics
aliases: [Azure SignalR Service, Real-time Messaging]
---

# Azure SignalR Service

**Primary cost**: Per-unit daily rate (by tier) + messages per 1M/month

> **Trap (daily billing)**: Unit meters use `1/Day` billing, not hourly. The script multiplies `retailPrice × 730` which is wrong for daily meters. Manually calculate: `retailPrice × 30 × unitCount`.

> **Trap (free tier rows)**: The `Standard Unit - Free` meter returns `$0.00`. This is a free-tier grant (1 unit with 20K connections/day and 20K messages). The script sums this with paid rows — ignore free-tier rows for paid estimates.

## Query Pattern

### Standard tier — 1 unit (default)

ServiceName: SignalR
SkuName: Standard
MeterName: Standard Unit

### Standard tier — messages (per 1M, use Quantity for monthly volume)

ServiceName: SignalR
SkuName: Standard
MeterName: Standard Message
Quantity: 10

### Premium tier — 1 unit

ServiceName: SignalR
SkuName: Premium
MeterName: Premium Unit

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
