---
serviceName: Phone Numbers
category: communication
aliases: [ACS Phone Numbers, PSTN, Telephony]
primaryCost: "Per-number monthly lease — rates vary by country and number type"
---

# Azure Communication Services — Phone Numbers

> **Trap (154+ meters)**: Unfiltered queries return 121 regional meters plus 33 Global-only meters (Mobile, Number Lookup, 10DLC registration). Always filter by `ProductName` (geographic vs toll-free vs mobile) and `SkuName` (country code) to get specific rates.

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
SkuName: UK
MeterName: UK Leased Number

## Key Fields

| Parameter     | How to determine                    | Example values                               |
| ------------- | ----------------------------------- | -------------------------------------------- |
| `serviceName` | Always `Phone Numbers`              | `Phone Numbers`                              |
| `productName` | Number type                         | `Geographic Numbers - I`, `Toll Free Numbers - I`, `Mobile` |
| `skuName`     | Country code (2-letter)             | `US`, `UK`, `CA`, `DE`, `AU`, `FR`          |
| `meterName`   | Country + Leased Number             | `US Leased Number`, `UK Leased Number`       |

## Meter Names

| Meter               | productName               | unitOfMeasure | Notes                              |
| ------------------- | ------------------------- | ------------- | ---------------------------------- |
| `US Leased Number`  | `Geographic Numbers - I`  | `1/Month`     | US geographic number lease         |
| `US Leased Number`  | `Toll Free Numbers - I`   | `1/Month`     | US toll-free number lease          |
| `UK Leased Number`  | `Geographic Numbers - I`  | `1/Month`     | UK geographic number lease         |
| `CA Leased Number`  | `Geographic Numbers - I`  | `1/Month`     | Canada geographic number lease     |

> Additional country-specific meters follow the pattern `{CC} Leased Number` where CC is the country code used by the API (e.g., `UK` not `GB`).

## Cost Formula

```
Monthly = retailPrice × numberOfPhoneNumbers
```

## Notes

- **Part of ACS family**: Related services use separate API serviceNames — `Voice`, `SMS`, `Email`, `Messaging`, `Network Traversal`, `Routing`
- **Country-dependent pricing**: Rates vary significantly by country and number type — query the API with the target country's `SkuName` for exact pricing
- **154+ meters total**: 121 regional meters (Geographic/Toll Free) plus 33 Global-only meters (Mobile, Number Lookup, 10DLC) — always filter by country and product type
- Products with a `-I` suffix (e.g., `Geographic Numbers - I`) and without that suffix are alternative product-name variants with identical prices; use whichever variant exists for the target country, but note that `AU` and `JP` only appear in the non-I variants
- Toll-free numbers are generally more expensive than geographic numbers
- **Mobile numbers** (`ProductName: Mobile`): Available in 10 countries (AU, BE, DK, FI, IE, LV, NL, PL, SE, UK) — Global region only
- **Number Lookup** (`ProductName: Number Lookup`): Line Type query at sub-cent rates — Global region only
- **10DLC registration** (US only): Brand Registration, Brand Vetting (one-time), and Campaign Registration (monthly) fees — Global region only; required for US geographic numbers used for SMS
