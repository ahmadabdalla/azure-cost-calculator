---
serviceName: Foundry Models
category: ai-ml
aliases: [OpenAI, GPT, Azure OpenAI, AOAI, ChatGPT, GPT-4]
billingConsiderations: [Reserved Instances]
primaryCost: "Per-token billing (input + output tokens per 1M or 1K) — varies by model and deployment type."
privateEndpoint: true
---

# Azure OpenAI Service

> **Trap (serviceName rebrand)**: The API `serviceName` is `Foundry Models`, NOT `Azure OpenAI Service`. Queries using `Azure OpenAI Service` return zero results. Always use `ServiceName 'Foundry Models'`.

> **Trap (inflated totals)**: An unfiltered `ServiceName 'Foundry Models'` query returns hundreds of meters across all AI Foundry models (GPT, DeepSeek, Llama, Grok, Mistral, Phi, Cohere, Kimi, Qwen, BFL Flux, etc.). Always filter by `ProductName` to isolate OpenAI models.

> **Trap (sub-cent embeddings)**: Embedding prices are sub-cent. The script shows minimal cost — use `Quantity` with a large value to see meaningful costs.

> **Trap (mixed units)**: `unitOfMeasure` varies across products — `1K` or `1M` for tokens, `1/Hour` for PTU, `100` for DALL-E images, `1` for Sora video seconds. Always check `unitOfMeasure` per meter.

> **Agent instruction**: Model names change frequently. Always discover current models before querying. Run the discovery query below first, then construct pricing queries using the naming conventions documented in this file.

## Query Pattern

### Discover available models (always run first — model names change frequently)

SearchTerm: Azure OpenAI
Top: 20

### Chat / completion model — substitute discovered values

ServiceName: Foundry Models
ProductName: {productName from discovery}
SkuName: {model} {direction} {deployment}
Quantity: {tokenCount in units matching unitOfMeasure}

### Embeddings — Global/Regional (substitute discovered embedding skuName)

ServiceName: Foundry Models
ProductName: Azure OpenAI
SkuName: {embedding model} {deployment}
Quantity: {tokenCount in units matching unitOfMeasure}

### Embeddings — Data Zone text-embedding-3 (separate product)

ServiceName: Foundry Models
ProductName: Azure OpenAI Embedding
SkuName: {text embedding 3 model} DZ
Quantity: {tokenCount in units matching unitOfMeasure}

## Key Fields

| Parameter     | How to determine                              | Stable pattern                                                      |
| ------------- | --------------------------------------------- | ------------------------------------------------------------------- |
| `serviceName` | Always `Foundry Models`                       | `Foundry Models`                                                    |
| `productName` | Model family — use exact value from discovery | `Azure OpenAI`, `Azure OpenAI GPT5`, `Azure OpenAI Reasoning`, `Azure OpenAI Media`, `Azure OpenAI Embedding` |
| `skuName`     | `{model} {direction} {deployment}`             | Deployment: `glbl`/`Gl`/`global`, `DZone`/`Dz`/`Data Zone`, `regnl`/`rgnl` |
| `meterName`   | skuName + ` 1M Tokens` or ` Tokens`           | Unit varies: `1M` (large models) or `1K` (small/embedding)          |

## SKU Naming Conventions

Meter names follow a predictable pattern. Use these to construct queries from discovered model names:

| Component  | Values                                                                                           | Notes                             |
| ---------- | ------------------------------------------------------------------------------------------------ | --------------------------------- |
| Direction  | `Inpt`/`Inp`/`inp`/`Input`/`in` = input, `outpt`/`Outp`/`out`/`Output` = output                  | Casing varies by model family     |
| Deployment | `glbl`/`Gl`/`global` = Global (cheapest), `DZone`/`Dz`/`DZ`/`Data Zone` = Data Zone (+10%), `regnl`/`rgnl` = Regional (+10%) | |
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
- **Provisioned throughput (PTU)**: Consumption meters under `Azure OpenAI` (`Provisioned Managed Global/Data Zone/Regional`); reservations under `Azure AI Foundry Provisioned Throughput Reservation` with 1 Month and 1 Year terms
- **Reasoning models**: o4-mini, codex-mini, o3-deep-research are under `Azure OpenAI Reasoning` productName — query separately
- **Media models**: Audio, TTS, Sora 2 video (per-second), and GPT-Image under `Azure OpenAI Media` — query separately
- **Fine-tuning**: Three billing dimensions — training tokens (per 1K), model hosting (per hour, charged even when idle), and inference tokens (per 1K)
- **Third-party models**: `Foundry Models` also hosts non-OpenAI families (`Azure Deepseek Models`, `Azure Grok Models`, `Azure Mistral Models`, `Azure Phi Models`, `Azure Llama Models`, `Cohere Models`, `Azure Kimi`, `Qwen models` (note: lowercase `m`), `Azure BFL Flux Models`). Each has its own `productName` — query with discovery first
- **Embeddings**: Data Zone text-embedding-3 models under separate `Azure OpenAI Embedding` product — see dual query patterns above
