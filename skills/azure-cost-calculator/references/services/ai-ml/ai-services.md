---
serviceName: Foundry Tools
category: ai-ml
aliases: [Azure AI Foundry Tools, AI Studio, AI Foundry Workspace, Azure AI Services, Cognitive Services, Language, Decision]
primaryCost: "Per-transaction pricing (per 1K records/pages/characters or per hour), varying by cognitive domain."
hasFreeGrant: true
privateEndpoint: true
---

# Azure AI Services

> **Trap (serviceName rebrand)**: API `serviceName` is `Foundry Tools`, NOT `Azure AI Services` or `Cognitive Services`. Old names return zero results.

> **Trap (inflated totals)**: Unfiltered queries return 300+ meters across 37 product families. Always filter by `ProductName`.

> **Trap (sub-cent pricing)**: Some meters (e.g., Face Storage) have sub-cent `retailPrice` and display as minimal cost. Use large `Quantity`.

> **Agent instruction**: Tiered meters (e.g., `Standard Text Records`) return multiple rows with different `tierMinimumUnits`. Use the tier matching the user's volume; do not sum all tiers.

## Query Pattern

### Language: text analytics (tiered meter)

ServiceName: Foundry Tools
ProductName: Azure Language
SkuName: Standard
MeterName: Standard Text Records

### Document Intelligence: 10K pages/month

ServiceName: Foundry Tools
ProductName: Azure Document Intelligence
SkuName: S0
MeterName: S0 Read Pages
Quantity: 10

### Vision Face: 50K transactions/month

ServiceName: Foundry Tools
ProductName: Azure Vision - Face
SkuName: Standard
MeterName: Standard Transactions
Quantity: 50

### Translator: 10M characters/month

ServiceName: Foundry Tools
ProductName: Translator Text
SkuName: S1
MeterName: S1 Characters
Quantity: 10

## Key Fields

| Parameter     | How to determine               | Example values                                             |
| ------------- | ------------------------------ | ---------------------------------------------------------- |
| `serviceName` | Always `Foundry Tools`         | `Foundry Tools`                                            |
| `productName` | Cognitive domain (sub-service) | `Azure Language`, `Azure Vision - Face`, `Translator Text` |
| `skuName`     | Tier, varies by sub-service    | `Standard`, `S0`, `S1`, `Free`, `Commitment Tier ...`      |
| `meterName`   | SKU prefix + feature description | `Standard Text Records`, `S0 Read Pages`, `S1 Characters` |

## Meter Names

| Meter                   | productName                   | unitOfMeasure | Notes                   |
| ----------------------- | ----------------------------- | ------------- | ----------------------- |
| `Standard Text Records` | `Azure Language`              | `1K`          | Tiered; see `language.md` |
| `S0 Read Pages`         | `Azure Document Intelligence` | `1K`          | OCR/layout; see `document-intelligence.md` |
| `Standard Transactions` | `Azure Vision - Face`         | `1K`          | Tiered; see `vision.md` |
| `S1 Characters`         | `Translator Text`             | `1M`          | Text translation; see `translator.md` |
| `S1 Speech To Text`     | `Azure Speech`                | `1 Hour`      | Core STT; see `speech.md` |
| `Standard Text Records` | `Content Safety`              | `1K`          | Text moderation; see `content-safety.md` |
| `Standard Transactions` | `Anomaly Detector`            | `1K`          | Anomaly detection PAYG |
| `S0 Predictions`        | `Azure Custom Vision`         | `1K`          | Custom image inference; also `S0 Training Images` |
| `Standard Doc Content Extraction Pages` | `Azure Content Understanding` | `1K` | See `ai-content-understanding.md` |
| `Evaluations input tokens Tokens` | `Observability`       | `1K`          | Foundry eval; also Output variant |

## Cost Formula

```
Block meters (1K, 1M): Monthly = retailPrice × Quantity
Daily meters (1/Day):  Script auto-multiplies by 30
Hourly meters (1 Hour): Script auto-multiplies by 730
```

`Quantity` = billable units (e.g., 100 = 100K records when `unitOfMeasure` is `1K`).

## Notes

- **Scope**: Covers AI Services (formerly Cognitive Services). Azure OpenAI is separate (see `openai-service.md`)
- **Free tiers**: Most sub-services offer Free SKU with limited quota (Language: 5K records, Vision: 20/min)
- **Daily billing**: Translator S2–S4 and C2–C4 use `1/Day`; script auto-multiplies by 30
- **Legacy/Disconnected**: `Form Recognizer` → Azure Document Intelligence, `Content Moderator` → Content Safety. `- Disconnected` products bill annually. Exclude from monthly estimates
- **Sub-service files**: Language, Vision, Speech, Translator, Document Intelligence, Content Safety, and Content Understanding each have dedicated reference files with full meter tables
- **Supports private endpoints** via the AI Services multi-service resource (see `networking/private-link.md` for PE pricing)
