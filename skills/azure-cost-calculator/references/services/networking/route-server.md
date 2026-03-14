---
serviceName: Azure Route Server
category: networking
aliases: [BGP Routing]
billingNeeds: [IP Addresses]
primaryCost: "Gateway hourly rate × 730 + additional routing infrastructure unit hours beyond 4,000 VMs"
pricingRegion: global
---

# Azure Route Server

> **Warning**: Route Server pricing is **Global-only** — querying any standard region (e.g., `eastus`) returns zero results. Use `Region: Global`. Prices are USD-only.

> **Trap**: Unfiltered queries sum the base gateway and routing infrastructure unit meters — `totalMonthlyCost` is meaningless. Query each meter separately using `MeterName`.

> **Trap (scaling units)**: The base gateway price includes **2 routing infrastructure units** supporting 4,000 VMs. The `Routing Infrastructure Unit` meter is for **additional** units only. Do NOT add 2 × unit cost to the base — those are already included.

## Query Pattern

### Base gateway hourly cost (always-on)

ServiceName: Azure Route Server
SkuName: Basic
MeterName: Basic Gateway
Region: Global

### Additional routing infrastructure units (only if VMs > 4,000; Quantity = additional units needed)

ServiceName: Azure Route Server
SkuName: Routing Infrastructure Unit
MeterName: Routing Infrastructure Unit
Region: Global
Quantity: 2

### Multiple Route Server instances (InstanceCount = number of deployments)

ServiceName: Azure Route Server
SkuName: Basic
MeterName: Basic Gateway
Region: Global
InstanceCount: 3

## Key Fields

| Parameter     | How to determine                                                | Example values                                 |
| ------------- | --------------------------------------------------------------- | ---------------------------------------------- |
| `serviceName` | Always `Azure Route Server`                                     | `Azure Route Server`                           |
| `productName` | Single product for all meters                                   | `Azure Route Server`                           |
| `skuName`     | `Basic` for gateway, `Routing Infrastructure Unit` for scaling  | `Basic`, `Routing Infrastructure Unit`         |
| `meterName`   | Matches the billing component                                   | `Basic Gateway`, `Routing Infrastructure Unit` |

## Meter Names

| Meter                         | skuName                       | unitOfMeasure | Notes                                |
| ----------------------------- | ----------------------------- | ------------- | ------------------------------------ |
| `Basic Gateway`               | `Basic`                       | 1 Hour        | Always-on base deployment fee        |
| `Routing Infrastructure Unit` | `Routing Infrastructure Unit` | 1 Hour        | Per additional unit beyond default 2 |

## Cost Formula

```
Gateway monthly       = gateway_retailPrice × 730 × instanceCount
Scaling units monthly = unit_retailPrice × 730 × max(0, ceil((vmCount - 4000) / 1000))
Total monthly         = Gateway + Scaling units
```

## Notes

- **Always-on cost**: Route Server bills per-hour from deployment — minimum monthly cost even with zero BGP sessions
- **Default capacity**: Base deployment includes 2 routing infrastructure units supporting up to 4,000 VMs in the VNet and peered VNets
- **Scaling**: Beyond 4,000 VMs, Route Server auto-scales by 1 unit per additional 1,000 VMs (max 50,000 VMs total)
- **BGP limits**: Max 8 BGP peers per Route Server, 4,000 routes per BGP peer, 500 peered VNets
- **Public IP required**: Each Route Server requires a Standard Static Public IP — billed separately under IP Addresses
- **Data transfer**: Route Server does not charge for routes processed or BGP sessions; NVA traffic egress is billed separately under Bandwidth
- **Related services**: Commonly deployed alongside VPN Gateway or ExpressRoute for transit routing scenarios
