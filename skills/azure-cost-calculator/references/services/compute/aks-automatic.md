---
serviceName: Azure Kubernetes Service
category: compute
aliases: [AKS Automatic, Kubernetes Automatic]
billingNeeds: [Managed Disks]
primaryCost: "Per-cluster control plane fee + per-vCPU-hour workload fees by compute class"
privateEndpoint: true
---

# AKS Automatic

> **Trap (cross-product contamination)**: Querying `-ServiceName 'Azure Kubernetes Service'` without `-ProductName` returns both Standard and Automatic meters (10 total). Always include `-ProductName 'Azure Kubernetes Service - Automatic'`.

> **Trap (mixed unit ambiguity)**: All 8 meters report `unitOfMeasure: 1 Hour`, but the control plane is per **cluster**-hour while the other 7 are per **vCPU**-hour. The API does not distinguish these — apply the correct multiplier manually.

## Query Pattern

### Control plane fee (one per cluster, flat rate across all regions)

ServiceName: Azure Kubernetes Service
ProductName: Azure Kubernetes Service - Automatic
SkuName: Automatic
MeterName: Automatic Hosted Control Plane

### Per-vCPU fee — General Purpose (most common workload type)

ServiceName: Azure Kubernetes Service
ProductName: Azure Kubernetes Service - Automatic
SkuName: Automatic
MeterName: Automatic General Purpose
Quantity: 12

### Per-vCPU fee — substitute MeterName for other workload types

ServiceName: Azure Kubernetes Service
ProductName: Azure Kubernetes Service - Automatic
SkuName: Automatic
MeterName: Automatic Compute Optimized

## Meter Names

| Meter | Billing unit | Purpose |
| --- | --- | --- |
| `Automatic Hosted Control Plane` | per cluster-hour | Flat-rate cluster management fee |
| `Automatic General Purpose` | per vCPU-hour | Standard workloads |
| `Automatic Compute Optimized` | per vCPU-hour | CPU-intensive workloads |
| `Automatic Memory Optimized` | per vCPU-hour | Memory-intensive workloads |
| `Automatic Storage Optimized` | per vCPU-hour | Storage-intensive workloads |
| `Automatic GPU Accelerated` | per vCPU-hour | GPU workloads (highest rate) |
| `Automatic Confidential Compute` | per vCPU-hour | Confidential computing workloads |
| `Automatic High Performance Compute` | per vCPU-hour | HPC workloads |

## Cost Formula

```
Monthly = (controlPlane_retailPrice × 730 × clusterCount)
        + Σ(workloadClass_retailPrice × vCPUs_in_class × 730)
        + Managed_Disks (separate query)
```

## Notes

- **No free tier** — Automatic clusters always use Standard tier; control plane fee always applies
- **No VM billing** — unlike Standard AKS, compute is billed per-vCPU through AKS meters (no separate VM queries)
- **No RI pricing** — zero Reservation meters in the API for Automatic
- Control plane rate is flat across all 59 regions; per-vCPU rates vary ~2.4× by region
- User must specify total vCPU count and workload type (General Purpose, Compute Optimized, etc.)
- Managed Disks, Load Balancer/NAT Gateway, Azure Monitor, and data transfer are billed separately
- For Standard AKS (separate VM billing model), see `compute/aks.md`
