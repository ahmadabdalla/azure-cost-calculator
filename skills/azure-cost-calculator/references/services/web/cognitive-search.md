---
serviceName: Azure Cognitive Search
category: web
aliases: [Azure AI Search, Search Service, Full-text Search]
primaryCost: "Fixed hourly rate per search unit (SU) × 730, varies by tier"
hasKnownRates: true
hasFreeGrant: true
privateEndpoint: true
---

# Azure AI Search

> **Trap (Inflated totals)**: Omitting `SkuName` returns all tiers, add-ons, and AI enrichment meters summed in `totalMonthlyCost`. Always include `SkuName` to isolate a single tier.

> **Trap (CC variants)**: Each tier has a customer-controlled encryption variant (e.g., `Standard S1 CC`). These are separate SKUs with ~10% higher prices; do not confuse with the standard tier.

> **Trap (Semantic Ranker MonthlyCost)**: The `Semantic Ranker Unit` meter uses `1/Day` units. The script auto-multiplies by 30, so `MonthlyCost` is already the **monthly** cost. Do NOT pass `Quantity: 30`; that would overcount by 30x. The per-query meters (`Semantic Ranker queries`, `Semantic Ranker Overage Queries`) use `1K` units and default to ×1; compute them as `queriesPerMonth ÷ 1000 × retailPrice`.

> **Trap (Agentic Retrieval sub-cent)**: The three Agentic Retrieval reasoning meters (`1K` unit) have sub-cent per-token rates, so the script rounds `MonthlyCost` to zero. Do not report zero to the user; use the Known Rates table and multiply `retailPrice × (max(0, tokens − freeGrant) ÷ 1000)`. The free grant is level-specific (see Known Rates).

## Query Pattern

### {SkuName} tier: use InstanceCount for multi-SU deployments

ServiceName: Azure Cognitive Search
SkuName: {SkuName}
MeterName: {SkuName} Unit
InstanceCount: {searchUnits}

### Semantic Ranker add-on (script auto-multiplies daily rate × 30)

ServiceName: Azure Cognitive Search
SkuName: Semantic Ranker
MeterName: Semantic Ranker Unit

### Semantic Ranker per-query (bills per 1K queries; use for queriesPerMonth)

ServiceName: Azure Cognitive Search
SkuName: Semantic Ranker
MeterName: Semantic Ranker queries
Quantity: ({queriesPerMonth} ÷ 1000)

### Agentic Retrieval (per 1K tokens; Level = Minimum, Low, or Medium)

ServiceName: Azure Cognitive Search
SkuName: Agentic Retrieval {Level} Reasoning
MeterName: Agentic Retrieval {Level} Reasoning Tokens
Quantity: ({tokens} ÷ 1000)

## Key Fields

| Parameter     | How to determine                     | Example values                                                |
| ------------- | ------------------------------------ | ------------------------------------------------------------- |
| `serviceName` | Always `Azure Cognitive Search`      | `Azure Cognitive Search`                                      |
| `productName` | Always `Azure AI Search`             | `Azure AI Search`                                             |
| `skuName`     | Tier name, selects the pricing tier  | `Basic`, `Standard S1`, `Standard S2`, `Standard S3`          |
| `meterName`   | Tier name + `Unit` suffix            | `Basic Unit`, `Standard S1 Unit`, `Storage Optimized L1 Unit` |

## Meter Names

| Meter                                       | skuName                            | unitOfMeasure | Notes                    |
| ------------------------------------------- | ---------------------------------- | ------------- | ------------------------ |
| `Free Unit`                                 | `Free`                             | `1 Hour`      | Free tier (1 index)      |
| `Basic Unit`                                | `Basic`                            | `1 Hour`      | Up to 15 indexes         |
| `Standard S1 Unit`                          | `Standard S1`                      | `1 Hour`      | Up to 50 indexes         |
| `Standard S2 Unit`                          | `Standard S2`                      | `1 Hour`      | Up to 200 indexes        |
| `Standard S3 Unit`                          | `Standard S3`                      | `1 Hour`      | Up to 1000 indexes       |
| `Storage Optimized L1 Unit`                 | `Storage Optimized L1`             | `1 Hour`      | Up to 1000 indexes       |
| `Storage Optimized L2 Unit`                 | `Storage Optimized L2`             | `1 Hour`      | Up to 1000 indexes       |
| `Semantic Ranker Unit`                      | `Semantic Ranker`                  | `1/Day`       | Daily add-on charge      |
| `Semantic Ranker queries`                   | `Semantic Ranker`                  | `1K`          | Per-query billing        |
| `Semantic Ranker Overage Queries`           | `Semantic Ranker`                  | `1K`          | Overage per-query        |
| `Agentic Retrieval Minimum Reasoning Tokens` | `Agentic Retrieval Minimum Reasoning` | `1K`    | Sub-cent per 1K tokens   |
| `Agentic Retrieval Low Reasoning Tokens`    | `Agentic Retrieval Low Reasoning`  | `1K`          | Sub-cent per 1K tokens   |
| `Agentic Retrieval Medium Reasoning Tokens` | `Agentic Retrieval Medium Reasoning` | `1K`       | Sub-cent per 1K tokens   |

AI-related add-on meters, including enrichment meters such as Document Cracking and Custom Entity Skills and token-based meters such as Agentic Retrieval, use per-1K pricing and are separate from the base tier.

## Cost Formula

```
Monthly Base  = retailPrice × 730 × searchUnits
Semantic daily (if enabled)   = semantic_daily_retailPrice × 30
Semantic queries (if enabled) = semantic_query_retailPrice × (queriesPerMonth ÷ 1000)
Agentic (if enabled)          = agentic_retailPrice × (max(0, tokens − freeGrant) ÷ 1000)
Total = Monthly Base + Semantic daily + Semantic queries + Agentic
```

## Notes

- **Storage included**: Each tier includes a fixed amount of storage per SU (Basic 2 GB, S1 25 GB, S2 100 GB, S3 200 GB, L1 1 TB, L2 2 TB). No separate storage meter.
- **Search units (SU)**: replicas × partitions. Scale replicas for query throughput and HA; scale partitions for index size. Max 36 SUs per service (12 for Basic).
- **Free tier**: 1 index, 50 MB storage, no SLA. Use `skuName='Free'`. Free Agentic Retrieval grants exist at all reasoning levels.
- **Tier limits**: Basic supports up to 3 replicas, 1 partition. Standard tiers support up to 12 replicas, 12 partitions. L1/L2 support up to 12 replicas, 12 partitions.
- **Semantic Ranker**: Billed daily, not hourly. Script auto-multiplies `1/Day` by 30. Also has per-query meters (`Semantic Ranker queries` at per-1K, `Semantic Ranker Overage Queries` at higher per-1K rate).
- **Agentic Retrieval**: Three reasoning levels (Minimum, Low, Medium) billed per 1K tokens at sub-cent rates. Free grants available.
- **Private Endpoints**: Supported on Basic tier and above. Not available on the Free tier.

## Known Rates

Sub-cent Agentic Retrieval rates the script rounds to `$0.00`. Free monthly grants apply per level (see `Free Agentic Retrieval {Level} Reasoning` SKUs); confirm current allotment on the pricing page.

| Meter                                        | Unit | Published Rate (USD) |
| -------------------------------------------- | ---- | -------------------- |
| `Agentic Retrieval Minimum Reasoning Tokens` | 1K   | $0.000022            |
| `Agentic Retrieval Low Reasoning Tokens`     | 1K   | $0.000022            |
| `Agentic Retrieval Medium Reasoning Tokens`  | 1K   | $0.0001              |
