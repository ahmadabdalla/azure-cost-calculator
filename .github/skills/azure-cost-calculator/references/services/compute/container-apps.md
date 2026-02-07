# Container Apps

**Primary cost**: vCPU seconds + memory GiB seconds (Consumption plan) or vCPU hours + memory GiB hours (Dedicated plan)

> **Trap**: Unfiltered query returns 13 meters across 4 SKUs (`Standard`, `Dedicated`, `Hybrid`, `Dynamic Sessions`) incl. GPU at ~$6,666/mo — always use `-SkuName`. Consumption (`Standard`) meters show `$0.00` (sub-cent precision); use published rates below. Always ask if workload is always-on or event-driven to pick the right SKU.

## Query Pattern

```powershell
# $sku: 'Standard' (Consumption, per-second — UnitPrice shows $0.00) | 'Dedicated' (per-hour, prices correct) | 'Hybrid'
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Container Apps' `
    -ProductName 'Azure Container Apps' `
    -SkuName $sku
```

## SKU Selection Guide

| Workload Type                   | SKU         | Pricing Model | Notes                                    |
| ------------------------------- | ----------- | ------------- | ---------------------------------------- |
| Scale-to-zero, event-driven     | `Standard`  | Per-second    | Free grant: 180K vCPU-s + 360K GiB-s/mo  |
| Always-on, minimum replicas > 0 | `Dedicated` | Per-hour      | Use for background workers, ML pipelines |
| Hybrid (on-prem connected)      | `Hybrid`    | Per-hour      | For Arc-enabled environments             |

## Meter Names

| Plan      | Meter                          | unitOfMeasure | Notes                                |
| --------- | ------------------------------ | ------------- | ------------------------------------ |
| Dedicated | `Dedicated vCPU Usage`         | 1 Hour        | Per vCPU per hour                    |
| Dedicated | `Dedicated Memory Usage`       | 1 Hour        | Per GiB per hour                     |
| Dedicated | `Dedicated Plan Management`    | 1 Hour        | Per environment (shared across apps) |
| Dedicated | `Dedicated GPU Usage`          | 1 Hour        | GPU workloads only                   |
| Standard  | `Standard vCPU Active Usage`   | 1 Second      | Shows $0.00 — sub-cent               |
| Standard  | `Standard vCPU Idle Usage`     | 1 Second      | Shows $0.00 — sub-cent               |
| Standard  | `Standard Memory Active Usage` | 1 GiB Second  | Shows $0.00 — sub-cent               |
| Standard  | `Standard Memory Idle Usage`   | 1 GiB Second  | Shows $0.00 — sub-cent               |
| Standard  | `Standard Requests`            | 1M            | Only meter returning non-zero price  |

## Cost Formula

```
Consumption (Standard):
  Monthly = (vCPU_seconds × $0.000024) + (GiB_seconds × $0.000003)
  Free grant: 180K vCPU-s + 360K GiB-s per subscription/month

Dedicated:
  Monthly = (vCPUs × vCPU_price × 730) + (GiB × mem_price × 730) + (mgmt_price × 730)
```

## Known Consumption Plan Rates

| Meter               | Published Rate (USD)                      | Free Grant              |
| ------------------- | ----------------------------------------- | ----------------------- |
| vCPU Active Usage   | $0.000024 per vCPU-second                 | 180,000 vCPU-seconds/mo |
| Memory Active Usage | $0.000003 per GiB-second                  | 360,000 GiB-seconds/mo  |
| Requests            | ~$0.40 per 1M requests (varies by region) | 2M requests/mo          |

> **Note**: Rates from [Azure Container Apps pricing page](https://azure.microsoft.com/pricing/details/container-apps/). API returns `$0.00` for vCPU/memory in all currencies (sub-cent rounding). Use USD rates above; for other currencies convert via [shared.md](../shared.md).

### Manual Calculation Example

10M req/mo, 0.5 vCPU, 1 GiB, 0.8s avg duration:

```
Active-s = 10M × 0.8 = 8M | vCPU-s = 8M × 0.5 = 4M | GiB-s = 8M × 1 = 8M
Billable: vCPU-s = 4M − 180K = 3,820K · GiB-s = 8M − 360K = 7,640K · reqs = 10M − 2M = 8M
Cost: vCPU 3,820K × $0.000024 = $91.68 + mem 7,640K × $0.000003 = $22.92 + reqs 8 × $0.40 = $3.20
Total = $117.80/mo
```
