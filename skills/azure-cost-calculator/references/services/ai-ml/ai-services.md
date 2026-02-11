---
serviceName: Foundry Tools
category: ai-ml
aliases: [Cognitive Services, Vision, Speech, Language, Decision]
---

# Azure AI Services

**Primary cost**: Per-transaction pricing (per 1K records/pages/characters or per hour) — varies by cognitive domain (Language, Vision, Speech, Document Intelligence, Translator, Content Safety).

> **Trap (serviceName rebrand)**: The API `serviceName` is `Foundry Tools`, NOT `Azure AI Services` or `Cognitive Services`. Queries using the old names return zero results. Always use `ServiceName 'Foundry Tools'`.

> **Trap (inflated totals)**: An unfiltered `ServiceName 'Foundry Tools'` query returns hundreds of meters across 27+ product families. Always filter by `ProductName` to isolate a specific cognitive domain.

> **Trap (sub-cent pricing)**: Some meters (Face Storage, Immersive Reader) are priced below $0.01 per 1K and display as `$0.00`. Use `Quantity` with a large value to surface meaningful costs.

> **Trap (no standard Speech SKU)**: Azure Speech has no `Standard` SKU — only Free, commitment tiers, and specialized SKUs. Use commitment tier queries for Speech pricing.

## Query Pattern

### Language — text analytics (100K text records/month)

ServiceName: Foundry Tools
ProductName: Azure Language
SkuName: Standard
MeterName: Standard Text Records

> Note: This meter is tiered — run without `Quantity` to see tier rows, then manually calculate cost.

### Document Intelligence — OCR read pages (10K pages/month)

ServiceName: Foundry Tools
ProductName: Azure Document Intelligence
SkuName: S0
MeterName: S0 Read Pages
Quantity: 10

### Vision — Face API transactions (50K transactions/month)

ServiceName: Foundry Tools
ProductName: Azure Vision - Face
SkuName: Standard
MeterName: Standard Transactions
Quantity: 50

### Content Safety — text moderation (100K records/month)

ServiceName: Foundry Tools
ProductName: Content Safety
SkuName: Standard
MeterName: Standard Text Records
Quantity: 100

### Translator — S1 PAYG characters (10M characters/month)

ServiceName: Foundry Tools
ProductName: Translator Text
SkuName: S1
MeterName: S1 Characters
Quantity: 10

## Key Fields

| Parameter     | How to determine                                | Example values                                                         |
| ------------- | ----------------------------------------------- | ---------------------------------------------------------------------- |
| `serviceName` | Always `Foundry Tools`                          | `Foundry Tools`                                                        |
| `productName` | Cognitive domain — each sub-service has its own | `Azure Language`, `Azure Vision - Face`, `Azure Document Intelligence` |
| `skuName`     | Tier — varies by sub-service                    | `Standard`, `S0`, `S1`, `Free`, `Commitment Tier ...`                  |
| `meterName`   | Feature-specific meter within the sub-service   | `Standard Text Records`, `S0 Read Pages`, `Standard Transactions`      |

## Product Names

| Cognitive Domain      | productName                   | Common skuNames                            |
| --------------------- | ----------------------------- | ------------------------------------------ |
| Language (NLP)        | `Azure Language`              | `Standard`, `S0`–`S4`                      |
| Vision — Face         | `Azure Vision - Face`         | `Standard`                                 |
| Vision — Custom       | `Azure Custom Vision`         | `S0`, `Free`                               |
| Document Intelligence | `Azure Document Intelligence` | `S0`, `Free`                               |
| Speech                | `Azure Speech`                | `Free`, commitment tiers, specialized SKUs |
| Translator            | `Translator Text`             | `S1`–`S4`, `C2`–`C4`, `Free`               |
| Content Safety        | `Content Safety`              | `Standard`                                 |
| Anomaly Detector      | `Anomaly Detector`            | `Standard`, `Free`                         |

## Cost Formula

- **Block meters (`1K`, `1M`)**: `Monthly = retailPrice × Quantity`
- **Daily meters (`1/Day`)**: Script shows daily cost — multiply by 30 for monthly
- **Hourly meters (`1 Hour`)**: Script auto-multiplies by 730
- **Monthly meters (`1/Month`)**: `Monthly = retailPrice × Quantity`

`Quantity` = billable units (e.g., 100 = 100K text records when `unitOfMeasure` is `1K`).

## Notes

- **Scope**: This file covers AI Services (formerly Cognitive Services). Azure OpenAI (GPT/DALL-E) is a separate service — see `openai.md`
- **Free tiers**: Most sub-services offer a Free SKU with limited monthly quota (e.g., Language: 5K text records, Vision: 20 transactions/minute)
- **Commitment tiers**: Speech and Language offer monthly commitment tiers (e.g., `Commitment Tier Custom Speech to Text Azure 10K`) with lower per-unit overage rates
- **Daily billing**: Translator S2–S4 and C2–C4 tiers use `1/Day` billing — script shows daily cost; multiply by 30 for monthly estimates
- **Disconnected containers**: Products ending in `- Disconnected` are air-gapped container deployments with annual billing (`1/Year`) — exclude unless specifically requested
- Reserved pricing is **not available** — all meters are Consumption-based
