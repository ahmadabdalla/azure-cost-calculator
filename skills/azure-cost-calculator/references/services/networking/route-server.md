---
serviceName: Azure Route Server
category: networking
aliases: [BGP Routing]
billingNeeds: [IP Addresses]
primaryCost: "Gateway hourly rate × 730 + connection units + scaling units beyond 4,000 VMs"
pricingRegion: global
---

# Azure Route Server

> **Warning**: Route Server has no per-commercial-region meters: standard regions (e.g., `eastus`) return zero results. Use `Region: Global` for commercial cloud; a parallel `US Gov` meter set exists for government cloud at a premium. Prices are USD-only.

> **Trap**: Unfiltered queries sum all 6 meters (gateway, scaling units, Route Maps, and connection units). `totalMonthlyCost` is meaningless. Query each meter separately using `MeterName`.

> **Trap (scaling units)**: The base gateway price includes **2 routing infrastructure units** supporting 4,000 VMs. The `Routing Infrastructure Unit` meter is for **additional** units only. Do NOT add 2 × unit cost to the base. Those are already included.

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

> Example: 6,000 VMs requires ceil((6000 − 4000) / 1000) = 2 additional units beyond the included 2

### Route Maps add-on gateway (only if Route Maps feature is enabled)

ServiceName: Azure Route Server
SkuName: Basic Gateway with Route Maps
MeterName: Basic Gateway with Route Maps Unit
Region: Global

### Connection units (Quantity = number of connections; requires upgraded software)

ServiceName: Azure Route Server
SkuName: VPN S2S Connection Unit
MeterName: VPN S2S Connection Unit
Region: Global
Quantity: 5

> Substitute `ExpressRoute Connection Unit` or `NVA Connection with Route Maps` / `NVA Connection with Route Maps Unit` for other connection types

### Multiple Route Server instances (InstanceCount = number of deployments)

ServiceName: Azure Route Server
SkuName: Basic
MeterName: Basic Gateway
Region: Global
InstanceCount: 3

## Key Fields

| Parameter     | How to determine                                                              | Example values                                                           |
| ------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| `serviceName` | Always `Azure Route Server`                                                   | `Azure Route Server`                                                     |
| `productName` | Single product for all meters                                                 | `Azure Route Server`                                                     |
| `skuName`     | Matches the billing component (see Meter Names)                               | `Basic`, `Routing Infrastructure Unit`, `VPN S2S Connection Unit`        |
| `meterName`   | Matches the billing component                                                 | `Basic Gateway`, `Routing Infrastructure Unit`, `VPN S2S Connection Unit`|

## Meter Names

| Meter                                  | skuName                          | unitOfMeasure | Notes                                          |
| -------------------------------------- | -------------------------------- | ------------- | ---------------------------------------------- |
| `Basic Gateway`                        | `Basic`                          | 1 Hour        | Always-on base deployment fee                  |
| `Routing Infrastructure Unit`          | `Routing Infrastructure Unit`    | 1 Hour        | Per additional unit beyond default 2           |
| `Basic Gateway with Route Maps Unit`   | `Basic Gateway with Route Maps`  | 1 Hour        | Add-on when Route Maps feature is enabled      |
| `ExpressRoute Connection Unit`         | `ExpressRoute Connection Unit`   | 1 Hour        | Per ER circuit connected (upgraded SW only)    |
| `NVA Connection with Route Maps Unit`  | `NVA Connection with Route Maps` | 1 Hour        | Per NVA connection with Route Maps applied     |
| `VPN S2S Connection Unit`              | `VPN S2S Connection Unit`        | 1 Hour        | Per VPN branch site connected (upgraded SW only)|

## Cost Formula

```
Gateway monthly       = gateway_retailPrice × 730
Scaling units monthly = unit_retailPrice × 730 × max(0, ceil((vmCount - 4000) / 1000))
Route Maps monthly    = routeMaps_retailPrice × 730 (if enabled)
Connections monthly   = connection_retailPrice × 730 × connectionCount
Total monthly         = (Gateway + Scaling + Route Maps + Connections) × instanceCount
```

## Notes

- **Always-on cost**: Route Server bills per-hour from deployment. Minimum monthly cost even with zero BGP sessions
- **Default capacity**: Base deployment includes 2 routing infrastructure units supporting up to 4,000 VMs in the VNet and peered VNets
- **Scaling**: Beyond 4,000 VMs, Route Server auto-scales by 1 unit per additional 1,000 VMs (max 50,000 VMs = 46 additional units)
- **Connection units**: VPN S2S and ExpressRoute connection meters apply only after upgrading Route Server to the latest software version
- **Public IP required**: Each Route Server requires a Standard Static Public IP, billed separately under IP Addresses
- **Data transfer**: Route Server does not charge for routes processed or BGP sessions; NVA traffic egress is billed separately under Bandwidth
