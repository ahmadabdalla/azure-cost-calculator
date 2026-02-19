---
serviceName: VPN Gateway
category: networking
aliases: [VPN, Site-to-Site, Point-to-Site, S2S, P2S]
billingNeeds: [IP Addresses]
primaryCost: "Gateway SKU hourly rate × 730 + S2S tunnels beyond 10 free + P2S per-connection"
---

# VPN Gateway

> **Trap (S2S included tunnels)**: All VpnGw1+ SKUs include **10 S2S tunnels free** in the base gateway price. Basic SKU supports max 10 tunnels total (cannot exceed 10). The API always returns a non-zero `S2S Connection` rate regardless of SKU — do NOT multiply it by total tunnel count. Only tunnels beyond the first 10 incur the per-tunnel hourly charge. Applying the S2S rate to all tunnels grossly inflates the estimate.
>
> **Agent instruction**: For Basic SKU, S2S cost is always zero (max 10 tunnels, all included). For VpnGw1+, calculate S2S cost as `max(0, tunnelCount - 10) × s2s_retailPrice × 730`.

> **Trap**: Unfiltered queries return **gateway meters AND connection meters** combined — always query gateway SKU and connection meters separately.

## Query Pattern

### Gateway hourly cost — substitute {GatewayMeter} from Meter Names table

ServiceName: VPN Gateway
MeterName: {GatewayMeter}

### S2S tunnel connections (only needed when tunnelCount > 10)

ServiceName: VPN Gateway
SkuName: {GatewaySku}
MeterName: S2S Connection
Quantity: 5

### P2S client connections (use Quantity for concurrent connections)

ServiceName: VPN Gateway
SkuName: {GatewaySku}
MeterName: P2S Connection
Quantity: 50

> **Gateway placeholders**: `{GatewayMeter}` (for `MeterName`) = Basic Gateway, VpnGw1, VpnGw1AZ, VpnGw2, VpnGw2AZ, VpnGw3, VpnGw3AZ, VpnGw4, VpnGw4AZ, VpnGw5, VpnGw5AZ. `{GatewaySku}` (for `SkuName`) uses the same values. AZ variants are zone-redundant.

## Key Fields

| Parameter     | How to determine                                  | Example values                                 |
| ------------- | ------------------------------------------------- | ---------------------------------------------- |
| `serviceName` | Always `VPN Gateway`                              | `VPN Gateway`                                  |
| `productName` | Single product for all meters                     | `VPN Gateway`                                  |
| `skuName`     | Matches the gateway SKU deployed                  | `Basic`, `VpnGw1`, `VpnGw2AZ`, `VpnGw5`        |
| `meterName`   | SKU name for gateway; connection type for tunnels | `VpnGw2AZ`, `S2S Connection`, `P2S Connection` |

## Meter Names

| Meter                          | skuName                        | unitOfMeasure | Notes                                |
| ------------------------------ | ------------------------------ | ------------- | ------------------------------------ |
| `Basic Gateway`                | `Basic`                        | 1 Hour        | Legacy SKU, limited throughput       |
| `VpnGw1` / `VpnGw1AZ`          | matching                       | 1 Hour        | ~650 Mbps, max 30 S2S tunnels        |
| `VpnGw2` / `VpnGw2AZ`          | matching                       | 1 Hour        | ~1 Gbps, max 30 S2S tunnels          |
| `VpnGw3` / `VpnGw3AZ`          | matching                       | 1 Hour        | ~1.25 Gbps, max 30 S2S tunnels       |
| `VpnGw4` / `VpnGw4AZ`          | matching                       | 1 Hour        | ~5 Gbps, max 100 S2S tunnels         |
| `VpnGw5` / `VpnGw5AZ`          | matching                       | 1 Hour        | ~10 Gbps, max 100 S2S tunnels        |
| `S2S Connection`               | per SKU                        | 1 Hour        | Only for tunnels beyond 10 included  |
| `P2S Connection`               | per SKU                        | 1 Hour        | Per point-to-site client             |
| `Advanced Connectivity Add-On` | `Advanced Connectivity Add-On` | 1 Hour        | Optional add-on for advanced routing |

## Cost Formula

```
Gateway monthly    = gateway_retailPrice × 730
S2S monthly        = s2s_retailPrice × 730 × max(0, tunnelCount - 10)
P2S monthly        = p2s_retailPrice × 730 × concurrentConnections
Total monthly      = Gateway + S2S + P2S
```

## Notes

- **10 S2S tunnels included free** in the base price for VpnGw1+ SKUs; only tunnels 11+ are billed. Basic SKU supports max 10 tunnels total (all included, cannot exceed).
- **Max S2S tunnels**: Basic 10, VpnGw1–3 30, VpnGw4–5 100 (same limits for AZ variants)
- **AZ variants** provide zone redundancy at a slightly higher cost than non-AZ equivalents
- **Basic SKU** is legacy with limited features (no BGP, no IKEv2, no P2S OpenVPN) — use VpnGw1+ for production
- **Data transfer**: Outbound data egress is billed separately under the Bandwidth service, not VPN Gateway
- **Companion service**: Often deployed alongside ExpressRoute for failover connectivity
