---
serviceName: Foundry Models
category: ai-ml
aliases: [OpenAI, GPT, Azure OpenAI, AOAI, ChatGPT, GPT-4]
---

# Azure OpenAI Service

**Primary cost**: Per-token billing (input + output tokens per 1M or 1K) — varies by model and deployment type (Global, Data Zone, Regional).

> **Trap (serviceName rebrand)**: The API `serviceName` is `Foundry Models`, NOT `Azure OpenAI Service`. Queries using `Azure OpenAI Service` return zero results. Always use `ServiceName 'Foundry Models'`.

> **Trap (inflated totals)**: An unfiltered `ServiceName 'Foundry Models'` query returns hundreds of meters across all AI Foundry models (GPT, DeepSeek, Llama, Grok, etc.). Always filter by `ProductName` to isolate OpenAI models.

> **Trap (sub-cent embeddings)**: Embedding prices are sub-cent. The script shows `$0.00` — use `Quantity` with a large value to see meaningful costs.

> **Agent instruction**: Model names change frequently. Always discover current models before querying. Run the discovery query below first, then construct pricing queries using the naming conventions documented in this file.

## Query Pattern

# Step 1: Discover current OpenAI models and SKU names

Use the explore script with SearchTerm Azure OpenAI and Top 20

# Step 2: Query a specific model — use exact productName and skuName from discovery

# Example: chat model input tokens, Global deployment, 10M tokens

ServiceName: Foundry Models
ProductName: Azure OpenAI GPT5
SkuName: GPT 5 Mini Inpt Glbl
Quantity: 10

# Embeddings — substitute discovered embedding skuName, 50M tokens (50K × 1K)

ServiceName: Foundry Models
ProductName: Azure OpenAI Embedding
SkuName: {embedding model} DZ
Quantity: 50000

## Key Fields

| Parameter     | How to determine                              | Stable pattern                                                      |
| ------------- | --------------------------------------------- | ------------------------------------------------------------------- |
| `serviceName` | Always `Foundry Models`                       | `Foundry Models`                                                    |
| `productName` | Model family — use exact value from discovery | `Azure OpenAI GPT5`, `Azure OpenAI Embedding`, `Azure OpenAI Media` |
| `skuName`     | `{model} {Inpt/outpt/inp/out} {deployment}`   | Deployment: `Glbl`, `DZone`/`Dz`/`DZ`, `regnl`                      |
| `meterName`   | skuName + ` 1M Tokens` or ` Tokens`           | Unit varies: `1M` (large models) or `1K` (small/embedding)          |

## SKU Naming Conventions

Meter names follow a predictable pattern. Use these to construct queries from discovered model names:

| Component  | Values                                                                                           | Notes                             |
| ---------- | ------------------------------------------------------------------------------------------------ | --------------------------------- |
| Direction  | `Inpt`/`inp`/`in` = input, `outpt`/`out` = output                                                | Casing varies by model family     |
| Deployment | `Glbl`/`Gl` = Global (cheapest), `DZone`/`Dz`/`DZ` = Data Zone (+10%), `regnl` = Regional (+10%) |                                   |
| Cached     | `cchd`/`cd` prefix on input meters                                                               | 50-90% discount vs standard input |
| Batch      | `Batch` in skuName                                                                               | ~50% discount, async processing   |
| Codex      | `codex` in skuName                                                                               | Code-focused variants             |

## Cost Formula

```
Monthly = (input_retailPrice × inputTokensInUnits) + (output_retailPrice × outputTokensInUnits)
```

Check `unitOfMeasure` from query results: if `1M`, divide token count by 1,000,000; if `1K`, divide by 1,000.

## Notes

- **Deployment types**: Global is cheapest, Data Zone and Regional add ~10%. Prefer Global unless data residency requires otherwise
- **Batch pricing**: ~50% discount for async workloads — meters include `Batch` in skuName
- **Provisioned throughput (PTU)**: Hourly per-unit billing under `Azure AI Foundry Provisioned Throughput Reservation` productName. Query separately — PTU is Global-only pricing
- Reserved pricing is **not available** for token-based consumption meters
- **Embeddings regional availability**: Embedding models may not be available in all regions — if a query returns zero results, try `westus` or `westeurope`
- **Media models**: Audio and image generation meters are under `Azure OpenAI Media` productName — query separately
