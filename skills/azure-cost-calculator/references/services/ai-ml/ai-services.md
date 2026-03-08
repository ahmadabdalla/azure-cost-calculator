---
serviceName: Foundry Tools
category: ai-ml
aliases: [Azure AI Foundry Tools, AI Studio, AI Foundry Workspace, Azure AI Services, Cognitive Services, Language, Decision]
primaryCost: "Per-transaction pricing (per 1K records/pages/characters or per hour) — varies by cognitive domain."
hasFreeGrant: true
privateEndpoint: true
---

# Azure AI Services

> **Trap (serviceName rebrand)**: API `serviceName` is `Foundry Tools`, NOT `Azure AI Services` or `Cognitive Services`. Old names return zero results.

> **Trap (inflated totals)**: Unfiltered queries return 300+ meters across 37 product families. Always filter by `ProductName`.

> **Trap (sub-cent pricing)**: Some meters (e.g., Face Storage) have sub-cent `retailPrice` and display as minimal cost. Use large `Quantity`.

## Query Pattern

### Language — text analytics (tiered meter)

ServiceName: Foundry Tools
ProductName: Azure Language
SkuName: Standard
MeterName: Standard Text Records

### Document Intelligence — 10K pages/month

ServiceName: Foundry Tools
ProductName: Azure Document Intelligence
SkuName: S0
MeterName: S0 Read Pages
Quantity: 10

### Vision Face — 50K transactions/month

ServiceName: Foundry Tools
ProductName: Azure Vision - Face
SkuName: Standard
MeterName: Standard Transactions
Quantity: 50

### Translator — 10M characters/month

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
| `skuName`     | Tier — varies by sub-service   | `Standard`, `S0`, `S1`, `Free`, `Commitment Tier ...`      |

## Meter Names

| Meter                   | productName                   | unitOfMeasure | Notes                   |
| ----------------------- | ----------------------------- | ------------- | ----------------------- |
| `Standard Text Records` | `Azure Language`              | `1K`          | Tiered pricing          |
| `S0 Read Pages`         | `Azure Document Intelligence` | `1K`          | OCR/layout extraction   |
| `Standard Transactions` | `Azure Vision - Face`         | `1K`          | Face detection/identify |
| `S1 Characters`         | `Translator Text`             | `1M`          | Text translation        |

## Cost Formula

```
Block meters (1K, 1M): Monthly = retailPrice × Quantity
Daily meters (1/Day):  Script auto-multiplies by 30
Hourly meters (1 Hour): Script auto-multiplies by 730
```

`Quantity` = billable units (e.g., 100 = 100K records when `unitOfMeasure` is `1K`).

## Notes

- **Scope**: Covers AI Services (formerly Cognitive Services). Azure OpenAI is separate — see `openai-service.md`
- **Free tiers**: Most sub-services offer Free SKU with limited quota (Language: 5K records, Vision: 20/min)
- **Daily billing**: Translator S2–S4 and C2–C4 use `1/Day` — script auto-multiplies by 30
- **Legacy/Disconnected**: `Form Recognizer` → Azure Document Intelligence, `Content Moderator` → Content Safety. `- Disconnected` products bill annually — exclude

## Product Names

| productName                   | Common skuNames                                                                                                                             |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `Azure Language`              | `Standard`, `S0`–`S4`                                                                                                                       |
| `Azure Vision - Face`         | `Standard`                                                                                                                                  |
| `Azure Document Intelligence` | `S0`, `Free`                                                                                                                                |
| `Azure Speech`                | `Free`, commitment tiers, specialized SKUs — see `speech.md`                                                                                |
| `Translator Text`             | `S1`–`S4`, `C2`–`C4`, `Free`                                                                                                                |
| `Content Safety`              | `Standard`                                                                                                                                  |
| `Anomaly Detector`            | `Standard`, `Free`                                                                                                                          |
| `Azure Custom Vision`         | `S0`, `Free`                                                                                                                                |
| `Azure Content Understanding` | `Basic Doc`, `Basic Audio`, `Basic Video`, `Standard Doc`, `Standard Audio`, `Standard Video`, `Add-On Doc`, `Add-On Audio`, `Add-On Video` |
| `Observability`               | `Evaluations input tokens`, `Evaluations output tokens` (meterNames append ` Tokens`)                                                      |
