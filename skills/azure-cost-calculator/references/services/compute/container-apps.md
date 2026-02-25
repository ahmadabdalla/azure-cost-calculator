---
serviceName: Azure Container Apps
category: compute
aliases: [ACA, Container Apps]
primaryCost: "vCPU seconds + memory GiB seconds (Consumption) or vCPU hours + memory GiB hours (Dedicated)"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Container Apps

> **Trap**: Unfiltered query returns 13 meters across 4 SKUs (`Standard`, `Dedicated`, `Hybrid`, `Dynamic Sessions`) including GPU — always filter by `SkuName`. For Consumption (`Standard`), the script's `MonthlyCost` shows zero because per-second units cannot be multiplied by 730 — use `UnitPrice` from API results directly. If workload type is unspecified, default to Consumption (event-driven); always-on workloads require Dedicated plan.

## Query Pattern

### Consumption (Standard) — per-second billing (use UnitPrice from API)

ServiceName: Azure Container Apps
ProductName: Azure Container Apps
SkuName: Standard

### Dedicated — per-hour billing (InstanceCount = workload profile instances)

ServiceName: Azure Container Apps
ProductName: Azure Container Apps
SkuName: Dedicated
InstanceCount: 3

### Hybrid — per-hour billing (Arc-enabled environments)

ServiceName: Azure Container Apps
ProductName: Azure Container Apps
SkuName: Hybrid

## Meter Names

| Plan             | Meter                           | unitOfMeasure | Notes                                        |
| ---------------- | ------------------------------- | ------------- | -------------------------------------------- |
| Standard         | `Standard vCPU Active Usage`    | 1 Second      | Free grant: 180K vCPU-s/mo                   |
| Standard         | `Standard vCPU Idle Usage`      | 1 Second      | ~1/8 of active rate                          |
| Standard         | `Standard Memory Active Usage`  | 1 GiB Second  | Free grant: 360K GiB-s/mo                    |
| Standard         | `Standard Memory Idle Usage`    | 1 GiB Second  | Same rate as active                          |
| Standard         | `Standard Requests`             | 1M            | Free grant: 2M requests/mo                   |
| Standard         | `Standard NC T4 v3 GPU Usage`   | 1 Second      | Additive to vCPU/memory                      |
| Standard         | `Standard NC A100 v4 GPU Usage` | 1 Second      | Additive to vCPU/memory                      |
| Dedicated        | `Dedicated vCPU Usage`          | 1 Hour        | Per vCPU per hour                            |
| Dedicated        | `Dedicated Memory Usage`        | 1 Hour        | Per GiB per hour                             |
| Dedicated        | `Dedicated Plan Management`     | 1 Hour        | Per environment; additive for PE/maintenance |
| Dedicated        | `Dedicated GPU Usage`           | 1 Hour        | GPU workloads only                           |
| Hybrid           | `Hybrid vCPU Usage`             | 1 Hour        | Arc-enabled; memory included                 |
| Dynamic Sessions | `Dynamic Sessions`              | 1 Hour        | Per session hour (Consumption only)          |

## Cost Formula

```
Consumption (Standard):
  Monthly = (max(0, vCPU_s − 180K) × vCPU_UnitPrice) + (max(0, GiB_s − 360K) × mem_UnitPrice)
           + max(0, requests − 2M) / 1M × request_UnitPrice

Dedicated:
  Monthly = (vCPUs × vCPU_price × 730) + (GiB × mem_price × 730) + (mgmt_price × 730)
```

> **Agent instruction**: For Consumption, if request count given without per-request duration, assume **1s/request**. Derive `active_seconds = requests × 1s` — never assume 730 × 3600 (always-on) for Standard SKU.

## Notes

- Dedicated plan charges per-environment management fee in addition to vCPU/memory; fee is additive for private endpoints and planned maintenance
- GPU: Standard supports T4 and A100 (additive to vCPU/memory charges); Dedicated has generic GPU meter
- Free grant (180K vCPU-s + 360K GiB-s + 2M requests) is per subscription, shared across all Container Apps
- Idle vs Active: vCPU idle rate ~1/8 of active; memory idle = active; replicas at min count > 0 charge active rate
- Scale to zero incurs zero charges; health probe and intra-environment requests are not billable

## SKU Selection Guide

| Workload Type               | SKU                | Pricing Model | Notes                                   |
| --------------------------- | ------------------ | ------------- | --------------------------------------- |
| Scale-to-zero, event-driven | `Standard`         | Per-second    | Free grant: 180K vCPU-s + 360K GiB-s/mo |
| Always-on, min replicas > 0 | `Dedicated`        | Per-hour      | Background workers, ML pipelines        |
| Hybrid (on-prem connected)  | `Hybrid`           | Per-hour      | Arc-enabled environments                |
| Code interpreter sessions   | `Dynamic Sessions` | Per-hour      | Consumption plan only                   |

## Manual Calculation Example

10M req/mo, 0.5 vCPU, 1 GiB, 0.8s avg duration:

```
Active-s = 10M × 0.8 = 8M | vCPU-s = 8M × 0.5 = 4M | GiB-s = 8M × 1 = 8M
Billable: vCPU-s = 4M − 180K = 3,820K · GiB-s = 8M − 360K = 7,640K · reqs = 10M − 2M = 8M
Cost: (3,820K × vCPU_UnitPrice) + (7,640K × mem_UnitPrice) + (8 × request_UnitPrice)
```

> Query API for `Standard vCPU Active Usage`, `Standard Memory Active Usage`, and `Standard Requests` UnitPrice values.
