---
serviceName: Microsoft Discovery
category: ai-ml
aliases: [Discovery Platform, Scientific Discovery]
primaryCost: "retailPrice × userMessageCount (per-user-message consumption, regional rates)"
---

# Microsoft Discovery

> **Trap (unitOfMeasure)**: The single `User Messages` meter uses `unitOfMeasure: "1"` (flat rate per message), not hourly. The script treats this as unitless (monthly multiplier `1`, not `730`), so `MonthlyCost` reflects a single message only. Always set `Quantity` to the actual number of user messages.

> **Trap (regional variance)**: Per-message rates vary by region. Only 15 regions are priced; always pass the user's region and never assume a flat rate.

## Query Pattern

### User messages: per-message consumption

ServiceName: Microsoft Discovery
ProductName: Microsoft Discovery
SkuName: User Messages
MeterName: User Messages
Region: <user region>
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

- Single product/SKU/meter in the Retail Prices API (`User Messages`): per-message consumption only, no tiers, no free grant, no reserved instances. This meter covers Discovery runtime (data-plane) usage only
- **Billing boundary**: Discovery uses a two-component model. The `User Messages` meter is the only one in the pricing API, but the underlying Azure compute and storage resources deployed by workspaces/projects are billed separately under their own services. A total estimate must add those resource costs
- Priced in 15 regions only: `australiaeast`, `centralus`, `eastus`, `eastus2`, `francecentral`, `japaneast`, `koreacentral`, `northeurope`, `southcentralus`, `southeastasia`, `swedencentral`, `uksouth`, `westeurope`, `westus2`, `westus3`. Regional rate variance applies (per-message rate differs by region)
- `unitOfMeasure` is `1`; the script's `MonthlyCost` reflects one message — multiply `retailPrice` by the actual message count
