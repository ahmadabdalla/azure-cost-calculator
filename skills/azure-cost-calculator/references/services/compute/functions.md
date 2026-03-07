---
serviceName: Functions
category: compute
aliases: [Serverless Functions, Function App]
billingNeeds: [Storage, Azure App Service]
primaryCost: "Per-execution + GB-seconds (Consumption/Flex) or App Service Plan rate (Dedicated)"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Functions

> **Trap**: Sub-cent unit prices display as zero (`MonthlyCost` rounds to 2 dp). Always query in the user's target currency first — if the API returns a non-zero `UnitPrice`, use it directly (Azure publishes rounded non-USD rates that can be ~2× the direct FX conversion, e.g. AUD 0.0001 vs ~0.00005 from manual conversion). If it returns zero, fall back to the USD rate and convert via [regions-and-currencies.md](../../regions-and-currencies.md). Always explain the free grant deduction.
>
> **Caveat (Flex Consumption non-USD inflation)**: For Flex Consumption On Demand Execution Time, some non-USD rates (e.g. AUD `0.0001/GB-s`) are a published floor — the lowest non-zero value the API returns — which can overstate cost by ~4× vs the USD-derived rate at high volumes. If total Flex Consumption On Demand GB-s across the estimate exceeds **1M GB-s/month** in a non-USD currency, also derive the rate from USD using [regions-and-currencies.md](../../regions-and-currencies.md). Use the API-published non-USD rate for the primary cost total; surface the USD-derived rate as an informational comparison noting the API rate may be inflated by currency rounding.

## Query Pattern

### Consumption plan meters

ServiceName: Functions
SkuName: Standard
ProductName: Functions

### Premium plan meters

ServiceName: Functions
SkuName: Premium
ProductName: Premium Functions

### Flex Consumption — Always Ready meters

ServiceName: Functions
SkuName: Always Ready
ProductName: Flex Consumption

### Flex Consumption — On Demand meters (use Quantity for monthly volume)

ServiceName: Functions
SkuName: On Demand
ProductName: Flex Consumption
Quantity: 1000000

### Dedicated (App Service Plan)

> **Agent instruction**: Functions on a Dedicated plan (B1/S1/P1v3) have **NO** `Functions` meters — billing flows entirely through `Azure App Service`. Use app-service.md query patterns.

## Meter Names

| Plan              | Meter                                                           | Unit                   | Free Grant |
| ----------------- | --------------------------------------------------------------- | ---------------------- | ---------- |
| Consumption       | `Standard Total Executions`                                     | per 10 exec            | 1M exec    |
| Consumption       | `Standard Execution Time`                                       | per 1 GB-s             | 400K GB-s  |
| Premium           | `Premium vCPU Duration`                                         | 1 Hour                 | —          |
| Premium           | `Premium Memory Duration`                                       | 1 GiB Hour             | —          |
| Flex Always Ready | `Always Ready Baseline` / `Execution Time` / `Total Executions` | per GB-s / per 10 exec | —          |
| Flex On Demand    | `On Demand Execution Time`                                      | per 1 GB-s             | 100K GB-s  |
| Flex On Demand    | `On Demand Total Executions`                                    | per 10 exec            | 250K exec  |

## Cost Formula

```text
Consumption:
  Executions = (max(0, totalExecutions - 1,000,000) / 10) × execUnitPrice
  Duration   = max(0, gbSeconds - 400,000) × pricePerGBSecond
  Monthly    = Executions + Duration

Premium:
  Monthly = (vCPU_price × vCPUs × 730) + (memory_price × memoryGiB × 730)

Flex Consumption:
  Always Ready = baseline_price × idle_gbSeconds + execTime_price × exec_gbSeconds + exec_price × (executions / 10)
  On Demand    = max(0, on_demand_gbSeconds - 100,000) × execTime_price + max(0, executions - 250,000) / 10 × exec_price
  Monthly      = Always Ready + On Demand

Dedicated: Monthly = App Service Plan retailPrice × 730 × instanceCount (see app-service.md)
```

## Notes

- Consumption: generous free grant (1M executions, 400K GB-s) is per subscription, shared across all Function Apps — do not deduct per app
- Convert user-specified memory to GiB by dividing MiB by 1,024 (e.g. 256 MiB = 0.25 GiB)
- Premium: billed per-second with a minimum of one instance
- Flex Consumption: free grant of 250K executions + 100K GB-s/month; Always Ready baseline charges apply even with no traffic
- **Dedicated (App Service Plan)**: no `Functions` meters exist — cost is the App Service Plan itself, billed under `Azure App Service`; use app-service.md
- `MonthlyCost` rounds sub-cent prices to zero — pass an explicit `Quantity` or read `UnitPrice` from JSON output
- Private endpoints require Flex Consumption, Premium, or Dedicated plan

## Premium Plan Sizes (Elastic Premium)

The API returns generic `Premium vCPU Duration` and `Premium Memory Duration` meters — NO EP1/EP2/EP3-specific meter. Multiply by plan specs below.

| Plan | vCPUs | Memory (GiB) | Monthly Formula                                     |
| ---- | ----- | ------------ | --------------------------------------------------- |
| EP1  | 1     | 3.5          | (vCPU_price × 1 × 730) + (memory_price × 3.5 × 730) |
| EP2  | 2     | 7            | (vCPU_price × 2 × 730) + (memory_price × 7 × 730)   |
| EP3  | 4     | 14           | (vCPU_price × 4 × 730) + (memory_price × 14 × 730)  |

> **Agent instruction**: When the user says "Functions Premium EP2", query `Premium Functions` for the generic per-vCPU and per-GiB hourly rates, then multiply by the EP2 specs (2 vCPU, 7 GiB) from the table above.
