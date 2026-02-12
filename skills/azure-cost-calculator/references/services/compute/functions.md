---
serviceName: Functions
category: compute
aliases: [azure functions, serverless, function app]
---

# Azure Functions

**Primary cost**: Execution count + execution time (GB-seconds)

**Consumption plan**: Execution count + execution time (GB-seconds). Free grant: 1M executions + 400K GB-s.
**Premium plan**: vCPU duration + memory duration (hourly).

> **Warning**: **Sub-cent pricing** — see shared.md & Common Traps. The script's `MonthlyCost` shows `$0` because quantity is unknown — use the `UnitPrice` from API results directly. Always explain the free grant deduction.

## Query Pattern

### Consumption plan meters

ServiceName: Functions
SkuName: Standard
ProductName: Functions

### Premium plan meters

ServiceName: Functions
SkuName: Premium
ProductName: Premium Functions

## Consumption Plan Meters

| Meter                       | Unit        | Free Grant      |
| --------------------------- | ----------- | --------------- |
| `Standard Total Executions` | per 10 exec | 1M executions   |
| `Standard Execution Time`   | per 1 GB-s  | 400K GB-seconds |

> Query the API for current `UnitPrice` values. The script's `MonthlyCost` shows `$0` because it cannot infer quantity — use `UnitPrice` directly in your calculation.

> **For non-USD currencies**: Sub-cent rates may not convert cleanly — see shared.md & Common Traps.

## Cost Formula

```
Consumption Plan:
  Executions = max(0, totalExecutions - 1,000,000) × pricePerExecution
  Duration   = max(0, gbSeconds - 400,000) × pricePerGBSecond
  Monthly    = Executions + Duration

Premium Plan:
  Monthly = (vCPU_price × 730) + (memory_price_per_GiB × memoryGB × 730)
```

## Premium Plan Sizes (Elastic Premium)

The API returns generic `Premium vCPU Duration` and `Premium Memory Duration` meters — there is NO EP1/EP2/EP3-specific meter. You must know the plan's vCPU and memory allocation to calculate correctly.

| Plan | vCPUs | Memory (GiB) | Monthly Formula                                     |
| ---- | ----- | ------------ | --------------------------------------------------- |
| EP1  | 1     | 3.5          | (vCPU_price × 1 × 730) + (memory_price × 3.5 × 730) |
| EP2  | 2     | 7            | (vCPU_price × 2 × 730) + (memory_price × 7 × 730)   |
| EP3  | 4     | 14           | (vCPU_price × 4 × 730) + (memory_price × 14 × 730)  |

> **Agent instruction**: When the user says "Functions Premium EP2", query `Premium Functions` for the generic per-vCPU and per-GiB hourly rates, then multiply by the EP2 specs (2 vCPU, 7 GiB) from the table above.

## Notes

- Consumption plan has a generous free grant — many small workloads cost $0
- Premium plan is billed per-second with a minimum of one instance
- The script's `MonthlyCost` shows `$0` for Consumption because quantity is unknown — use `UnitPrice` directly

## Manual Calculation Example

For 2M executions/month at 512 MB memory, 1 second average duration:

```
GB-seconds = 2,000,000 × 0.5 GB × 1s = 1,000,000 GB-s

Billable executions = max(0, 2,000,000 - 1,000,000) = 1,000,000
Billable GB-seconds = max(0, 1,000,000 - 400,000)   = 600,000

Execution cost = billable_executions × (executions_UnitPrice / 10)
Duration cost  = billable_GB_seconds × execution_time_UnitPrice
Total          = Execution cost + Duration cost
```

> Query API for `Standard Total Executions` and `Standard Execution Time` UnitPrice values.
