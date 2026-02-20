---
serviceName: Virtual Network
category: networking
aliases: [VNet, Peering]
primaryCost: "VNet peering per-GB (bidirectional) + public IP hourly rate × 730 × ipCount"
---

# Virtual Network

> **Trap (multiple products)**: `serviceName: Virtual Network` contains distinct products (IP Addresses, VNet Peering, Global VNet Peering, Private Link). Always include `ProductName` to isolate the component. Unfiltered queries return all products combined.

> **Trap (bidirectional peering)**: VNet peering charges BOTH ingress and egress. A 100 GB transfer between peered VNets incurs 200 GB × rate. Always calculate both directions.

> **Trap (peering region)**: Intra-region peering meters exist only in `Region: Global`. Inter-region peering meters are regional (rate varies by zone pairing). Use the correct region parameter for each type.

## Query Pattern

### Standard Public IP (InstanceCount = number of IPs)

ServiceName: Virtual Network
ProductName: IP Addresses
SkuName: Standard
MeterName: Standard IPv4 Static Public IP
InstanceCount: 3

### Intra-region VNet peering (Quantity = GB transferred per direction)

ServiceName: Virtual Network
ProductName: Virtual Network Peering
MeterName: Intra-Region Ingress
Region: Global
Quantity: 500

### Inter-region VNet peering — substitute {direction} with Ingress or Egress

ServiceName: Virtual Network
ProductName: Global Virtual Network Peering
MeterName: Inter-Region {direction}

## Key Fields

| Parameter     | How to determine                 | Example values                                            |
| ------------- | -------------------------------- | --------------------------------------------------------- |
| `serviceName` | Always `Virtual Network`         | `Virtual Network`                                         |
| `productName` | Select by cost component         | `IP Addresses`, `Virtual Network Peering`                 |
| `skuName`     | Varies by product                | `Standard`, `Basic`, `Intra-Region`, `Inter-Region`       |
| `meterName`   | Specific meter within product    | `Standard IPv4 Static Public IP`, `Intra-Region Ingress`  |

## Meter Names

| Meter | skuName | productName | unitOfMeasure | Notes |
| ----- | ------- | ----------- | ------------- | ----- |
| `Standard IPv4 Static Public IP` | `Standard` | `IP Addresses` | `1 Hour` | Production default; zone-redundant |
| `Basic IPv4 Static Public IP` | `Basic` | `IP Addresses` | `1 Hour` | Legacy; no zone redundancy |
| `Basic IPv4 Dynamic Public IP` | `Basic` | `IP Addresses` | `1 Hour` | Free when attached to running VM |
| `Global IPv4 Static Public IP` | `Global` | `IP Addresses` | `1 Hour` | Cross-region services (e.g., Front Door) |
| `Intra-Region Ingress` | `Intra-Region` | `Virtual Network Peering` | `1 GB` | Region: Global required |
| `Intra-Region Egress` | `Intra-Region` | `Virtual Network Peering` | `1 GB` | Region: Global required |
| `Inter-Region Ingress` | `Inter-Region` | `Global Virtual Network Peering` | `1 GB` | Regional; rate varies by zone pair |
| `Inter-Region Egress` | `Inter-Region` | `Global Virtual Network Peering` | `1 GB` | Regional; rate varies by zone pair |

> Other products under this serviceName: Public IP Prefix, Accelerated Connections, Azure Virtual Network Manager, Virtual Network TAP. Private Endpoints — see `networking/private-link.md`.

## Cost Formula

```
PublicIP  = ip_retailPrice × 730 × ipCount
Peering  = (ingress_retailPrice × ingressGB) + (egress_retailPrice × egressGB)
Monthly  = PublicIP + Peering
```

## Notes

- VNets, subnets, route tables, and NSGs are free — no API meters for these resources
- Basic Public IPs are being retired — use Standard SKU for new deployments
- Standard IPs are static-only and zone-redundant by default
- Inter-region peering rates vary by zone pairing (same continent vs cross-continent)
- VNet flow logs are billed under `Network Watcher` — not under this serviceName
- Private endpoints share this `serviceName` — see `networking/private-link.md` for PE pricing
- VPN/ExpressRoute connectivity — see `networking/vpn-gateway.md` and `networking/express-route.md`
- NAT Gateway is billed separately under its own service
