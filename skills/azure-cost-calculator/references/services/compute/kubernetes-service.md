---
serviceName: Azure Kubernetes Service
category: compute
aliases: [AKS, Kubernetes, K8s, AKS Automatic, Kubernetes Automatic]
billingNeeds: [Virtual Machines, Load Balancer]
billingConsiderations: [Reserved Instances, Spot Pricing]
primaryCost: "Management fee + VM node costs; Automatic adds per-vCPU surcharge"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Kubernetes Service

> **Trap (Standard SKU inflation)**: `-SkuName 'Standard'` returns **two** meters (`Uptime SLA` + `Long Term Support`), inflating totals ~7×. Filter with `-MeterName 'Standard Uptime SLA'` unless user needs LTS.

> **Trap (Premium SKU)**: `-SkuName 'Premium'` returns **zero** results. Premium maps to `Standard Long Term Support` under `skuName=Standard`.

> **Trap (cross-product contamination)**: Unfiltered `-ServiceName` returns both Standard and Automatic meters (10 total). Always include `-ProductName` to isolate the correct SKU.

> **Trap (Automatic mixed units)**: Automatic meters all report `1 Hour`, but control plane is per **cluster**-hour while workload meters are per **vCPU**-hour.

## Query Pattern

### Standard tier — management fee (filter to Uptime SLA only)

ServiceName: Azure Kubernetes Service
ProductName: Azure Kubernetes Service
SkuName: Standard
MeterName: Standard Uptime SLA

### Automatic — control plane (one per cluster, flat rate across all regions)

ServiceName: Azure Kubernetes Service
ProductName: Azure Kubernetes Service - Automatic
SkuName: Automatic
MeterName: Automatic Hosted Control Plane

### Automatic — per-vCPU surcharge (substitute MeterName from table below)

ServiceName: Azure Kubernetes Service
ProductName: Azure Kubernetes Service - Automatic
SkuName: Automatic
MeterName: Automatic General Purpose
Quantity: 12

### Node VMs — query as Virtual Machines (both Standard and Automatic)

ServiceName: Virtual Machines
ArmSkuName: Standard_D4s_v5
InstanceCount: 3

## Key Fields

| Parameter     | How to determine                           | Example values                                       |
| ------------- | ------------------------------------------ | ---------------------------------------------------- |
| `productName` | Differs by SKU — must include to avoid mix | `Azure Kubernetes Service`, `...Service - Automatic` |
| `skuName`     | Cluster SKU type                           | `Standard`, `Automatic`                              |
| `meterName`   | Tier-prefixed; see Meter Names table       | `Standard Uptime SLA`, `Automatic General Purpose`   |

## Meter Names

| SKU       | Meter                                | Billing unit     | Purpose                            |
| --------- | ------------------------------------ | ---------------- | ---------------------------------- |
| Standard  | `Standard Uptime SLA`                | per cluster-hour | Management fee with uptime SLA     |
| Standard  | `Standard Long Term Support`         | per cluster-hour | Optional LTS add-on (Premium tier) |
| Automatic | `Automatic Hosted Control Plane`     | per cluster-hour | Flat-rate cluster management       |
| Automatic | `Automatic General Purpose`          | per vCPU-hour    | Standard workloads                 |
| Automatic | `Automatic Compute Optimized`        | per vCPU-hour    | CPU-intensive workloads            |
| Automatic | `Automatic Memory Optimized`         | per vCPU-hour    | Memory-intensive workloads         |
| Automatic | `Automatic Storage Optimized`        | per vCPU-hour    | Storage-intensive workloads        |
| Automatic | `Automatic GPU Accelerated`          | per vCPU-hour    | GPU workloads (highest rate)       |
| Automatic | `Automatic Confidential Compute`     | per vCPU-hour    | Confidential computing             |
| Automatic | `Automatic High Performance Compute` | per vCPU-hour    | HPC workloads                      |

## Cost Formula

```
### Standard:  Monthly = uptime_SLA_fee × 730 + (VM_hourly × 730 × nodeCount)
### Automatic: Monthly = (controlPlane × 730 × clusterCount) + Σ(workloadClass × vCPUs × 730) + (VM_hourly × 730 × nodeCount)
```

## Notes

- **Two SKUs, one service**: Standard (Base) and Automatic share the same ARM resource type (`managedClusters`) — Automatic is a SKU, not a separate product
- Free tier (Standard SKU only): no uptime SLA fee, no financially-backed SLA — includes all AKS features
- **Do NOT include** `Standard Long Term Support` unless explicitly requested — optional LTS add-on
- Automatic clusters always use Standard pricing tier — control plane fee always applies, no free tier
- Automatic per-vCPU fees are a surcharge **in addition to** VM node costs — VMs still billed via `billingNeeds`
- `billingConsiderations: [Reserved Instances, Spot Pricing]` applies to underlying VMs only, not AKS meters
- Automatic control plane rate is flat across all regions; per-vCPU rates vary ~2.4× by region
- Standard Load Balancer auto-provisioned for outbound traffic — billed via `billingNeeds`
- Private endpoints require Standard pricing tier (not available on Free tier)
- NAT Gateway, Azure Monitor, and data transfer may also apply as separate services
