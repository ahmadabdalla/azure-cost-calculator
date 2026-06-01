---
serviceName: Azure Container Apps
category: compute
aliases: [ACA, Container Apps]
primaryCost: "vCPU seconds + memory GiB seconds (Consumption) or vCPU hours + memory GiB hours (Dedicated)"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Container Apps

> **Trap**: Unfiltered query returns 13 meters across 4 SKUs (`Standard`, `Dedicated`, `Hybrid`, `Dynamic Sessions`) including GPU. Always filter by `SkuName`. For Consumption (`Standard`), the script's `MonthlyCost` shows zero because per-second units cannot be multiplied by 730. Use `UnitPrice` from API results directly. If workload type is unspecified, default to Consumption (event-driven); always-on workloads require Dedicated plan.

## Query Pattern

### All plans: substitute {Plan} SKU (ServiceName and ProductName are always the same)

ServiceName: Azure Container Apps
ProductName: Azure Container Apps
SkuName: {Plan}

- **Consumption**: SkuName `Standard` — per-second; use `UnitPrice` directly
- **Dedicated**: SkuName `Dedicated` — per-hour; add `InstanceCount` for profile instances
- **Hybrid**: SkuName `Hybrid` — per-hour; Arc-enabled environments
- **Dynamic Sessions**: SkuName `Dynamic Sessions` — per-hour

## Key Fields

| Parameter     | How to determine                           | Example values                                       |
| ------------- | ------------------------------------------ | ---------------------------------------------------- |
| `serviceName` | Always `Azure Container Apps`              | `Azure Container Apps`                               |
| `productName` | Always `Azure Container Apps`              | `Azure Container Apps`                               |
| `skuName`     | Plan type; determines billing model        | `Standard`, `Dedicated`, `Hybrid`, `Dynamic Sessions` |
| `meterName`   | Resource dimension within plan (see below) | `Standard vCPU Active Usage`, `Dedicated vCPU Usage` |

## Meter Names

| Plan             | Meter                           | unitOfMeasure | Notes                                        |
| ---------------- | ------------------------------- | ------------- | -------------------------------------------- |
| Standard         | `Standard vCPU Active Usage`    | 1 Second      | Free grant: 180K vCPU-s/mo                   |
| Standard         | `Standard vCPU Idle Usage`      | 1 Second      | ~1/8 of active rate                          |
| Standard         | `Standard Memory Active Usage`  | 1 GiB Second  | Free grant: 360K GiB-s/mo                    |
| Standard         | `Standard Memory Idle Usage`    | 1 GiB Second  | Same rate as active                          |
| Standard         | `Standard Requests`             | 1M            | Free grant: 2M/mo; probes & intra-env free   |
| Standard         | `Standard NC T4 v3 GPU Usage`   | 1 Second      | Additive to vCPU/memory                      |
| Standard         | `Standard NC A100 v4 GPU Usage` | 1 Second      | Additive to vCPU/memory                      |
| Dedicated        | `Dedicated vCPU Usage`          | 1 Hour        | Per vCPU per hour                            |
| Dedicated        | `Dedicated Memory Usage`        | 1 Hour        | Per GiB per hour                             |
| Dedicated        | `Dedicated Plan Management`     | 1 Hour        | Per environment; additive for PE/maintenance |
| Dedicated        | `Dedicated GPU Usage`           | 1 Hour        | GPU workloads only                           |
| Hybrid           | `Hybrid vCPU Usage`             | 1 Hour        | Arc-enabled; memory included                 |
| Dynamic Sessions | `Dynamic Sessions`              | 1 Hour        | Per session hour; billed separately          |

## Cost Formula

```
Consumption (Standard):
  Monthly = (max(0, vCPU_s − 180K) × vCPU_UnitPrice) + (max(0, GiB_s − 360K) × mem_UnitPrice)
           + max(0, requests − 2M) / 1M × request_UnitPrice
Dedicated (non-GPU):
  Monthly = (vCPUs × vCPU_price × 730) + (GiB × mem_price × 730) + (N × mgmt_price × 730)
Dedicated (GPU): Monthly = (GPU_count × GPU_price × 730) + (N × mgmt_price × 730)
Hybrid:  Monthly = vCPUs × hybrid_price × 730
Dynamic: Monthly = sessions × session_price × 730
  N = enabled features (base Dedicated=1, +PE=1, +planned maintenance=1)
```

> **Agent instruction**: For Consumption, if request count given without per-request duration, assume **1s/request**. Derive `active_seconds = requests × 1s`. Never assume 730 × 3600 (always-on) for Standard SKU.

## Notes

- Dedicated management fee (N in formula): base Dedicated = 1, +1 per PE, +1 per planned maintenance
- GPU: Standard T4/A100 are additive to vCPU/memory; Dedicated GPU replaces vCPU/memory (GPU + management only)
- Free grant (180K vCPU-s + 360K GiB-s + 2M requests) is per subscription, shared across all Container Apps
- Idle vs Active: vCPU idle ~1/8 of active; memory idle = active; min replicas > 0 = active rate; scale-to-zero = no charges
- Dynamic Sessions: code interpreter billed per session-hour; custom pools on Dedicated use Dedicated meters only
- Private endpoints require Dedicated plan; Savings Plans shown on pricing page but not in Retail Prices API

## SKU Selection Guide

| Workload Type               | SKU                | Pricing Model | Notes                                   |
| --------------------------- | ------------------ | ------------- | --------------------------------------- |
| Scale-to-zero, event-driven | `Standard`         | Per-second    | Free grant: 180K vCPU-s + 360K GiB-s/mo |
| Always-on, min replicas > 0 | `Dedicated`        | Per-hour      | Background workers, ML pipelines        |
| Hybrid (on-prem connected)  | `Hybrid`           | Per-hour      | Arc-enabled environments                |
| Code interpreter sessions   | `Dynamic Sessions` | Per-hour      | Billed separately by session duration   |

## Manual Calculation Example
10M req/mo, 0.5 vCPU, 1 GiB, 0.8s avg duration:

```
Active-s = 10M × 0.8 = 8M | vCPU-s = 8M × 0.5 = 4M | GiB-s = 8M × 1 = 8M
Billable vCPU-s = 4M − 180K = 3,820K · GiB-s = 8M − 360K = 7,640K · reqs = 10M − 2M = 8M
Cost = (3,820K × vCPU_UnitPrice) + (7,640K × mem_UnitPrice) + (8 × request_UnitPrice)
```
