---
serviceName: Load Balancer
category: networking
aliases: [LB, load balancer]
---

# Virtual Network / Load Balancer

**Primary cost**: Per-hour base fee + per-GB data processed + overage rules (Standard SKU); VNet peering per-GB transfer

## Virtual Network

VNets themselves are free. Costs come from:

- **Peering**: per-GB data transfer (intra-region is lower-cost, inter-region is higher-cost)
- **Public IPs**: per-hour for static IPs
- **NAT Gateway**: per-hour + per-GB processed

## Load Balancer

> **Note**: **Global-region / USD-only** — see shared.md & Common Traps for mandatory currency conversion.

## Query Pattern

### Standard SKU (substitute {meterName} from Meter Names table)

ServiceName: Load Balancer
SkuName: Standard
MeterName: {meterName}
Region: Global

## Cost Formula

```
Base      = basePrice × 730
Overage   = max(0, totalRules - 5) × overagePrice × 730
Data      = processedGB × dataPrice
Monthly   = Base + Overage + Data
```

## Example (8 rules, 200 GB)

Query each meter via the script, then calculate:

```
Base:    basePrice × 730
Overage: 3 × overagePrice × 730
Data:    200 × dataPrice
Total:   Base + Overage + Data (USD)
```

## Notes

- Basic SKU is free but lacks SLA and zone redundancy
- Standard SKU requires Standard public IPs

## Meter Names

| Meter                                           | unitOfMeasure | Notes                            |
| ----------------------------------------------- | ------------- | -------------------------------- |
| `Standard Data Processed`                       | `1 GB`        | Per-GB processed                 |
| `Standard Included LB Rules and Outbound Rules` | `1 Hour`      | First 5 rules included           |
| `Standard Overage LB Rules and Outbound Rules`  | `1/Hour`      | Per additional rule beyond 5     |
| `Standard Data Processed - Free`                | `1 GB`        | Free tier (Basic SKU equivalent) |
