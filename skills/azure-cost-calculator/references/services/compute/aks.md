---
serviceName: Azure Kubernetes Service
category: compute
aliases: [AKS, kubernetes, k8s]
---

# Azure Kubernetes Service (AKS)

**Primary cost**: AKS management fee + VM node costs (priced separately as VMs)

> **Trap**: Querying with just `-SkuName 'Standard'` returns **two** meters: `Standard Uptime SLA` ($0.1429/hr) and `Standard Long Term Support` ($0.8573/hr). The `summary.totalMonthlyCost` sums both, inflating the estimate ~7× (~$730/mo instead of ~$104/mo). Always filter with `-MeterName 'Standard Uptime SLA'` unless the user specifically needs LTS Kubernetes version support.

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
Quantity: 1
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

- Free tier: no uptime SLA fee, limited cluster management
- Standard tier: hourly fee for uptime SLA — query live price
- **Do NOT include** `Standard Long Term Support` unless explicitly requested — it's an optional add-on for extended Kubernetes version support
- Main cost is in the node VMs — price those as Virtual Machines
