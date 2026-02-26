---
serviceName: Azure Bastion
category: networking
aliases: [Bastion Host, Jump Host, Jump Box]
billingNeeds: [IP Addresses]
primaryCost: "Gateway hourly rate × 730 + additional scale unit hours + outbound data transfer per-GB"
---

# Azure Bastion

> **Trap**: Bastion is always-on. It bills per-hour (× 730/month) from deployment, not per-use. Even with zero connections, the gateway meter charges continuously.

> **Trap**: Unfiltered queries return gateway, additional gateway, and data transfer meters combined — query each meter separately. Standard/Premium have separate "Additional Gateway" meters for scale units beyond the base 2 instances.

## Query Pattern

### Basic tier — gateway (always-on)

ServiceName: Azure Bastion
SkuName: Basic
MeterName: Basic Gateway

### Standard tier — gateway (always-on)

ServiceName: Azure Bastion
SkuName: Standard
MeterName: Standard Gateway

### Standard tier — additional scale units (InstanceCount = scale units beyond base 2)

ServiceName: Azure Bastion
SkuName: Standard
MeterName: Standard Additional Gateway
InstanceCount: 3

### Premium tier — gateway (always-on)

ServiceName: Azure Bastion
SkuName: Premium
MeterName: Premium Gateway
ArmSkuName: Premium

### Premium tier — additional scale units (InstanceCount = scale units beyond base 2)

ServiceName: Azure Bastion
SkuName: Premium
MeterName: Premium Additional Gateway
ArmSkuName: Premium
InstanceCount: 3

### Outbound data transfer — substitute {Tier} with Basic, Standard, or Premium

ServiceName: Azure Bastion
SkuName: {Tier}
MeterName: {Tier} Data Transfer Out

> **Agent instruction**: Data transfer uses tiered pricing (first 5 GB free, then tiered rates). This query returns multiple rows with `TierMinUnits`; ignore any `summary.totalMonthlyCost` from tooling and manually compute `Σ(tierRate × GB_in_tier)` with the first 5 GB at zero cost. `ArmSkuName` is not required for data transfer queries — `SkuName` alone is sufficient for all tiers.

## Key Fields

| Parameter     | How to determine                       | Example values                                 |
| ------------- | -------------------------------------- | ---------------------------------------------- |
| `serviceName` | Always `Azure Bastion`                 | `Azure Bastion`                                |
| `productName` | Single product for all meters          | `Azure Bastion`                                |
| `skuName`     | Matches the Bastion tier deployed      | `Basic`, `Standard`, `Premium`                 |
| `meterName`   | Tier-prefixed meter name               | `Basic Gateway`, `Standard Additional Gateway` |
| `armSkuName`  | Only needed for Premium gateway meters | `Premium` (empty for Basic/Standard)           |

## Meter Names

| Meter                         | skuName    | unitOfMeasure | Notes                                    |
| ----------------------------- | ---------- | ------------- | ---------------------------------------- |
| `Basic Gateway`               | `Basic`    | 1 Hour        | Always-on base gateway                   |
| `Standard Gateway`            | `Standard` | 1 Hour        | Always-on base gateway (2 instances)     |
| `Standard Additional Gateway` | `Standard` | 1 Hour        | Per scale unit beyond base 2             |
| `Premium Gateway`             | `Premium`  | 1 Hour        | Always-on base gateway (2 instances)     |
| `Premium Additional Gateway`  | `Premium`  | 1 Hour        | Per scale unit beyond base 2             |
| `{Tier} Data Transfer Out`    | per tier   | 1 GB          | Tiered outbound pricing, first 5 GB free |

## Cost Formula

```
Gateway monthly        = gateway_retailPrice × 730
Scale units monthly    = additionalGw_retailPrice × 730 × scaleUnits
Data transfer monthly  = Σ(tierRate × GB_in_tier)  [first 5 GB free]
Total monthly          = Gateway + Scale units + Data transfer
```

## Notes

- **Always-on cost**: Basic tier minimum is gateway hourly × 730/month with zero connections
- **Scale unit math**: Base gateway includes 2 instances. Additional scale units = (totalInstances − 2), billed via "Additional Gateway" meter
- **Capacity per scale unit**: Each scale unit supports ~20 concurrent SSH connections or ~40 concurrent RDP connections
- **Developer tier**: Free — no API meters exist. Do NOT query; report zero cost
- **Basic tier**: Fixed at 2 instances, no scaling — supports RDP/SSH only, no file transfer or IP-based connections
- **Standard tier**: 2–50 instances, adds native client support, file transfer, IP-based connections, shareable links
- **Premium tier**: 2–200 instances, adds session recording and private-only access
- **Data transfer tiers**: 0–5 GB free, then tiered rates starting at 5 GB — identical across all Bastion tiers
