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

> **Trap (inflated totals)**: An unfiltered `ServiceName 'Foundry Models'` query returns hundreds of meters across OpenAI, non-OpenAI model families, `Managed Compute`, and `Microsoft Agent Pre-Purchase Plan`. Always filter by `ProductName` to isolate Azure OpenAI pricing.

> **Trap (sub-cent embeddings)**: Embedding prices are sub-cent. The script shows minimal cost; use `Quantity` with a large value to see meaningful costs.

> **Trap (mixed units)**: `unitOfMeasure` varies widely: `Azure OpenAI GPT5` now spans both `1M` and `1K`; `Azure OpenAI Reasoning` spans `1K`, `1M`, and `1 Hour`; `Azure OpenAI Media` spans `1`, `1 Second`, `1K`, `1M`, and `1 Hour`; PTU stays `1/Hour`. Watch `1/Hour` vs `1 Hour` — they are different UoMs. Always check `unitOfMeasure` per meter.

> **Trap (PTU reservations)**: Provisioned Throughput reservations use the separate `productName` `Azure AI Foundry Provisioned Throughput Reservation` with `reservationTerm` values `1 Month` and `1 Year`. Standard RI query patterns require a `ProductName` filter; unfiltered `PriceType: Reservation` queries under `Foundry Models` also return `Microsoft Agent Pre-Purchase Plan` meters.

> **Agent instruction**: Model names change frequently. Always discover current models before querying. Run the discovery query below first, then construct pricing queries using the patterns in this file.

## Query Pattern

### Discover available models (always run first; model names change frequently)

Run explore with `SearchTerm: Azure OpenAI` and `Top: 20` to discover current models, then fill query templates below.

### Chat / completion model: substitute discovered values

ServiceName: Foundry Models
ProductName: {productName from discovery}
SkuName: {model} {direction} {deployment}
Quantity: 100 # units of unitOfMeasure; 100M tokens when UoM is 1M

### Embeddings: Global/Regional (substitute discovered embedding skuName)

ServiceName: Foundry Models
ProductName: Azure OpenAI
SkuName: {embedding model} {deployment}
Quantity: 500 # units of unitOfMeasure; 500K tokens when UoM is 1K

### Embeddings: Data Zone text-embedding-3 (separate product)

ServiceName: Foundry Models
ProductName: Azure OpenAI Embedding
SkuName: {text embedding 3 model} DZ
Quantity: 500 # units of unitOfMeasure; 500K tokens when UoM is 1K

### PTU reservations: exact reservation product

ServiceName: Foundry Models
ProductName: Azure AI Foundry Provisioned Throughput Reservation
SkuName: Provisioned Managed {Global|Data Zone|Regional}
PriceType: Reservation

> **Trap (reservation term)**: This query returns both `1 Month` and `1 Year` reservationTerm rows and the scripts have no term filter; select the term from the `ReservationTerm` output field. `1 Year` MonthlyCost is correct (prepaid ÷ 12). For `1 Month` the uom is `1/Hour`, so the scripts multiply by 730 and overcount ~730×; read `UnitPrice` as the monthly price instead.

## Key Fields

| Parameter     | How to determine                               | Example values                                                                                                                                                                                  |
| ------------- | ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `serviceName` | Always `Foundry Models` (see `apiServiceName`) | `Foundry Models`                                                                                                                                                                                |
| `productName` | Model family, use exact value from discovery   | `Azure OpenAI`, `Azure OpenAI GPT5`, `Azure OpenAI Reasoning`, `Azure OpenAI Media`, `Azure OpenAI Embedding`, `Azure OpenAI PP FT GPT4s`, `Azure OpenAI OSS Models`, `Azure OpenAI Free Meter` |
| `skuName`     | `{model} {direction} {deployment}`             | Deployment: `glbl`/`Gl`/`global`, `DZone`/`Dz`/`Data Zone`, `regnl`/`rgnl`                                                                                                                      |
| `meterName`   | skuName + ` 1M Tokens` or ` Tokens`            | Unit varies: `1M` (large models) or `1K` (small/embedding)                                                                                                                                      |

## Meter Names

| Meter                                       | productName              | unitOfMeasure | Notes                                                     |
| ------------------------------------------- | ------------------------ | ------------- | --------------------------------------------------------- |
| `5.4 inp Gl 1M Tokens`                      | `Azure OpenAI GPT5`      | `1M`          | Direction: inp/Inp/in=input, opt/Opt/out=output           |
| `gpt-5-codex-inp-glbl Tokens`               | `Azure OpenAI GPT5`      | `1K`          | GPT5 also has `1K` meters; do not assume all GPT5 is `1M` |
| `o4-mini 0416 Inp glbl Tokens`              | `Azure OpenAI Reasoning` | `1K`          | Reasoning; deploy: glbl/Gl, DZone/Dz, regnl               |
| `text-embedding-3-large-regional Tokens`    | `Azure OpenAI`           | `1K`          | Embeddings `1K`; DZ: separate `Azure OpenAI Embedding`    |
| `Provisioned Managed Global Unit`           | `Azure OpenAI`           | `1/Hour`      | PTU hourly; also Regional, Data Zone variants             |
| `Image-Dall-E-3 Std LowRes-regnl EP Images` | `Azure OpenAI`           | `100`         | Per 100 images                                            |
| `Sora 2 dzone Second`                       | `Azure OpenAI Media`     | `1`           | Video generation per-second                               |

## Cost Formula

```
Monthly = (input_retailPrice × inputTokensInUnits) + (output_retailPrice × outputTokensInUnits)
```

Check `unitOfMeasure` from query results: if `1M`, divide token count by 1,000,000; if `1K`, divide by 1,000.

## Notes

- **Deployment types**: Global is cheapest, Data Zone and Regional add ~10%. Prefer Global unless data residency requires otherwise
- **Batch pricing**: ~50% discount for async workloads; meters include `Batch` in skuName
- **Provisioned throughput (PTU)**: Consumption meters stay under `Azure OpenAI` (`Provisioned Managed Global/Data Zone/Regional`); reservations use `Azure AI Foundry Provisioned Throughput Reservation` with `1 Month` and `1 Year` terms
- **Reasoning models**: o4-mini, codex-mini, o3-deep-research are under `Azure OpenAI Reasoning` productName. Query separately
- **Media models**: Audio, TTS, Sora 2 video (per-second), and GPT-Image under `Azure OpenAI Media`. Query separately
- **Fine-tuning**: Three billing dimensions: training tokens (per 1K), model hosting (per hour, charged even when idle), and inference tokens (per 1K). Current fine-tuning meters span `Azure OpenAI PP FT GPT4s`, `Azure OpenAI OSS Models`, and `Azure OpenAI Reasoning`
- **Third-party models**: `Foundry Models` also hosts non-OpenAI families (`Azure Deepseek Models`, `Azure Fireworks Models`, `Azure Grok Models`, `Azure Mistral Models`, `Azure Phi Models`, `Azure Llama Models`, `MAI Models`, `Cohere Models`, `Azure Kimi`, `Qwen models`, `Azure BFL Flux Models`) plus `Managed Compute` and `Microsoft Agent Pre-Purchase Plan`. Query with discovery first
- **Embeddings**: Data Zone text-embedding-3 models under separate `Azure OpenAI Embedding` product (see dual query patterns above)
