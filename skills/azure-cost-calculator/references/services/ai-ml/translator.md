---
serviceName: Azure Translator
category: ai-ml
aliases: [Translator Text, Text Translation, Document Translation]
apiServiceName: Foundry Tools
primaryCost: "Per-character translation (1M chars) plus daily, monthly, hourly, or annual tier charges."
hasFreeGrant: true
privateEndpoint: true
---

# Azure Translator

> **Trap (serviceName rebrand)**: API `serviceName` is `Foundry Tools`, not `Azure Translator`; the display name returns zero price rows.

> **Trap (product-specific names)**: Always filter `ProductName`. Regional `Translator Text` uses `... Overage Characters` and `... CT Overage Characters`; Global `Azure Translator` uses `... Characters` and tier-specific hosting SKUs.

> **Trap (mixed units + region scope)**: Billing mixes `1M`, `1/Day`, `1/Month`, `1/Year`, `1 Hour`, and `1K`. Use `Region: Global` for `Azure Translator`; divide disconnected annual meters by 12.

## Query Pattern

### S1 standard text translation: 10M characters/month

ServiceName: Foundry Tools
ProductName: Translator Text
SkuName: S1
MeterName: S1 Characters
Quantity: 10 # millions of characters

### S1 document translation

ServiceName: Foundry Tools
ProductName: Translator Text
SkuName: S1
MeterName: S1 Document Characters

### Commitment tier overage: Azure 250M (regional)

ServiceName: Foundry Tools
ProductName: Translator Text
SkuName: Commitment Tier Azure 250M
MeterName: Commitment Tier Azure 250M CT Overage Characters

### Document Translation App PAYG (Global)

ServiceName: Foundry Tools
ProductName: Azure Translator
SkuName: Standard Pay As You Go
MeterName: Standard Pay As You Go App
Region: Global

## Key Fields

| Parameter | How to determine | Example values |
| --- | --- | --- |
| `serviceName` | Always use the API identity | `Foundry Tools` |
| `productName` | Pick the billing family first | `Translator Text`, `Azure Translator`, `Azure Translator - Disconnected` |
| `skuName` | Match tier or commitment family | `S1`, `D3`, `Commitment Tier Azure 250M`, `Commitment Tier App 20K hours` |
| `meterName` | Match the exact billing dimension for that product | `S1 Characters`, `D3 Overage Characters`, `Commitment Tier Azure 250M Characters` |

## Meter Names

| Meter | skuName | productName | unitOfMeasure | Notes |
| --- | --- | --- | --- | --- |
| `S1 Characters` | `S1` | `Translator Text` | `1M` | Standard text translation |
| `S1 Document Characters` | `S1` | `Translator Text` | `1M` | Document translation |
| `S1 Custom Translation Characters` | `S1` | `Translator Text` | `1M` | Custom model inference |
| `S1 Custom Training Characters` | `S1` | `Translator Text` | `1M` | Custom model training |
| `Custom Model Hosting Unit` | `S1` | `Translator Text` | `1/Month` | Also appears under `Free`, `S2`, `S3`, `S4`, `C2`, `C3`, and `C4` |
| `S2 Unit` | `S2` | `Translator Text` | `1/Day` | Legacy daily tier base charge |
| `S2 Overage Characters` | `S2` | `Translator Text` | `1M` | Regional S2 overage |
| `C2 Unit` | `C2` | `Translator Text` | `1/Day` | Connected container base charge |
| `C2 Overage Characters` | `C2` | `Translator Text` | `1M` | Connected container overage |
| `C2 Custom Training Characters` | `C2` | `Translator Text` | `1M` | Connected container training |
| `D3 Unit` | `D3` | `Translator Text` | `1/Day` | Disconnected daily tier base charge |
| `D3 Overage Characters` | `D3` | `Translator Text` | `1M` | Disconnected daily tier overage |
| `S1 Standard Characters` | `S1 Standard` | `Azure Translator` | `1M` | Global S1 standard text |
| `S1 Image Images` | `S1 Image` | `Azure Translator` | `1K` | Global image translation |
| `Commitment Tier Azure 250M Unit` | `Commitment Tier Azure 250M` | `Translator Text` | `1/Month` | Regional commitment base charge |
| `Commitment Tier Azure 250M CT Overage Characters` | `Commitment Tier Azure 250M` | `Translator Text` | `1M` | Regional commitment overage |
| `Commitment Tier Azure 250M Characters` | `Commitment Tier Azure 250M` | `Azure Translator` | `1M` | Global commitment overage name |
| `Standard Pay As You Go App` | `Standard Pay As You Go` | `Azure Translator` | `1 Hour` | Document Translation App PAYG |
| `Commitment Tier App 20K hours Unit` | `Commitment Tier App 20K hours` | `Azure Translator` | `1/Month` | App commitment base charge |
| `Commitment Tier App 20K hours App Overage` | `Commitment Tier App 20K hours` | `Azure Translator` | `1 Hour` | App commitment overage |
| `Commitment Tier Emb 250M Unit` | `Commitment Tier Emb 250M` | `Azure Translator` | `1/Month` | Embeddings commitment base charge |
| `Commitment Tier Emb 250M Characters` | `Commitment Tier Emb 250M` | `Azure Translator` | `1M` | Embeddings commitment overage |
| `Commitment Tier Disconnected 4000M Unit` | `Commitment Tier Disconnected 4000M` | `Azure Translator - Disconnected` | `1/Year` | Annual disconnected commitment |

## Cost Formula

```
Per-character (1M):  Monthly = retailPrice × Quantity
Daily tiers (1/Day): Monthly = retailPrice × 30
Hourly app (1 Hour): Monthly = retailPrice × 730
Monthly commitments (1/Month): Monthly = basePrice + max(0, billableUsage) × overagePrice
Annual disconnected (1/Year): Monthly = retailPrice ÷ 12
Free grant:          BillableChars = max(0, totalChars - 2M)
```

## Notes

- Free SKU includes 2M characters/month, but `Custom Model Hosting Unit` still bills separately.
- `Translator Text` covers regional `S1`, `S2`, `S3`, `S4`, `C2`, `C3`, `C4`, and `D3`; Global `Azure Translator` also exposes parallel `S2`, `S3`, `S4`, `C2`, `C3`, `C4`, and `D3` families plus `S1 Standard`, `S1 Image`, App, Emb, and product-specific hosting SKUs.
- Daily tiers still appear in the API as exact base meters (`S2 Unit`, `S3 Unit`, `S4 Unit`, `C2 Unit`, `C3 Unit`, `C4 Unit`, `D3 Unit`) plus matching character overage meters.
- Commitment families currently present are Azure 250M/1000M/4000M, Connected 250M/1000M/4000M, App 20K/50K/150K/400K hours, Emb 250M/1000M/4000M/10000M, and Disconnected 4000M/10000M.
- Supports private endpoints through the Azure AI Services resource; see `ai-services.md` and `networking/private-link.md`.
