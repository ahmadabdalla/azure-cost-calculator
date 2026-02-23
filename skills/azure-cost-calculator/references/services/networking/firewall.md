---
serviceName: Azure Firewall
category: networking
aliases: [Azure Firewall Premium/Standard/Basic]
billingNeeds: [IP Addresses]
primaryCost: "Deployment hourly rate × 730 + data processing per-GB"
---

# Azure Firewall

> **Trap**: You need **TWO separate queries** per tier — one for the fixed deployment cost and one for data processing. A single unfiltered query returns both meters mixed together, and the `summary.totalMonthlyCost` is meaningless because it sums a per-hour rate with a per-GB rate.
> **Trap**: The deployment (fixed) cost is the **dominant expense** — typically 99%+ of the total for moderate traffic. Do not confuse the small data processing charge with the full cost.

## Query Pattern

Substitute `{Tier}` with `Standard`, `Premium`, or `Basic` (see Meter Names table). Run **two queries per tier**:

### {Tier} — fixed deployment cost

ServiceName: Azure Firewall
ProductName: Azure Firewall
SkuName: {Tier}
MeterName: {Tier} Deployment

### {Tier} — data processing

ServiceName: Azure Firewall
ProductName: Azure Firewall
SkuName: {Tier}
MeterName: {Tier} Data Processed

## Meter Names

| Tier     | skuName    | Deployment Meter      | Data Meter                |
| -------- | ---------- | --------------------- | ------------------------- |
| Standard | `Standard` | `Standard Deployment` | `Standard Data Processed` |
| Premium  | `Premium`  | `Premium Deployment`  | `Premium Data Processed`  |
| Basic    | `Basic`    | `Basic Deployment`    | `Basic Data Processed`    |

> **Note**: Secured Virtual Hub variants also exist with a different skuName (e.g., `'Standard Secure Virtual Hub'`). Query with Explore-AzurePricing if the firewall is deployed in a Virtual WAN hub.

## Cost Formula

```
Monthly = deploymentPrice × 730 + dataPrice × estimatedGB
```

## Notes

- Standard → Premium adds IDPS, TLS inspection, URL filtering (higher fixed cost)
- Basic is a budget option with limited features and throughput
