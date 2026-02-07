# Azure Functions

- **serviceName**: `Functions`
- **category**: compute
- **aliases**: [azure functions, serverless, function app]

**Consumption plan**: Execution count + execution time (GB-seconds). Free grant: 1M executions + 400K GB-s.
**Premium plan**: vCPU duration + memory duration (hourly).

> **Trap**: Consumption plan unit prices are **sub-cent** (e.g., ~$0.000016/GB-s, ~$0.0000002/execution in USD). The script displays these as `$0.00` for both `UnitPrice` and `MonthlyCost`, making it impossible to calculate costs directly from script output. You must apply the cost formula manually using the known per-unit rates below.
>
> **Agent instruction**: Do NOT report `$0.00` to the user — that is a display rounding issue. Use the Azure pricing page rates and the manual calculation example below. Always explain the free grant deduction.

## Query Pattern

```powershell
# Consumption plan meters
.\Get-AzurePricing.ps1 `
    -ServiceName 'Functions' `
    -SkuName 'Standard' `
    -ProductName 'Functions'

# Premium plan meters
.\Get-AzurePricing.ps1 `
    -ServiceName 'Functions' `
    -SkuName 'Premium' `
    -ProductName 'Premium Functions'
```

## Known Consumption Plan Rates

| Meter                       | Unit        | Published Rate (USD)  | Free Grant      |
| --------------------------- | ----------- | --------------------- | --------------- |
| `Standard Total Executions` | per 10 exec | $0.000002 per 10 exec | 1M executions   |
| `Standard Execution Time`   | per 1 GB-s  | $0.000016 per GB-s    | 400K GB-seconds |

> These rates are from the [Azure Functions pricing page](https://azure.microsoft.com/en-au/pricing/details/functions/). The API returns them but at precision below what the script rounds to — the script shows `$0.00` for both.

> **For non-USD currencies**: The API returns `$0.00` in all currencies due to rounding. Use the USD rates above and convert using either the user's known exchange rate or the ratio derived from another meter in the same region (e.g., query a VM price in both USD and the target currency to derive the conversion factor). See [regions-and-currencies.md](../../regions-and-currencies.md) for the currency derivation method.

## Manual Calculation Example

For 2M executions/month at 512 MB memory, 1 second average duration:

```
GB-seconds = 2,000,000 × 0.5 GB × 1s = 1,000,000 GB-s

Billable executions = max(0, 2,000,000 - 1,000,000) = 1,000,000
Billable GB-seconds = max(0, 1,000,000 - 400,000)   = 600,000

Execution cost = 1,000,000 × ($0.000002 / 10) = $0.20 USD
Duration cost  = 600,000 × $0.000016          = $9.60 USD
Total          = $9.80 USD/month
```

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
