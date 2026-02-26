---
serviceName: Virtual WAN
category: networking
aliases: [vWAN, WAN Hub]
primaryCost: "Hub hourly rate × 730 + data processed per-GB + gateway scale-unit and connection-unit hours"
hasFreeGrant: true
---

# Virtual WAN

> **Trap**: Unfiltered queries sum **17 meters** (hub + VPN + ExpressRoute + NVA + data processing) — always query each billing component separately.

> **Trap (Basic tier)**: Basic WAN type is free with **no API meters**. Only Standard hubs incur charges.

## Query Pattern

### Standard Hub deployment (always-on base cost)

ServiceName: Virtual WAN
SkuName: Standard Hub
MeterName: Standard Hub Unit

### Hub data processing (per-GB through hub router)

ServiceName: Virtual WAN
SkuName: Standard Hub
MeterName: Standard Hub Data Processed
Quantity: 500

### VPN S2S gateway — scale units (500 Mbps each)

ServiceName: Virtual WAN
SkuName: VPN S2S Scale Unit
MeterName: VPN S2S Scale Unit
InstanceCount: 2

### VPN S2S connections (per branch site)

ServiceName: Virtual WAN
SkuName: VPN S2S Connection Unit
MeterName: VPN S2S Connection Unit
Quantity: 10

### ExpressRoute gateway — scale units 1–5 (2 Gbps each)

ServiceName: Virtual WAN
SkuName: ExpressRoute Scale Unit
MeterName: ExpressRoute Scale Unit
InstanceCount: 3

> **Note**: ER units 6–10 use `SkuName: ExpressRoute Additional Scale Unit` at a lower rate. VPN P2S queries follow the S2S pattern — substitute `VPN P2S Scale Unit` / `VPN P2S Connection Unit`.

## Key Fields

| Parameter | How to determine | Example values |
| --------- | ---------------- | -------------- |
| `serviceName` | Always `Virtual WAN` | `Virtual WAN` |
| `productName` | Single product for all meters | `Virtual WAN` |
| `skuName` | Matches the meter component type | `Standard Hub`, `VPN S2S Scale Unit` |
| `meterName` | Component-specific, often matches skuName | `Standard Hub Unit`, `VPN S2S Connection Unit` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `Standard Hub Unit` | `Standard Hub` | 1 Hour | Base hub deployment (always-on) |
| `Standard Hub Data Processed` | `Standard Hub` | 1 GB | Traffic through hub router |
| `VPN S2S Scale Unit` | matching | 1 Hour | 500 Mbps per unit |
| `VPN S2S Connection Unit` | matching | 1 Hour | Per branch-site tunnel |
| `VPN P2S Scale Unit` / `VPN P2S Connection Unit` | matching | 1 Hour | P2S gateway + per-client connection |
| `VPN Policy Unit` | matching | 1 Hour | Per custom IPsec/IKE policy |
| `ExpressRoute Scale Unit` | matching | 1 Hour | Units 1–5, 2 Gbps each |
| `ExpressRoute Additional Scale Unit` | matching | 1 Hour | Units 6–10, lower rate |
| `ExpressRoute Connection Unit` | matching | 1 Hour | Per ER circuit connection |
| `Hub to Hub Transfer Unit` | `Hub to Hub Transfer` | 1 Hour | Inter-hub connectivity |
| `NVA Infrastructure Unit` | matching | 1 Hour | 500 Mbps/unit; marketplace licensing extra |
| `Routing Infrastructure Unit` | matching | 1 Hour | Auto-scales beyond 2,000 VMs |
| `App Gateway Unit` | matching | 1 Hour | App Gateway deployed in hub |
| `Firewall NVA Data Processing Data Processed` | `Firewall NVA Data Processing` | 1 GB | NVA load-balancer data |

> Also: `Standard Hub with Firewall policies for Third party security provider(s) Unit` (1 Hour) and `...Data Processed` (1 GB) replace the standard hub meters when 3rd-party Firewall Manager policies are configured.

## Cost Formula

```
Hub monthly        = hub_retailPrice × 730 + data_retailPrice × estimatedGB
S2S VPN monthly    = s2s_scale_retailPrice × 730 × scaleUnits + s2s_conn_retailPrice × 730 × connections
P2S VPN monthly    = p2s_scale_retailPrice × 730 × scaleUnits + p2s_conn_retailPrice × 730 × connections
ER monthly         = er_scale_retailPrice × 730 × min(units, 5) + er_addl_retailPrice × 730 × max(0, units - 5) + er_conn_retailPrice × 730 × connections
Optional monthly   = (hub2hub / nva / routing / appgw) retailPrice × 730 × units + fw_nva_data_retailPrice × GB
Total monthly      = Hub + S2S VPN + P2S VPN + ER + Optional (sum only deployed components)
```

## Notes

- **Basic tier** is free (S2S VPN only, no ER/P2S/inter-hub); Standard required for full features
- **Capacity**: 1 VPN scale unit = 500 Mbps; 1 ER scale unit = 2 Gbps; base hub includes 2 routing units (3 Gbps, 2,000 VMs)
- **Routing Infrastructure Unit**: auto-scales at 1 unit per additional 1,000 VMs beyond the included 2,000
- **Secured Virtual Hub**: Azure Firewall in hub is billed under `Azure Firewall`, not Virtual WAN — see `networking/firewall.md`
- **Data transfer**: outbound egress billed under Bandwidth; NVA marketplace licensing is additional to infra units
