---
serviceName: Azure Vision
category: ai-ml
aliases: [Computer Vision, Face API, Spatial Analysis, Image Analysis]
apiServiceName: Foundry Tools
primaryCost: "Per-transaction (per 1K) + per-hour (Spatial Analysis, Video) + daily/monthly commitment tiers"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Vision

> **Trap (serviceName)**: API `serviceName` is `Foundry Tools`, NOT `Azure Vision`. Always filter by `ProductName` to isolate Vision meters from the 300+ Foundry Tools meters.

> **Trap (multiple products)**: Three products: `Azure Vision`, `Azure Vision - Face`, `Azure Vision - Disconnected`. Liveness meters exist under BOTH Vision and Face products—filter by `productName` to avoid double-counting. Disconnected bills annually (`1/Year`).

> **Trap (tiered pricing)**: Image Analysis and Face transaction meters return multiple rows per tier bracket. The script's `totalMonthlyCost` sums all tiers; calculate manually based on volume.

## Query Pattern

### Image Analysis: PAYG (most common)

ServiceName: Foundry Tools
ProductName: Azure Vision
SkuName: Image Analysis Group 1
MeterName: Image Analysis Group 1 Transactions

### Face API: 50K transactions/month

ServiceName: Foundry Tools
ProductName: Azure Vision - Face
SkuName: Standard
MeterName: Standard Transactions
Quantity: 50 # 50 × 1K = 50,000 transactions

### Spatial Analysis: per camera-hour

ServiceName: Foundry Tools
ProductName: Azure Vision
SkuName: Spatial Analysis
MeterName: Spatial Analysis Video Stream Edge
InstanceCount: 3 # 3 cameras

### Video Retrieval: ingestion

ServiceName: Foundry Tools
ProductName: Azure Vision
SkuName: Video Retrieval and Description - Ingestion
MeterName: Video Retrieval and Description - Ingestion Vision

## Key Fields

| Parameter     | How to determine                    | Example values                                                            |
| ------------- | ----------------------------------- | ------------------------------------------------------------------------- |
| `serviceName` | Always `Foundry Tools`              | `Foundry Tools`                                                           |
| `productName` | Vision sub-product                  | `Azure Vision`, `Azure Vision - Face`, `Azure Vision - Disconnected`      |
| `skuName`     | Tier or feature, varies by product  | `Image Analysis Group 1`, `Standard`, `P1`, `Commitment Tier Azure 500K` |
| `meterName`   | Specific operation being billed     | `Image Analysis Group 1 Transactions`, `Standard Transactions`            |

## Meter Names

| Meter | skuName | productName | unitOfMeasure | Notes |
| ----- | ------- | ----------- | ------------- | ----- |
| `Image Analysis Group 1 Transactions` | `Image Analysis Group 1` | `Azure Vision` | `1K` | Tiered: Tag, Face detect, Thumbnail |
| `Image Analysis Group 2 Transactions` | `Image Analysis Group 2` | `Azure Vision` | `1K` | Tiered: Describe |
| `Standard Transactions` | `Standard` | `Azure Vision - Face` | `1K` | Tiered: Face detection/identify |
| `Face Storage` | `Standard` | `Azure Vision - Face` | `1K` | Per 1K faces stored |
| `Standard Faces` | `Standard` | `Azure Vision - Face` | `1M` | Face IDs stored for training |
| `Liveness Transactions` | `Liveness` | `Azure Vision - Face` | `1K` | Face liveness detection |
| `Liveness and Verification Transactions` | `Liveness and Verification` | `Azure Vision - Face` | `1K` | Liveness + face verification |
| `Spatial Analysis Video Stream Edge` | `Spatial Analysis` | `Azure Vision` | `1 Hour` | Per camera-hour |
| `Video Retrieval and Description - Ingestion Vision` | `Video Retrieval and Description - Ingestion` | `Azure Vision` | `1 Hour` | Video ingestion |
| `Vectorize Image Transactions` | `Vectorize Image` | `Azure Vision` | `1K` | Image embeddings |
| `Vectorize Text Transactions` | `Vectorize Text` | `Azure Vision` | `1K` | Text embeddings; sub-cent |
| `Image Analysis Group 1-1 Transactions` | `Image Analysis Group 1-1` | `Azure Vision` | `1K` | Tiered: same tiers as Group 1 |
| `Custom Image Classification Training` | `Custom Image Classification` | `Azure Vision` | `1 Hour` | Custom model training |
| `Custom Object Detection Training` | `Custom Object Detection` | `Azure Vision` | `1 Hour` | Custom model training |
| `Video Retrieval - Summary Vision` | `Video Retrieval - Summary` | `Azure Vision` | `1 Hour` | Video summarization |
| `P1 Unit` | `P1` | `Azure Vision` | `1/Day` | P-series daily fee; P1/P3 daily-only, P2 daily + overage |
| `P4 Overage Transactions` | `P4` | `Azure Vision` | `1K` | P4–P6 overage-only, no daily fee |
| `Commitment Tier Azure 500K Unit` | `Commitment Tier Azure 500K` | `Azure Vision` | `1/Month` | Monthly commitment; 4 tiers: 500K–16M |

## Cost Formula

```
Transaction meters (1K):   Monthly = retailPrice × (transactions / 1000)
Hourly meters (1 Hour):    Monthly = retailPrice × hoursUsed
Daily meters (1/Day):      Monthly = retailPrice × 30 (script auto-multiplies)
Monthly meters (1/Month):  Monthly = retailPrice (commitment tier base fee)
Spatial Analysis:          Monthly = retailPrice × 730 × cameraCount
Annual meters (1/Year):    Monthly = retailPrice ÷ 12
```

## Notes

- **Free tiers**: Image Analysis 5K txns/mo, Face 30K txns/mo, Spatial Analysis 1 camera/mo, Custom Training free hours
- **Commitment tiers**: Azure (500K–16M txns/mo) and Connected container variants offer volume discounts with overage, not RI. Disconnected (`1/Year`): divide by 12
- **P-series**: Vision P1/P3 daily-only (`1/Day`); P2 daily + overage; P4–P6 overage-only. Face P1–P3: daily fee + tiered overage + storage
- **Scope**: See `ai-services.md` for full Foundry Tools umbrella. Additional Vision meters: Image Retrieval, Shelf Product Recognition, Video Retrieval (Query/Summary)
- **Capacity planning**: `Quantity: 1` = 1,000 transactions when `unitOfMeasure` is `1K`; 1 Spatial Analysis unit = 1 camera-hour
