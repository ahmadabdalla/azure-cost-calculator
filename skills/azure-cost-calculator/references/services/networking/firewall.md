---
serviceName: Azure Firewall
category: networking
aliases: [AzFW, Azure Firewall Premium/Standard/Basic]
billingNeeds: [IP Addresses]
primaryCost: "Deployment hourly rate × 730 + data processing per-GB + capacity units"
---

# Azure Firewall

> **Trap**: Each tier has **separate meters** for deployment (hourly), data processing (per-GB), and capacity units (Standard/Premium only). A single unfiltered query mixes all three, making `summary.totalMonthlyCost` meaningless.
> **Trap**: The deployment (fixed) cost is the **dominant expense** — typically 99%+ of the total for moderate traffic. Do not confuse the small data processing charge with the full cost.

## Query Pattern

Substitute `{Tier}` with `Standard`, `Premium`, or `Basic` (see Meter Names table).

### {Tier} — fixed deployment cost

ServiceName: Azure Firewall
ProductName: Azure Firewall
SkuName: {Tier}
MeterName: {Tier} Deployment

### {Tier} — data processing (use Quantity for estimated monthly GB)

ServiceName: Azure Firewall
ProductName: Azure Firewall
SkuName: {Tier}
MeterName: {Tier} Data Processed
Quantity: 100

### {Tier} — capacity units (Standard and Premium only)

ServiceName: Azure Firewall
ProductName: Azure Firewall
SkuName: {Tier}
MeterName: {Tier} Capacity Unit
Quantity: 2 # number of additional scale units

## Meter Names

| Tier     | skuName    | Deployment Meter      | Data Meter                | Capacity Unit Meter      |
| -------- | ---------- | --------------------- | ------------------------- | ------------------------ |
| Standard | `Standard` | `Standard Deployment` | `Standard Data Processed` | `Standard Capacity Unit` |
| Premium  | `Premium`  | `Premium Deployment`  | `Premium Data Processed`  | `Premium Capacity Unit`  |
| Basic    | `Basic`    | `Basic Deployment`    | `Basic Data Processed`    | —                        |

> **Note**: Secured Virtual Hub variants use different skuName values (e.g., `Standard Secure Virtual Hub` — note "Secure" without "d" for Standard, but "Secured" for Basic/Premium). Query with Explore-AzurePricing if deployed in a Virtual WAN hub.

## Cost Formula

```
Monthly = deploymentPrice × 730 + dataPrice × estimatedGB + capacityUnitPrice × units × 730
```

## Notes

- Standard → Premium adds IDPS, TLS inspection, URL filtering (higher fixed cost)
- Basic is a budget option — limited features, no auto-scaling (no Capacity Unit meter)
- Standard/Premium auto-scale when throughput or connections exceed thresholds — each capacity unit billed hourly
- Secured Virtual Hub variants have identical pricing but different `skuName` values for Virtual WAN deployments
