---
serviceName: Azure Bot Service
category: ai-ml
aliases: [Bot Framework, Chatbot]
billingNeeds: [Azure App Service, Functions]
primaryCost: "Health Bot Standard daily fee (×30) + MCU/message overage. Basic Bot Service channels are free."
hasFreeGrant: true
privateEndpoint: true
---

# Azure Bot Service (Health Bot)

> **Trap (channel split)**: Standard channels (Teams, Slack) are free. Premium channels (DirectLine, Web Chat) have Global-only S1 meters — most deployments use free tier. Queries below focus on **Health Bot** — the main paid product.

> **Trap (daily billing)**: Standard tier uses `1/Day` unit — the script auto-multiplies by 30 for monthly cost. Do not manually multiply again.

## Query Pattern

### Health Bot — Standard tier (daily base + overage)

ServiceName: Azure Bot Service
ProductName: Microsoft Azure Health Bot
SkuName: Standard

### Health Bot — Agent Tier (5K actions/month)

ServiceName: Azure Bot Service
ProductName: Microsoft Azure Health Bot
SkuName: Agent Tier
Quantity: 5000

### Health Bot — Free tier

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
| `Free MCU`                  | `Free`       | `1`           | Free tier — zero price       |
| `Free Message`              | `Free`       | `1K`          | Free tier — zero price       |

## Cost Formula

```
Standard Monthly = standard_retailPrice × 30 + mcu_retailPrice × mcuOverageUnits + msg_retailPrice × (messages / 1000)
Agent Tier Monthly = action_retailPrice × numberOfActions
Free = no charge (all meters return zero price)
```

## Notes

- **Bot Service channel pricing split**: Standard channels (Teams, Slack) are free. Premium channels (DirectLine, Web Chat) use paid Global-only S1 channel-message meters — Health Bot is the primary paid product in this reference
- **Underlying compute**: Bot apps typically run on Azure App Service or Functions — billed separately. If secured via API Management, APIM costs also apply
- **MCU (Message Compute Unit)**: 1 MCU = one Health Bot scenario execution; Standard tier includes daily allowance, overages billed per-unit
- **Free tier**: Returns zero-price meters — included to prevent unnecessary API queries
- **PE sub-resources** (never-assume): `Bot`, `Token` — both needed for full network isolation
