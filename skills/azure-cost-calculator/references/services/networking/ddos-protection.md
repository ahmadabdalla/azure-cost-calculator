---
serviceName: Azure DDOS Protection
category: networking
aliases: [DDoS, DDoS Protection, DDoS Network Protection, DDoS IP Protection]
primaryCost: "Plan hourly rate × 730 + overage IPs + data processing per-GB (tiered)"
---

# Azure DDOS Protection

> **Trap (tiered data)**: Network Protection data processing returns 4 tiered rows (0–100 TB, 100–500 TB, 500 TB–1 PB, 1 PB+; last two share the same rate). The script's `totalMonthlyCost` sums all tiers — query each tier's rate and calculate manually based on actual volume.

> **Trap (case-sensitive)**: The API serviceName is `Azure DDOS Protection` (all-caps "DDOS"). Searching with "DDoS" returns zero results.

> **Trap (included IPs)**: Network Protection Plan includes 100 public IPs. Overage is charged per additional IP via the `Network Protection Resource` meter. Do not multiply plan cost by IP count.

## Query Pattern

### Network Protection — base plan (always-on)

ServiceName: Azure DDOS Protection
SkuName: Network Protection
MeterName: Network Protection Plan

### IP Protection — per-IP (InstanceCount = number of protected public IPs)

ServiceName: Azure DDOS Protection
SkuName: Azure DDoS Protection IP Protection
MeterName: IP Protection Resource
InstanceCount: 5

### Network Protection — overage IPs beyond 100 (InstanceCount = additional IPs)

ServiceName: Azure DDOS Protection
SkuName: Network Protection
MeterName: Network Protection Resource
InstanceCount: 20

### Network Protection — data processed (Quantity = estimated monthly GB)

ServiceName: Azure DDOS Protection
SkuName: Network Protection
MeterName: Network Protection Data Processed
Quantity: 1000

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- |
| `Network Protection Plan` | `Network Protection` | `1 Hour` | Base plan, includes 100 public IPs |
| `Network Protection Resource` | `Network Protection` | `1 Hour` | Per additional IP beyond 100 included |
| `Network Protection Data Processed` | `Network Protection` | `1 GB` | 4 tiers: 0–100 TB, 100–500 TB, 500 TB–1 PB, 1 PB+ |
| `IP Protection Resource` | `Azure DDoS Protection IP Protection` | `1 Hour` | Per-IP plan, one charge per protected IP |

## Cost Formula

```
Network Protection:
  Plan        = plan_retailPrice × 730
  Overage IPs = resource_retailPrice × 730 × max(0, publicIpCount − 100)
  Data        = Σ(tier_retailPrice × GB_in_tier)
  Total       = Plan + Overage IPs + Data

IP Protection:
  Total       = ip_retailPrice × 730 × publicIpCount
```

## Notes

- **Tier comparison**: IP Protection is cheaper for small deployments (≤14 IPs); Network Protection's flat plan is cheaper at ~15+ IPs
- **Data processing tiers**: Typically minimal unless under active DDoS attack — most customers pay only the base plan/IP cost
- **WAF discount**: Azure Firewall Premium and Application Gateway WAF v2 are eligible for DDoS cost benefits under Network Protection
- **No RI available**: Both plans are PAYG only — no reserved instance pricing exists
