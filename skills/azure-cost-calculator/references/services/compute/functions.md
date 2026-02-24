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

> **Warning**: The script's `MonthlyCost` shows zero because quantity is unknown — use `UnitPrice` directly. Always explain the free grant deduction.

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

## Consumption Plan Meters

| Meter                       | Unit        | Free Grant      |
| --------------------------- | ----------- | --------------- |
| `Standard Total Executions` | per 10 exec | 1M executions   |
| `Standard Execution Time`   | per 1 GB-s  | 400K GB-seconds |

> The script's `MonthlyCost` shows zero — use `UnitPrice` directly.

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

## Premium Plan Sizes (Elastic Premium)

The API returns generic `Premium vCPU Duration` and `Premium Memory Duration` meters — NO EP1/EP2/EP3-specific meter. Multiply by plan specs below.

| Plan | vCPUs | Memory (GiB) | Monthly Formula                                     |
| ---- | ----- | ------------ | --------------------------------------------------- |
| EP1  | 1     | 3.5          | (vCPU_price × 1 × 730) + (memory_price × 3.5 × 730) |
| EP2  | 2     | 7            | (vCPU_price × 2 × 730) + (memory_price × 7 × 730)   |
| EP3  | 4     | 14           | (vCPU_price × 4 × 730) + (memory_price × 14 × 730)  |

> **Agent instruction**: When the user says "Functions Premium EP2", query `Premium Functions` for the generic per-vCPU and per-GiB hourly rates, then multiply by the EP2 specs (2 vCPU, 7 GiB) from the table above.

## Notes

- Consumption: generous free grant — many small workloads cost zero
- Premium: billed per-second with a minimum of one instance
- Flex Consumption: free grant of 250K executions + 100K GB-s/month; Always Ready baseline charges apply even with no traffic
- **Dedicated (App Service Plan)**: no `Functions` meters exist — cost is the App Service Plan itself, billed under `Azure App Service`; use app-service.md
- The script's `MonthlyCost` shows zero for Consumption/Flex because quantity is unknown — use `UnitPrice` directly
- Private endpoints require Flex Consumption, Premium, or Dedicated plan
