---
serviceName: Azure Language
category: ai-ml
aliases: [Language Understanding, LUIS, Text Analytics, NER, Sentiment Analysis, CLU]
billingNeeds: [Azure Cognitive Search]
apiServiceName: Foundry Tools
primaryCost: "Per-1K text records + training hours + monthly commitment tiers and overage."
hasFreeGrant: true
privateEndpoint: true
---

# Azure Language

> **Trap (product split)**: API `serviceName` is `Foundry Tools`. Azure Language also spans `Language Understanding`, `Text Analytics Container`, and `*-Disconnected` products, so always filter by `ProductName`.

> **Trap (tiered totals)**: `Standard Text Records`, `Standard Health Text Records`, and `Standard QA Text Records` return multiple `tierMinimumUnits` rows. Use only the tier matching your volume.

> **Trap (mixed billing units)**: Training is `1 Hour`, commitments are `1/Month`, and disconnected products are `1/Year`. Do not use one monthly formula for every meter.

> **Agent instruction**: When estimating Question Answering, also price `Azure Cognitive Search`; the search index is billed separately.

## Query Pattern

### Standard text analytics (NER, Sentiment, PII): 100K records

ServiceName: Foundry Tools
ProductName: Azure Language
SkuName: Standard
MeterName: Standard Text Records
Quantity: 100 # 100 x 1K = 100K records

### Standard commitment tier: 1M included records/month

ServiceName: Foundry Tools
ProductName: Azure Language
SkuName: Commitment Tier Azure 1M
MeterName: Commitment Tier Azure 1M Unit

### CLU / custom model training

ServiceName: Foundry Tools
ProductName: Azure Language
SkuName: Standard
MeterName: Standard CLU Advanced Training Unit

### Legacy LUIS inference

ServiceName: Foundry Tools
ProductName: Language Understanding
SkuName: S1
MeterName: S1 Transactions

## Key Fields

| Parameter | How to determine | Example values |
| --- | --- | --- |
| `serviceName` | Always `Foundry Tools` in the API | `Foundry Tools` |
| `productName` | Feature family or deployment model | `Azure Language`, `Language Understanding`, `Text Analytics Container` |
| `skuName` | Tier, legacy SKU, or commitment band | `Standard`, `Free`, `P1`, `Commitment Tier Azure 1M` |
| `meterName` | Exact billing dimension | `Standard Text Records`, `Doc-PII Redaction Pages`, `P1 Transactions` |

## Meter Names

| Meter | skuName | productName | unitOfMeasure | Notes |
| --- | --- | --- | --- | --- |
| `Standard Text Records` | `Standard` | `Azure Language` | `1K` | Core text analytics; tiers at 0/500/2500/10000 |
| `Standard Health Text Records` | `Standard` | `Azure Language` | `1K` | TA4H; tiers at 0/5/500/2500/10000 |
| `Standard QA Text Records` | `Standard` | `Azure Language` | `1K` | Question Answering; tiers at 0/2500 |
| `Standard CLU Text Records` | `Standard` | `Azure Language` | `1K` | CLU inference |
| `Standard CLU Advanced Training Unit` | `Standard` | `Azure Language` | `1 Hour` | CLU training |
| `Standard Custom Text Records` | `Standard` | `Azure Language` | `1K` | Custom NER / classification |
| `Standard Custom Summarization Text Records` | `Standard` | `Azure Language` | `1K` | Custom summarization |
| `Standard Custom Training Unit` | `Standard` | `Azure Language` | `1 Hour` | Custom model training |
| `Standard Custom Hosting Unit` | `Standard` | `Azure Language` | `1/Month` | Hosted custom model |
| `Doc-PII Redaction Pages` | `Doc-PII Redaction Pages` | `Azure Language` | `1K` | Document PII redaction |
| `Commitment Tier Azure {1M|3M|10M|25M} Unit` | `Commitment Tier Azure {1M|3M|10M|25M}` | `Azure Language` | `1/Month` | Standard included usage; overage uses `...CT Overage Transactions` |
| `Commitment Tier CLU Azure {1M|3M|10M|25M} Unit` | `Commitment Tier CLU Azure {1M|3M|10M|25M}` | `Azure Language` | `1/Month` | CLU commitment tiers |
| `Commitment Tier Summarization Azure {3M|10M} Unit` | `Commitment Tier Summarization Azure {3M|10M}` | `Azure Language` | `1/Month` | Summarization commitment tiers |
| `Commitment Tier TA4H {1M|3M|10M} Unit` | `Commitment Tier TA4H {1M|3M|10M}` | `Azure Language` | `1/Month` | Health commitment tiers |
| `P1 Transactions` | `P1` | `Language Understanding` | `1K` | Legacy LUIS inference |
| `S1 Transactions` | `S1` | `Language Understanding` | `1K` | Legacy LUIS inference |
| `S1 Speech To Intent - Understanding Transactions` | `S1` | `Language Understanding` | `1K` | Legacy speech-to-intent |
| `Standard Text Records` | `Standard` | `Text Analytics Container` | `1K` | Connected container PAYG |

## Cost Formula

```
Text records (1K):   Monthly = retailPrice × Quantity
Training (1 Hour):   Monthly = retailPrice × trainingHours
Monthly CTs:         Monthly = commitmentFee + (overage_retailPrice × excessQuantity)
Annual CTs:          Monthly = retailPrice ÷ 12
Free grant:          Billable = max(0, totalRecords − includedFreeRecords)
```

## Notes

- **Free meters**: `Free Text Records`, `Free Training Unit`, `Free Transactions`, `Free Authoring Transactions`, and `Standard Text Records - Free` appear in the API
- **Commitment tiers**: Standard and CLU Azure/Connected use 1M/3M/10M/25M; Summarization uses 3M/10M; TA4H uses 1M/3M/10M; legacy LUIS uses 1M/5M/25M
- **Disconnected products**: `Azure Language - Disconnected` and `Language Understanding - Disconnected` bill annually (`1/Year`); exclude unless the user asks for disconnected containers
- **Container product split**: `Text Analytics Container` is the connected PAYG product, but connected commitment SKUs still live under `Azure Language`
- **Legacy scope**: `Language Understanding` still contains LUIS meters, including `P1 Transactions`, `S1 Transactions`, and daily S0-S4 tiers
- **QA dependency**: Question Answering requires a separate Azure AI Search resource; Azure Language also supports private endpoints through the Azure AI Services resource
