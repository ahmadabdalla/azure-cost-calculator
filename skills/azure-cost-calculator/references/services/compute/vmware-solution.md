---
serviceName: Azure VMware Solution
category: compute
aliases: [AVS, VMware on Azure]
billingConsiderations: [Reserved Instances]
apiServiceName: Specialized Compute
primaryCost: "Per-host hourly rate × node count × 730 hours/month"
---

# Azure VMware Solution

> **Trap**: API serviceName is `Specialized Compute` — always filter by productName

> **Trap (VCF BYOL)**: Current SKUs use `VCF BYOL` suffix — requires separate Broadcom VCF subscription

## Query Pattern

### Host Node

ServiceName: Specialized Compute <!-- cross-service -->
ProductName: Specialized Compute Azure VMware Solution
SkuName: AV36P VCF BYOL
MeterName: AV36P VCF BYOL Node
InstanceCount: 3

### Reservation

ServiceName: Specialized Compute <!-- cross-service -->
ProductName: Specialized Compute Azure VMware Solution
SkuName: AV36P VCF BYOL
PriceType: Reservation
InstanceCount: 3

## Key Fields

| Parameter       | How to determine                       | Example values                              |
| --------------- | -------------------------------------- | ------------------------------------------- |
| `serviceName`   | Always `Specialized Compute` for AVS   | `Specialized Compute`                       |
| `productName`   | AVS product within Specialized Compute | `Specialized Compute Azure VMware Solution` |
| `skuName`       | Node SKU with VCF BYOL suffix          | `AV36P VCF BYOL`, `AV64 VCF BYOL`           |
| `meterName`     | Node meter matching selected SKU       | `AV36P VCF BYOL Node`                       |
| `unitOfMeasure` | Hourly billing unit                    | `1 Hour`                                    |

## Meter Names

| Meter               | Regions |
| ------------------- | ------- |
| AV36 VCF BYOL Node  | 1       |
| AV36P VCF BYOL Node | 27      |
| AV48 VCF BYOL Node  | 16      |
| AV52 VCF BYOL Node  | 5       |
| AV64 VCF BYOL Node  | 41      |

## Cost Formula

`monthly = retailPrice × 730 × nodeCount`

Reservation: `effective_monthly = unitPrice ÷ 12` (1-year), `÷ 36` (3-year), `÷ 60` (5-year)

Minimum 3 hosts per cluster.

## Notes

- HCX Enterprise included at no extra cost
- vSphere, vSAN, and NSX-T included in per-host price
- Broadcom VCF subscription required separately — not in API
- Trial nodes exist for all SKUs at zero cost — exclude from estimates
- AV36: single region (italynorth); AV64: broadest availability (41 regions); AV52: most limited (5 regions)
- 5-year RI available for AV48 and AV64 only
- Max 16 hosts/cluster, 12 clusters/private cloud (up to 192 hosts)
- SQL Server on AVS billed separately under serviceName `Virtual Machines Licenses`
- Legacy SKUs (CS28, CS36, VS20, VS36) exist under different productNames
