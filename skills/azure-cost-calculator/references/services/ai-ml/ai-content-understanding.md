---
serviceName: Azure AI Content Understanding
category: ai-ml
aliases: [Content Extraction, Multi-modal AI, Document Understanding]
billingNeeds: [Azure OpenAI Service]
apiServiceName: Foundry Tools
primaryCost: "Per-page (doc), per-hour (audio/video), per-1K-token (field extraction); PAYG only."
privateEndpoint: true
---

# Azure AI Content Understanding

> **Trap (serviceName)**: API `serviceName` is `Foundry Tools`, NOT `Azure AI Content Understanding`. Always use `ServiceName: Foundry Tools` with `ProductName: Azure Content Understanding` (no "AI" in productName) to isolate meters.

> **Trap (mixed units)**: Meters use 3 unit types: `1K` (pages/tokens/images/transactions), `1 Hour` (audio/video processing), `1K/Month` (face storage). Script's `× 730` only applies to `1 Hour` meters. Verify unit per meter.

> **Trap (regional gaps)**: Only 3 regions (westus, swedencentral, australiaeast) have all 22 meters. Default region eastus has only 7 GA content extraction meters. Field Extraction, Classification, and Face meters return empty in other regions.

> **Trap (regional prices)**: Within the 3-region narrow tier, `swedencentral` prices differ from `westus`/`australiaeast` by ~9–10%; the direction inverts by meter type. Per-page and per-hour narrow-tier meters are cheaper in swedencentral; token-based narrow-tier meters are more expensive. `westus` and `australiaeast` are always price-identical. Specify region explicitly for narrow-tier meter queries.

## Query Pattern

### Standard document content extraction: 10K pages/month

ServiceName: Foundry Tools
ProductName: Azure Content Understanding
SkuName: Doc Content Extraction Standard
MeterName: Doc Content Extraction Standard Pages
Quantity: 10 # 10 × 1K = 10,000 pages

### Audio content extraction: 50 hours

ServiceName: Foundry Tools
ProductName: Azure Content Understanding
SkuName: Audio Content Extraction
MeterName: Audio Content Extraction
Quantity: 50 # total hours of audio processed per month

### Video content extraction

ServiceName: Foundry Tools
ProductName: Azure Content Understanding
SkuName: Video Content Extraction
MeterName: Video Content Extraction

### Standard field extraction: input tokens (3 regions only)

ServiceName: Foundry Tools
ProductName: Azure Content Understanding
SkuName: Std Field Extract Inp
MeterName: Std Field Extract Inp Tokens
Quantity: 1000 # 1000 × 1K = 1M tokens

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `Doc Content Extraction Min Pages` | `Doc Content Extraction Min` | `1K` | Minimal doc tier; 17 regions |
| `Doc Content Extraction Basic Pages` | `Doc Content Extraction Basic` | `1K` | Basic doc extraction; 16 regions |
| `Doc Content Extraction Standard Pages` | `Doc Content Extraction Standard` | `1K` | Standard doc extraction; 16 regions |
| `Audio Content Extraction` | `Audio Content Extraction` | `1 Hour` | Audio processing; 16 regions |
| `Video Content Extraction` | `Video Content Extraction` | `1 Hour` | Video processing; 16 regions |
| `Std Contextualization Tokens` | `Std Contextualization` | `1K` | Sub-cent; 16 regions |
| `Add-On Layout Pages` | `Add-On Layout` | `1K` | Layout add-on; 16 regions |
| `Std Field Extract Inp Tokens` | `Std Field Extract Inp` | `1K` | Sub-cent; 3 regions |
| `Std Field Extract Outp Tokens` | `Std Field Extract Outp` | `1K` | 3 regions |
| `Document Field Extraction Pages` | `Document Field Extraction` | `1K` | 3 regions |
| `Image Field Extraction Images` | `Image Field Extraction` | `1K` | 3 regions |
| `Face Storage Faces` | `Face Storage` | `1K/Month` | Monthly face storage; 3 regions |
| `Add-On Face Grouping Video` | `Add-On Face Grouping` | `1 Hour` | Face grouping add-on; 3 regions |
| `Add-On Formula Pages` | `Add-On Formula` | `1K` | Formula extraction add-on; 3 regions |
| `Audio Field Extraction` | `Audio Field Extraction` | `1 Hour` | Audio field extraction; 3 regions |
| `Classification Input Tokens` | `Classification Input` | `1K` | Sub-cent; 3 regions |
| `Classification Output Tokens` | `Classification Output` | `1K` | 3 regions |
| `Face Transaction Transactions` | `Face Transaction` | `1K` | 3 regions |
| `Pro Contextualization Tokens` | `Pro Contextualization` | `1K` | Sub-cent; 3 regions |
| `Pro Field Extract Inp Tokens` | `Pro Field Extract Inp` | `1K` | Sub-cent; 3 regions |
| `Pro Field Extract Outp Tokens` | `Pro Field Extract Outp` | `1K` | Sub-cent; 3 regions |
| `Video Field Extraction` | `Video Field Extraction` | `1 Hour` | Video field extraction; 3 regions |

## Cost Formula

```
Page meters (1K):       Monthly = retailPrice × (pages ÷ 1000)
Hourly meters (1 Hour): Monthly = retailPrice × hoursProcessed
Token meters (1K):      Monthly = retailPrice × (tokens ÷ 1000)
Face storage (1K/Mo):   Monthly = retailPrice × (faces ÷ 1000)
Composite:              Monthly = ContentExtraction + Contextualization + FieldExtraction
```

## Notes

- **No free tier**: Unlike sibling AI services, Content Understanding has no free tier or monthly grant
- **Azure OpenAI dependency**: Field extraction incurs separate Azure OpenAI model charges (see `openai-service.md` for model pricing)
- **Extraction tiers** (never-assume): Documents offer Minimal/Basic/Standard tiers; contextualization and field extraction also have **Pro** variants. Ask user which tier
- **Regional availability**: GA content extraction in 16–17 regions; Field Extraction/Classification/Face only in westus, swedencentral, australiaeast
- **Two-phase billing**: Content extraction + field extraction are separate meters for all modalities (doc/audio/video); field extraction rates are significantly higher
- **Capacity planning**: `Quantity: 1` = 1K pages/tokens/images when `unitOfMeasure` is `1K`; `1 Hour` meters bill per hour of media processed
- **Supports private endpoints** via AI Services multi-service resource (see `networking/private-link.md` for PE pricing)
