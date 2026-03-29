---
serviceName: Azure Translator
category: ai-ml
aliases: [Translator Text, Text Translation, Document Translation]
apiServiceName: Foundry Tools
primaryCost: "Per-character translation (per 1M chars); S1 pay-per-use + commitment tier discounts."
hasFreeGrant: true
privateEndpoint: true
---

# Azure Translator

> **Trap (serviceName rebrand)**: API `serviceName` is `Foundry Tools`, NOT `Azure Translator`. Queries using the display name return zero results.

> **Trap (multiple products)**: Three `productName` values: `Translator Text` (regional), `Azure Translator` (Global-only), `Azure Translator - Disconnected` (annual). Always filter by `ProductName`.

> **Trap (mixed units + Global naming)**: `unitOfMeasure` varies: `1M`, `1/Day` (S2–S4, C2–C4, D3), `1/Month`, `1/Year` (disconnected); script auto-multiplies daily by 30. `Azure Translator` (Global) uses different names: `S1 Standard`/`S1 Standard Characters` vs `S1`/`S1 Characters`.

## Query Pattern

### S1 standard text translation: 10M characters/month

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Translator Text
SkuName: S1
MeterName: S1 Characters
Quantity: 10 # millions of characters

### S1 document translation

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Translator Text
SkuName: S1
MeterName: S1 Document Characters

### S1 custom model translation

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Translator Text
SkuName: S1
MeterName: S1 Custom Translation Characters

### Commitment tier (Azure 250M chars/month)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Translator Text
SkuName: Commitment Tier Azure 250M
MeterName: Commitment Tier Azure 250M Unit

### S1 standard text translation (Global product)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Translator
SkuName: S1 Standard
MeterName: S1 Standard Characters
Region: Global

## Key Fields

| Parameter     | How to determine                  | Example values                                                           |
| ------------- | --------------------------------- | ------------------------------------------------------------------------ |
| `serviceName` | Always `Foundry Tools` (API name) | `Foundry Tools`                                                          |
| `productName` | Deployment model                  | `Translator Text`, `Azure Translator`, `Azure Translator - Disconnected` |
| `skuName`     | Tier and feature                  | `S1`, `S1 Standard` (Global), `C2`, `Commitment Tier Azure 250M`, `Free`        |
| `meterName`   | Billing dimension                 | `S1 Characters`, `S1 Standard Characters` (Global), `Custom Model Hosting Unit`  |

## Meter Names

| Meter                              | skuName                      | productName        | unitOfMeasure | Notes                            |
| ---------------------------------- | ---------------------------- | ------------------ | ------------- | -------------------------------- |
| `S1 Characters`                    | `S1`                         | `Translator Text`  | `1M`          | Standard text translation        |
| `S1 Document Characters`           | `S1`                         | `Translator Text`  | `1M`          | Document translation             |
| `S1 Custom Translation Characters` | `S1`                         | `Translator Text`  | `1M`          | Custom model inference           |
| `S1 Custom Training Characters`    | `S1`                         | `Translator Text`  | `1M`          | Custom model training            |
| `Custom Model Hosting Unit`        | `S1`                         | `Translator Text`  | `1/Month`     | Per model per region (all SKUs)  |
| `C2 Unit`                          | `C2`                         | `Translator Text`  | `1/Day`       | 250M chars included              |
| `S2–S4 Unit`                       | `S2`–`S4`                    | `Translator Text`  | `1/Day`       | Retiring daily tiers + overage   |
| `C3–C4 Unit`                       | `C3`–`C4`                    | `Translator Text`  | `1/Day`       | Container tiers, 1B/10B chars    |
| `D3 Unit`                          | `D3`                         | `Translator Text`  | `1/Day`       | Disconnected container           |
| `S1 Standard Characters`           | `S1 Standard`                | `Azure Translator` | `1M`          | Global-only equiv of S1 regional |
| `Commitment Tier Azure 250M Unit`  | `Commitment Tier Azure 250M` | `Translator Text`  | `1/Month`     | 250M chars included              |

## Cost Formula

```
Per-character (1M):  Monthly = retailPrice × Quantity
Daily tiers (1/Day): Script auto-multiplies by 30
Monthly (1/Month):   Monthly = retailPrice (use directly)
Annual (1/Year):     Monthly = retailPrice ÷ 12
Free grant:          Billable = max(0, chars − 2M free) then price per 1M
```

## Notes

- **Free tier**: 2M characters/month (standard + custom training combined) on Free SKU; custom model hosting still costs per model per region
- **Retiring tiers**: S2–S4 retiring Oct 2026; use S1 pay-per-use + Commitment Tiers for new deployments
- **Commitment tiers**: Azure (250M/1000M/4000M) and Connected (250M/1000M/4000M) variants; Connected tiers run in customer containers at slightly lower rates
- **Containers**: C2–C4 (connected, daily + overage) and D3 (disconnected, daily); `Azure Translator - Disconnected` bills annually (4000M/10000M, ÷12 for monthly)
- **Umbrella service**: Translator is part of Foundry Tools (AI Services). See `ai-services.md` for umbrella query patterns and other sub-services
- **Supports private endpoints** via the AI Services multi-service resource (see `networking/private-link.md` for PE pricing)
