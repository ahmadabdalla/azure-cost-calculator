---
serviceName: Azure Site Recovery
category: management
aliases: [ASR, Disaster Recovery, DR]
billingNeeds: [Storage]
billingConsiderations: [Azure Hybrid Benefit]
primaryCost: "Per protected VM instance per month — flat rate varies by replication target (Azure, System Center, or on-prem)."
privateEndpoint: true
---

# Azure Site Recovery

> **Trap**: Unfiltered `ServiceName: Azure Site Recovery` returns both Azure and System Center SKUs, inflating costs by summing charges for both SKUs. Always filter with `SkuName: Azure` for Azure-to-Azure DR (most common scenario).

> **Trap (hidden costs)**: The per-instance fee covers orchestration only. Compute at the DR site during failover is billed separately (AHUB can apply to those VMs).

## Query Pattern

### Azure-to-Azure replication — 10 protected VMs

ServiceName: Azure Site Recovery
SkuName: Azure
MeterName: VM Replicated to Azure
InstanceCount: 10

### System Center (on-premises VMM) replication — 5 protected VMs

ServiceName: Azure Site Recovery
SkuName: System Center
MeterName: VM Replicated to System Center
InstanceCount: 5

## Key Fields

| Parameter     | How to determine             | Example values                                             |
| ------------- | ---------------------------- | ---------------------------------------------------------- |
| `serviceName` | Always `Azure Site Recovery` | `Azure Site Recovery`                                      |
| `productName` | Always `Azure Site Recovery` | `Azure Site Recovery`                                      |
| `skuName`     | Replication target           | `Azure`, `System Center`, `On-premise`                     |
| `meterName`   | Matches the SKU target       | `VM Replicated to Azure`, `VM Replicated to System Center`, `VM Replicated between On-premise sites` |

## Meter Names

| Meter                            | skuName         | unitOfMeasure | Notes                              |
| -------------------------------- | --------------- | ------------- | ---------------------------------- |
| `VM Replicated to Azure`         | `Azure`         | `1/Month`     | Azure-to-Azure or on-prem-to-Azure |
| `VM Replicated to System Center` | `System Center` | `1/Month`     | On-prem to System Center VMM       |
| `VM Replicated between On-premise sites` | `On-premise` | `1/Month` | On-prem to on-prem; limited regions |

## Cost Formula

```
Monthly = retailPrice × protectedVMCount

Azure target:          retailPrice (Azure SKU) × VM count
System Center target:  retailPrice (System Center SKU) × VM count
```

> Capacity planning: count each VM with replication enabled. A single VM = 1 protected instance regardless of disk count or VM size.

## Notes

- First 31 days of protection for each new instance are free (not reflected in API). When ASR is used via Azure Migrate for server migration, a longer **180-day** free period applies — see the Azure Migrate reference
- The ASR license fee is per-instance; VM size and disk count do not affect the rate
- `Azure` SKU covers both Azure-to-Azure and on-premises-to-Azure scenarios
- `System Center` SKU is for on-premises-to-on-premises replication via VMM
- Some regions use `On-premise` SKU instead of `System Center` (same price) — if `System Center` returns empty, query with `SkuName: On-premise`
