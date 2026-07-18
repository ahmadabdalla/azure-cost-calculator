---
serviceName: Backup
category: storage
aliases: [Azure Backup, Recovery Services Vault, MARS Agent, VM Backup]
billingConsiderations: [Reserved Instances]
primaryCost: "Protected instance/month (workload type) + storage per-GB/month (redundancy)"
privateEndpoint: true
---

# Backup

> **Trap (meter-flood)**: Unfiltered `ServiceName: Backup` returns 35+ meters across every workload type plus storage redundancy tiers, inflating `totalMonthlyCost`. Always filter by `SkuName` for the workload (e.g., `Azure VM`) and, for storage, by both `SkuName` and `MeterName` (e.g., `Standard` + `Standard LRS Data Stored`).

> **Trap (productName-split)**: PAYG uses `productName: Backup` — protected-instance meters are singular (`Azure VM Protected Instance`, not `Instances`) and Standard storage meters carry the tier prefix (`Standard LRS Data Stored`). Reserved capacity uses `productName: Backup Reserved Capacity` with unprefixed storage meters (`LRS Data Stored`). Mixing these returns zero results.

## Query Pattern

### Azure VM backup: 10 protected VMs

ServiceName: Backup
ProductName: Backup
SkuName: Azure VM
MeterName: Azure VM Protected Instance
InstanceCount: 10

### Backup storage: 500 GB LRS

ServiceName: Backup
ProductName: Backup
SkuName: Standard
MeterName: Standard LRS Data Stored
Quantity: 500

### SQL Server in Azure VM backup

ServiceName: Backup
ProductName: Backup
SkuName: SQL Server in Azure VM
MeterName: SQL Server in Azure VM Protected Instance

## Key Fields

| Parameter     | How to determine                                   | Example values                                              |
| ------------- | -------------------------------------------------- | ----------------------------------------------------------- |
| `serviceName` | Always `Backup`                                    | `Backup`                                                    |
| `productName` | `Backup` (PAYG) or `Backup Reserved Capacity` (RI) | `Backup`, `Backup Reserved Capacity`                        |
| `skuName`     | Workload type or storage tier                      | `Azure VM`, `SQL Server in Azure VM`, `Standard`, `Archive` |
| `meterName`   | Instance fee (singular) or data stored             | `Azure VM Protected Instance`, `Standard LRS Data Stored`   |

## Meter Names

| Meter                                       | skuName                  | unitOfMeasure | Notes                         |
| ------------------------------------------- | ------------------------ | ------------- | ----------------------------- |
| `Azure VM Protected Instance`               | `Azure VM`               | `1/Month`     | Per VM                        |
| `SQL Server in Azure VM Protected Instance` | `SQL Server in Azure VM` | `1/Month`     | Per SQL instance              |
| `SAP HANA on Azure VM Protected Instance`   | `SAP HANA on Azure VM`   | `1/Month`     | Per SAP HANA instance         |
| `Cosmos DB Protected Instance`              | `Cosmos DB`              | `1/Month`     | Vault backup (not native PITR) |
| `Azure Files Vaulted Protected Instance`    | `Azure Files Vaulted`    | `1/Month`     | Vaulted Files backup          |
| `On Premises Server Protected Instance`     | `On Premises Server`     | `1/Month`     | MARS/DPM/MABS agents          |
| `Standard LRS Data Stored`                  | `Standard`               | `1 GB/Month`  | Standard vault storage (LRS)  |
| `Standard GRS Data Stored`                  | `Standard`               | `1 GB/Month`  | Geo-redundant vault storage   |
| `Azure Files Vaulted LRS Data Stored`       | `Azure Files Vaulted`    | `1 GB/Month`  | Vaulted Files storage         |

Other workload SKUs: `Azure Files` (snapshot, no vault storage), `Azure Kubernetes` and `AKS` (per-namespace, unit `1 Count`), `PostgreSQL`, `SAP ASE on Azure VM`, `Azure Blob`, `ADLS Gen2 Vaulted`, `Cross region for ADLS and Blobs`. `Standard` storage also exposes `ZRS`/`RA-GRS` meters; `Archive` (LRS/GRS only) offers sub-cent long-term storage with early-delete fees. `Azure Blob`/`ADLS Gen2 Vaulted` bill per-10K write operations by redundancy. Enhanced-policy workloads (SQL Server, SAP HANA) add a matching `... Snapshot Instance` meter.

## Cost Formula

```
Monthly = (instance_retailPrice × protectedInstanceCount) + (storage_retailPrice × storageGB)

Example: 10 VMs with 500 GB LRS storage
  Instance = instance_retailPrice × 10
  Storage  = storage_retailPrice × 500
  Total    = Instance + Storage
```

## Notes

- Storage is billed separately from the protected instance fee; always query both components
- Redundancy options: LRS, GRS, ZRS, RA-GRS; each has a different storage rate
- Protected instance fees vary by workload: VM/Files are lowest, SQL/Cosmos DB mid-range, SAP HANA/ASE highest
- Enhanced (Instant Restore) policies for SQL Server and SAP HANA add a `... Snapshot Instance` fee plus disk-snapshot storage billed under Managed Disks (`storage/managed-disks.md`)
- Archive tier applies to long-term retention points only (LRS/GRS); sub-cent per-GB rates and 180-day early-delete fees apply
- First 31 days of Azure VM backup storage (up to 50 GB per VM) are free (not reflected in API)
- **Cosmos DB vault backup vs native PITR**: vault backup uses `SkuName: Cosmos DB` (`Cosmos DB Protected Instance`) plus `Standard` vault storage; do NOT confuse with Cosmos DB native PITR (`serviceName: Azure Cosmos DB`, `productName: Azure Cosmos DB - PITR`), which is significantly more expensive per-GB — see `databases/cosmos-db.md`

## Reserved Instance Pricing

Only vault storage capacity is reservable (100 TB or 1 PB commitments, 1-Year / 3-Year); protected instance fees are always PAYG. Reserved meters drop the tier prefix.

ServiceName: Backup
ProductName: Backup Reserved Capacity
SkuName: Standard - 100 TB LRS
MeterName: LRS Data Stored
PriceType: Reservation
