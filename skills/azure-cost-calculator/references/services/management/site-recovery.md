---
serviceName: Azure Site Recovery
category: management
aliases: [ASR, Disaster Recovery, DR]
---

# Azure Site Recovery

**Primary cost**: Per protected VM instance per month — flat rate varies by replication target (Azure or System Center).

> **Trap**: Unfiltered `-ServiceName 'Azure Site Recovery'` returns both Azure and System Center SKUs, inflating `totalMonthlyCost` by summing charges for both SKUs. Always filter with `-SkuName 'Azure'` for Azure-to-Azure DR (most common scenario).

> **Trap (hidden costs)**: The per-instance fee covers orchestration only. Replicated storage, compute at the DR site during failover, bandwidth, and managed disks are billed separately through their respective services. Always price these components independently.

## Query Pattern

```powershell
# Azure-to-Azure replication — 10 protected VMs
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Site Recovery' `
    -SkuName 'Azure' `
    -MeterName 'VM Replicated to Azure' `
    -InstanceCount 10

# System Center (on-premises VMM) replication — 5 protected VMs
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Site Recovery' `
    -SkuName 'System Center' `
    -MeterName 'VM Replicated to System Center' `
    -InstanceCount 5
```

## Key Fields

| Parameter     | How to determine                        | Example values                      |
| ------------- | --------------------------------------- | ----------------------------------- |
| `serviceName` | Always `Azure Site Recovery`            | `Azure Site Recovery`               |
| `productName` | Always `Azure Site Recovery`            | `Azure Site Recovery`               |
| `skuName`     | Replication target                      | `Azure`, `System Center`            |
| `meterName`   | Matches the SKU target                  | `VM Replicated to Azure`, `VM Replicated to System Center` |

## Meter Names

| Meter                             | skuName          | unitOfMeasure | Notes                              |
| --------------------------------- | ---------------- | ------------- | ---------------------------------- |
| `VM Replicated to Azure`          | `Azure`          | `1/Month`     | Azure-to-Azure or on-prem-to-Azure |
| `VM Replicated to System Center`  | `System Center`  | `1/Month`     | On-prem to System Center VMM       |

## Cost Formula

```
Monthly = retailPrice × protectedVMCount

Azure target:          retailPrice (Azure SKU) × VM count
System Center target:  retailPrice (System Center SKU) × VM count
```

> Capacity planning: count each VM with replication enabled. A single VM = 1 protected instance regardless of disk count or VM size.

## Notes

- Reserved pricing is **not available** — RI queries return zero results
- First 31 days of protection for each new instance are free (not reflected in API)
- The ASR license fee is per-instance; VM size and disk count do not affect the rate
- Additional costs to estimate separately: target-region Managed Disks (replica), storage account for cache, bandwidth egress, and compute during test/actual failover
- `Azure` SKU covers both Azure-to-Azure and on-premises-to-Azure scenarios
- `System Center` SKU is for on-premises-to-on-premises replication via VMM
- Storage replication is **not included** in the ASR fee — always query Managed Disks or Storage separately for the DR replica
