---
serviceName: VPN Gateway
category: networking
aliases: [VPN, Site-to-Site, Point-to-Site, S2S, P2S]
---

# VPN Gateway

**Primary cost**: Gateway SKU hourly rate × 730 + S2S/P2S connection fees per tunnel/connection

> **Trap**: Unfiltered queries return **gateway meters AND connection meters** combined. Gateway fees are the dominant cost while S2S/P2S connections are small per-hour charges — the `totalMonthlyCost` mixes them. Always query gateway SKU and connection meters separately.

## Query Pattern

### Gateway hourly cost — substitute {GatewayMeter} from Meter Names table

ServiceName: VPN Gateway
MeterName: {GatewayMeter}

### S2S tunnel connections (use Quantity for number of tunnels)

ServiceName: VPN Gateway
SkuName: {GatewaySku}
MeterName: S2S Connection
Quantity: 2

### P2S client connections (use Quantity for concurrent connections)

ServiceName: VPN Gateway
SkuName: {GatewaySku}
MeterName: P2S Connection
Quantity: 50

> **Gateway placeholders**: `{GatewayMeter}` (for `MeterName`) = Basic Gateway, VpnGw1, VpnGw1AZ, VpnGw2, VpnGw2AZ, VpnGw3, VpnGw3AZ, VpnGw4, VpnGw4AZ, VpnGw5, VpnGw5AZ. `{GatewaySku}` (for `SkuName`) = Basic, VpnGw1, VpnGw1AZ, VpnGw2, VpnGw2AZ, VpnGw3, VpnGw3AZ, VpnGw4, VpnGw4AZ, VpnGw5, VpnGw5AZ. AZ variants are zone-redundant.

## Key Fields

| Parameter     | How to determine                     | Example values                             |
| ------------- | ------------------------------------ | ------------------------------------------ |
| `serviceName` | Always `VPN Gateway`                 | `VPN Gateway`                              |
| `productName` | Single product for all meters        | `VPN Gateway`                              |
| `skuName`     | Matches the gateway SKU deployed     | `Basic`, `VpnGw1`, `VpnGw2AZ`, `VpnGw5`   |
| `meterName`   | SKU name for gateway; connection type for tunnels | `VpnGw2AZ`, `S2S Connection`, `P2S Connection` |

## Meter Names

| Meter                        | skuName        | unitOfMeasure | Notes                          |
| ---------------------------- | -------------- | ------------- | ------------------------------ |
| `Basic Gateway`              | `Basic`        | 1 Hour        | Legacy SKU, limited throughput |
| `VpnGw1` / `VpnGw1AZ`       | matching       | 1 Hour        | ~650 Mbps, 250 S2S tunnels     |
| `VpnGw2` / `VpnGw2AZ`       | matching       | 1 Hour        | ~1 Gbps, 500 S2S tunnels       |
| `VpnGw3` / `VpnGw3AZ`       | matching       | 1 Hour        | ~1.25 Gbps, 1000 S2S tunnels   |
| `VpnGw4` / `VpnGw4AZ`       | matching       | 1 Hour        | ~5 Gbps, 5000 S2S tunnels      |
| `VpnGw5` / `VpnGw5AZ`       | matching       | 1 Hour        | ~10 Gbps, 10000 S2S tunnels    |
| `S2S Connection`             | per SKU        | 1 Hour        | Per site-to-site VPN tunnel    |
| `P2S Connection`             | per SKU        | 1 Hour        | Per point-to-site client       |
| `Advanced Connectivity Add-On` | `Advanced Connectivity Add-On` | 1 Hour | Optional add-on for advanced routing |

## Cost Formula

```
Gateway monthly    = gateway_retailPrice × 730
S2S monthly        = s2s_retailPrice × 730 × tunnelCount
P2S monthly        = p2s_retailPrice × 730 × concurrentConnections
Total monthly      = Gateway + S2S + P2S
```

## Notes

- **S2S/P2S connections bill separately** from the gateway — S2S is per tunnel, P2S is per concurrent connection
- **AZ variants** provide zone redundancy at a slightly higher cost than non-AZ equivalents
- **Basic SKU** is legacy with limited features (no BGP, no IKEv2, no P2S OpenVPN) — use VpnGw1+ for production
- **Data transfer**: Outbound data egress is billed separately under the Bandwidth service, not VPN Gateway
- Reserved pricing is not available for VPN Gateway
- **Companion service**: Often deployed alongside ExpressRoute for failover connectivity
