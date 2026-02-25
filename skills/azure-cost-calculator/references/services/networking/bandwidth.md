---
serviceName: Bandwidth
category: networking
aliases: [Data Transfer, Egress, Outbound Transfer, Inter-region Transfer]
primaryCost: "Per-GB egress rate × monthly GB out (tiered; first 100 GB free)"
hasFreeGrant: true
---

# Bandwidth

> **Trap (tiered pricing)**: Egress meters use **volume-based tiers** — the API returns multiple rows per meter with different `tierMinimumUnits`. Each row's `retailPrice` applies only to GB within that tier. Do NOT sum retailPrices — calculate each tier's cost separately. First 100 GB/month is free.

> **Trap (two products)**: `serviceName: Bandwidth` contains two products: `Rtn Preference: MGN` (Microsoft Global Network — default) and `Bandwidth - Routing Preference: Internet` (cheaper, uses ISP network). Always filter by `ProductName` to isolate the routing preference. Most deployments use MGN (default).

> **Trap (ingress free)**: Inbound data transfer (`Standard Data Transfer In`) is free (zero price). Only outbound (egress) and inter-region/inter-AZ transfers incur charges.

## Query Pattern

### Internet egress — default MGN routing (Quantity = estimated monthly GB out)

ServiceName: Bandwidth
ProductName: Rtn Preference: MGN
MeterName: Standard Data Transfer Out
Region: eastus
Quantity: 500

### Inter-region data transfer (Quantity = GB transferred between regions)

ServiceName: Bandwidth
ProductName: Rtn Preference: MGN
MeterName: Standard Inter-Region Data Transfer
Region: eastus
Quantity: 200

### Inter-AZ transfer — substitute {direction} with In or Out

ServiceName: Bandwidth
ProductName: Rtn Preference: MGN
MeterName: Standard Inter-Availability Zone Data Transfer {direction}
Quantity: 100

### Internet egress — Internet routing preference (cheaper alternative)

ServiceName: Bandwidth
ProductName: Bandwidth - Routing Preference: Internet
MeterName: Standard Data Transfer Out
Quantity: 500

## Key Fields

| Parameter     | How to determine                        | Example values                               |
| ------------- | --------------------------------------- | -------------------------------------------- |
| `serviceName` | Always `Bandwidth`                      | `Bandwidth`                                  |
| `productName` | Routing preference                      | `Rtn Preference: MGN`, `Bandwidth - Routing Preference: Internet` |
| `skuName`     | Always `Standard` for common meters     | `Standard`                                   |
| `meterName`   | Transfer type and direction             | `Standard Data Transfer Out`                 |

## Meter Names

| Meter | productName | unitOfMeasure | Notes |
| ----- | ----------- | ------------- | ----- |
| `Standard Data Transfer Out` | `Rtn Preference: MGN` | `1 GB` | Internet egress; tiered by volume |
| `Standard Data Transfer In` | `Rtn Preference: MGN` | `1 GB` | Always zero — ingress is free |
| `Standard Inter-Region Data Transfer` | `Rtn Preference: MGN` | `1 GB` | Between Azure regions; flat per-GB |
| `Standard Inter-Availability Zone Data Transfer In` | `Rtn Preference: MGN` | `1 GB` | Within region, cross-AZ inbound |
| `Standard Inter-Availability Zone Data Transfer Out` | `Rtn Preference: MGN` | `1 GB` | Within region, cross-AZ outbound |
| `Standard Data Transfer Out` | `Bandwidth - Routing Preference: Internet` | `1 GB` | Internet routing; tiered, lower rates |

## Cost Formula

```
Egress monthly       = sum of (tier_retailPrice × GB_in_tier) for each tier
Inter-region monthly = interRegion_retailPrice × transferGB
Inter-AZ monthly     = (azIn_retailPrice × inboundGB) + (azOut_retailPrice × outboundGB)
Total monthly        = Egress + Inter-region + Inter-AZ
```

## Notes

- **Free grant**: First 100 GB/month of internet egress is free (both MGN and Internet routing)
- **Tiered egress**: Rates decrease with volume — query returns multiple rows with `tierMinimumUnits`; apply each tier's rate only to GB within that tier's range
- **Inter-AZ**: Per-GB rate each direction; charges both in and out separately — query each meter independently
- **Inter-region**: Flat per-GB rate; varies by region pair — always query with the source region
- **Routing preference**: MGN (default) routes via Microsoft backbone; Internet routing uses ISP network at lower cost
- **Shared billing**: Many Azure services (VMs, App Service, Storage) generate bandwidth charges — those egress costs appear under Bandwidth, not under the originating service
- **VNet peering**: Billed separately under `Virtual Network` — see `networking/virtual-network.md`
