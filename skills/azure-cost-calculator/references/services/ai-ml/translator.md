---
serviceName: Azure Translator
category: ai-ml
aliases: [Translator Text, Text Translation, Document Translation]
apiServiceName: Foundry Tools
primaryCost: "Per-character translation (per 1M chars) — S1 pay-per-use + commitment tier discounts."
hasFreeGrant: true
privateEndpoint: true
---

# Azure Translator

> **Trap (serviceName rebrand)**: API `serviceName` is `Foundry Tools`, NOT `Azure Translator`. Queries using the display name return zero results.

> **Trap (multiple products)**: Three `productName` values — `Translator Text` (regional), `Azure Translator` (Global-only), `Azure Translator - Disconnected` (annual). Always filter by `ProductName`.

> **Trap (mixed units)**: `unitOfMeasure` varies: `1M` (characters), `1/Day` (S2–S4, C2–C4, D3), `1/Month` (commitment/hosting), `1/Year` (disconnected). Script auto-multiplies daily by 30; annual meters show raw price as MonthlyCost.

> **Trap (Global meter naming)**: `Azure Translator` (Global-only product) uses different meter/SKU names than `Translator Text` (regional): e.g., `S1 Standard Characters` vs `S1 Characters`, `S1 Document` SKU vs `S1`. Always verify meter names per product.

## Query Pattern

### S1 standard text translation — 10M characters/month

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
Quantity: 10 # millions of document characters

### S1 custom model translation

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Translator Text
SkuName: S1
MeterName: S1 Custom Translation Characters
Quantity: 10 # millions of characters

### Commitment tier (Azure 250M chars/month)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Translator Text
SkuName: Commitment Tier Azure 250M
MeterName: Commitment Tier Azure 250M Unit

## Key Fields

| Parameter     | How to determine                  | Example values                                                           |
| ------------- | --------------------------------- | ------------------------------------------------------------------------ |
| `serviceName` | Always `Foundry Tools` (API name) | `Foundry Tools`                                                          |
| `productName` | Deployment model                  | `Translator Text`, `Azure Translator`, `Azure Translator - Disconnected` |
| `skuName`     | Tier and feature                  | `S1`, `C2`, `Commitment Tier Azure 250M`, `Free`                        |
| `meterName`   | Billing dimension                 | `S1 Characters`, `S1 Document Characters`, `Custom Model Hosting Unit`   |

## Meter Names

| Meter                              | productName       | unitOfMeasure | Notes                             |
| ---------------------------------- | ----------------- | ------------- | --------------------------------- |
| `S1 Characters`                    | `Translator Text` | `1M`          | Standard text translation         |
| `S1 Document Characters`           | `Translator Text` | `1M`          | Document translation              |
| `S1 Custom Translation Characters` | `Translator Text` | `1M`          | Custom-trained model inference    |
| `S1 Custom Training Characters`    | `Translator Text` | `1M`          | Custom model training data        |
| `Custom Model Hosting Unit`        | `Translator Text` | `1/Month`     | Per model per region (all SKUs)   |
| `C2 Unit`                          | `Translator Text` | `1/Day`       | Volume tier — 250M chars included |
| `Commitment Tier Azure 250M Unit`  | `Translator Text` | `1/Month`     | Commitment — 250M chars included  |

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
- **Retiring tiers**: S2–S4 retiring Oct 2026 — use S1 pay-per-use + Commitment Tiers for new deployments
- **Commitment tiers**: Azure (250M/1000M/4000M) and Connected (250M/1000M/4000M) variants; Connected tiers run in customer containers at slightly lower rates
- **Container tiers**: C2–C4 (connected) and D3 (disconnected) use daily billing with included character allowances + overage rates
- **Disconnected containers**: `Azure Translator - Disconnected` bills annually (4000M and 10000M tiers) — divide by 12 for monthly equivalent
- **Umbrella service**: Translator is part of Foundry Tools (AI Services) — see `ai-services.md` for umbrella query patterns and other sub-services
- **Supports private endpoints** via the AI Services multi-service resource — see `networking/private-link.md` for PE pricing
