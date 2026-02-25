---
serviceName: Intelligent Recommendations
category: ai-ml
aliases: [Recommendations, Personalization]
primaryCost: "Token-based billing for Serving (inference) and Modelling (training)"
hasKnownRates: true
---

# Intelligent Recommendations

> **Warning**: Intelligent Recommendations **retires March 31, 2026**. No equivalent Microsoft service is available — plan for migration or decommissioning before shutdown.

> **Trap (sub-cent pricing)**: `Serving Request Token` has sub-cent per-token pricing — the script displays zero cost. Use the Known Rates table or large `Quantity` values (e.g., 1000000) for accurate estimates.

> **Trap (tracking meters)**: `Serving Request Usage` and `Modelling Usage` return zero price — these are tracking/included-quantity meters, not billable. Only `Serving Request Token` and `Modelling Token` generate cost.

> **Agent instruction**: Do NOT report zero cost to the user for token meters. Use Known Rates table values and multiply by expected token volume.

## Query Pattern

### Serving — inference tokens (1M tokens/month)

ServiceName: Intelligent Recommendations
ProductName: Intelligent Recommendations
SkuName: Serving
MeterName: Serving Request Token
Quantity: 1000000

### Modelling — training tokens (100K tokens/month)

ServiceName: Intelligent Recommendations
ProductName: Intelligent Recommendations
SkuName: Modelling
MeterName: Modelling Token
Quantity: 100000

### All meters — discovery query

ServiceName: Intelligent Recommendations

## Key Fields

| Parameter     | How to determine                  | Example values                  |
| ------------- | --------------------------------- | ------------------------------- |
| `serviceName` | Always `Intelligent Recommendations` | `Intelligent Recommendations` |
| `productName` | Always `Intelligent Recommendations` | `Intelligent Recommendations` |
| `skuName`     | Component: inference or training  | `Serving`, `Modelling`          |
| `meterName`   | Billing dimension                 | `Serving Request Token`, `Modelling Token` |

## Meter Names

| Meter                    | skuName     | unitOfMeasure | Notes                          |
| ------------------------ | ----------- | ------------- | ------------------------------ |
| `Serving Request Token`  | `Serving`   | `1`           | Per-token inference cost       |
| `Modelling Token`        | `Modelling` | `1`           | Per-token training cost        |
| `Serving Request Usage`  | `Serving`   | `1`           | Tracking meter — zero price    |
| `Modelling Usage`        | `Modelling` | `1`           | Tracking meter — zero price    |

## Cost Formula

```
Serving Monthly   = serving_token_retailPrice × serving_tokens
Modelling Monthly = modelling_token_retailPrice × modelling_tokens
Total Monthly     = Serving Monthly + Modelling Monthly
```

## Notes

- Two SKU categories: **Serving** (inference) and **Modelling** (training) — each has a token meter and a tracking meter
- Only token meters (`Serving Request Token`, `Modelling Token`) generate billable cost
- Usage meters (`Serving Request Usage`, `Modelling Usage`) are zero-price tracking meters — exclude from estimates
- Single `productName`: all meters share `Intelligent Recommendations`

## Known Rates

| Meter                   | Unit      | Published Rate (USD) |
| ----------------------- | --------- | -------------------- |
| `Serving Request Token` | Per token | $0.000001            |
| `Modelling Token`       | Per token | $0.01                |

## Manual Calculation Example

For 5M serving tokens + 200K modelling tokens per month:

```
Serving   = 5,000,000 × serving_token_retailPrice
Modelling = 200,000 × modelling_token_retailPrice
Total     = Serving + Modelling
```

> Use rates from the Known Rates table above or query the API for `Serving Request Token` and `Modelling Token` retailPrice values.
