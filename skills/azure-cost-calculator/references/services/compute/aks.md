---
serviceName: Azure Kubernetes Service
category: compute
aliases: [AKS, Kubernetes, K8s]
billingNeeds: [Virtual Machines]
billingConsiderations: [Reserved Instances]
primaryCost: "AKS management fee + VM node costs (priced separately as VMs)"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Kubernetes Service (AKS)

> **Trap (Standard SKU inflation)**: Querying with just `-SkuName 'Standard'` returns **two** meters: `Standard Uptime SLA` and `Standard Long Term Support`. The `summary.totalMonthlyCost` sums both, inflating the estimate ~7×. Always filter with `-MeterName 'Standard Uptime SLA'` unless the user specifically needs LTS Kubernetes version support.

> **Trap (Premium SKU)**: Querying `-SkuName 'Premium'` returns **zero** results. Premium tier billing maps to the `Standard Long Term Support` meter under `skuName=Standard`. Always use `-SkuName 'Standard' -MeterName 'Standard Long Term Support'` for Premium tier estimates.

## Query Pattern

### AKS management fee — Standard tier (filter to Uptime SLA only)

ServiceName: Azure Kubernetes Service
SkuName: Standard
MeterName: Standard Uptime SLA

### AKS management fee — Standard LTS (only if user needs Long Term Support)

ServiceName: Azure Kubernetes Service
SkuName: Standard
MeterName: Standard Long Term Support

### Node VMs - query as Virtual Machines

ServiceName: Virtual Machines
ArmSkuName: Standard_D4s_v5
InstanceCount: 3

## Meter Names

| Meter                        | Purpose                                        |
| ---------------------------- | ---------------------------------------------- |
| `Standard Uptime SLA`        | Standard management fee with uptime SLA        |
| `Standard Long Term Support` | Optional LTS Kubernetes version support add-on |

## Cost Formula

```
Monthly = AKS_uptime_SLA_fee × 730 + (VM_hourly × 730 × nodeCount)
```

## Notes

- Free tier: no uptime SLA fee, no financially-backed SLA — includes all AKS features
- Standard tier: hourly fee for uptime SLA — query live price
- **Do NOT include** `Standard Long Term Support` unless explicitly requested — it's an optional add-on for extended Kubernetes version support
- `billingConsiderations: [Reserved Instances]` applies to underlying node VMs via `billingNeeds`, not to AKS management meters
- For AKS Automatic (per-vCPU billing model), see `compute/aks-automatic.md`
