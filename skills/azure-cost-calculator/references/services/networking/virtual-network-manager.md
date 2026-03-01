---
serviceName: Virtual Network Manager
category: networking
aliases: [AVNM, VNet Manager, Network Manager]
apiServiceName: Virtual Network
primaryCost: "Per-VNet or per-subscription hourly management fee × 730 + optional IPAM and verifier add-ons"
pricingRegion: global
---

# Virtual Network Manager

> **Warning**: Virtual Network Manager pricing is **Global-only** — querying any standard region (e.g., `eastus`) returns zero results. Use `Region: Global`. Prices are USD-only.

> **Trap (shared serviceName)**: API `serviceName` is `Virtual Network`, shared with IP Addresses, VNet Peering, Private Link, and others. Always include `ProductName: Azure Virtual Network Manager` to isolate AVNM meters.

> **Trap (mutually exclusive billing)**: Two billing models exist — subscription-based (`Standard Subscription`) and VNet-based (`Standard Virtual Network`). They are **not additive**. Each AVNM instance uses one or the other. Ask the user which model applies before querying.

## Query Pattern

### VNet-based billing — new default (InstanceCount = managed VNets)

ServiceName: Virtual Network <!-- cross-service -->
ProductName: Azure Virtual Network Manager
SkuName: Standard
MeterName: Standard Virtual Network
Region: Global
InstanceCount: 10

### Subscription-based billing — legacy (InstanceCount = managed subscriptions)

ServiceName: Virtual Network <!-- cross-service -->
ProductName: Azure Virtual Network Manager
SkuName: Standard
MeterName: Standard Subscription
Region: Global
InstanceCount: 3

### IPAM — per active managed IP address

ServiceName: Virtual Network <!-- cross-service -->
ProductName: Azure Virtual Network Manager
SkuName: Managed IP
MeterName: Managed IP Management
Region: Global

### Network Verifier — per analysis run (Quantity = runs/month)

ServiceName: Virtual Network <!-- cross-service -->
ProductName: Azure Virtual Network Manager
SkuName: Reachability Analysis
MeterName: Reachability Analysis Diagnostic Tool API
Region: Global
Quantity: 50

## Key Fields

| Parameter     | How to determine                          | Example values                                  |
| ------------- | ----------------------------------------- | ----------------------------------------------- |
| `serviceName` | Always `Virtual Network`                  | `Virtual Network`                               |
| `productName` | Always `Azure Virtual Network Manager`    | `Azure Virtual Network Manager`                 |
| `skuName`     | Billing model or add-on feature           | `Standard`, `Managed IP`, `Reachability Analysis` |
| `meterName`   | Specific meter — see table                | `Standard Virtual Network`, `Standard Subscription` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `Standard Virtual Network` | `Standard` | `1 Hour` | VNet-based billing (new default) — per managed VNet |
| `Standard Subscription` | `Standard` | `1 Hour` | Subscription-based billing (legacy, retiring Feb 2028) |
| `Managed IP Management` | `Managed IP` | `1 Hour` | IPAM add-on — sub-cent per active IP per hour |
| `Reachability Analysis Diagnostic Tool API` | `Reachability Analysis` | `1` | Network Verifier — per analysis run, not hourly |

## Cost Formula

```
VNetBased    = vnet_retailPrice × 730 × managedVNetCount
  -- OR --
SubBased     = sub_retailPrice × 730 × managedSubCount
IPAM         = ipam_retailPrice × 730 × managedIPCount
Verifier     = verifier_retailPrice × analysisRuns
Monthly      = (VNetBased or SubBased) + IPAM + Verifier
```

## Notes

- **Billing model choice is never-assume** — subscription-based vs VNet-based are mutually exclusive; new instances default to VNet-based; subscription-based retires Feb 2028
- **VNet peering billed separately** — connectivity configurations (mesh/hub-spoke) create peerings charged under `Virtual Network Peering` — see `networking/virtual-network.md`
- **Reachability Analysis is per-call** — set `Quantity` to runs/month; the script returns `retailPrice × Quantity` correctly, but defaults to a single call when `Quantity` is omitted
- **IPAM sub-cent pricing** — Managed IP Management is sub-cent per hour; use `retailPrice` directly for accurate cost
- **Legacy product exists** — API also contains `productName: Virtual Network Manager` (no "Azure" prefix) with Zone-based pricing; use `Azure Virtual Network Manager` for current pricing
- Capacity: 1 managed VNet = one VNet with active AVNM configuration deployed; multiple configs from the same instance on one VNet = single charge
