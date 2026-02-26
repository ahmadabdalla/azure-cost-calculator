---
serviceName: Messaging
category: communication
aliases: [ACS Chat, Chat Messaging]
primaryCost: "Per-message chat pricing"
hasKnownRates: true
---

# Azure Communication Services — Messaging

> **Trap (sub-cent pricing)**: Chat meters are priced at sub-cent levels — the script may display zero cost. Use `Quantity` with expected monthly volume for accurate estimates.

> **Trap (multi-product)**: The `Messaging` serviceName spans three products — `Chat` (regional), `Advanced Messaging` (Global), and `Channel Fee` (Global). **This reference only documents the `Chat` product.** For Advanced Messaging or Channel Fee, filter with `ProductName: Advanced Messaging` or `ProductName: Channel Fee` and `Region: Global`.

## Query Pattern

### Chat — sent message (per-message, Quantity = monthly messages)

ServiceName: Messaging
ProductName: Chat
SkuName: Basic
MeterName: Basic Sent Message
Quantity: 100000

### Teams interop chat message

ServiceName: Messaging
ProductName: Chat
SkuName: Basic
MeterName: Basic Sent InterOp Azure Message
Quantity: 10000

## Key Fields

| Parameter     | How to determine        | Example values                                    |
| ------------- | ----------------------- | ------------------------------------------------- |
| `serviceName` | Always `Messaging`      | `Messaging`                                       |
| `productName` | Always `Chat`           | `Chat`                                            |
| `skuName`     | Always `Basic`          | `Basic`                                           |
| `meterName`   | Message type            | `Basic Sent Message`, `Basic Sent InterOp Azure Message` |

## Meter Names

| Meter                              | unitOfMeasure | Notes               |
| ---------------------------------- | ------------- | ------------------- |
| `Basic Sent Message`               | `1`           | Per chat message    |
| `Basic Sent InterOp Azure Message` | `1`           | Teams interop chat  |

## Cost Formula

```
Monthly = chat_retailPrice × messages + interop_retailPrice × interopMessages
```

## Notes

- **Part of ACS family**: Related services use separate API serviceNames — `Voice`, `SMS`, `Email`, `Phone Numbers`, `Network Traversal`, `Routing`
- Chat has 2 meters — standard chat and Teams interop chat; use `productName: Chat`, `skuName: Basic`
- **Advanced Messaging (Global-only)**: WhatsApp user messages and connect fees also exist under this serviceName — use `ProductName: Advanced Messaging` or `ProductName: Channel Fee` with `Region: Global`

## Known Rates

| Meter                              | Unit    | Published Rate (USD) |
| ---------------------------------- | ------- | -------------------- |
| `Basic Sent Message`               | Per msg | $0.0008              |
| `Basic Sent InterOp Azure Message` | Per msg | $0.0008              |
