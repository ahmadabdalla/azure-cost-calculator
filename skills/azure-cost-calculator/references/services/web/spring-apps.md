---
serviceName: Azure Spring Cloud
category: web
aliases: [Azure Spring Apps, Java Microservices]
primaryCost: "Per-app vCPU and memory group hours × 730; overage billed separately by tier"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Spring Apps

> **Trap (Inflated totals)**: Omitting `SkuName` returns all tiers and tracking meters summed. Always include `SkuName` and `MeterName`. Use `ProductName: Azure Spring Apps` (not `Azure Spring Apps Enterprise`) for all tiers.

> **Trap (Enterprise dual billing)**: Enterprise has infrastructure + VMware Tanzu licensing as separate meters. Query `Enterprise vCPU and Memory Group Duration` and `Enterprise VMware IP` separately. VMware IP is per-vCPU of user apps, not per instance.

## Query Pattern

### {SkuName} tier — base group (use InstanceCount for multi-app deployments)

ServiceName: Azure Spring Cloud
ProductName: Azure Spring Apps
SkuName: {SkuName}
MeterName: {SkuName} vCPU and Memory Group Duration
InstanceCount: {appInstances}

### Enterprise VMware Tanzu licensing (per total vCPU of user apps)

ServiceName: Azure Spring Cloud
ProductName: Azure Spring Apps
SkuName: Enterprise
MeterName: Enterprise VMware IP
Quantity: {totalVCPUs}

### Standard Consumption — active vCPU usage

ServiceName: Azure Spring Cloud
ProductName: Azure Spring Apps
SkuName: Standard Consumption
MeterName: Standard Consumption vCPU Active Usage
Quantity: {vCPUHours}

## Key Fields

| Parameter | How to determine | Example values |
| --------- | ---------------- | -------------- |
| `serviceName` | Always `Azure Spring Cloud` | `Azure Spring Cloud` |
| `productName` | Always `Azure Spring Apps` for all tiers | `Azure Spring Apps` |
| `skuName` | Plan tier selected at deployment | `Basic`, `Standard`, `Enterprise`, `Standard Consumption` |
| `meterName` | Tier prefix + component suffix | `Basic vCPU and Memory Group Duration`, `Enterprise VMware IP` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `Basic vCPU and Memory Group Duration` | `Basic` | `1 Hour` | Base: includes 2 vCPU + 4 GB |
| `Basic Overage vCPU Duration` | `Basic` | `1 Hour` | Per extra vCPU beyond 2 |
| `Basic Overage Memory Duration` | `Basic` | `1 GB Hour` | Per extra GB beyond 4 |
| `Standard vCPU and Memory Group Duration` | `Standard` | `1 Hour` | Base: includes 6 vCPU + 12 GB |
| `Standard Overage vCPU Duration` | `Standard` | `1 Hour` | Per extra vCPU beyond 6 |
| `Enterprise vCPU and Memory Group Duration` | `Enterprise` | `1 Hour` | Base: includes 6 vCPU + 12 GB |
| `Enterprise VMware IP` | `Enterprise` | `1 Hour` | Tanzu licensing per vCPU |
| `Standard Consumption vCPU Active Usage` | `Standard Consumption` | `1 Hour` | Serverless active vCPU |
| `Standard Consumption Memory Active Usage` | `Standard Consumption` | `1 GiB Hour` | Serverless active memory |
| `Standard Consumption Requests` | `Standard Consumption` | `1M` | Per million requests |

Overage memory meters for Standard/Enterprise use same rates. Standard Consumption has additional meters (idle vCPU/memory, Eureka, Config Server) not listed above.

## Cost Formula

```
Basic/Standard/Enterprise:
  Group     = group_retailPrice × 730 × appInstances
  Overage   = (extraVCPUs × vcpu_retailPrice + extraGB × mem_retailPrice) × 730
  VMware IP = vmwareip_retailPrice × totalVCPUs × 730  (Enterprise only)
  Free      = deduct 50 vCPU-hrs + 100 memory GB-hrs/month
  Total     = Group + Overage + VMware IP − Free grant value

Standard Consumption:
  vCPU     = max(0, vCPUHrs − 50) × vcpu_retailPrice
  Memory   = max(0, memGiBHrs − 100) × mem_retailPrice
  Requests = max(0, requests − 2M) / 1M × request_retailPrice
  Total    = vCPU + Memory + Requests + managed components
```

## Notes

- **Free grant**: 50 vCPU-hours + 100 memory GB-hours per month shared across Basic/Standard/Enterprise. Standard Consumption adds 2M free requests (grant is shared across all apps in the same Container Apps environment).
- **Tier base resources**: Basic includes 2 vCPU + 4 GB per instance. Standard and Enterprise include 6 vCPU + 12 GB. Resources beyond included amounts incur overage charges.
- **Enterprise two-part billing**: Infrastructure (Microsoft) + VMware Tanzu licensing (VMware). Tanzu IP is charged per total vCPU of running user apps.
- **Standard Consumption**: Serverless model — billed for active/idle vCPU and memory usage plus per-request. Optional managed components (Config Server, Eureka) at hourly rates.
- **Standard Dedicated plan**: Uses Azure Container Apps Dedicated workload profile billing — no Spring Apps meters. Query `Azure Container Apps` serviceName instead.
- **Private Endpoints**: Supported on Standard and Enterprise tiers — not available on Basic.
