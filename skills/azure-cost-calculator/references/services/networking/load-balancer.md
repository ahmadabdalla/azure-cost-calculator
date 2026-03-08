---
serviceName: Load Balancer
category: networking
aliases: [ALB, LB, Standard LB, Basic LB]
billingNeeds: [IP Addresses]
primaryCost: "Per-hour base fee + per-GB data processed + rule overage beyond 5 included (Standard/Global/Gateway)"
hasFreeGrant: true
pricingRegion: global
privateEndpoint: true
---

# Load Balancer

> **Warning**: Load Balancer pricing is **Global-only** — querying any standard region (e.g., `eastus`) returns zero results. Use `Region: Global`. Prices are USD-only.

> **Trap**: Unfiltered queries sum base fee, data processing, overage, and free-tier meters — `totalMonthlyCost` is meaningless. Query each meter separately using `MeterName`.

## Query Pattern

### Standard base hourly cost (first 5 LB/outbound rules included)

ServiceName: Load Balancer
SkuName: Standard
MeterName: Standard Included LB Rules and Outbound Rules
Region: Global

### Standard data processed (Quantity = estimated monthly GB)

ServiceName: Load Balancer
SkuName: Standard
MeterName: Standard Data Processed
Region: Global
Quantity: 500

### Multiple load balancers (InstanceCount = number of LB resources)

ServiceName: Load Balancer
SkuName: Standard
MeterName: Standard Included LB Rules and Outbound Rules
Region: Global
InstanceCount: 3

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `Standard Included LB Rules and Outbound Rules` | `Standard` | `1 Hour` | Base hourly fee — first 5 rules included |
| `Standard Overage LB Rules and Outbound Rules` | `Standard` | `1/Hour` | Per additional rule beyond 5 |
| `Standard Data Processed` | `Standard` | `1 GB` | Per-GB processed (sub-cent) |
| `Gateway` | `Gateway` | `1 Hour` | Gateway LB base fee (NVA chaining) |
| `Gateway Chain` | `Gateway` | `1 Hour` | Per chained LB per hour |
| `Gateway Data Processed` | `Gateway` | `1 GB` | Gateway per-GB (sub-cent) |
| `Global Included LB Rules and Outbound Rules` | `Global` | `1 Hour` | Cross-region base fee — first 5 rules included |
| `Global Overage LB Rules and Outbound Rules` | `Global` | `1/Hour` | Per additional rule beyond 5 |
| `Global Data Processed` | `Global` | `1 GB` | Cross-region data — genuinely free |

## Cost Formula

```
Base      = base_retailPrice × 730
Overage   = max(0, totalRules − 5) × overage_retailPrice × 730
Data      = data_retailPrice × processedGB
Monthly   = (Base + Overage + Data) × instanceCount
```

## Notes

- **Basic SKU is free** but was retired September 30, 2025 — represented in API as `- Free` suffix meters under `skuName: Standard`
- **Standard Public IPs required**: Standard LB requires Standard SKU Public IP addresses — billed separately under IP Addresses
- **Bandwidth charges**: Data transfer (egress) is billed separately from LB data processing charges under the Bandwidth service
- **Three SKUs**: Standard (regional), Global (cross-region, data processing is free), Gateway (NVA chaining with base + chain + data meters)
- **Per-resource billing**: Each LB resource is billed independently — multiply total by resource count
- **Rule overage**: First 5 LB rules and outbound rules included in base hourly fee; each additional rule incurs overage charge. Inbound NAT rules are free and do not count toward the rule total
- **Private endpoint**: Only **Standard Internal** LB supports Private Link — Standard Public, Global, and Gateway do not. PE charges billed separately under `networking/private-link.md`
