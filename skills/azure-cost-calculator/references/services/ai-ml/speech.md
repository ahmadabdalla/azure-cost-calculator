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

> **Trap (no Standard SKU)**: Azure Speech has no `Standard` SKU; PAYG tier is `S1`. Querying `SkuName: Standard` returns zero results.

> **Trap (mixed units)**: Cloud `Azure Speech` meters use 7 `unitOfMeasure` values (`1 Hour`, `1/Hour`, `1/Day`, `1 Minute`, `1/Month`, `1K`, `1M`). `1/Year` belongs to `Azure Speech - Disconnected`. The script's default `× 730` only works for `1 Hour` meters.

> **Trap (commitment components)**: Commitment SKUs have separate `Unit` and `CT Overage` meters. Query both exact meters and never apply `× 730` to `1/Month` charges.

## Query Pattern

### Speech to Text: standard PAYG

ServiceName: Foundry Tools
ProductName: Azure Speech
SkuName: S1
MeterName: S1 Speech To Text
Quantity: 100 # audio hours

### Neural Text to Speech: standard PAYG

ServiceName: Foundry Tools
ProductName: Azure Speech
SkuName: S1
MeterName: S1 Neural Text To Speech Characters
Quantity: 10 # units of 1M characters

### Commitment tier: STT Azure 2K (base fee)

ServiceName: Foundry Tools
ProductName: Azure Speech
SkuName: Commitment Tier Speech to Text Azure 2K
MeterName: Commitment Tier Speech to Text Azure 2K Unit

### Commitment tier: STT Azure 2K (overage)

ServiceName: Foundry Tools
ProductName: Azure Speech
SkuName: Commitment Tier Speech to Text Azure 2K
MeterName: Commitment Tier Speech to Text Azure 2K Speech To Text CT Overage

### Fast Transcription

ServiceName: Foundry Tools
ProductName: Azure Speech
SkuName: Fast Transcription
MeterName: Fast Transcription Speech To Text
Quantity: 100 # audio hours

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
| `S1 Custom Speech to Text Batch` | `S1` | `1 Hour` | Custom batch transcription |
| `Fast Transcription Speech To Text` | `Fast Transcription` | `1 Hour` | Fast/LLM transcription; also `Custom - Fast Transcription` SKU |
| `Custom - Fast Transcription Speech To Text` | `Custom - Fast Transcription` | `1 Hour` | Custom model fast transcription (higher rate) |
| `S1 Speaker Identification Transactions` | `S1` | `1K` | Speaker recognition identification |
| `S1 Speaker Verification Transactions` | `S1` | `1K` | Speaker recognition verification |
| `Neural HD Text to Speech Characters` | `Neural HD Text to Speech` | `1M` | HD prebuilt voices |
| `S1 Custom Neural Realtime Characters` | `S1` | `1M` | Custom neural TTS |
| `S1 Text To Speech Characters` | `S1` | `1M` | Standard non-neural TTS |
| `S1 Custom Speech Model Hosting Unit` | `S1` | `1/Hour`, `1/Day` | Custom STT model hosting (dual-unit) |
| `S1 Custom Voice Font Hosting Unit` | `S1` | `1/Hour`, `1/Day` | Custom voice hosting (dual-unit) |
| `S1 Custom Neural Voice Model Hosting Unit` | `S1` | `1/Hour` | Custom neural voice hosting (no 1/Day variant) |
| `TTS Standard Avatar Realtime Speech` | `TTS Standard Avatar Realtime` | `1 Minute` | Avatar; also Custom variant |
| `Voice Live API Std - Standard Speech Audio Input Tokens` | `Voice Live API Std` | `1K` | Voice Live API; docs may call this tier Basic |
| `CNV Neural HD Synthesis Characters` | `CNV Neural HD Synthesis` | `1M` | Custom Neural Voice HD synthesis |
| `Commitment Tier Speech to Text Azure 2K Unit` | `Commitment Tier Speech to Text Azure 2K` | `1/Month` | Monthly flat fee (many variants) |
| `Commitment Tier Speech to Text Azure 2K Speech To Text CT Overage` | `Commitment Tier Speech to Text Azure 2K` | `1 Hour` | Overage beyond included STT hours |

## Cost Formula

```
STT hourly:    Monthly = retailPrice × audioHours
TTS block:     Monthly = retailPrice × (characters ÷ 1,000,000)
Minute meters: Monthly = retailPrice × minutesUsed
Commitment:    Monthly = commitmentUnit_retailPrice + (overageHours × overage_retailPrice)
Hosting (1/Hour): Monthly = retailPrice × 730
Hosting (1/Day):  Monthly = retailPrice × 30
```

## Notes

- **Free tier**: 5 realtime STT audio hours/month shared across Standard + Custom (batch excluded), 0.5M Neural TTS characters, and 5 hours Speech Translation
- **Commitment tiers**: STT (2K–100K hrs/mo), Custom STT, STT AddOn, Neural TTS (80M–4000M chars/mo); each has `Unit` + `CT Overage` meters
- **Containers**: Connected tiers use `Commit Tier` or `Commitment Tier ... Connected`; `Azure Speech - Disconnected` bills annually (`1/Year`) and should stay separate from monthly cloud estimates
- **Dual-unit hosting**: Custom Speech Model Hosting and Custom Voice Font Hosting have `1/Hour` (×730) and `1/Day` (×30) variants
- **Voice Live API**: Token-based pricing (`1K` tokens) with sub-cent cached-token meters; query exact `Lite`, `Std`, `Pro`, or `BYO` meter names
- **Capacity planning**: Collect audio hours, character volume, selected feature (STT, TTS, Avatar, Voice Live), and tier before estimating
- **Additional features**: Live Interpreter, Personal Voice, Voice Conversion, and Avatar each have distinct SKUs and can bill per minute, hour, or token block
- **Scope**: For other AI Services domains (Language, Vision, Translator), see `ai-services.md`
