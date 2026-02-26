---
serviceName: SMS
category: communication
aliases: [ACS SMS, Text Messaging]
primaryCost: "Per-consumption-unit SMS + per-month short code leasing"
---

# Azure Communication Services — SMS

> **Trap (consumption units)**: SMS meters use abstract consumption unit pricing, not per-message rates. Actual per-message cost depends on destination country and is set by the carrier. Use `Quantity` with expected monthly consumption units.

> **Trap (multi-product)**: SMS spans 36 productNames across regional and Global regions — covering Toll Free SMS, Short Codes, Local SMS (10DLC), Mobile SMS, Alphanumeric Sender ID, and surcharges. Many products are Global-only. Query each product type separately.

## Query Pattern

### Toll Free SMS outbound — consumption units (Quantity = monthly units)

ServiceName: SMS
ProductName: Toll Free SMS - Outbound
SkuName: ROW
MeterName: ROW Consumption Unit - Outbound
Quantity: 5000

### Short code leasing — monthly lease

ServiceName: SMS
ProductName: Short Codes - Leasing - Standard Number - I
SkuName: Standard
MeterName: US Lease

### Toll Free SMS inbound

ServiceName: SMS
ProductName: Toll Free SMS - Inbound
SkuName: ROW
MeterName: ROW Consumption Unit - Inbound

## Key Fields

| Parameter     | How to determine             | Example values                                        |
| ------------- | ---------------------------- | ----------------------------------------------------- |
| `serviceName` | Always `SMS`                 | `SMS`                                                 |
| `productName` | Message type and direction   | `Toll Free SMS - Outbound`, `Short Codes - Leasing - Standard Number - I` |
| `skuName`     | Country or tier              | `ROW`, `US`, `Standard`, `CA`, `UK`                  |
| `meterName`   | Billing dimension            | `ROW Consumption Unit - Outbound`, `US Lease`        |

## Meter Names

| Meter                              | productName                              | unitOfMeasure | Notes                   |
| ---------------------------------- | ---------------------------------------- | ------------- | ----------------------- |
| `ROW Consumption Unit - Outbound`  | `Toll Free SMS - Outbound`               | `1`           | Outbound consumption    |
| `ROW Consumption Unit - Inbound`   | `Toll Free SMS - Inbound`                | `1`           | Inbound consumption     |
| `Standard Consumption Unit`        | `Short Codes - Outbound - I`             | `1`           | Short code messaging    |
| `US Lease`                         | `Short Codes - Leasing - Standard Number - I` | `1/Month` | Short code monthly fee  |
| `US Provisioning Fee`              | `Short Codes - Provisioning - I`         | `1`           | One-time setup fee      |

## Cost Formula

```
Toll Free Monthly  = sms_retailPrice × consumptionUnits
Short Code Monthly = lease_retailPrice × shortCodeCount + messaging_retailPrice × consumptionUnits
Total Monthly      = Toll Free + Short Code (sum active components)
```

## Notes

- **Part of ACS family**: Related services use separate API serviceNames — `Voice`, `Email`, `Messaging`, `Phone Numbers`, `Network Traversal`, `Routing`
- **Country-dependent pricing**: SMS rates vary by destination country; `skuName` encodes country (e.g., `US`, `CA`, `UK`, `ROW`)
- Short code provisioning fees are one-time charges — separate from monthly lease
- Surcharge products (`Toll Free SMS-OB-Surcharge`, etc.) add carrier-level fees on top of base consumption units
- **Global-only products**: Alphanumeric Sender ID, Local SMS (10DLC), Mobile SMS, and non-`-I` Short Codes variants are only available in the Global region — use `Region: Global` to query
- **Vanity short codes**: `Short Codes - Leasing - Vanity Number - I` at higher monthly lease than standard
