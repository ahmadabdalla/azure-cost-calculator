---
serviceName: Voice
category: communication
aliases: [Azure Communication Services, ACS, ACS Voice, Voice Calling, VOIP]
---

# Azure Communication Services

**Primary cost**: Per-minute voice + per-message SMS/chat + per-email — each component uses a separate serviceName

> **Trap (multi-serviceName)**: ACS spans multiple API serviceNames: `Voice`, `SMS`, `Email`, `Messaging`, `Phone Numbers`, `Network Traversal`. Each query must target the correct serviceName — there is no single umbrella serviceName.

> **Trap (sub-cent pricing)**: Email and Chat meters are priced at sub-cent levels — the script may display minimal cost. Use `Quantity` with expected monthly volume for accurate estimates.

## Query Pattern

### Voice — Direct Routing outbound (per-minute)

ServiceName: Voice
ProductName: Direct Routing
SkuName: Standard
MeterName: Standard Outbound
Quantity: 10000

### Email — sent email (per-message, use Quantity for monthly volume)

ServiceName: Email  <!-- cross-service -->
ProductName: Email
SkuName: Basic
MeterName: Basic Sent Email
Quantity: 50000

### Chat — sent message (per-message)

ServiceName: Messaging  <!-- cross-service -->
ProductName: Chat
SkuName: Basic
MeterName: Basic Sent Message
Quantity: 100000

### SMS — Toll Free outbound

ServiceName: SMS  <!-- cross-service -->
ProductName: Toll Free SMS - Outbound
SkuName: Standard

## Key Fields

| Parameter     | How to determine             | Example values                                     |
| ------------- | ---------------------------- | -------------------------------------------------- |
| `serviceName` | Component determines service | `Voice`, `Email`, `SMS`, `Messaging`               |
| `productName` | Feature within component     | `Direct Routing`, `Email`, `Chat`, `Toll Free SMS` |
| `skuName`     | Tier or country variant      | `Standard`, `Basic`, `A2AGroupCalling`, `US`       |
| `meterName`   | Billing dimension            | `Standard Outbound`, `Basic Sent Email`            |

## Meter Names

| Meter                              | serviceName | unitOfMeasure | Notes                       |
| ---------------------------------- | ----------- | ------------- | --------------------------- |
| `Standard Outbound`                | `Voice`     | `1 Minute`    | Direct Routing per-minute   |
| `Standard Inbound`                 | `Voice`     | `1 Minute`    | Direct Routing per-minute   |
| `A2AGroupCalling`                  | `Voice`     | `1`           | Video/group call per-minute |
| `Basic Sent Email`                 | `Email`     | `1`           | Per email sent              |
| `Basic Data Transferred`           | `Email`     | `1 MB`        | Email attachment data       |
| `Basic Sent Message`               | `Messaging` | `1`           | Chat per message            |
| `Basic Sent InterOp Azure Message` | `Messaging` | `1`           | Teams interop chat          |

## Cost Formula

```
Voice:   Monthly = voice_retailPrice × minutes
Email:   Monthly = email_retailPrice × emails + dataTransfer_retailPrice × dataMB
Chat:    Monthly = chat_retailPrice × messages
SMS:     Monthly = sms_retailPrice × consumptionUnits
Total:   Monthly = Voice + Email + Chat + SMS (sum active components)
```

## Notes

- **Multi-serviceName architecture**: Each ACS capability uses a separate API serviceName — always include `ServiceName:` per query
- **Country-dependent pricing**: Voice and SMS rates vary by destination country; query defaults to USD
- **Phone Numbers**: serviceName `Phone Numbers` — per-number monthly lease across 19+ country SKUs
- **Network Traversal**: serviceName `Network Traversal` — TURN relay, per-GB pricing
- **Consumption unit pattern**: SMS and Voice local/toll-free calls use abstract consumption unit pricing — Direct Routing provides actual per-minute rates

## Known Rates

| Meter                    | serviceName | Unit       | Published Rate (USD) |
| ------------------------ | ----------- | ---------- | -------------------- |
| `Basic Sent Email`       | `Email`     | Per email  | $0.00025             |
| `Basic Data Transferred` | `Email`     | Per MB     | $0.00012             |
| `Basic Sent Message`     | `Messaging` | Per msg    | $0.0008              |
| `Standard Outbound`      | `Voice`     | Per minute | $0.004               |
| `Standard Inbound`       | `Voice`     | Per minute | $0.004               |
