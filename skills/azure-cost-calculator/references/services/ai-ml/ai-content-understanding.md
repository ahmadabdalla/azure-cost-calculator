---
serviceName: Azure AI Content Understanding
category: ai-ml
aliases: [Content Extraction, Multi-modal AI, Document Understanding]
billingNeeds: [Azure OpenAI Service]
apiServiceName: Foundry Tools
primaryCost: "Per-page (doc), per-hour (audio/video), per-1K-token (field extraction) — PAYG only."
privateEndpoint: true
---

# Azure AI Content Understanding

> **Trap (serviceName)**: API `serviceName` is `Foundry Tools`, NOT `Azure AI Content Understanding`. Always use `ServiceName: Foundry Tools` with `ProductName: Azure Content Understanding` (no "AI" in productName) to isolate meters.

> **Trap (mixed units)**: Meters use 3 unit types: `1K` (pages/tokens/images/transactions), `1 Hour` (audio/video processing), `1K/Month` (face storage). Script's `× 730` only applies to `1 Hour` meters — verify unit per meter.

> **Trap (regional gaps)**: Only 3 regions (westus, swedencentral, australiaeast) have all 22 meters. Default region eastus has only 7 GA content extraction meters. Field Extraction, Classification, and Face meters return empty in other regions.

## Query Pattern

### Standard document content extraction — 10K pages/month

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Content Understanding
SkuName: Standard Doc Content Extraction
MeterName: Standard Doc Content Extraction Pages
Quantity: 10 # 10 × 1K = 10,000 pages

### Audio content extraction — 50 hours

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Content Understanding
SkuName: Audio Content Extraction
MeterName: Audio Content Extraction
Quantity: 50 # total hours of audio processed per month

### Video content extraction

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Content Understanding
SkuName: Video Content Extraction
MeterName: Video Content Extraction

### Standard field extraction — input tokens (3 regions only)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Content Understanding
SkuName: Std Field Extract Inp
MeterName: Std Field Extract Inp Tokens
Quantity: 1000 # 1000 × 1K = 1M tokens

## Key Fields

| Parameter     | How to determine                     | Example values                                                      |
| ------------- | ------------------------------------ | ------------------------------------------------------------------- |
| `serviceName` | Always `Foundry Tools`               | `Foundry Tools`                                                     |
| `productName` | Always `Azure Content Understanding` | `Azure Content Understanding`                                       |
| `skuName`     | Modality + extraction tier           | `Standard Doc Content Extraction`, `Audio Content Extraction`       |
| `meterName`   | SKU name + unit suffix               | `Standard Doc Content Extraction Pages`, `Audio Content Extraction` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `Min. Doc Content Extraction Pages` | `Min. Doc Content Extraction` | `1K` | Minimal doc tier; 16 regions |
| `Basic Doc Content Extraction Pages` | `Basic Doc Content Extraction` | `1K` | Basic doc extraction; 15 regions |
| `Standard Doc Content Extraction Pages` | `Standard Doc Content Extraction` | `1K` | Standard doc extraction; 15 regions |
| `Audio Content Extraction` | `Audio Content Extraction` | `1 Hour` | Audio processing; 15 regions |
| `Video Content Extraction` | `Video Content Extraction` | `1 Hour` | Video processing; 15 regions |
| `Std Contextualization Tokens` | `Std Contextualization` | `1K` | Token-based contextualization; 15 regions |
| `Add-On Layout Pages` | `Add-On Layout` | `1K` | Layout extraction add-on; 15 regions |
| `Std Field Extract Inp Tokens` | `Std Field Extract Inp` | `1K` | Standard field input; 3 regions |
| `Std Field Extract Outp Tokens` | `Std Field Extract Outp` | `1K` | Standard field output; 3 regions |
| `Document Field Extraction Pages` | `Document Field Extraction` | `1K` | Doc field extraction; 3 regions |
| `Image Field Extraction Images` | `Image Field Extraction` | `1K` | Image field extraction; 3 regions |
| `Face Storage Faces` | `Face Storage` | `1K/Month` | Monthly face storage; 3 regions |

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
- **Azure OpenAI dependency**: Field extraction incurs separate Azure OpenAI model charges — see `openai-service.md` for model pricing
- **Extraction tiers** (never-assume): Documents offer Minimal/Basic/Standard tiers; contextualization and field extraction also have **Pro** variants — ask user which tier
- **Regional availability**: GA content extraction in 15–16 regions; Field Extraction/Classification/Face only in westus, swedencentral, australiaeast
- **Two-phase billing**: Content extraction + field extraction are separate meters for all modalities (doc/audio/video) — field extraction rates are significantly higher
- **Capacity planning**: `Quantity: 1` = 1K pages/tokens/images when `unitOfMeasure` is `1K`; `1 Hour` meters bill per hour of media processed
- **Supports private endpoints** via AI Services multi-service resource — see `networking/private-link.md` for PE pricing
- **10 additional meters** in 3-region tier: Classification In/Out, Pro Contextualization, Pro Field Extract In/Out, Audio/Video Field Extraction, Add-On Formula/Face Grouping, Face Transaction — query `ProductName: Azure Content Understanding` in westus
- **Scope**: For broader Foundry Tools coverage, see `ai-services.md`
