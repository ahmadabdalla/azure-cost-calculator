---
serviceName: Content Safety
category: ai-ml
aliases: [Content Moderation, Image Moderation, Text Moderation, AI Content Safety]
apiServiceName: Foundry Tools
primaryCost: "Per-transaction (per 1K) for text records and images; PAYG + commitment tier discounts."
hasFreeGrant: true
privateEndpoint: true
---

# Content Safety

> **Trap (serviceName)**: API `serviceName` is `Foundry Tools`, NOT `Content Safety`. Always filter by `ProductName` to isolate Content Safety meters from the 300+ Foundry Tools meters.

> **Trap (multiple products)**: Two products: `Content Safety` (regional PAYG + commitment) and `Content Safety - Disconnected` (Global, annual). Disconnected bills annually (`1/Year`). Exclude from standard estimates.

> **Trap (commitment tier dual-meter)**: Each commitment tier has TWO meters: a `Unit` flat monthly fee and a `CT Overage Transactions` per-1K rate. Query each meter separately to avoid summing both.

## Query Pattern

### Text moderation: 50K records/month

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Content Safety
SkuName: Standard
MeterName: Standard Text Records
Quantity: 50 # 50 × 1K = 50,000 text records

### Image moderation: PAYG

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Content Safety
SkuName: Standard
MeterName: Standard Images

### Commitment tier: Text Azure 1M (base fee)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Content Safety
SkuName: Commitment Tier Txt Azure 1M
MeterName: Commitment Tier Txt Azure 1M Unit

### Commitment tier: Text Azure 1M (overage)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Content Safety
SkuName: Commitment Tier Txt Azure 1M
MeterName: Commitment Tier Txt Azure 1M CT Overage Transactions

### Commitment tier: Image Azure 250K (base fee)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Content Safety
SkuName: Commitment Tier Image Azure 250K
MeterName: Commitment Tier Image Azure 250K Unit

### Commitment tier: Image Azure 250K (overage)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Content Safety
SkuName: Commitment Tier Image Azure 250K
MeterName: Commitment Tier Image Azure 250K CT Overage Transactions

## Key Fields

| Parameter     | How to determine         | Example values                                            |
| ------------- | ------------------------ | --------------------------------------------------------- |
| `serviceName` | Always `Foundry Tools`   | `Foundry Tools`                                           |
| `productName` | Deployment model         | `Content Safety`, `Content Safety - Disconnected`         |
| `skuName`     | Tier or commitment level | `Standard`, `Free`, `Commitment Tier Txt Azure 1M`       |
| `meterName`   | Billing dimension        | `Standard Text Records`, `Standard Images`                |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `Standard Text Records` | `Standard` | `1K` | PAYG text moderation |
| `Standard Images` | `Standard` | `1K` | PAYG image moderation |
| `Free Text Records` | `Free` | `1K` | 5K/month limit (hard stop) |
| `Free Images` | `Free` | `1K` | 5K/month limit (hard stop) |
| `Commitment Tier Txt Azure 1M Unit` | `Commitment Tier Txt Azure 1M` | `1/Month` | Flat fee, includes 1M text records |
| `Commitment Tier Txt Azure 1M CT Overage Transactions` | `Commitment Tier Txt Azure 1M` | `1K` | Overage beyond 1M included |
| `Commitment Tier Image Azure 250K Unit` | `Commitment Tier Image Azure 250K` | `1/Month` | Flat fee, includes 250K images |
| `Commitment Tier Image Azure 250K CT Overage Transactions` | `Commitment Tier Image Azure 250K` | `1K` | Overage beyond 250K included |

## Cost Formula

```
Transaction (1K):  Monthly = retailPrice × (transactions / 1000)
Commitment (1/Mo): Monthly = commitmentUnit_retailPrice + (overageQty × overage_retailPrice)
Annual (1/Year):   Monthly = retailPrice ÷ 12
Free grant:        Billable text = max(0, records − 5000); Billable images = max(0, images − 5000)
```

## Notes

- **Free tier**: 5K text records + 5K images/month; hard stop at limit (no overages on Free tier)
- **Commitment tiers**: Text Azure 1M + Image Azure 250K per modality; Connected (`Conn`) variants are ~5% cheaper (same query structure, substitute `Conn` for `Azure` in skuName/meterName)
- **Legacy/Disconnected**: `Content Moderator` → `Content Safety` (different tiered pricing; do NOT query). Disconnected product bills annually (`1/Year`), Global-only; divide by 12 for monthly
- **Capacity planning**: `Quantity: 1` = 1,000 transactions when `unitOfMeasure` is `1K`; text record = up to 1,000 Unicode characters
