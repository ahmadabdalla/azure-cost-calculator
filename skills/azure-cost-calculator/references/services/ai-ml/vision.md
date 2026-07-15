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

> **Trap (multiple products)**: Four products: `Azure Vision`, `Azure Vision - Face`, `Azure Vision - Disconnected`, and `Azure Custom Vision`. Liveness meters exist under BOTH Vision and Face products; disconnected bills annually (`1/Year`).

> **Trap (tiered pricing)**: Image Analysis Group 1/1-1/2 and Face `Standard Transactions` or `Overage Transactions` return multiple rows by `tierMinimumUnits`. The script's `totalMonthlyCost` sums all tiers; calculate manually from the matching bracket.

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

### Custom Vision: S0 inference

ServiceName: Foundry Tools
ProductName: Azure Custom Vision
SkuName: S0
MeterName: S0 Transactions

### Commitment tier: Azure 500K base fee

ServiceName: Foundry Tools
ProductName: Azure Vision
SkuName: Commitment Tier Azure 500K
MeterName: Commitment Tier Azure 500K Unit

## Key Fields

| Parameter     | How to determine                    | Example values                                                                              |
| ------------- | ----------------------------------- | ------------------------------------------------------------------------------------------- |
| `serviceName` | Always `Foundry Tools`              | `Foundry Tools`                                                                             |
| `productName` | Vision sub-product or legacy family | `Azure Vision`, `Azure Vision - Face`, `Azure Vision - Disconnected`, `Azure Custom Vision` |
| `skuName`     | Tier or feature, varies by product  | `Image Analysis Group 1`, `Standard`, `P1`, `Commitment Tier Azure 500K`                    |
| `meterName`   | Specific operation being billed     | `Image Analysis Group 1 Transactions`, `Standard Transactions`                              |

## Meter Names

| Meter                                                                     | skuName                                           | productName           | unitOfMeasure | Notes                                     |
| ------------------------------------------------------------------------- | ------------------------------------------------- | --------------------- | ------------- | ----------------------------------------- |
| `Image Analysis Group 1 Transactions`                                     | `Image Analysis Group 1`                          | `Azure Vision`        | `1K`          | Tiered: Tag, Face detect, Thumbnail       |
| `Image Analysis Group 2 Transactions`                                     | `Image Analysis Group 2`                          | `Azure Vision`        | `1K`          | Tiered: Describe                          |
| `Standard Transactions`                                                   | `Standard`                                        | `Azure Vision - Face` | `1K`          | Tiered: Face detection/identify           |
| `Face Storage`                                                            | `Standard`                                        | `Azure Vision - Face` | `1K`          | Per 1K faces stored                       |
| `Standard Faces`                                                          | `Standard`                                        | `Azure Vision - Face` | `1M`          | Face IDs stored for training              |
| `Liveness Transactions`                                                   | `Liveness`                                        | `Azure Vision - Face` | `1K`          | Face liveness detection                   |
| `Liveness and Verification Transactions`                                  | `Liveness and Verification`                       | `Azure Vision - Face` | `1K`          | Liveness + face verification              |
| `Spatial Analysis Video Stream Edge`                                      | `Spatial Analysis`                                | `Azure Vision`        | `1 Hour`      | Per camera-hour                           |
| `Video Retrieval and Description - Ingestion Vision`                      | `Video Retrieval and Description - Ingestion`     | `Azure Vision`        | `1 Hour`      | Video ingestion                           |
| `Vectorize Image Transactions`                                            | `Vectorize Image`                                 | `Azure Vision`        | `1K`          | Image embeddings                          |
| `Vectorize Text Transactions`                                             | `Vectorize Text`                                  | `Azure Vision`        | `1K`          | Text embeddings                           |
| `Image Analysis Group 1-1 Transactions`                                   | `Image Analysis Group 1-1`                        | `Azure Vision`        | `1K`          | Tiered: same tiers as Group 1             |
| `Custom Image Classification Training`                                    | `Custom Image Classification`                     | `Azure Vision`        | `1 Hour`      | Custom model training                     |
| `Custom Object Detection Training`                                        | `Custom Object Detection`                         | `Azure Vision`        | `1 Hour`      | Custom model training                     |
| `S0 Transactions`                                                         | `S0`                                              | `Azure Custom Vision` | `1K`          | Custom Vision inference                   |
| `S0 Training`                                                             | `S0`                                              | `Azure Custom Vision` | `1 Hour`      | Custom Vision training                    |
| `S0 Image Storage`                                                        | `S0`                                              | `Azure Custom Vision` | `1K`          | Custom Vision image storage               |
| `Video Retrieval - Summary Vision`                                        | `Video Retrieval - Summary`                       | `Azure Vision`        | `1 Hour`      | Video summarization                       |
| `P{1/2/3} Unit`                                                           | `P{1/2/3}`                                        | `Azure Vision`        | `1/Day`       | Vision P1/P3 daily-only; P2 adds overage  |
| `P{4/5/6} Overage Transactions`                                           | `P{4/5/6}`                                        | `Azure Vision`        | `1K`          | Vision overage-only tiers                 |
| `P{1/2/3} Unit`                                                           | `P{1/2/3}`                                        | `Azure Vision - Face` | `1/Day`       | Face daily fee; storage billed separately |
| `Overage Transactions`                                                    | `P{1/2/3}`                                        | `Azure Vision - Face` | `1K`          | Face tiered overage                       |
| `Commitment Tier Azure {500K/2000K/8000K/16000K} Unit`                    | `Commitment Tier Azure {500K/2000K/8000K/16000K}` | `Azure Vision`        | `1/Month`     | Monthly base fee                          |
| `Commitment Tier Azure {500K/2000K/8000K/16000K} CT Overage Transactions` | `Commitment Tier Azure {500K/2000K/8000K/16000K}` | `Azure Vision`        | `1K`          | Overage beyond included usage             |

## Cost Formula

```
Transaction meters (1K):   Monthly = retailPrice × (transactions / 1000)
Tiered meters:             Apply the retailPrice for the bracket matching `tierMinimumUnits`
Hourly meters (1 Hour):    Monthly = retailPrice × hoursUsed
Daily meters (1/Day):      Monthly = retailPrice × 30 (script auto-multiplies)
Monthly meters (1/Month):  Monthly = commitment_retailPrice + (overage_retailPrice × excessQuantity)
Spatial Analysis:          Monthly = retailPrice × 730 × cameraCount
Annual meters (1/Year):    Monthly = retailPrice ÷ 12
Free grant:                Billable = max(0, totalUsage − includedFreeUsage)
```

## Notes

- **Free tiers**: Image Analysis 5K txns/mo, Face 30K txns/mo, Spatial Analysis 1 camera/mo, Azure Custom Vision free transactions/training
- **Tier breakpoints**: Image Analysis Group 1 and 1-1 use 0/1K/10K/100K; Face Standard uses 0/1K/5K/100K; choose the matching tier row
- **Commitment tiers**: Azure `500K/2000K/8000K/16000K` and Connected variants use monthly base fee + `CT Overage Transactions`; disconnected tiers bill annually (`1/Year`)
- **P-series**: Vision P1/P3 daily-only (`1/Day`); P2 daily + overage; P4–P6 overage-only. Face P1–P3: daily fee + tiered overage + storage
- **Scope**: See `ai-services.md` for full Foundry Tools umbrella. Additional active meters include Image Retrieval, Shelf Product Recognition, and Video Retrieval Query
- **Capacity planning**: `Quantity: 1` = 1,000 transactions when `unitOfMeasure` is `1K`; 1 Spatial Analysis unit = 1 camera-hour
