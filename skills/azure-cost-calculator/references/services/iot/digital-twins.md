---
serviceName: Digital Twins
category: iot
aliases: [ADT, IoT Modeling]
primaryCost: "Consumption: messages + operations + query units, all per 1K units"
hasKnownRates: true
privateEndpoint: true
---

# Digital Twins

> **Trap (sub-cent pricing)**: All three meters return sub-cent `retailPrice` values (per 1K units). The script displays zero `MonthlyCost` for every meter — this is a rounding artifact, not the actual price. Use the Known Rates table below and calculate manually: `(quantity / 1000) × retailPrice`.

> **Trap (non-hourly units)**: `unitOfMeasure` is `1K` (per 1,000), not `1/Hour`. The script's `MonthlyCost` (which multiplies by 730) is meaningless. Operations are metered in 1 KB increments of response body; messages in 1 KB increments of payload — a 3 KB response counts as 3 operations.

## Query Pattern

### Messages — event route output (Quantity in 1K units; 50 = 50K messages)

ServiceName: Digital Twins
MeterName: Standard Message
Quantity: 50

### Operations — API calls (per 1K operations)

ServiceName: Digital Twins
MeterName: Standard Operations

### Query Units — graph query execution (per 1K QUs)

ServiceName: Digital Twins
MeterName: Standard Query Units

## Key Fields

| Parameter     | How to determine       | Example values                                                    |
| ------------- | ---------------------- | ----------------------------------------------------------------- |
| `serviceName` | Always `Digital Twins` | `Digital Twins`                                                   |
| `productName` | Single product         | `Digital Twins`                                                   |
| `skuName`     | Always `Standard`      | `Standard`                                                        |
| `meterName`   | Billing dimension      | `Standard Message`, `Standard Operations`, `Standard Query Units` |

## Meter Names

| Meter                  | unitOfMeasure | Notes                                             |
| ---------------------- | ------------- | ------------------------------------------------- |
| `Standard Message`     | 1K            | Event route output to Event Grid/Hubs/Service Bus |
| `Standard Operations`  | 1K            | API calls, metered in 1 KB increments of response |
| `Standard Query Units` | 1K            | Graph query CPU/memory/IOPS cost                  |

## Cost Formula

```
Messages monthly    = (messages   / 1000) × message_retailPrice
Operations monthly  = (operations / 1000) × operations_retailPrice
Query Units monthly = (queryUnits / 1000) × queryUnit_retailPrice
Total               = Messages + Operations + Query Units
```

## Notes

- No free tier or free grant — all consumption billable from the first unit; zero usage = zero cost (no platform fee)
- Single tier (Standard) — no tier selection needed; `skuName` is always `Standard`
- Operations count in 1 KB increments of response body (0.5 KB = 1 op, 1.5 KB = 2 ops); messages count in 1 KB increments of payload
- Query units vary by query complexity — check the `query-charge` response header to estimate consumption
- Available in 14 regions only; regional price variance up to ~50% (check region availability before estimating)
- Companion services (IoT Hub, Event Grid, Event Hubs, Functions) are billed separately — Digital Twins meters cover only the twin graph platform

## Known Rates

| Meter                  | Unit | Published Rate (USD) |
| ---------------------- | ---- | -------------------- |
| `Standard Message`     | 1K   | $0.001               |
| `Standard Operations`  | 1K   | $0.0025              |
| `Standard Query Units` | 1K   | $0.0005              |
