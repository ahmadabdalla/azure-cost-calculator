---
serviceName: ExpressRoute Gateway
category: networking
aliases: [ER Gateway, ExpressRoute VNet Gateway, ErGw]
billingNeeds: [ExpressRoute]
apiServiceName: ExpressRoute
primaryCost: "Gateway SKU hourly rate × 730; ErGwScale bills per scale unit"
---

# ExpressRoute Gateway

> **Trap**: The API `serviceName` is `ExpressRoute` — shared with ExpressRoute Circuit meters. Unfiltered queries return both circuit (monthly flat rates) and gateway (hourly rates) combined, making `totalMonthlyCost` meaningless. Always filter by `productName` to isolate gateway meters.

> **Trap (multiple productNames)**: Zone-redundant SKUs (ErGw1AZ, ErGw2AZ, ErGw3AZ, ErGwScale) use `productName: "ExpressRoute Gateway"`. Each legacy SKU has its own productName (`ExpressRoute Standard Gateway`, `ExpressRoute High Performance Gateway`, `ExpressRoute Ultra High Performance Gateway`).

## Query Pattern

### Zone-redundant gateway — substitute {GatewaySku} from Meter Names table

ServiceName: ExpressRoute
ProductName: ExpressRoute Gateway
MeterName: {GatewaySku} Gateway

### ErGwScale gateway — multiply by scale unit count

ServiceName: ExpressRoute
ProductName: ExpressRoute Gateway
MeterName: ErGwScale Unit
InstanceCount: 4

### Legacy gateway — substitute {Tier} from Meter Names table

ServiceName: ExpressRoute
ProductName: ExpressRoute {Tier} Gateway
MeterName: {Tier} Gateway

> **Gateway placeholders**: `{GatewaySku}` = ErGw1AZ, ErGw2AZ, ErGw3AZ. `{Tier}` (legacy) = Standard, High Performance, Ultra High Performance. Each legacy SKU requires its own `productName`: `ExpressRoute {Tier} Gateway`.

## Meter Names

| Meter                            | productName                                   | unitOfMeasure | Notes                         |
| -------------------------------- | --------------------------------------------- | ------------- | ----------------------------- |
| `Standard Gateway`               | `ExpressRoute Standard Gateway`               | 1 Hour        | Legacy non-AZ, ~1 Gbps       |
| `High Performance Gateway`       | `ExpressRoute High Performance Gateway`       | 1 Hour        | Legacy non-AZ, ~2 Gbps       |
| `Ultra High Performance Gateway` | `ExpressRoute Ultra High Performance Gateway` | 1 Hour        | Legacy non-AZ, ~10 Gbps      |
| `ErGw1AZ Gateway`                | `ExpressRoute Gateway`                        | 1 Hour        | Zone-redundant, ~1 Gbps      |
| `ErGw2AZ Gateway`                | `ExpressRoute Gateway`                        | 1 Hour        | Zone-redundant, ~2 Gbps      |
| `ErGw3AZ Gateway`                | `ExpressRoute Gateway`                        | 1 Hour        | Zone-redundant, ~10 Gbps     |
| `ErGwScale Unit`                 | `ExpressRoute Gateway`                        | 1 Hour        | Per scale unit, ~1 Gbps each |

## Cost Formula

```
Gateway monthly   = gateway_retailPrice × 730
ErGwScale monthly = erGwScale_retailPrice × 730 × scaleUnitCount
```

## Notes

- **Requires an ExpressRoute circuit**: Gateway and circuit are separate resources billed independently — see `networking/express-route.md` for circuit pricing
- **Always-on billing**: Gateway charges accrue from deployment, not usage — deprovisioning the circuit does not stop gateway charges
- **Zone-redundant vs legacy**: ErGw1AZ/ErGw2AZ/ErGw3AZ are zone-resilient equivalents of Standard/High Performance/Ultra High Performance; use ErGw*AZ for new deployments
- **Capacity**: ErGw1AZ ≈ 1 Gbps, ErGw2AZ ≈ 2 Gbps, ErGw3AZ ≈ 10 Gbps; ErGwScale ~1 Gbps per scale unit (1–40 units)
- **FastPath**: Available on ErGw3AZ, Ultra High Performance, and ErGwScale (≥10 units) — bypasses gateway for direct VM connectivity; no separate meter
- **Data transfer**: Outbound data egress is billed under the ExpressRoute circuit (metered plans) or Bandwidth service, not the gateway
