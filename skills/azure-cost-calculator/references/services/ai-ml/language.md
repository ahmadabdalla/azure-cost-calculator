---
serviceName: Azure Language
category: ai-ml
aliases: [Language Understanding, LUIS, Text Analytics, NER, Sentiment Analysis, CLU]
apiServiceName: Foundry Tools
primaryCost: "Per-1K text records (tiered by feature) + training per hour + optional commitment tiers."
hasFreeGrant: true
privateEndpoint: true
---

# Azure Language

> **Trap (serviceName)**: API `serviceName` is `Foundry Tools`, not `Azure Language`. Always filter by `ProductName` to isolate Language meters from other AI Services.

> **Trap (tiered pricing)**: Standard Text Records returns multiple rows with different `tierMinimumUnits`. The script sums all tiers — use the tier matching your volume.

> **Trap (training MonthlyCost)**: Training meters use `1 Hour` — the script multiplies by 730. Calculate as `trainingHours × retailPrice` instead.

## Query Pattern

### Standard text analytics (NER, Sentiment, PII) — 100K records

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Language
SkuName: Standard
MeterName: Standard Text Records
Quantity: 100 # 100 × 1K = 100K records

### CLU inference

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Language
SkuName: Standard
MeterName: Standard CLU Text Records

### CLU / custom model training

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Language
SkuName: Standard
MeterName: Standard CLU Advanced Training Unit

### LUIS (legacy)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Language Understanding
SkuName: S1
MeterName: S1 Transactions

## Key Fields

| Parameter     | How to determine             | Example values                                                        |
| ------------- | ---------------------------- | --------------------------------------------------------------------- |
| `serviceName` | Always `Foundry Tools`       | `Foundry Tools`                                                       |
| `productName` | Feature / deployment variant | `Azure Language`, `Language Understanding`, `Text Analytics Container` |
| `skuName`     | Tier — varies by feature     | `Standard`, `Free`, `S1`, `Commitment Tier Azure 1M`                  |
| `meterName`   | Feature-specific meter       | `Standard Text Records`, `Standard CLU Text Records`                  |

## Meter Names

| Meter                                  | productName                | unitOfMeasure | Notes                              |
| -------------------------------------- | -------------------------- | ------------- | ---------------------------------- |
| `Standard Text Records`               | `Azure Language`           | `1K`          | NER, Sentiment, PII (tiered)       |
| `Standard CLU Text Records`           | `Azure Language`           | `1K`          | CLU inference                      |
| `Standard CLU Advanced Training Unit` | `Azure Language`           | `1 Hour`      | CLU training                       |
| `Standard Custom Text Records`        | `Azure Language`           | `1K`          | Custom NER / classification        |
| `Standard Custom Summarization Text Records` | `Azure Language`  | `1K`          | Custom summarization               |
| `Standard Custom Training Unit`       | `Azure Language`           | `1 Hour`      | Custom model training              |
| `Standard Summarization Text Records` | `Azure Language`           | `1K`          | Summarization                      |
| `Standard Health Text Records`        | `Azure Language`           | `1K`          | Health NER (tiered, first 5K free) |
| `Standard QA Text Records`            | `Azure Language`           | `1K`          | Question Answering (tiered)        |
| `Standard Custom Hosting Unit`        | `Azure Language`           | `1/Month`     | Per custom model hosting           |
| `S1 Transactions`                     | `Language Understanding`   | `1K`          | LUIS text endpoint                 |
| `S1 Speech To Intent - Understanding Transactions` | `Language Understanding` | `1K` | LUIS speech-to-intent              |
| `Standard Text Records`               | `Text Analytics Container` | `1K`          | On-prem container (tiered)         |

## Cost Formula

```
Text analytics: Monthly = retailPrice × Quantity (Quantity = records ÷ 1,000)
Training:       Monthly = retailPrice × trainingHours (NOT 730)
Custom hosting: Monthly = retailPrice × modelCount
Commitment:     Monthly = commitmentFee + (overage_retailPrice × excessQuantity)
Free grant:     Health NER: max(0, records − 5,000) ÷ 1,000; Free (F0) SKU: hard 5K quota, no overage
```

## Notes

- **Free tier**: 5K text records/month shared across Sentiment, NER, KPE, Language Detection, QA, Summarization, CLU; 1 hour free training; 1 custom model hosting free
- **Commitment tiers**: Available for Standard, CLU, Summarization, and TA4H features at varying volume tiers (1M–25M depending on feature). Connected container tiers are ~20% cheaper than Azure-hosted
- **Disconnected products**: `Azure Language - Disconnected` and `Language Understanding - Disconnected` bill annually (`1/Year`) — exclude from monthly estimates
- **Scope**: Covers Language-specific products under Foundry Tools. For other AI Services, see `ai-services.md`
- **Legacy tiers**: S0–S4 daily-billed tiers (`1/Day` base + per-1K overage) are deprecated but still in API
- **QA dependency**: Question Answering requires a separate Azure AI Search resource (billed independently)
