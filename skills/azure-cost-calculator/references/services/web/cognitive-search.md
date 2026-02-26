---
serviceName: Azure Cognitive Search
category: web
aliases: [Azure AI Search, Search Service, Full-text Search]
primaryCost: "Fixed hourly rate per search unit (SU) × 730, varies by tier"
hasFreeGrant: true
privateEndpoint: true
---

# Azure AI Search

> **Trap (Inflated totals)**: Omitting `SkuName` returns all tiers, add-ons, and AI enrichment meters summed in `totalMonthlyCost`. Always include `SkuName` to isolate a single tier.

> **Trap (CC variants)**: Each tier has a customer-controlled encryption variant (e.g., `Standard S1 CC`). These are separate SKUs with higher prices — do not confuse with the standard tier.

> **Trap (Semantic Ranker MonthlyCost)**: The Semantic Ranker meter uses `1/Day` units. The script now auto-multiplies by 30, so `MonthlyCost` is already the **monthly** cost. Do NOT pass `Quantity: 30` — that would overcount by 30x.

## Query Pattern

### {SkuName} tier — use InstanceCount for multi-SU deployments

ServiceName: Azure Cognitive Search
SkuName: {SkuName}
MeterName: {SkuName} Unit
InstanceCount: {searchUnits}

### Semantic Ranker add-on (script auto-multiplies daily rate × 30)

ServiceName: Azure Cognitive Search
SkuName: Semantic Ranker
MeterName: Semantic Ranker Unit

## Key Fields

| Parameter     | How to determine                     | Example values                                                |
| ------------- | ------------------------------------ | ------------------------------------------------------------- |
| `serviceName` | Always `Azure Cognitive Search`      | `Azure Cognitive Search`                                      |
| `productName` | Always `Azure AI Search`             | `Azure AI Search`                                             |
| `skuName`     | Tier name — selects the pricing tier | `Basic`, `Standard S1`, `Standard S2`, `Standard S3`          |
| `meterName`   | Tier name + `Unit` suffix            | `Basic Unit`, `Standard S1 Unit`, `Storage Optimized L1 Unit` |

## Meter Names

| Meter                       | skuName                | unitOfMeasure | Notes               |
| --------------------------- | ---------------------- | ------------- | ------------------- |
| `Free Unit`                 | `Free`                 | `1 Hour`      | Free tier (1 index) |
| `Basic Unit`                | `Basic`                | `1 Hour`      | Up to 15 indexes    |
| `Standard S1 Unit`          | `Standard S1`          | `1 Hour`      | Up to 50 indexes    |
| `Standard S2 Unit`          | `Standard S2`          | `1 Hour`      | Up to 200 indexes   |
| `Standard S3 Unit`          | `Standard S3`          | `1 Hour`      | Up to 1000 indexes  |
| `Storage Optimized L1 Unit` | `Storage Optimized L1` | `1 Hour`      | Up to 1000 indexes  |
| `Storage Optimized L2 Unit` | `Storage Optimized L2` | `1 Hour`      | Up to 1000 indexes  |
| `Semantic Ranker Unit`      | `Semantic Ranker`      | `1/Day`       | Daily add-on charge |

AI enrichment meters (Document Cracking, Custom Entity Skills, Agentic Retrieval) are billed per 1K and are separate from the base tier.

## Cost Formula

```
Monthly Base  = retailPrice × 730 × searchUnits
Semantic (if enabled) = semantic_retailPrice × 30
Total = Monthly Base + Semantic
```

## Notes

- **Storage included**: Each tier includes a fixed amount of storage per SU (Basic 2 GB, S1 25 GB, S2 100 GB, S3 200 GB, L1 1 TB, L2 2 TB). No separate storage meter.
- **Search units (SU)**: replicas × partitions. Scale replicas for query throughput and HA; scale partitions for index size. Max 36 SUs per service (12 for Basic).
- **Free tier**: 1 index, 50 MB storage, no SLA. Use `skuName='Free'`.
- **Tier limits**: Basic supports up to 3 replicas, 1 partition. Standard tiers support up to 12 replicas, 12 partitions. L1/L2 support up to 12 replicas, 12 partitions.
- **Semantic Ranker**: Billed daily, not hourly. Script auto-multiplies `1/Day` by 30. Also has per-query overage meters (`Semantic Ranker queries`, `Semantic Ranker Overage Queries`).
- **Private Endpoints**: Supported on Basic tier and above — not available on the Free tier.
