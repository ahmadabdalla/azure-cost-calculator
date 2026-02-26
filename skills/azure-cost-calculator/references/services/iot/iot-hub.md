---
serviceName: IoT Hub
category: iot
aliases: [Device Messaging]
primaryCost: "Per-unit monthly flat rate by tier (Free, B1–B3, S1–S3) × unit count"
hasFreeGrant: true
privateEndpoint: true
---

# IoT Hub

> **Trap (unfiltered query)**: Querying with `ServiceName IoT Hub` without `ProductName IoT Hub` returns meters from **Device Update for IoT Hub** and **IoT Hub Device Provisioning** — separate services with their own pricing. Always add `ProductName IoT Hub` to isolate hub unit costs.

> **Trap (unitOfMeasure)**: All hub unit meters use `1/Month` — the monthly multiplier is 1, so `MonthlyCost = retailPrice × InstanceCount` (× Quantity if used); no ×730 hours conversion is needed.

## Query Pattern

### Standard S1 tier — per unit/month (use InstanceCount: N for multi-unit)

ServiceName: IoT Hub
ProductName: IoT Hub
MeterName: S1 Unit

### Basic B1 tier

ServiceName: IoT Hub
ProductName: IoT Hub
MeterName: B1 Unit

### IoT Hub Device Provisioning Service — 100K operations (Quantity in 1K units)

ServiceName: IoT Hub
ProductName: IoT Hub Device Provisioning
MeterName: S1 Operations
Quantity: 100

## Key Fields

| Parameter     | How to determine            | Example values                                     |
| ------------- | --------------------------- | -------------------------------------------------- |
| `serviceName` | Always `IoT Hub`            | `IoT Hub`                                          |
| `productName` | Hub units vs DPS            | `IoT Hub`, `IoT Hub Device Provisioning`           |
| `skuName`     | Tier and edition            | `Free`, `B1`, `B2`, `B3`, `S1`, `S2`, `S3`         |
| `meterName`   | Tier unit or DPS operations | `S1 Unit`, `B1 Unit`, `Free Unit`, `S1 Operations` |

## Meter Names

| Meter           | SKU  | unitOfMeasure | Notes                       |
| --------------- | ---- | ------------- | --------------------------- |
| `Free Unit`     | Free | 1/Month       | 1 unit max, 8K msgs/day     |
| `B1 Unit`       | B1   | 1/Month       | 400K msgs/unit/day          |
| `B2 Unit`       | B2   | 1/Month       | 6M msgs/unit/day            |
| `B3 Unit`       | B3   | 1/Month       | 300M msgs/unit/day          |
| `S1 Unit`       | S1   | 1/Month       | 400K msgs/unit/day          |
| `S2 Unit`       | S2   | 1/Month       | 6M msgs/unit/day            |
| `S3 Unit`       | S3   | 1/Month       | 300M msgs/unit/day          |
| `S1 Operations` | S1   | 1K            | DPS registration operations |

## Cost Formula

```
Monthly = retailPrice × unitCount
DPS monthly = (operations / 1000) × retailPrice
Total = Hub units + DPS (if used)
```

## Notes

- Free tier: 1 unit max, 8K messages/day, no scale-up; good for dev/test only
- Basic tiers (B1–B3): device-to-cloud messaging only — no cloud-to-device, device twins, or direct methods
- Standard tiers (S1–S3): full feature set including cloud-to-device messaging, device twins, direct methods, and IoT Edge
- Units are purchased per hub; scale by adding units (max 200 per hub for paid tiers)
- Capacity: 1 S1 unit = 400K messages/day (4 KB each); 1 S2 = 6M msgs/day; 1 S3 = 300M msgs/day
- Device Update for IoT Hub is a separate service — query with ProductName `Device Update for IoT Hub`
