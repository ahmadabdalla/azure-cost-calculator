---
serviceName: VPN Gateway
category: networking
aliases: [VPN, Site-to-Site, Point-to-Site, S2S, P2S]
billingNeeds: [IP Addresses]
primaryCost: "Gateway SKU hourly rate × 730 + S2S tunnels beyond 10 free + P2S beyond 128 free"
---

# VPN Gateway

> **Trap (S2S included tunnels)**: All VpnGw1+ SKUs include **10 S2S tunnels free** in the base gateway price. Basic SKU supports max 10 tunnels total (cannot exceed 10). The API always returns a non-zero `S2S Connection` rate regardless of SKU — do NOT multiply it by total tunnel count. Only tunnels beyond the first 10 incur the per-tunnel hourly charge. Applying the S2S rate to all tunnels grossly inflates the estimate.
>
> **Agent instruction**: For Basic SKU, S2S cost is always zero (max 10 tunnels, all included). For VpnGw1+, calculate S2S cost as `max(0, tunnelCount - 10) × s2s_retailPrice × 730`.

> **Trap (P2S included connections)**: All SKUs include **128 P2S connections free** in the base gateway price. The API returns a non-zero `P2S Connection` rate regardless — only connections beyond 128 incur charges. Basic SKU max is 128 (all free, no P2S charge possible).
>
> **Agent instruction**: Calculate P2S cost as `max(0, concurrentConnections - 128) × p2s_retailPrice × 730`.

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

### P2S client connections (only needed when concurrentConnections > 128)

ServiceName: VPN Gateway
SkuName: {GatewaySku}
MeterName: P2S Connection
Quantity: 50

> **Gateway placeholders**: `{GatewayMeter}` (for `MeterName`) = Basic Gateway, VpnGw1, VpnGw1AZ, VpnGw2, VpnGw2AZ, VpnGw3, VpnGw3AZ, VpnGw4, VpnGw4AZ, VpnGw5, VpnGw5AZ. `{GatewaySku}` (for `SkuName`) uses the same values. For VpnGw4AZ/VpnGw5AZ P2S/S2S queries, use VpnGw4/VpnGw5 — the API lacks connection meters for those AZ SKUs.

## Key Fields

| Parameter     | How to determine                                  | Example values                                 |
| ------------- | ------------------------------------------------- | ---------------------------------------------- |
| `serviceName` | Always `VPN Gateway`                              | `VPN Gateway`                                  |
| `productName` | Primary product for all standard meters           | `VPN Gateway`                                  |
| `skuName`     | Matches the gateway SKU deployed                  | `Basic`, `VpnGw1`, `VpnGw2AZ`, `VpnGw5`        |
| `meterName`   | SKU name for gateway; connection type for tunnels | `VpnGw2AZ`, `S2S Connection`, `P2S Connection` |

## Meter Names

| Meter                          | skuName                        | unitOfMeasure | Notes                                |
| ------------------------------ | ------------------------------ | ------------- | ------------------------------------ |
| `Basic Gateway`                | `Basic`                        | 1 Hour        | Legacy SKU, 100 Mbps                 |
| `VpnGw1` / `VpnGw1AZ`          | matching                       | 1 Hour        | 650 Mbps, max 30 S2S tunnels         |
| `VpnGw2` / `VpnGw2AZ`          | matching                       | 1 Hour        | 1 / 1.25 Gbps (AZ), max 30 S2S      |
| `VpnGw3` / `VpnGw3AZ`          | matching                       | 1 Hour        | 1.25 / 2.5 Gbps (AZ), max 30 S2S    |
| `VpnGw4` / `VpnGw4AZ`          | matching                       | 1 Hour        | 5 Gbps, max 100 S2S tunnels          |
| `VpnGw5` / `VpnGw5AZ`          | matching                       | 1 Hour        | 10 Gbps, max 100 S2S tunnels         |
| `S2S Connection`               | per SKU                        | 1 Hour        | Only for tunnels beyond 10 included  |
| `P2S Connection`               | per SKU                        | 1 Hour        | Only beyond 128 included connections |
| `Advanced Connectivity Add-On` | `Advanced Connectivity Add-On` | 1 Hour        | VpnGw5AZ only; boosts to 20 Gbps    |

## Cost Formula

```
Gateway monthly    = gateway_retailPrice × 730
S2S monthly        = s2s_retailPrice × 730 × max(0, tunnelCount - 10)
P2S monthly        = p2s_retailPrice × 730 × max(0, concurrentConnections - 128)
Total monthly      = Gateway + S2S + P2S
```

## Notes

- **10 S2S tunnels included free** in base price for all SKUs; only tunnels 11+ are billed. Basic max 10 (all included, cannot exceed).
- **128 P2S connections included free** in base price for all SKUs; only connections 129+ are billed. Basic max 128 (all included).
- **Max S2S tunnels**: Basic 10, VpnGw1–3 30, VpnGw4–5 100 (same limits for AZ variants)
- **AZ variants** provide zone redundancy at higher cost; VpnGw2AZ/VpnGw3AZ have higher throughput than non-AZ
- **Basic SKU** is legacy with limited features (no BGP, no IKEv2, no P2S OpenVPN) — use VpnGw1+ for production
- **Data transfer**: Outbound data egress is billed separately under the Bandwidth service, not VPN Gateway
- **VpnGw4AZ/VpnGw5AZ**: API lacks P2S/S2S connection meters for these SKUs; use non-AZ variant meters (same rates)
