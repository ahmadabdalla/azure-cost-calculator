---
serviceName: Intelligent Recommendations
category: ai-ml
aliases: [Recommendations, Personalization]
primaryCost: "Token-based billing for Serving (inference) and Modelling (training)"
hasKnownRates: true
retired: true
---

# Intelligent Recommendations

> **Warning**: Intelligent Recommendations **retired March 31, 2026**. The API endpoint is decommissioned and may return stale data or errors. Do NOT attempt pricing queries. No equivalent Microsoft service is available.

> **Agent instruction**: This service is retired. Do NOT run any pricing scripts or API queries. Inform the user that the service was decommissioned on March 31, 2026 and cost estimation is no longer available.

## Query Pattern

### Serving: inference tokens (1M tokens/month)

ServiceName: Intelligent Recommendations
ProductName: Intelligent Recommendations
SkuName: Serving
MeterName: Serving Request Token
Quantity: 1000000

### Modelling: training tokens (100K tokens/month)

ServiceName: Intelligent Recommendations
ProductName: Intelligent Recommendations
SkuName: Modelling
MeterName: Modelling Token
Quantity: 100000

### All meters: discovery query

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
| `Serving Request Usage`  | `Serving`   | `1`           | Tracking meter, zero price     |
| `Modelling Usage`        | `Modelling` | `1`           | Tracking meter, zero price     |

## Cost Formula

```
Serving Monthly   = serving_token_retailPrice × serving_tokens
Modelling Monthly = modelling_token_retailPrice × modelling_tokens
Total Monthly     = Serving Monthly + Modelling Monthly
```

## Notes

- **Retired**: Service was decommissioned March 31, 2026. No new deployments; API endpoint is no longer active
- Two SKU categories: **Serving** (inference) and **Modelling** (training); each has a token meter and a tracking meter
- Only token meters (`Serving Request Token`, `Modelling Token`) generate billable cost
- Usage meters (`Serving Request Usage`, `Modelling Usage`) are zero-price tracking meters. Exclude from estimates
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

> These rates were from the [Azure pricing page](https://azure.microsoft.com/pricing/details/intelligent-recommendations/) prior to service retirement. The service was decommissioned March 31, 2026; API queries may return stale or no data.
