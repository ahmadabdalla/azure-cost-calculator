---
serviceName: ExpressRoute
category: networking
aliases: [ER, Dedicated Circuit]
---

# ExpressRoute

**Primary cost**: Circuit fee (flat monthly by bandwidth/plan) + gateway hourly cost

> **Trap**: Unfiltered queries return **circuit meters AND gateway meters** combined. Circuit fees are flat monthly rates while gateways are hourly — the `totalMonthlyCost` is meaningless. Always query circuits and gateways separately.
> **Trap (Circuit regions)**: Circuit pricing uses **peering location zones** (`Zone 1`, `Zone 2`, etc.), not ARM regions. Circuit queries MUST use `-Region 'Zone 1'` (or the appropriate zone) — the default `eastus` returns zero results. Zone mapping: Zone 1 = US/Europe, Zone 2 = Asia Pacific/Australia/Japan, Zone 3 = Brazil/South Africa/UAE.

## Query Pattern

```powershell
# Gateway — zone-redundant (most common) — use -InstanceCount for multiple gateways
.\Get-AzurePricing.ps1 `
    -ServiceName 'ExpressRoute' `
    -ProductName 'ExpressRoute Gateway' `
    -MeterName 'ErGw2AZ Gateway' `
    -InstanceCount 1

# Circuit — Standard Metered 1 Gbps (flat monthly fee, Zone 1 = US/Europe)
.\Get-AzurePricing.ps1 `
    -ServiceName 'ExpressRoute' `
    -ProductName 'ExpressRoute' `
    -MeterName 'Standard Metered Data 1 Gbps Circuit' `
    -Region 'Zone 1'

# Circuit — Standard Unlimited 1 Gbps
.\Get-AzurePricing.ps1 `
    -ServiceName 'ExpressRoute' `
    -ProductName 'ExpressRoute' `
    -MeterName 'Standard Unlimited Data 1 Gbps Circuit' `
    -Region 'Zone 1'

# Circuit — Premium Metered 1 Gbps (adds global reach)
.\Get-AzurePricing.ps1 `
    -ServiceName 'ExpressRoute' `
    -ProductName 'ExpressRoute' `
    -MeterName 'Premium Metered Data 1 Gbps Circuit' `
    -Region 'Zone 1'

# Metered outbound data (per-GB egress on Metered circuits)
.\Get-AzurePricing.ps1 `
    -ServiceName 'ExpressRoute' `
    -ProductName 'ExpressRoute' `
    -SkuName '1 Gbps Metered Data' `
    -MeterName 'Metered Data - Data Transfer Out' `
    -Quantity 1000 `
    -Region 'Zone 1'
```

## Meter Names — Gateways

| Meter                            | productName                                    | unitOfMeasure | Notes                              |
| -------------------------------- | ---------------------------------------------- | ------------- | ---------------------------------- |
| `Standard Gateway`               | `ExpressRoute Standard Gateway`                | 1 Hour        | Non-AZ, basic throughput           |
| `High Performance Gateway`       | `ExpressRoute High Performance Gateway`        | 1 Hour        | Non-AZ, higher throughput          |
| `Ultra High Performance Gateway` | `ExpressRoute Ultra High Performance Gateway`  | 1 Hour        | Non-AZ, max throughput             |
| `ErGw1AZ Gateway`                | `ExpressRoute Gateway`                         | 1 Hour        | Zone-redundant, ~1 Gbps            |
| `ErGw2AZ Gateway`                | `ExpressRoute Gateway`                         | 1 Hour        | Zone-redundant, ~2 Gbps            |
| `ErGw3AZ Gateway`                | `ExpressRoute Gateway`                         | 1 Hour        | Zone-redundant, ~10 Gbps           |
| `ErGwScale Unit`                 | `ExpressRoute Gateway`                         | 1 Hour        | Scalable gateway, per scale unit   |

## Meter Names — Circuits (sample for 1 Gbps)

| Meter                                    | skuName                | unitOfMeasure | Notes                           |
| ---------------------------------------- | ---------------------- | ------------- | ------------------------------- |
| `Standard Metered Data 1 Gbps Circuit`   | `1 Gbps Metered Data`  | 1/Month       | Flat monthly + per-GB egress    |
| `Standard Unlimited Data 1 Gbps Circuit` | `1 Gbps Unlimited Data`| 1/Month       | Flat monthly, no egress charge  |
| `Premium Metered Data 1 Gbps Circuit`    | `1 Gbps Metered Data`  | 1/Month       | Global routing + per-GB egress  |
| `Premium Unlimited Data 1 Gbps Circuit`  | `1 Gbps Unlimited Data`| 1/Month       | Global routing, no egress charge|
| `Metered Data - Data Transfer Out`       | `1 Gbps Metered Data`  | 1 GB          | Outbound data on metered plans  |

> Circuit bandwidths available: 50 Mbps, 100 Mbps, 200 Mbps, 500 Mbps, 1 Gbps, 2 Gbps, 5 Gbps, 10 Gbps. Replace `1 Gbps` in skuName/meterName patterns above.

## Cost Formula

```
Gateway monthly  = gateway_retailPrice × 730
Circuit monthly  = circuit_retailPrice  (already a monthly rate)
Egress (metered) = egress_retailPrice × estimatedGB  (Unlimited plans: $0)
Total monthly    = Gateway + Circuit + Egress
```

## Notes

- **Two independent resources**: A circuit (connectivity to provider) and a gateway (VNet attachment) are billed separately
- **Metered vs Unlimited**: Metered circuits have a lower base fee but charge per-GB for outbound data; Unlimited circuits include all data transfer
- **Standard vs Premium**: Premium adds global routing across all geopolitical regions; Standard is limited to one geopolitical region
- **Local circuits**: Available at select peering locations co-located with Azure regions — flat monthly with unlimited data at reduced cost
- Reserved pricing is not available for ExpressRoute
- **Gateway capacity**: ErGw1AZ ≈ 1 Gbps, ErGw2AZ ≈ 2 Gbps, ErGw3AZ ≈ 10 Gbps; ErGwScale bills per scale unit (~1 Gbps each, multiply unit price by count needed)
