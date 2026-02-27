---
serviceName: Azure Speech
category: ai-ml
aliases: [Speech to Text, STT, TTS, Text to Speech, Neural TTS, Speech Services]
apiServiceName: Foundry Tools
primaryCost: "Per-hour (STT) or per-1M-characters (TTS) with commitment tiers from 2K–100K hrs/mo."
hasFreeGrant: true
privateEndpoint: true
---

# Azure Speech

> **Trap (serviceName)**: API `serviceName` is `Foundry Tools`, NOT `Azure Speech`. Always use `ServiceName: Foundry Tools` with `ProductName: Azure Speech` to isolate Speech meters.

> **Trap (no Standard SKU)**: Azure Speech has no `Standard` SKU — PAYG tier is `S1`. Querying `SkuName: Standard` returns zero results.

> **Trap (mixed units)**: Meters use 7 different `unitOfMeasure` values (`1 Hour`, `1/Hour`, `1/Day`, `1 Minute`, `1/Month`, `1K`, `1M`). The script's default `× 730` only works for `1 Hour` meters — verify `unitOfMeasure` per meter.

## Query Pattern

### Speech to Text — standard PAYG

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Speech
SkuName: S1
MeterName: S1 Speech To Text
Quantity: 100 # audio hours

### Neural Text to Speech — standard PAYG

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Speech
SkuName: S1
MeterName: S1 Neural Text To Speech Characters
Quantity: 10 # units of 1M characters

### Commitment tier — STT Azure 2K (base fee)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Speech
SkuName: Commitment Tier Speech to Text Azure 2K
MeterName: Commitment Tier Speech to Text Azure 2K Unit

## Key Fields

| Parameter     | How to determine                           | Example values                                             |
| ------------- | ------------------------------------------ | ---------------------------------------------------------- |
| `serviceName` | Always `Foundry Tools`                     | `Foundry Tools`                                            |
| `productName` | `Azure Speech` (cloud) or `- Disconnected` | `Azure Speech`                                             |
| `skuName`     | Tier + feature                             | `S1`, `Free`, `Commitment Tier Speech to Text Azure 2K`    |
| `meterName`   | SKU prefix + feature description           | `S1 Speech To Text`, `S1 Neural Text To Speech Characters` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `S1 Speech To Text` | `S1` | `1 Hour` | Core STT |
| `S1 Neural Text To Speech Characters` | `S1` | `1M` | Core Neural TTS |
| `S1 Speech Translation` | `S1` | `1 Hour` | Realtime translation |
| `S1 Speech to Text Batch` | `S1` | `1 Hour` | Batch transcription |
| `Fast Transcription Speech To Text` | `Fast Transcription` | `1 Hour` | Fast/LLM transcription |
| `Neural HD Text to Speech Characters` | `Neural HD Text to Speech` | `1M` | HD prebuilt voices |
| `S1 Custom Neural Realtime Characters` | `S1` | `1M` | Custom neural TTS |
| `S1 Text To Speech Characters` | `S1` | `1M` | Standard TTS (deprecated) |
| `Commitment Tier Speech to Text Azure 2K Unit` | `Commitment Tier Speech to Text Azure 2K` | `1/Month` | Monthly flat fee (many variants) |

## Cost Formula

```
STT hourly:    Monthly = retailPrice × audioHours
TTS block:     Monthly = retailPrice × (characters ÷ 1,000,000)
Minute meters: Monthly = retailPrice × minutesUsed
Commitment:    Monthly = commitmentUnit_retailPrice + (overageHours × overage_retailPrice)
Daily hosting: Script auto-multiplies by 30
```

## Notes

- **Free tier**: 5 audio hours STT, 0.5M Neural TTS characters, 5 hours Speech Translation per month
- **Commitment tiers**: STT (2K–100K hrs/mo), Custom STT, STT AddOn, Neural TTS (80M–4000M chars/mo) — each has Unit + CT Overage meters
- **Connected containers**: Same commitment tiers at ~95% of Azure pricing; some use abbreviated `Commit Tier` prefix
- **Disconnected containers**: `Azure Speech - Disconnected` bills annually (`1/Year`) — exclude from monthly estimates
- **Dual-unit hosting**: `S1 Custom Speech Model Hosting Unit` and `S1 Custom Voice Font Hosting Unit` each have both `1/Hour` and `1/Day` variants — use `1/Hour`
- **Voice Live API**: Token-based pricing (`1K` tokens) with sub-cent cached-token meters; 3 tiers (Lite/Std/Pro) + BYO
- **Scope**: For other AI Services domains (Language, Vision, Translator), see `ai-services.md`
