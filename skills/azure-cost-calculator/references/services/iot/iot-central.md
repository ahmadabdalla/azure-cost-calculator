---
serviceName: IoT Central
category: iot
aliases: [IoT SaaS, IoT Application]
primaryCost: "Per-device hourly (×730) by tier (ST0/ST1/ST2) × deviceCount + per-1K message overage"
hasFreeGrant: true
---

# IoT Central

> **Trap (tier selection)**: All Standard tiers share `skuName: Standard` — tier is determined solely by `MeterName` (`Standard Tier 0`, `Standard Tier 1`, `Standard Tier 2`). Always filter by `MeterName` to select a specific tier.

> **Trap (overage meter mismatch)**: ST0 uses `Standard Overage Messages ST0` at a higher per-1K rate, while ST1 and ST2 share `Standard Overage Messages` at a lower rate. Match the overage meter to the device tier.

## Query Pattern

### Standard Tier 1 — per-device hourly rate

ServiceName: IoT Central
MeterName: Standard Tier 1

### Standard Tier 0 — lowest per-device cost

ServiceName: IoT Central
MeterName: Standard Tier 0

### Standard Tier 2 — highest message allocation

ServiceName: IoT Central
MeterName: Standard Tier 2

### Multi-device deployment — 100 ST1 devices

ServiceName: IoT Central
MeterName: Standard Tier 1
InstanceCount: 100

### Message overage — ST1/ST2 (Quantity in 1K-message units)

ServiceName: IoT Central
MeterName: Standard Overage Messages
Quantity: 50

### Message overage — ST0

ServiceName: IoT Central
MeterName: Standard Overage Messages ST0

## Key Fields

| Parameter     | How to determine                                 | Example values                                                    |
| ------------- | ------------------------------------------------ | ----------------------------------------------------------------- |
| `serviceName` | Always `IoT Central`                             | `IoT Central`                                                     |
| `productName` | Always `IoT Central` (single product)            | `IoT Central`                                                     |
| `skuName`     | `Standard` for all paid tiers, `Trial` for trial | `Standard`, `Trial`                                               |
| `meterName`   | Tier-specific device meter or overage meter      | `Standard Tier 0`, `Standard Tier 1`, `Standard Overage Messages` |

## Meter Names

| Meter                            | unitOfMeasure | Notes                                         |
| -------------------------------- | ------------- | --------------------------------------------- |
| `Standard Tier 0`               | 1/Hour        | Per-device; 400 msgs/device/month included    |
| `Standard Tier 1`               | 1/Hour        | Per-device; 5,000 msgs/device/month included  |
| `Standard Tier 2`               | 1/Hour        | Per-device; 30,000 msgs/device/month included |
| `Standard Overage Messages`     | 1K            | ST1/ST2 overage per 1K messages               |
| `Standard Overage Messages ST0` | 1K            | ST0 overage per 1K messages (higher rate)     |
| `Trial Application`             | 1/Day         | Free trial; genuinely zero-cost               |

## Cost Formula

```
Per-device monthly = retailPrice × 730
Billable devices   = max(0, totalDevices - 2)
Device cost        = perDeviceMonthly × billableDevices
Included messages  = messagesPerDevice × totalDevices
Overage messages   = max(0, totalMessages - includedMessages)
Overage cost       = (overageMessages / 1000) × overageRetailPrice
Total monthly      = deviceCost + overageCost
```

## Notes

- **Free grant**: 2 active devices per application are free (with included message allocation); subtract 2 before multiplying by per-device rate
- **Message allocations** (per device/month): ST0 = 400, ST1 = 5,000, ST2 = 30,000; total pool = per-device allocation × device count, pooled across the app
- **Tiers**: ST0 has lowest per-device cost but highest overage rate; ST2 has highest per-device cost but largest message allocation
- **Device billing**: Hourly prorated — each hour, the peak active device count is billed; devices must be removed when no longer needed
- **Message sizing**: Standard message = 4 KB; a 4.5 KB message counts as 2 messages
- **Trial**: 7-day expiry, max 5 devices, genuinely free (not sub-cent rounding)
- **Capacity planning**: 1 device = 1 billing unit; adding devices increases both cost and the shared message pool linearly
- IoT Central is a fully managed SaaS — no separate IoT Hub or storage billing; data export destinations (Event Hubs, Storage, etc.) are billed separately
