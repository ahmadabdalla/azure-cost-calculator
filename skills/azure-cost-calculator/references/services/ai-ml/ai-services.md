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

> **Trap (inflated totals)**: Broad `eastus` queries return 500+ meters across 28 product families. Always filter by `ProductName`.

> **Trap (mixed regions)**: Default regional queries miss Global-only products such as `Azure Health Insights`. Check `Global` when a product seems missing.

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
| `meterName`   | Billing dimension, varies by product | `Standard Text Records`, `S0 Read Pages`, `S1 Characters` |

## Meter Names

| Meter                   | productName                   | unitOfMeasure | Notes                   |
| ----------------------- | ----------------------------- | ------------- | ----------------------- |
| `Standard Text Records` | `Azure Language`              | `1K`          | Tiered; see `language.md` |
| `S0 Read Pages`         | `Azure Document Intelligence` | `1K`          | Tiered; OCR/layout; see `document-intelligence.md` |
| `Standard Transactions` | `Azure Vision - Face`         | `1K`          | Tiered; see `vision.md` |
| `S1 Characters`         | `Translator Text`             | `1M`          | Text translation; see `translator.md` |
| `S1 Speech To Text`     | `Azure Speech`                | `1 Hour`      | Core STT; see `speech.md` |
| `Standard Text Records` | `Content Safety`              | `1K`          | Text moderation; see `content-safety.md` |
| `Standard Univariate Transactions` | `Anomaly Detector`   | `1K`          | Anomaly detection PAYG |
| `S0 Transactions`       | `Azure Custom Vision`         | `1K`          | Custom image inference; also `S0 Training`, `S0 Image Storage` |
| `Doc Content Extraction Standard Pages` | `Azure Content Understanding` | `1K` | See `ai-content-understanding.md` |
| `Evaluations input tokens Tokens` | `Observability`       | `1K`          | Foundry eval; also Output variant |
| `Model Routers GL 1M Tokens` | `Model Tools`        | `1M`          | Model router prompt charge; also DZ variant |
| `Radiology Insights Language Detection Text Records` | `Azure Health Insights` | `1K` | Global-only; verify availability |

## Cost Formula

```
Block meters (1K, 1M): Monthly = retailPrice × Quantity
Daily meters (1/Day):  Script auto-multiplies by 30
Hourly meters (1 Hour): Script auto-multiplies by 730
```

`Quantity` = billable units (e.g., 100 = 100K records when `unitOfMeasure` is `1K`).

## Notes

- **Scope**: Covers umbrella and unrouted `Foundry Tools` products; dedicated sub-service files remain authoritative. Azure OpenAI is separate (`openai-service.md`)
- **Free tiers**: Most sub-services offer Free SKU with limited quota (Language: 5K records, Vision: 20/min)
- **Daily billing**: Translator S2–S4 and C2–C4 use `1/Day`; script auto-multiplies by 30
- **Health Insights caution**: The API exposes one Global meter, but Learn docs remain archived/preview-oriented. Verify availability before estimating
- **Legacy/Disconnected**: `Form Recognizer` → Azure Document Intelligence, `Content Moderator` → Content Safety. Azure Custom Vision is planned for retirement on 9/25/2028. `- Disconnected` products bill annually; exclude them from monthly estimates
- **Sub-service files**: Language, Vision, Speech, Translator, Document Intelligence, Content Safety, Content Understanding, Video Indexer, and Foundry Agents each have dedicated reference files with full meter tables
- **Supports private endpoints** via the AI Services multi-service resource (see `networking/private-link.md` for PE pricing)
