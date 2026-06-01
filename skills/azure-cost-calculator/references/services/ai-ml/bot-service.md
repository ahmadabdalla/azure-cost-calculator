---
serviceName: Azure Bot Service
category: ai-ml
aliases: [Bot Framework, Chatbot]
billingNeeds: [Azure App Service, Functions]
pricingRegion: global
primaryCost: "S1 premium channel messages per 1K (DirectLine/Web Chat); standard channels free"
hasFreeGrant: true
---

# Azure Bot Service

> **Trap (shared API name)**: The `serviceName` "Azure Bot Service" is shared with Health Bot. Always filter by `ProductName: Azure Bot Service` to isolate channel meters. For Health Bot pricing, see `specialist/health-bot.md`.

> **Trap (global-only)**: Channel meters exist only in Global (commercial) and US Gov sovereign regions — any standard region like `eastus` returns zero results.

> **Trap (free channels)**: Standard channels (Teams, Slack, Facebook) are always free with no paid meter. Only premium channels (DirectLine, Web Chat) are billable at S1 tier.

## Query Pattern

### S1 premium channel messages (DirectLine/Web Chat)

ServiceName: Azure Bot Service <!-- cross-service -->
ProductName: Azure Bot Service
SkuName: S1
MeterName: S1 Premium Channel Messages
Quantity: 50 # thousands of messages per month

### Free tier (premium channels, 10K messages/month included)

ServiceName: Azure Bot Service <!-- cross-service -->
ProductName: Azure Bot Service
SkuName: Free
MeterName: Free Premium Channel Messages

## Key Fields

| Parameter     | How to determine                   | Example values                                          |
| ------------- | ---------------------------------- | ------------------------------------------------------- |
| `serviceName` | Always `Azure Bot Service`         | `Azure Bot Service`                                     |
| `productName` | Always `Azure Bot Service`         | `Azure Bot Service`                                     |
| `skuName`     | Tier selected by user              | `Free`, `S1`                                            |
| `meterName`   | Channel type + tier (never-assume) | `S1 Premium Channel Messages`, `Free Premium Channel Messages` |

## Meter Names

| Meter                            | skuName | unitOfMeasure | Notes                                    |
| -------------------------------- | ------- | ------------- | ---------------------------------------- |
| `S1 Premium Channel Messages`    | `S1`    | `1K`          | Paid: DirectLine, Web Chat               |
| `Free Premium Channel Messages`  | `Free`  | `1K`          | Zero price; 10K messages/month cap       |
| `Free Standard Channel Messages` | `Free`  | `1K`          | Zero price; unlimited (Teams, Slack)     |

## Cost Formula

```
S1 Monthly = premium_retailPrice × (messages / 1000)
Free = no charge (10K premium messages/month included; standard channels unlimited)
```

## Notes

- **Standard channels are free**: Teams, Slack, Facebook, etc. have no paid meter at any tier
- **Premium channels**: DirectLine and Web Chat; billable only on S1 tier
- **Underlying compute**: Bot apps run on Azure App Service or Functions; billed separately under those services
- **Free tier cap**: 10,000 premium channel messages/month (enforced service-side; API returns zero-price meters)
- **Health Bot**: For healthcare bot pricing (Agent Tier, Standard daily fee), see `specialist/health-bot.md`
- **RI check**: `PriceType: Reservation` returns no results; Reserved Instances not available
