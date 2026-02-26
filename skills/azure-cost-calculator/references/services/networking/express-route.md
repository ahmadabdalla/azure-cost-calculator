---
serviceName: ExpressRoute
category: networking
aliases: [ER, Dedicated Circuit]
primaryCost: "Circuit fee (flat monthly by bandwidth/plan) + metered data egress"
pricingRegion: empty-region
---

# ExpressRoute

> **Trap (Circuit regions)**: Circuit pricing uses **peering location zones** (`Zone 1`, `Zone 2`, etc.), not ARM regions. Circuit queries MUST use `-Region 'Zone 1'` (or the appropriate zone) — the default `eastus` returns zero results. Zone mapping: Zone 1 = US/Europe, Zone 2 = Asia Pacific/Australia/Japan, Zone 3 = Brazil/South Africa/UAE.

> **Trap (skuName collision)**: Standard and Premium circuits share the same `skuName` (e.g., `1 Gbps Metered Data`). The only differentiator is `meterName`. Always filter by `meterName`, not `skuName`.

## Query Pattern

### Circuit — substitute {Plan}, {DataModel}, {Bandwidth} from Meter Names table

ServiceName: ExpressRoute
ProductName: ExpressRoute
MeterName: {Plan} {DataModel} {Bandwidth} Circuit
Region: {Zone}

### Metered outbound data (per-GB egress on Metered circuits only)

ServiceName: ExpressRoute
ProductName: ExpressRoute
MeterName: Metered Data - Data Transfer Out
Region: {Zone}
Quantity: 500

> **Circuit placeholders**: `{Plan}` = Standard / Premium / Local. `{DataModel}` = Metered Data / Unlimited Data. `{Bandwidth}` = 50 Mbps, 100 Mbps, 200 Mbps, 500 Mbps, 1 Gbps, 2 Gbps, 5 Gbps, 10 Gbps. `{Zone}` = Zone 1 (US/Europe), Zone 2 (APAC/Australia/Japan), Zone 3 (Brazil/South Africa/UAE).

## Meter Names

| Meter                                    | skuName                 | unitOfMeasure | Notes                            |
| ---------------------------------------- | ----------------------- | ------------- | -------------------------------- |
| `Standard Metered Data 1 Gbps Circuit`   | `1 Gbps Metered Data`   | 1/Month       | Flat monthly + per-GB egress     |
| `Standard Unlimited Data 1 Gbps Circuit` | `1 Gbps Unlimited Data` | 1/Month       | Flat monthly, no egress charge   |
| `Premium Metered Data 1 Gbps Circuit`    | `1 Gbps Metered Data`   | 1/Month       | Global routing + per-GB egress   |
| `Premium Unlimited Data 1 Gbps Circuit`  | `1 Gbps Unlimited Data` | 1/Month       | Global routing, no egress charge |
| `Metered Data - Data Transfer Out`       | `1 Gbps Metered Data`   | 1 GB          | Outbound data on metered plans   |

> Circuit bandwidths available: 50 Mbps, 100 Mbps, 200 Mbps, 500 Mbps, 1 Gbps, 2 Gbps, 5 Gbps, 10 Gbps. Replace `1 Gbps` in skuName/meterName patterns above.

## Cost Formula

```
Circuit monthly  = circuit_retailPrice  (already a monthly rate)
Egress (metered) = egress_retailPrice × estimatedGB  (Unlimited plans: $0)
Total monthly    = Circuit + Egress
```

## Notes

- **Gateway billed separately**: An ExpressRoute gateway (VNet attachment) is a separate resource — see `networking/expressroute-gateway.md` for gateway pricing
- **Metered vs Unlimited**: Metered circuits have a lower base fee but charge per-GB for outbound data; Unlimited circuits include all data transfer
- **Standard vs Premium**: Premium adds global routing across all geopolitical regions; Standard is limited to one geopolitical region
- **Local circuits**: Available at select peering locations only (1/2/5/10 Gbps, Unlimited Data only) — flat monthly at reduced cost
