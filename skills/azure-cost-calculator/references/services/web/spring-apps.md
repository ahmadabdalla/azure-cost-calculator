---
serviceName: Azure Spring Cloud
category: web
aliases: [Azure Spring Apps, Java Microservices]
primaryCost: "Per-app vCPU and memory group hours × 730; overage billed separately by tier"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Spring Apps

> **Warning**: Azure Spring Apps is retiring. No new customers after March 2025; full shutdown March 31, 2028. Migrate to Azure Container Apps or AKS.

> **Trap (Inflated totals)**: Omitting `SkuName` returns all tiers and tracking meters summed. Always include `SkuName` and `MeterName`. Use `ProductName: Azure Spring Apps` (not `Azure Spring Apps Enterprise`) for all tiers.

> **Trap (Enterprise dual billing)**: Enterprise has infrastructure + VMware Tanzu licensing as separate meters. Query `Enterprise vCPU and Memory Group Duration` and `Enterprise VMware IP` separately. VMware IP is per-vCPU of user apps, not per instance.

> **Trap (GB Hour MonthlyCost)**: Overage memory meters use `1 GB Hour` units. The script does not auto-convert this — `MonthlyCost` will be incorrect. Calculate manually: `retailPrice × GB × 730`.

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

### Standard Consumption — query each: vCPU, memory, requests

ServiceName: Azure Spring Cloud
ProductName: Azure Spring Apps
SkuName: Standard Consumption
MeterName: Standard Consumption vCPU Active Usage
Quantity: {avgVCPUs}

Repeat with MeterName: `Standard Consumption Memory Active Usage` (Quantity: {avgGiBs}) and `Standard Consumption Requests`.

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
| `Standard Overage Memory Duration` | `Standard` | `1 GB Hour` | Per extra GB beyond 12 |
| `Enterprise vCPU and Memory Group Duration` | `Enterprise` | `1 Hour` | Base: includes 6 vCPU + 12 GB |
| `Enterprise Overage vCPU Duration` | `Enterprise` | `1 Hour` | Per extra vCPU beyond 6 |
| `Enterprise Overage Memory Duration` | `Enterprise` | `1 GB Hour` | Per extra GB beyond 12 |
| `Enterprise VMware IP` | `Enterprise` | `1 Hour` | Tanzu licensing per vCPU |
| `Standard Consumption vCPU Active Usage` | `Standard Consumption` | `1 Hour` | Serverless active vCPU |
| `Standard Consumption Memory Active Usage` | `Standard Consumption` | `1 GiB Hour` | Serverless active memory |
| `Standard Consumption Requests` | `Standard Consumption` | `1M` | Per million requests |

Overage memory meters for Standard/Enterprise use same rates. Standard Consumption also has idle vCPU/memory, Eureka, and Config Server meters — query with the same pattern above.

## Cost Formula

```
Basic/Standard/Enterprise:
  Group     = group_retailPrice × 730 × appInstances
  Overage   = (totalExtraVCPUs × vcpu_retailPrice + totalExtraGiB × mem_retailPrice) × 730
  VMware IP = vmwareip_retailPrice × totalVCPUs × 730  (Enterprise only)
  Free      = deduct 50 vCPU-hrs + 100 memory GB-hrs/month
  Total     = Group + Overage + VMware IP − Free grant value

Standard Consumption:
  vCPU     = max(0, avgVCPUs × 730 − 50) × vcpu_retailPrice
  Memory   = max(0, avgGiBs × 730 − 100) × mem_retailPrice
  Requests = max(0, requests − 2M) / 1M × request_retailPrice
  Total    = vCPU + Memory + Requests + managed components
```

## Notes

- **Free grant**: 50 vCPU-hours + 100 memory GB-hours per month (Basic/Standard/Enterprise pool). Standard Consumption: 50 vCPU-hours + 100 GiB-hours + 2M requests (shared with Container Apps environment).
- **Tier base resources**: Basic: 2 vCPU + 4 GB per instance. Standard/Enterprise: 6 vCPU + 12 GB. Overage vCPU/memory charged beyond included amounts.
- **Enterprise**: Infrastructure + VMware Tanzu licensing. Tanzu IP charged per total vCPU of running user apps. Standard Consumption: serverless active/idle vCPU + memory + per-request; managed components (Config Server, Eureka) at hourly rates.
- **Standard Dedicated plan**: Uses Azure Container Apps Dedicated workload profile billing — no Spring Apps meters. Query `Azure Container Apps` serviceName instead.
- **Private Endpoints**: Supported on Standard and Enterprise tiers — not available on Basic.
