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

> **Trap**: Sub-cent unit prices display as zero (`MonthlyCost` rounds to 2 dp). Always query in the user's target currency first. If the API returns a non-zero `UnitPrice`, use it directly (Azure publishes rounded non-USD rates that can be ~2× the direct FX conversion, e.g. AUD 0.0001 vs ~0.00005 from manual conversion). If it returns zero, fall back to the USD rate and convert via [regions-and-currencies.md](../../regions-and-currencies.md). Always explain the free grant deduction.
>
> **Trap (Flex non-USD inflation)**: For Flex Consumption On Demand Execution Time, some non-USD rates (e.g. AUD `0.0001/GB-s`) are a published floor, the lowest non-zero value the API returns, which can overstate cost by ~4× vs the USD-derived rate at high volumes. If total Flex Consumption On Demand GB-s across the estimate exceeds **1M GB-s/month** in a non-USD currency, also derive the rate from USD using [regions-and-currencies.md](../../regions-and-currencies.md). Use the API-published non-USD rate for the primary cost total; surface the USD-derived rate as an informational comparison noting the API rate may be inflated by currency rounding.

## Query Pattern

### Consumption plan meters

ServiceName: Functions
SkuName: Standard
ProductName: Functions

### Premium plan meters

ServiceName: Functions
SkuName: Premium
ProductName: Premium Functions

### Flex Consumption: Always Ready meters

ServiceName: Functions
SkuName: Always Ready
ProductName: Flex Consumption

### Flex Consumption: On Demand meters

ServiceName: Functions
SkuName: On Demand
ProductName: Flex Consumption

### Dedicated (App Service Plan)

> Functions on a Dedicated plan have **NO** `Functions` meters; billing flows through `Azure App Service`. Use app-service.md.

## Key Fields

| Parameter     | How to determine                          | Example values                                          |
| ------------- | ----------------------------------------- | ------------------------------------------------------- |
| `serviceName` | Always `Functions`                        | `Functions`                                             |
| `productName` | Plan type                                 | `Functions`, `Premium Functions`, `Flex Consumption`    |
| `skuName`     | Plan tier within product                  | `Standard`, `Premium`, `Always Ready`, `On Demand`      |
| `meterName`   | Billing dimension (executions / duration) | `Standard Total Executions`, `On Demand Execution Time` |

## Meter Names

| Plan              | Meter                                                                                     | Unit                   | Free Grant |
| ----------------- | ----------------------------------------------------------------------------------------- | ---------------------- | ---------- |
| Consumption       | `Standard Total Executions`                                                               | per 10 exec            | 1M exec    |
| Consumption       | `Standard Execution Time`                                                                 | per 1 GB-s             | 400K GB-s  |
| Premium           | `Premium vCPU Duration`                                                                   | 1 Hour                 | -          |
| Premium           | `Premium Memory Duration`                                                                 | 1 GiB Hour             | -          |
| Flex Always Ready | `Always Ready Baseline` / `Always Ready Execution Time` / `Always Ready Total Executions` | per GB-s / per 10 exec | -          |
| Flex On Demand    | `On Demand Execution Time`                                                                | per 1 GB-s             | 100K GB-s  |
| Flex On Demand    | `On Demand Total Executions`                                                              | per 10 exec            | 250K exec  |

## Cost Formula

```text
Consumption:
  Executions = (max(0, totalExecutions - 1,000,000) / 10) × execUnitPrice
  Duration   = max(0, gbSeconds - 400,000) × pricePerGBSecond
  Monthly    = Executions + Duration
Premium:
  Monthly = (vCPU_price × vCPUs × 730) + (memory_price × memoryGiB × 730)
Flex Consumption:
  Always Ready = baseline_price × idle_gbSeconds + ar_execTime_price × exec_gbSeconds + ar_exec_price × (executions / 10)
  On Demand    = max(0, on_demand_gbSeconds - 100,000) × od_execTime_price + max(0, executions - 250,000) / 10 × od_exec_price
  Monthly      = Always Ready + On Demand
Dedicated: Monthly = App Service Plan retailPrice × 730 × instanceCount (see app-service.md)
```

## Notes

- Consumption free grant (1M executions, 400K GB-s) is per subscription, shared across all Function Apps; do not deduct per app
- Convert user-specified memory to GiB by dividing MiB by 1,024 (e.g. 256 MiB = 0.25 GiB)
- Premium: billed per-second with a minimum of one instance
- Flex Consumption: free grant of 250K executions + 100K GB-s/month; Always Ready baseline charges apply even with no traffic
- **Dedicated**: no `Functions` meters exist; cost is the App Service Plan itself under `Azure App Service`; use app-service.md
- `MonthlyCost` rounds sub-cent prices to zero. Pass an explicit `Quantity` or read `UnitPrice` from JSON; private endpoints require Flex Consumption, Premium, or Dedicated plan

## Premium Plan Sizes (Elastic Premium)

| Plan | vCPUs | Memory (GiB) | Notes                                               |
| ---- | ----- | ------------ | --------------------------------------------------- |
| EP1  | 1     | 3.5          | (vCPU_price × 1 × 730) + (memory_price × 3.5 × 730) |
| EP2  | 2     | 7            | (vCPU_price × 2 × 730) + (memory_price × 7 × 730)   |
| EP3  | 4     | 14           | (vCPU_price × 4 × 730) + (memory_price × 14 × 730)  |
> **Agent instruction**: The API returns generic `Premium vCPU Duration` and `Premium Memory Duration` meters with no EP1/EP2/EP3-specific meter. When the user says "Functions Premium EP2", query `Premium Functions` for the per-vCPU and per-GiB hourly rates, then multiply by EP2 specs above.
