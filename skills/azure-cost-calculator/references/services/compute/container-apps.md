---
serviceName: Azure Container Apps
category: compute
aliases: [ACA, Container Apps]
primaryCost: "vCPU seconds + memory GiB seconds (Consumption) or vCPU hours + memory GiB hours (Dedicated)"
hasFreeGrant: true
privateEndpoint: true
---

# Container Apps

> **Trap**: Unfiltered query returns 13+ meters across 4 SKUs (`Standard`, `Dedicated`, `Hybrid`, `Dynamic Sessions`) including GPU — always filter by `SkuName`. For Consumption (`Standard`), the script's `MonthlyCost` shows zero because quantity is unknown — use the `UnitPrice` from API results directly. If workload type is unspecified, default to Consumption (event-driven); always-on workloads require Dedicated plan.

## Query Pattern

### Consumption (Standard) — per-second billing (MonthlyCost shows zero; use UnitPrice from API)

ServiceName: Azure Container Apps
ProductName: Azure Container Apps
SkuName: Standard

### Dedicated — per-hour billing (prices correct in API)

ServiceName: Azure Container Apps
ProductName: Azure Container Apps
SkuName: Dedicated

### Hybrid — per-hour billing (Arc-enabled environments)

ServiceName: Azure Container Apps
ProductName: Azure Container Apps
SkuName: Hybrid

## Meter Names

| Plan      | Meter                          | unitOfMeasure | Notes                                |
| --------- | ------------------------------ | ------------- | ------------------------------------ |
| Dedicated | `Dedicated vCPU Usage`         | 1 Hour        | Per vCPU per hour                    |
| Dedicated | `Dedicated Memory Usage`       | 1 Hour        | Per GiB per hour                     |
| Dedicated | `Dedicated Plan Management`    | 1 Hour        | Per environment (shared across apps) |
| Dedicated | `Dedicated GPU Usage`          | 1 Hour        | GPU workloads only                   |
| Standard  | `Standard vCPU Active Usage`   | 1 Second      | Use `UnitPrice` from API             |
| Standard  | `Standard vCPU Idle Usage`     | 1 Second      | Use `UnitPrice` from API             |
| Standard  | `Standard Memory Active Usage` | 1 GiB Second  | Use `UnitPrice` from API             |
| Standard  | `Standard Memory Idle Usage`   | 1 GiB Second  | Use `UnitPrice` from API             |
| Standard  | `Standard Requests`            | 1M            | Use `UnitPrice` from API             |

### Consumption Plan Meters

| Meter                          | Free Grant              |
| ------------------------------ | ----------------------- |
| `Standard vCPU Active Usage`   | 180,000 vCPU-seconds/mo |
| `Standard Memory Active Usage` | 360,000 GiB-seconds/mo  |
| `Standard Requests`            | 2M requests/mo          |

> Query the API for current `UnitPrice` values. The script's `MonthlyCost` shows zero because it cannot infer quantity — use `UnitPrice` directly in your calculation.

## Cost Formula

```
Consumption (Standard):
  Monthly = (billable_vCPU_seconds × vCPU_UnitPrice) + (billable_GiB_seconds × mem_UnitPrice)
           + max(0, requests − 2M) / 1M × request_UnitPrice
  Free grant: 180K vCPU-s + 360K GiB-s + 2M requests per subscription/month

Dedicated:
  Monthly = (vCPUs × vCPU_price × 730) + (GiB × mem_price × 730) + (mgmt_price × 730)
```

> **Agent defaults** (when not specified): Use Consumption plan. If request count given without per-request duration, assume **1s/request**. Derive `active_seconds = requests × 1s` — never assume `730 × 3600` (always-on) for Standard SKU.

## Notes

- Dedicated plan charges per-environment management fee in addition to vCPU/memory
- GPU workloads require Dedicated plan with `Dedicated GPU Usage` meter
- Free grant (180K vCPU-s + 360K GiB-s + 2M requests) is per subscription, shared across all Container Apps

## SKU Selection Guide

| Workload Type                   | SKU         | Pricing Model | Notes                                    |
| ------------------------------- | ----------- | ------------- | ---------------------------------------- |
| Scale-to-zero, event-driven     | `Standard`  | Per-second    | Free grant: 180K vCPU-s + 360K GiB-s/mo  |
| Always-on, minimum replicas > 0 | `Dedicated` | Per-hour      | Use for background workers, ML pipelines |
| Hybrid (on-prem connected)      | `Hybrid`    | Per-hour      | For Arc-enabled environments             |

## Manual Calculation Example

10M req/mo, 0.5 vCPU, 1 GiB, 0.8s avg duration:

```
Active-s = 10M × 0.8 = 8M | vCPU-s = 8M × 0.5 = 4M | GiB-s = 8M × 1 = 8M
Billable: vCPU-s = 4M − 180K = 3,820K · GiB-s = 8M − 360K = 7,640K · reqs = 10M − 2M = 8M
Cost: (billable_vCPU-s × vCPU_UnitPrice) + (billable_GiB-s × mem_UnitPrice) + (billable_reqs × req_UnitPrice)
```

> Query API for `Standard vCPU Active Usage`, `Standard Memory Active Usage`, and `Standard Requests` UnitPrice values.
