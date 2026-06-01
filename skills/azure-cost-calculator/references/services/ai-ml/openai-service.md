---
serviceName: Azure OpenAI Service
apiServiceName: Foundry Models
category: ai-ml
aliases: [OpenAI, GPT, Azure OpenAI, AOAI, ChatGPT, GPT-4]
primaryCost: "Per-token billing (input + output tokens per 1M or 1K), varying by model and deployment type."
privateEndpoint: true
billingConsiderations: [Reserved Instances]
---

# Azure OpenAI Service

> **Trap (serviceName rebrand)**: The API `serviceName` is `Foundry Models`, NOT `Azure OpenAI Service`. Queries using `Azure OpenAI Service` return zero results. Always use `ServiceName 'Foundry Models'`.

> **Trap (inflated totals)**: An unfiltered `ServiceName 'Foundry Models'` query returns hundreds of meters across all AI Foundry models (GPT, DeepSeek, Llama, Grok, Mistral, Phi, Cohere, Kimi, Qwen, BFL Flux, etc.). Always filter by `ProductName` to isolate OpenAI models.

> **Trap (sub-cent embeddings)**: Embedding prices are sub-cent. The script shows minimal cost; use `Quantity` with a large value to see meaningful costs.

> **Trap (mixed units)**: `unitOfMeasure` varies across products: `1K` or `1M` for tokens, `1/Hour` for PTU, `1 Hour` (with space) for fine-tune hosting, `1 Second` for video, `1/Day` for Assistants File Search storage, `1/Month` for monthly items, `100` for DALL-E images, `1` for Sora. Watch `1/Hour` vs `1 Hour` — they are different UoMs. Always check `unitOfMeasure` per meter.

> **Trap (PTU reservations)**: Provisioned Throughput reservations use a separate `productName`: `Azure AI Foundry Provisioned Throughput Reservation`. Standard RI query patterns require a `ProductName` filter; unfiltered `PriceType: Reservation` queries under `Foundry Models` return PTU and Agent pre-purchase meters.

> **Agent instruction**: Model names change frequently. Always discover current models before querying. Run the discovery query below first, then construct pricing queries using the patterns in this file.

## Query Pattern

### Discover available models (always run first; model names change frequently)

Run explore with `SearchTerm: Azure OpenAI` and `Top: 20` to discover current models, then fill query templates below.

### Chat / completion model: substitute discovered values

ServiceName: Foundry Models <!-- cross-service -->
ProductName: {productName from discovery}
SkuName: {model} {direction} {deployment}
Quantity: 100 # units of unitOfMeasure; 100M tokens when UoM is 1M

### Embeddings: Global/Regional (substitute discovered embedding skuName)

ServiceName: Foundry Models <!-- cross-service -->
ProductName: Azure OpenAI
SkuName: {embedding model} {deployment}
Quantity: 500 # units of unitOfMeasure; 500K tokens when UoM is 1K

### Embeddings: Data Zone text-embedding-3 (separate product)

ServiceName: Foundry Models <!-- cross-service -->
ProductName: Azure OpenAI Embedding
SkuName: {text embedding 3 model} DZ
Quantity: 500 # units of unitOfMeasure; 500K tokens when UoM is 1K

## Key Fields

| Parameter     | How to determine                              | Example values                                                      |
| ------------- | --------------------------------------------- | ------------------------------------------------------------------- |
| `serviceName` | Always `Foundry Models` (see `apiServiceName`) | `Foundry Models`                                                    |
| `productName` | Model family, use exact value from discovery | `Azure OpenAI`, `Azure OpenAI GPT5`, `Azure OpenAI Reasoning`, `Azure OpenAI Media`, `Azure OpenAI Embedding`, `Azure OpenAI PP FT GPT4s`, `Azure OpenAI OSS Models`, `Azure OpenAI Free Meter` |
| `skuName`     | `{model} {direction} {deployment}`             | Deployment: `glbl`/`Gl`/`global`, `DZone`/`Dz`/`Data Zone`, `regnl`/`rgnl` |
| `meterName`   | skuName + ` 1M Tokens` or ` Tokens`           | Unit varies: `1M` (large models) or `1K` (small/embedding)          |

## Meter Names

| Meter | productName | unitOfMeasure | Notes |
| ----- | ----------- | ------------- | ----- |
| `5.4 inp Gl 1M Tokens` | `Azure OpenAI GPT5` | `1M` | Direction: inp/Inp/in=input, opt/Opt/out=output |
| `5.4 mini cd Inp Gl 1M Tokens` | `Azure OpenAI GPT5` | `1M` | `cd`/`cchd` = cached input (50-90% discount) |
| `o4-mini 0416 Inp glbl Tokens` | `Azure OpenAI Reasoning` | `1K` | Reasoning; deploy: glbl/Gl, DZone/Dz, regnl |
| `text-embedding-3-large-regional Tokens` | `Azure OpenAI` | `1K` | Embeddings `1K`; DZ: separate `Azure OpenAI Embedding` |
| `Provisioned Managed Global Unit` | `Azure OpenAI` | `1/Hour` | PTU hourly; also Regional, Data Zone variants |
| `Image-Dall-E-3 Std LowRes-regnl EP Images` | `Azure OpenAI` | `100` | Per 100 images |
| `Sora 2 dzone Second` | `Azure OpenAI Media` | `1` | Video generation per-second |

## Cost Formula

```
Monthly = (input_retailPrice × inputTokensInUnits) + (output_retailPrice × outputTokensInUnits)
```

Check `unitOfMeasure` from query results: if `1M`, divide token count by 1,000,000; if `1K`, divide by 1,000.

## Notes

- **Deployment types**: Global is cheapest, Data Zone and Regional add ~10%. Prefer Global unless data residency requires otherwise
- **Batch pricing**: ~50% discount for async workloads; meters include `Batch` in skuName
- **Provisioned throughput (PTU)**: Consumption meters under `Azure OpenAI` (`Provisioned Managed Global/Data Zone/Regional`); reservations under `Azure AI Foundry Provisioned Throughput Reservation` with 1 Month and 1 Year terms
- **Reasoning models**: o4-mini, codex-mini, o3-deep-research are under `Azure OpenAI Reasoning` productName. Query separately
- **Media models**: Audio, TTS, Sora 2 video (per-second), and GPT-Image under `Azure OpenAI Media`. Query separately
- **Fine-tuning**: Three billing dimensions: training tokens (per 1K), model hosting (per hour, charged even when idle), and inference tokens (per 1K). Current fine-tuning meters under `Azure OpenAI PP FT GPT4s` (GPT-4.1/4o, hosting via `Deployment Hosting Unit` UoM `1 Hour`) and `Azure OpenAI OSS Models` (GPT-OSS-20b/120b)
- **Third-party models**: `Foundry Models` also hosts non-OpenAI families (`Azure Deepseek Models`, `Azure Fireworks Models`, `Azure Grok Models`, `Azure Mistral Models`, `Azure Phi Models`, `Azure Llama Models`, `MAI Models`, `Cohere Models`, `Azure Kimi`, `Qwen models` (note: lowercase `m`), `Azure BFL Flux Models`). Each has its own `productName`. Query with discovery first
- **Embeddings**: Data Zone text-embedding-3 models under separate `Azure OpenAI Embedding` product (see dual query patterns above)
