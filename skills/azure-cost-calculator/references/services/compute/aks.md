---
serviceName: Azure Kubernetes Service
category: compute
aliases: [AKS, Kubernetes, K8s]
billingNeeds: [Virtual Machines]
billingConsiderations: [Reserved Instances]
primaryCost: "AKS management fee + VM node costs (priced separately as VMs)"
privateEndpoint: true
---

# Azure Kubernetes Service (AKS)

> **Trap**: Querying with just `-SkuName 'Standard'` returns **two** meters: `Standard Uptime SLA` and `Standard Long Term Support`. The `summary.totalMonthlyCost` sums both, inflating the estimate ~7×. Always filter with `-MeterName 'Standard Uptime SLA'` unless the user specifically needs LTS Kubernetes version support.

## Query Pattern

### AKS management fee — Standard tier (filter to Uptime SLA only)

ServiceName: Azure Kubernetes Service
SkuName: Standard
MeterName: Standard Uptime SLA

### AKS management fee — Premium tier (LTS support)

ServiceName: Azure Kubernetes Service
SkuName: Standard
MeterName: Standard Long Term Support

### AKS Automatic — control plane

ServiceName: Azure Kubernetes Service
ProductName: Azure Kubernetes Service - Automatic
MeterName: Automatic Hosted Control Plane

### AKS Automatic — compute (Quantity = vCPU count)

ServiceName: Azure Kubernetes Service
ProductName: Azure Kubernetes Service - Automatic
MeterName: Automatic General Purpose
Quantity: 8

### Node VMs — query as Virtual Machines (Base SKU only)

ServiceName: Virtual Machines
ArmSkuName: Standard_D4s_v5
InstanceCount: 3

## Key Fields

| Parameter     | How to determine       | Example values                                                     |
| ------------- | ---------------------- | ------------------------------------------------------------------ |
| `serviceName` | Always                 | `Azure Kubernetes Service`                                         |
| `productName` | Base SKU vs Automatic  | `Azure Kubernetes Service`, `Azure Kubernetes Service - Automatic` |
| `skuName`     | Tier selection         | `Standard`, `Automatic`                                            |
| `meterName`   | Specific fee component | `Standard Uptime SLA`, `Automatic General Purpose`                 |

## Meter Names

| Meter                            | unitOfMeasure | Notes                                         |
| -------------------------------- | ------------- | --------------------------------------------- |
| `Standard Uptime SLA`           | `1 Hour`      | Standard tier management fee with uptime SLA  |
| `Standard Long Term Support`    | `1 Hour`      | Premium tier — LTS Kubernetes version support |
| `Automatic Hosted Control Plane` | `1 Hour`      | Automatic mode control plane fee              |
| `Automatic General Purpose`     | `1 Hour`      | Automatic per-vCPU rate — general purpose     |
| `Automatic Compute Optimized`   | `1 Hour`      | Automatic per-vCPU rate — compute-optimized   |
| `Automatic Memory Optimized`    | `1 Hour`      | Automatic per-vCPU rate — memory-optimized    |
| `Automatic GPU Accelerated`     | `1 Hour`      | Automatic per-vCPU rate — GPU workloads       |

> Also: `Automatic High Performance Compute`, `Automatic Storage Optimized`, `Automatic Confidential Compute`

## Cost Formula

```
Standard:  Monthly = uptime_SLA_retailPrice × 730 + (VM_hourly × 730 × nodeCount)
Automatic: Monthly = (control_plane_retailPrice + vCPU_retailPrice × vCPUs) × 730
```

## Notes

- Free tier: no management fee, best-effort uptime SLA — query only the underlying VMs
- Standard tier: hourly Uptime SLA fee — add separately to node VM costs
- Premium tier: uses `Standard Long Term Support` meter (no "Premium" SKU in API) — includes 24-month LTS
- Automatic mode: bundles compute — no separate VM billing; choose workload meter matching node pool type (never-assume)
- **Do NOT include** `Standard Long Term Support` unless explicitly requested
- Supports private endpoints (Standard tier or higher) — see `networking/private-link.md` for PE and DNS zone pricing
