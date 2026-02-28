---
serviceName: Azure Video Indexer
category: ai-ml
aliases: [Video AI, Media Indexer, Video Analysis]
apiServiceName: Foundry Tools
primaryCost: "Per-minute audio/video analysis — separate meters per preset tier; no commitment tiers."
---

# Azure Video Indexer

> **Trap (serviceName)**: API `serviceName` is `Foundry Tools`, NOT `Azure Video Indexer`. Always use `ServiceName: Foundry Tools` with `ProductName: Azure Video Indexer` to isolate Video Indexer meters.

> **Trap (unitOfMeasure)**: All meters use `unitOfMeasure: "1"`, which the pricing scripts treat as unitless (monthly multiplier `1`, not `730`). Always set `Quantity` to the number of content-minutes processed.

> **Trap (legacy meters)**: The API returns 3 legacy meters (without "Indexing" in the name) alongside 7 current meters. Always filter by `SkuName` or `MeterName` to avoid mixing legacy and current presets.

## Query Pattern

### Basic Audio Indexing — 1,000 minutes/month

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Video Indexer
SkuName: Basic Audio Indexing Analysis
MeterName: Basic Audio Indexing Analysis Input Content Minutes
Quantity: 1000 # minutes of audio content

### Basic Video Indexing — 1,000 minutes/month

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Video Indexer
SkuName: Basic Video Indexing Analysis
MeterName: Basic Video Indexing Analysis Input Content Minutes
Quantity: 1000 # minutes of video content

### Advanced Video Indexing

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Video Indexer
SkuName: Advanced Video Indexing Analysis
MeterName: Advanced Video Indexing Analysis Input Content Minutes

### Video Modification (face redaction / encoding)

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Video Indexer
SkuName: Video Modification
MeterName: Video Modification Input Content Minutes

## Key Fields

| Parameter     | How to determine                 | Example values                                                     |
| ------------- | -------------------------------- | ------------------------------------------------------------------ |
| `serviceName` | Always `Foundry Tools`           | `Foundry Tools`                                                    |
| `productName` | Always `Azure Video Indexer`     | `Azure Video Indexer`                                              |
| `skuName`     | Preset tier — matches meter name | `Basic Audio Indexing Analysis`, `Advanced Video Indexing Analysis` |
| `meterName`   | Preset + "Input Content Minutes" | `Basic Audio Indexing Analysis Input Content Minutes`               |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `Basic Audio Indexing Analysis Input Content Minutes` | `Basic Audio Indexing Analysis` | `1` | Transcription, translation, captions |
| `Standard Audio Indexing Analysis Input Content Minutes` | `Standard Audio Indexing Analysis` | `1` | Basic + speakers, sentiment, NER |
| `Advanced Audio Indexing Analysis Input Content Minutes` | `Advanced Audio Indexing Analysis` | `1` | All audio AI models |
| `Basic Video Indexing Analysis Input Content Minutes` | `Basic Video Indexing Analysis` | `1` | Objects, labels, OCR, keyframes |
| `Standard Video Indexing Analysis Input Content Minutes` | `Standard Video Indexing Analysis` | `1` | Basic + face recognition, celebrities |
| `Advanced Video Indexing Analysis Input Content Minutes` | `Advanced Video Indexing Analysis` | `1` | All video AI models |
| `Video Modification Input Content Minutes` | `Video Modification` | `1` | Face redaction + encoding |
| `Basic Audio Analysis Input Content Minutes` | `Basic Audio Analysis` | `1` | Legacy — use Basic Audio Indexing |
| `Standard Audio Analysis Input Content Minutes` | `Standard Audio Analysis` | `1` | Legacy — use Advanced Audio Indexing |
| `Standard Video Analysis Input Content Minutes` | `Standard Video Analysis` | `1` | Legacy — use Advanced Video Indexing |

## Cost Formula

```
Per-minute:      Monthly = retailPrice × minutes_processed
Combined A+V:    Monthly = (audio_retailPrice × minutes) + (video_retailPrice × minutes)
With modification: Total = audio + video + (modification_retailPrice × modified_minutes)
```

## Notes

- **Free trial**: Account-level only (10 hrs website, 40 hrs API) — not an API meter; do not deduct from estimates
- **No commitment tiers**: Unlike other Foundry Tools sub-services, Video Indexer has no volume commitments or RI
- **Audio + Video billed separately**: Indexing a video with both audio and video analysis incurs two charges — query each preset and sum
- **Legacy meters**: 3 legacy presets (Basic Audio Analysis, Standard Audio Analysis, Standard Video Analysis) remain in the API but are absent from the pricing page — use current "Indexing" equivalents for new estimates
- **Regional availability**: Basic Video Indexing Analysis is unavailable in 6 regions (brazilsoutheast, jioindiawest, koreasouth, and 3 US Gov regions)
- **Arc-enabled**: Same pricing as cloud; only Basic Audio and Basic Video Indexing presets are supported on Arc
- **Capacity planning**: `Quantity: 1` = 1 minute of content processed; typical media library: estimate total content-minutes across all files
- **Scope**: Part of Foundry Tools (AI Services) — see `ai-services.md` for umbrella patterns and other sub-services
