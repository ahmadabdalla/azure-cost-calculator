# Container Apps

**Primary cost**: vCPU seconds + memory GiB seconds (Consumption plan) or vCPU hours + memory GiB hours (Dedicated plan)

> **Trap (verified 2026-02-06)**: Querying without `-SkuName` returns **13 meters** across 4 SKU types (`Standard`, `Dedicated`, `Hybrid`, `Dynamic Sessions`) including a GPU meter at $6,666/mo. Always filter by `-SkuName`. Additionally, Consumption (`Standard`) meters show `$0.00` because pricing is per-second — the same sub-cent precision trap as Azure Functions.
>
> **Agent instruction**: For always-on workloads, use the `Dedicated` SKU query (prices display correctly). For Consumption (`Standard`), the script shows `$0.00` — use the published Azure per-second rates and the cost formula below instead. Always ask whether the workload is always-on or event-driven to pick the right SKU.

## Query Pattern

```powershell
# Consumption plan (Standard SKU) — per-second pricing
# WARNING: UnitPrice shows $0.00 due to sub-cent precision
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Container Apps' `
    -ProductName 'Azure Container Apps' `
    -SkuName 'Standard'

# Dedicated plan — per-hour pricing (works correctly)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Container Apps' `
    -ProductName 'Azure Container Apps' `
    -SkuName 'Dedicated'
```

## SKU Selection Guide

| Workload Type                   | SKU         | Pricing Model | Notes                                    |
| ------------------------------- | ----------- | ------------- | ---------------------------------------- |
| Scale-to-zero, event-driven     | `Standard`  | Per-second    | Free grant: 180K vCPU-s + 360K GiB-s/mo  |
| Always-on, minimum replicas > 0 | `Dedicated` | Per-hour      | Use for background workers, ML pipelines |
| Hybrid (on-prem connected)      | `Hybrid`    | Per-hour      | For Arc-enabled environments             |

## Meter Names (verified 2026-02-06)

### Dedicated Plan (recommended for always-on workloads)

| Meter                       | unitOfMeasure | Notes                    |
| --------------------------- | ------------- | ------------------------ |
| `Dedicated vCPU Usage`      | 1 Hour        | Per vCPU per hour        |
| `Dedicated Memory Usage`    | 1 Hour        | Per GiB per hour         |
| `Dedicated Plan Management` | 1 Hour        | Per environment (shared) |
| `Dedicated GPU Usage`       | 1 Hour        | GPU workloads only       |

### Consumption Plan (Standard)

| Meter                          | unitOfMeasure | Notes                   |
| ------------------------------ | ------------- | ----------------------- |
| `Standard vCPU Active Usage`   | 1 Second      | Shows $0.00 — sub-cent  |
| `Standard vCPU Idle Usage`     | 1 Second      | Shows $0.00 — sub-cent  |
| `Standard Memory Active Usage` | 1 GiB Second  | Shows $0.00 — sub-cent  |
| `Standard Memory Idle Usage`   | 1 GiB Second  | Shows $0.00 — sub-cent  |
| `Standard Requests`            | 1M            | $0.5716 per 1M requests |

> **Note**: The `Standard Requests` meter is the ONLY Consumption plan meter that returns a non-zero price from the API. For vCPU and memory meters, use the published USD rates in the "Known Consumption Plan Rates" section below.

## Cost Formula

```
Consumption Plan (Standard):
  Monthly = (vCPU_seconds × vCPU_price) + (memory_GiB_seconds × memory_price)
  Free grant: 180,000 vCPU-seconds + 360,000 GiB-seconds per subscription/month

Dedicated Plan:
  vCPU    = vCPU_count × vCPU_unitPrice × 730
  Memory  = GiB_count × memory_unitPrice × 730
  Mgmt    = mgmt_unitPrice × 730 (per environment, shared across all apps)
  Monthly = vCPU + Memory + Mgmt (if not sharing environment)
```

## Known Consumption Plan Rates (verified 2026-02-06)

| Meter               | Published Rate (USD)                      | Free Grant              |
| ------------------- | ----------------------------------------- | ----------------------- |
| vCPU Active Usage   | $0.000024 per vCPU-second                 | 180,000 vCPU-seconds/mo |
| Memory Active Usage | $0.000003 per GiB-second                  | 360,000 GiB-seconds/mo  |
| Requests            | ~$0.40 per 1M requests (varies by region) | 2M requests/mo          |

> These rates are from the [Azure Container Apps pricing page](https://azure.microsoft.com/pricing/details/container-apps/). The API returns them but at precision below what the script rounds to — the script shows `$0.00` for vCPU and memory meters.

> **For non-USD currencies**: The API returns `$0.00` in all currencies due to rounding. Use the USD rates above and convert using the currency derivation method in [shared.md](../shared.md).

### Manual Calculation Example

For 10M requests/month, 0.5 vCPU, 1 GiB memory, 0.8s average duration:

```
Active seconds = 10,000,000 × 0.8 = 8,000,000s
vCPU-seconds   = 8,000,000 × 0.5  = 4,000,000
GiB-seconds    = 8,000,000 × 1    = 8,000,000

Billable vCPU-s = max(0, 4,000,000 - 180,000) = 3,820,000
Billable GiB-s  = max(0, 8,000,000 - 360,000) = 7,640,000
Billable reqs   = max(0, 10,000,000 - 2,000,000) = 8,000,000

vCPU cost    = 3,820,000 × $0.000024 = $91.68
Memory cost  = 7,640,000 × $0.000003 = $22.92
Request cost = 8 × $0.40             = $3.20
Total        = $117.80 USD/month
```

## Always-On Example (1 vCPU, 2 GiB, 1 replica)

Query live prices, then apply the Dedicated Plan formula above.

> **Note**: The Dedicated Plan Management fee (query live price) is per Container Apps environment, not per app. If multiple apps share an environment, split this cost across them.
