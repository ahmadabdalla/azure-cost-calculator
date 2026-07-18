---
serviceName: Azure Health Bot
category: specialist
aliases: [Healthcare Bot, Health Virtual Assistant, Medical Bot]
apiServiceName: Azure Bot Service
primaryCost: "Agent Tier per-action (recommended); Standard daily fee ×30 + overage (legacy); Free available"
hasFreeGrant: true
---

# Azure Health Bot

> **Trap (shared API name)**: The API `serviceName` "Azure Bot Service" is shared with Bot Framework channel meters. Always filter by `ProductName: Microsoft Azure Health Bot` to isolate Health Bot meters.

> **Trap (daily billing)**: Standard tier uses `1/Day` unit; the script auto-multiplies by 30 for monthly cost. Do not manually multiply again.

> **Trap (deprecated tier)**: Standard (S1) was deprecated in November 2025; no new instances can be created. Existing S1 deployments continue to work. For new deployments, use Agent Tier (C1).

## Query Pattern

### Health Bot: Agent Tier (per-action, recommended)

ServiceName: Azure Bot Service
ProductName: Microsoft Azure Health Bot
SkuName: Agent Tier
Quantity: 5000 # actions per month

### Health Bot: Standard tier (daily base + overage, legacy)

ServiceName: Azure Bot Service
ProductName: Microsoft Azure Health Bot
SkuName: Standard

### Health Bot: Free tier

ServiceName: Azure Bot Service
ProductName: Microsoft Azure Health Bot
SkuName: Free

## Key Fields

| Parameter     | How to determine                    | Example values                   |
| ------------- | ----------------------------------- | -------------------------------- |
| `serviceName` | Always `Azure Bot Service`          | `Azure Bot Service`              |
| `productName` | Always `Microsoft Azure Health Bot` | `Microsoft Azure Health Bot`     |
| `skuName`     | Tier selected by user               | `Free`, `Standard`, `Agent Tier` |

## Meter Names

| Meter                       | skuName      | unitOfMeasure | Notes                        |
| --------------------------- | ------------ | ------------- | ---------------------------- |
| `Standard Unit`             | `Standard`   | `1/Day`       | Daily base fee               |
| `Standard Overage MCU`      | `Standard`   | `1`           | Message Compute Unit overage |
| `Standard Overage Messages` | `Standard`   | `1K`          | Per 1K messages overage      |
| `Agent Tier Action`         | `Agent Tier` | `1`           | Per-action billing           |
| `Free MCU`                  | `Free`       | `1`           | Free tier, zero price        |
| `Free Message`              | `Free`       | `1K`          | Free tier, zero price        |

## Cost Formula

```
Agent Tier Monthly = action_retailPrice × numberOfActions
Standard Monthly = standard_retailPrice × 30 + mcu_retailPrice × mcuOverageUnits + msg_retailPrice × (messages / 1000)
Free = no charge (all meters return zero price)
```

## Notes

- **Free tier**: Returns zero-price meters (Free MCU, Free Message); included to prevent unnecessary API queries
- **Standard tier includes monthly allowance**: 10,000 messages and 1,000 MCUs per month; overages billed per-unit above the monthly allowance
- **MCU (Medical Content Consumption Unit)**: charged per encounter with licensed third-party medical content (e.g. Infermedica symptom checker) or Generative AI features, not per scenario; most tenant-authored scenarios consume zero MCUs; Standard tier includes monthly allowance, overages billed per-unit
- **Agent Tier**: Per-action billing; action multipliers vary by feature type (1–18 actions per interaction depending on scenario complexity)
- **Bot Service channels**: Standard channels (Teams, Slack) are free; premium channels (DirectLine, Web Chat) are separate; see `ai-ml/bot-service.md`
