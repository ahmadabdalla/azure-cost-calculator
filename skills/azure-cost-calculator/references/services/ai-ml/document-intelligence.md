---
serviceName: Azure Document Intelligence
category: ai-ml
aliases: [Form Recognizer, Document AI, OCR, Invoice Processing]
apiServiceName: Foundry Tools
primaryCost: "Per-page billing (per 1K pages) by model type — Read, Pre-built, Custom with free tier."
hasFreeGrant: true
privateEndpoint: true
---

# Azure Document Intelligence

> **Trap (serviceName filter)**: API `serviceName` is `Foundry Tools`, NOT `Azure Document Intelligence`. Always add `ProductName: Azure Document Intelligence` to isolate this sub-service.

> **Trap (tiered Read pricing)**: `S0 Read Pages` and `S0 Batch Read Pages` each return two tiered rows — the script sums both, producing a meaningless total. Calculate manually: tier 1 rate for ≤1M pages, tier 2 rate for volume above 1M.

## Query Pattern

### Pre-built models (Invoice, Receipt, ID, W-2) — 10K pages/month

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Document Intelligence
SkuName: S0
MeterName: S0 Pre-built Pages
Quantity: 10 # 10 × 1K = 10,000 pages

### Read (OCR/layout extraction)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Document Intelligence
SkuName: S0
MeterName: S0 Read Pages

### Custom extraction models

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Document Intelligence
SkuName: S0
MeterName: S0 Custom Pages

### Commitment tier — Pre-Built Azure 100K (monthly fee)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Document Intelligence
SkuName: Commitment Tier Pre-Built Azure 100K
MeterName: Commitment Tier Pre-Built Azure 100K Unit

## Key Fields

| Parameter     | How to determine                        | Example values                                                              |
| ------------- | --------------------------------------- | --------------------------------------------------------------------------- |
| `serviceName` | Always `Foundry Tools` (API name)       | `Foundry Tools`                                                             |
| `productName` | Deployment model                        | `Azure Document Intelligence`, `Azure Document Intelligence - Disconnected` |
| `skuName`     | Tier + model type + deployment + volume | `S0`, `Free`, `Commitment Tier Pre-Built Azure 100K`                        |
| `meterName`   | Billing dimension                       | `S0 Read Pages`, `S0 Pre-built Pages`, `S0 Custom Pages`                   |

## Meter Names

| Meter                          | skuName | unitOfMeasure | Notes                                     |
| ------------------------------ | ------- | ------------- | ----------------------------------------- |
| `S0 Read Pages`                | `S0`    | `1K`          | OCR/text extraction — **tiered** (2 rows) |
| `S0 Pre-built Pages`           | `S0`    | `1K`          | Invoice, Receipt, ID, W-2, Layout         |
| `S0 Custom Pages`              | `S0`    | `1K`          | Custom extraction models                  |
| `S0 Custom Generative Pages`   | `S0`    | `1K`          | Custom generative extraction              |
| `S0 Add-on for Pages`          | `S0`    | `1K`          | High Res, Font, Formula, Barcode          |
| `S0 Query Pages`               | `S0`    | `1K`          | Premium query — most expensive PAYG meter |
| `S0 pages for query fields`    | `S0`    | `1K`          | Query field extraction — note lowercase   |
| `S0 pages for doc classifier`  | `S0`    | `1K`          | Document classification — note lowercase  |
| `S0 Training`                  | `S0`    | `1 Hour`      | Neural model training (first 10 hrs free) |
| `Free Transactions`            | `Free`  | `1K`          | Free tier — 500 pages/month               |

## Cost Formula

```
PAYG pages:  Monthly = retailPrice × Quantity   (Quantity = pages ÷ 1000)
Read tiered: First 1M pages at tier-1 rate, excess at tier-2 rate
Commitment:  Monthly = commitment Unit retailPrice (flat 1/Month fee)
  Overage:   CT Overage retailPrice × excess Quantity
Free grant:  Billable = max(0, pages − 500) then apply PAYG formula
```

## Notes

- **Free tier**: F0 SKU includes 500 pages/month; S0 Training: first 10 hours free for neural models, template training always free
- **Model types** (never-assume): Read (OCR), Pre-built (Invoice/Receipt/ID/W-2/Layout), Custom (extraction/generative), Add-on — ask user which model
- **Commitment tiers**: Pre-built/Custom 20K–1M pages/month, Read 500K–16M pages/month; Connected Container tiers are ~10–20% cheaper (varies by model type)
- **Disconnected containers**: Separate product (`Azure Document Intelligence - Disconnected`), annual billing (`1/Year`), no overage — divide `retailPrice` by 12 for monthly equivalent
- **Legacy**: `Form Recognizer` productName has higher Custom pricing — always use `Azure Document Intelligence` for current rates
- **Scope**: For broader Foundry Tools coverage (Language, Vision, Speech, Translator), see `ai-ml/ai-services.md`
- **Private endpoints**: Supported via Azure AI Services multi-service resource — see `networking/private-link.md`
- **Batch API**: Separate meters at same prices but names may differ (e.g., `S0 Batch Custom Extraction Pages` not `S0 Batch Custom Pages`); Batch Layout has its own meter (`S0 Batch Layout Pages`)
