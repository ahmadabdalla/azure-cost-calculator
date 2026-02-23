---
serviceName: Phone Numbers
category: communication
aliases: [ACS Phone Numbers, PSTN, Telephony]
primaryCost: "Per-number monthly lease — rates vary by country and number type"
---

# Azure Communication Services — Phone Numbers

> **Trap (121 meters)**: Unfiltered queries return 121+ meters across all countries. Always filter by `ProductName` (geographic vs toll free) and `SkuName` (country code) to get specific rates.

## Query Pattern

### Geographic number — US monthly lease (InstanceCount = number of phone numbers)

ServiceName: Phone Numbers
ProductName: Geographic Numbers - I
SkuName: US
MeterName: US Leased Number
InstanceCount: 10

### Toll free number — US monthly lease

ServiceName: Phone Numbers
ProductName: Toll Free Numbers - I
SkuName: US
MeterName: US Leased Number

### Geographic number — UK monthly lease

ServiceName: Phone Numbers
ProductName: Geographic Numbers - I
SkuName: GB
MeterName: GB Leased Number

## Key Fields

| Parameter     | How to determine                    | Example values                               |
| ------------- | ----------------------------------- | -------------------------------------------- |
| `serviceName` | Always `Phone Numbers`              | `Phone Numbers`                              |
| `productName` | Number type                         | `Geographic Numbers - I`, `Toll Free Numbers - I` |
| `skuName`     | Country code (ISO 2-letter)         | `US`, `GB`, `CA`, `DE`, `AU`, `FR`          |
| `meterName`   | Country + Leased Number             | `US Leased Number`, `GB Leased Number`       |

## Meter Names

| Meter               | productName               | unitOfMeasure | Notes                              |
| ------------------- | ------------------------- | ------------- | ---------------------------------- |
| `US Leased Number`  | `Geographic Numbers - I`  | `1/Month`     | US geographic number lease         |
| `US Leased Number`  | `Toll Free Numbers - I`   | `1/Month`     | US toll-free number lease          |
| `GB Leased Number`  | `Geographic Numbers - I`  | `1/Month`     | UK geographic number lease         |
| `CA Leased Number`  | `Geographic Numbers - I`  | `1/Month`     | Canada geographic number lease     |

> Additional country-specific meters follow the pattern `{CC} Leased Number` where CC is the ISO country code.

## Cost Formula

```
Monthly = retailPrice × 30 × numberOfPhoneNumbers
```

## Notes

- **Part of ACS family**: Related services use separate API serviceNames — `Voice`, `SMS`, `Email`, `Messaging`, `Network Traversal`
- **Country-dependent pricing**: Rates vary significantly by country (e.g., US geographic ~$1/month, ES ~$5/month, toll-free ~$2–25/month)
- **121 meters in eastus**: Each country × number type combination has its own meter — always filter by country
- Products with `-I` suffix (e.g., `Geographic Numbers - I`) and without overlap; use either variant for the target country
- Toll-free numbers are generally more expensive than geographic numbers
