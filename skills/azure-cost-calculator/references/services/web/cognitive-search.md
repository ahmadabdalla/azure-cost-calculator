---
serviceName: Azure Cognitive Search
category: web
aliases: [Azure AI Search, Search Service, Full-text Search]
---

# Azure AI Search

**Primary cost**: Fixed hourly rate per search unit (SU) × 730, varies by tier

> **Trap (Inflated totals)**: Omitting `-SkuName` returns all tiers, add-ons, and AI enrichment meters summed in `totalMonthlyCost`. Always include `-SkuName` to isolate a single tier.

> **Trap (CC variants)**: Each tier has a customer-controlled encryption variant (e.g., `Standard S1 CC`). These are separate SKUs with higher prices — do not confuse with the standard tier.

## Query Pattern

```powershell
# Standard S1 — 1 search unit (swap SkuName/MeterName for other tiers)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Cognitive Search' `
    -SkuName 'Standard S1' `
    -MeterName 'Standard S1 Unit'
```

```powershell
# Standard S1 — 3 search units (use -InstanceCount for multi-SU deployments)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Cognitive Search' `
    -SkuName 'Standard S1' `
    -MeterName 'Standard S1 Unit' `
    -InstanceCount 3
```

```powershell
# Semantic Ranker add-on (daily billing)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Cognitive Search' `
    -SkuName 'Semantic Ranker' `
    -MeterName 'Semantic Ranker Unit'
```

## Key Fields

| Parameter     | How to determine                        | Example values                                              |
| ------------- | --------------------------------------- | ----------------------------------------------------------- |
| `serviceName` | Always `Azure Cognitive Search`         | `Azure Cognitive Search`                                    |
| `productName` | Always `Azure AI Search`                | `Azure AI Search`                                           |
| `skuName`     | Tier name — selects the pricing tier    | `Basic`, `Standard S1`, `Standard S2`, `Standard S3`        |
| `meterName`   | Tier name + `Unit` suffix               | `Basic Unit`, `Standard S1 Unit`, `Storage Optimized L1 Unit` |

## Meter Names

| Meter                          | skuName                  | unitOfMeasure | Notes                    |
| ------------------------------ | ------------------------ | ------------- | ------------------------ |
| `Free Unit`                    | `Free`                   | `1 Hour`      | Free tier (1 index)      |
| `Basic Unit`                   | `Basic`                  | `1 Hour`      | Up to 15 indexes         |
| `Standard S1 Unit`             | `Standard S1`            | `1 Hour`      | Up to 50 indexes         |
| `Standard S2 Unit`             | `Standard S2`            | `1 Hour`      | Up to 200 indexes        |
| `Standard S3 Unit`             | `Standard S3`            | `1 Hour`      | Up to 1000 indexes       |
| `Storage Optimized L1 Unit`    | `Storage Optimized L1`   | `1 Hour`      | Up to 1000 indexes       |
| `Storage Optimized L2 Unit`    | `Storage Optimized L2`   | `1 Hour`      | Up to 1000 indexes       |
| `Semantic Ranker Unit`         | `Semantic Ranker`        | `1/Day`       | Daily add-on charge      |

AI enrichment meters (Document Cracking, Custom Entity Skills, Agentic Retrieval) are billed per 1K and are separate from the base tier.

## Cost Formula

```
Monthly Base  = retailPrice × 730 × searchUnits
Semantic (if enabled) = semantic_retailPrice × 30
Total = Monthly Base + Semantic
```

## Notes

- **Storage included**: Each tier includes a fixed amount of storage per SU (e.g., Basic 2 GB, S1 25 GB, S2 100 GB, L1 1 TB). No separate storage meter.
- **Search units (SU)**: replicas × partitions. Scale replicas for query throughput and HA; scale partitions for index size. Max 36 SUs per service (12 for Basic).
- **Free tier**: 1 index, 50 MB storage, no SLA. Use `skuName='Free'`.
- **No reserved pricing**: RI queries return zero results. Do not attempt `-PriceType Reservation`.
- **Tier limits**: Basic supports up to 3 replicas, 1 partition. Standard tiers support up to 12 replicas, 12 partitions. L1/L2 support up to 12 replicas, 12 partitions.
- **Semantic Ranker**: Billed daily, not hourly. Formula: `retailPrice × 30`. Also has per-query overage meters (`Semantic Ranker queries`, `Semantic Ranker Overage Queries`).
