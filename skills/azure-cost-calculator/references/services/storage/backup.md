---
serviceName: Backup
category: storage
aliases: [Azure Backup, Recovery Services Vault, MARS Agent, VM Backup]
billingConsiderations: [Reserved Instances]
primaryCost: "Protected instance/month (workload type) + storage per-GB/month (redundancy)"
privateEndpoint: true
---

# Azure Backup

> **Trap**: Unfiltered `ServiceName: Backup` returns ~36 meters across all workload types plus storage, inflating `totalMonthlyCost`. Always filter with `SkuName` for the specific workload (e.g., `Azure VM`) or storage tier (e.g., `Standard`).

## Query Pattern

### Azure VM backup — 10 protected VMs

ServiceName: Backup
SkuName: Azure VM
MeterName: Azure VM Protected Instances
InstanceCount: 10

### Backup storage — 500 GB LRS

ServiceName: Backup
SkuName: Standard
MeterName: LRS Data Stored
Quantity: 500

### SQL Server in Azure VM backup

ServiceName: Backup
SkuName: SQL Server in Azure VM
MeterName: SQL Server in Azure VM Protected Instances

## Key Fields

| Parameter     | How to determine                                   | Example values                                              |
| ------------- | -------------------------------------------------- | ----------------------------------------------------------- |
| `serviceName` | Always `Backup`                                    | `Backup`                                                    |
| `productName` | `Backup` (PAYG) or `Backup Reserved Capacity` (RC) | `Backup`, `Backup Reserved Capacity`                        |
| `skuName`     | Workload type or storage tier                      | `Azure VM`, `SQL Server in Azure VM`, `Standard`, `Archive` |
| `meterName`   | Instance fee or data stored                        | `Azure VM Protected Instances`, `LRS Data Stored`           |

## Meter Names

| Meter                                        | skuName                  | unitOfMeasure | Notes                       |
| -------------------------------------------- | ------------------------ | ------------- | --------------------------- |
| `Azure VM Protected Instances`               | `Azure VM`               | `1/Month`     | Per VM                      |
| `SQL Server in Azure VM Protected Instances` | `SQL Server in Azure VM` | `1/Month`     | Per SQL instance            |
| `SAP HANA on Azure VM Protected Instances`   | `SAP HANA on Azure VM`   | `1/Month`     | Per SAP HANA instance       |
| `Azure Files Protected Instances`            | `Azure Files`            | `1/Month`     | Snapshot-based (no vault)   |
| `Azure Files Vaulted Protected Instances`    | `Azure Files Vaulted`    | `1/Month`     | Vaulted backup              |
| `On Premises Server Protected Instances`     | `On Premises Server`     | `1/Month`     | MARS agent                  |
| `LRS Data Stored`                            | `Standard`               | `1 GB/Month`  | Standard vault storage      |
| `GRS Data Stored`                            | `Standard`               | `1 GB/Month`  | Geo-redundant vault storage |
| `Archive LRS Data Stored`                    | `Archive`                | `1 GB/Month`  | Archive tier LRS            |

Other workload types: `PostgreSQL`, `Azure Kubernetes`, `Azure Blob`, `ADLS Gen2 Vaulted`, `SAP ASE on Azure VM`, `Cross region for ADLS and Blobs`. ZRS and RA-GRS storage meters also available. Blob/ADLS Gen2 Vaulted also include per-10K write operation meters by redundancy.

## Cost Formula

```
Monthly = (instance_retailPrice × protectedInstanceCount) + (storage_retailPrice × storageGB)

Example: 10 VMs with 500 GB LRS storage
  Instance = instance_retailPrice × 10
  Storage  = storage_retailPrice × 500
  Total    = Instance + Storage
```

## Notes

- Storage is billed separately from the protected instance fee — always query both components
- Redundancy options: LRS, GRS, ZRS, RA-GRS — each has a different storage rate
- Archive tier offers lower storage cost but applies to long-term retention points only; early delete fees apply
- Reserved capacity available via `productName = 'Backup Reserved Capacity'` for 100 TB or 1 PB commitments (1-Year / 3-Year)
- Protected instance fees vary significantly by workload: VM/Files are lower-cost per protected instance, SQL is mid-range, and SAP HANA/ASE are among the highest-cost options
- First 31 days of Azure VM backup storage (up to 50 GB per VM) are free (not reflected in API)
- **Cosmos DB vault backup vs native PITR**: Azure Backup vault protects Cosmos DB using standard vault storage meters (e.g., `LRS Data Stored` under `skuName: Standard`). There is no Cosmos DB-specific workload SKU. Do NOT confuse with Cosmos DB native PITR (`serviceName: Azure Cosmos DB`, `productName: Azure Cosmos DB - PITR`) which is ~9× more expensive per-GB — see `databases/cosmos-db.md`

## Reserved Instance Pricing

ServiceName: Backup
ProductName: Backup Reserved Capacity
MeterName: LRS Data Stored
PriceType: Reservation
