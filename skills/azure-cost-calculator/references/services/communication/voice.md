---
serviceName: Voice
category: communication
aliases: [ACS Voice, Voice Calling, VOIP]
primaryCost: "Per-minute Direct Routing + per-participant video/group calling"
hasKnownRates: true
---

# Azure Communication Services — Voice

> **Trap (consumption units)**: Local/Toll Free call meters use abstract consumption unit pricing (not per-minute). Only Direct Routing provides actual per-minute rates. Use `ProductName: Direct Routing` for transparent pricing.

> **Trap (sub-cent pricing)**: Direct Routing per-minute rates are sub-cent — the script may display minimal cost. Use `Quantity` with expected monthly call minutes.

## Query Pattern

### Direct Routing outbound (per-minute, Quantity = monthly minutes)

ServiceName: Voice
ProductName: Direct Routing
SkuName: Standard
MeterName: Standard Outbound
Quantity: 10000

### Video/group calling (per-participant-minute)

ServiceName: Voice
ProductName: Voice and Video Calling
SkuName: A2AGroupCalling
MeterName: A2AGroupCalling User Minute
Quantity: 50000

### Local calls outbound — consumption units

ServiceName: Voice
ProductName: Local Calls - Outbound
SkuName: ROW

## Key Fields

| Parameter     | How to determine              | Example values                                          |
| ------------- | ----------------------------- | ------------------------------------------------------- |
| `serviceName` | Always `Voice`                | `Voice`                                                 |
| `productName` | Calling type                  | `Direct Routing`, `Voice and Video Calling`, `Local Calls - Outbound` |
| `skuName`     | Tier or country               | `Standard`, `A2AGroupCalling`, `ROW`, `US`, `Trial`    |
| `meterName`   | Direction + billing dimension | `Standard Outbound`, `A2AGroupCalling User Minute`     |

## Meter Names

| Meter                                    | productName              | unitOfMeasure | Notes                         |
| ---------------------------------------- | ------------------------ | ------------- | ----------------------------- |
| `Standard Outbound`                      | `Direct Routing`         | `1 Minute`    | Per-minute outbound           |
| `Standard Inbound`                       | `Direct Routing`         | `1 Minute`    | Per-minute inbound            |
| `Standard Refer Unit`                    | `Direct Routing`         | `1`           | Call transfer/refer           |
| `Standard Transfer Unit`                 | `Direct Routing`         | `1`           | Call transfer (free)          |
| `A2AGroupCalling User Minute`            | `Voice and Video Calling`| `1`           | Video/group per-participant   |
| `A2AGroupCalling User InterOp Azure Minute` | `Voice and Video Calling` | `1`       | Azure interop per-participant |
| `A2AGroupCalling User InterOp M365 Minute` | `Voice and Video Calling` | `1`        | Teams interop per-participant |
| `A2AGroupCalling User CCaaS Minute`      | `Voice and Video Calling`| `1`           | Contact Center per-participant|
| `ROW Consumption Unit - Outbound`        | `Local Calls - Outbound` | `1`           | Abstract consumption unit     |

## Cost Formula

```
Direct Routing Monthly = retailPrice × minutes
Group Calling Monthly  = retailPrice × participantMinutes
Total Monthly          = Direct Routing + Group Calling (sum active components)
```

## Notes

- **Part of ACS family**: Related services use separate API serviceNames — `SMS`, `Email`, `Messaging`, `Phone Numbers`, `Network Traversal`, `Routing`
- **VoIP leg only**: Direct Routing rates cover the VoIP/SBC leg; PSTN legs have separate, higher country-dependent rates
- **Country-dependent pricing**: Local/Toll Free call rates vary by destination country via `skuName` (e.g., `US`, `ROW`)
- **Additional billable features**: Call Recording, Audio Streaming, and Closed Captions exist under Voice serviceName — all Global region only (`Region: Global` required)

## Known Rates

| Meter                         | Unit       | Published Rate (USD) |
| ----------------------------- | ---------- | -------------------- |
| `Standard Outbound`           | Per minute | $0.004               |
| `Standard Inbound`            | Per minute | $0.004               |
| `A2AGroupCalling User Minute` | Per unit   | $0.004               |
| `A2AGroupCalling User CCaaS Minute` | Per unit | $0.004              |
