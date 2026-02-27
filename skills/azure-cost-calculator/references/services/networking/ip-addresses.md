---
serviceName: IP Addresses
category: networking
aliases: [Public IP, PIP, Public IP Address]
apiServiceName: Virtual Network
primaryCost: "Per-hour IPv4 rate × 730 × ipCount"
---

# IP Addresses

> **Trap (product filter)**: API `serviceName` is `Virtual Network`, which contains many products (IP Addresses, VNet Peering, Private Link, etc.). Always include `ProductName: IP Addresses` to isolate Public IP meters.

> **Note (IPv6)**: IPv6 public IPs are free — no meters exist in the API. Only IPv4 addresses incur charges.

## Query Pattern

### Standard Static Public IP (InstanceCount = number of IPs)

ServiceName: Virtual Network <!-- cross-service -->
ProductName: IP Addresses
SkuName: Standard
MeterName: Standard IPv4 Static Public IP
InstanceCount: 3

### Basic Dynamic Public IP

ServiceName: Virtual Network <!-- cross-service -->
ProductName: IP Addresses
SkuName: Basic
MeterName: Basic IPv4 Dynamic Public IP

### Global Static Public IP (cross-region services like Front Door)

ServiceName: Virtual Network <!-- cross-service -->
ProductName: IP Addresses
SkuName: Global
MeterName: Global IPv4 Static Public IP

## Key Fields

| Parameter     | How to determine              | Example values                   |
| ------------- | ----------------------------- | -------------------------------- |
| `serviceName` | Always `Virtual Network`      | `Virtual Network`                |
| `productName` | Always `IP Addresses`         | `IP Addresses`                   |
| `skuName`     | Matches the IP SKU deployed   | `Basic`, `Standard`, `Global`    |
| `meterName`   | Tier-prefixed IPv4 meter name | `Standard IPv4 Static Public IP` |

## Meter Names

| Meter                            | skuName    | unitOfMeasure | Notes                                         |
| -------------------------------- | ---------- | ------------- | --------------------------------------------- |
| `Standard IPv4 Static Public IP` | `Standard` | `1 Hour`      | Production default; zone-redundant             |
| `Basic IPv4 Static Public IP`    | `Basic`    | `1 Hour`      | Legacy; no zone redundancy                     |
| `Basic IPv4 Dynamic Public IP`   | `Basic`    | `1 Hour`      | Free when attached to running VM               |
| `Global IPv4 Static Public IP`   | `Global`   | `1 Hour`      | Cross-region services (Front Door, Global LB)  |

> Public IP Prefix meters also exist under `productName: Public IP Prefix` — billed per IP in the prefix at a higher hourly rate.

## Cost Formula

```
Monthly = ip_retailPrice × 730 × ipCount
```

## Notes

- Basic Public IPs were retired September 30, 2025 — use Standard SKU for new deployments
- Standard IPs are static-only and zone-redundant by default
- Basic Dynamic IPs are free when attached to a running VM — charged only when idle or unattached
- IPv6 Public IPs are [free](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses) (no API meters)
- Public IP Prefix reserves a contiguous range — billed per IP in the range
