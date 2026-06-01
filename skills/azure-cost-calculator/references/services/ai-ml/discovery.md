---
serviceName: Microsoft Discovery
category: ai-ml
aliases: [Discovery Platform, Scientific Discovery]
primaryCost: "retailPrice × userMessageCount (per-user-message consumption, regional rates)"
---

# Microsoft Discovery

> **Trap (unitOfMeasure)**: The single `User Messages` meter uses `unitOfMeasure: "1"` (flat rate per message), not hourly. The script treats this as unitless (monthly multiplier `1`, not `730`), so `MonthlyCost` reflects a single message only. Always set `Quantity` to the actual number of user messages.

> **Trap (regional variance)**: Per-message rates vary by region. Only 12 regions are priced; always pass the user's region and never assume a flat rate.

## Query Pattern

### User messages: per-message consumption

ServiceName: Microsoft Discovery
ProductName: Microsoft Discovery
SkuName: User Messages
MeterName: User Messages
Quantity: 10000 # number of user messages

## Key Fields

| Parameter     | How to determine             | Example values     |
| ------------- | ---------------------------- | ------------------ |
| `serviceName` | Always `Microsoft Discovery` | `Microsoft Discovery` |
| `productName` | Always `Microsoft Discovery` | `Microsoft Discovery` |
| `skuName`     | Always `User Messages`       | `User Messages`    |
| `meterName`   | Always `User Messages`       | `User Messages`    |

## Meter Names

| Meter           | unitOfMeasure | Notes                              |
| --------------- | ------------- | ---------------------------------- |
| `User Messages` | `1`           | Flat rate per user message (PAYG)  |

## Cost Formula

```
Monthly = retailPrice × userMessageCount
```

`Quantity` maps directly to the number of user messages (`unitOfMeasure` is `1`).

## Notes

- Single product, single SKU, single meter: pure pay-per-user-message consumption. No tiers, no free grant, no reserved instances
- Priced in 12 regions only: `southcentralus`, `northeurope`, `southeastasia`, `westus2`, `uksouth`, `eastus`, `swedencentral`, `eastus2`, `australiaeast`, `westeurope`, `westus3`, `japaneast`. Regional rate variance applies (per-message rate differs by region)
- `unitOfMeasure` is `1`; the script's `MonthlyCost` reflects one message — multiply `retailPrice` by the actual message count
