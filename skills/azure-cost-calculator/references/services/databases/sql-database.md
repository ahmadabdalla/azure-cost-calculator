---
serviceName: SQL Database
category: databases
aliases: [Azure SQL, SQL DB]
billingConsiderations: [Azure Hybrid Benefit, Reserved Instances]
primaryCost: "vCore hourly rate × 730 + storage per-GB/month"
privateEndpoint: true
---

# Azure SQL Database

> **Trap (inflated totals)**: Omitting `SkuName` returns all vCore sizes summed. Always filter by `ProductName`, `SkuName`, and `MeterName`; the service has 39 products spanning vCore, DTU, Serverless, Elastic Pool, storage, and backup.

> **Trap (DTU billing)**: DTU tiers (Basic/Standard/Premium) use `unitOfMeasure: 1/Day`. The script auto-multiplies by 30 for these meters, so `MonthlyCost` is already the monthly cost.

> **Trap (Zone Redundancy)**: GP zone-redundant deployments have separate compute meters (`Zone Redundancy vCore`) and storage meters (`General Purpose Zone Redundancy Data Stored` at ~2× standard rate). The ZR compute meter is an **additive hourly surcharge**. BC includes zone-redundant HA in base price (no separate ZR meter).

## Query Pattern

### vCore compute (e.g., 2 vCore GP; swap productName for Business Critical)

ServiceName: SQL Database
ProductName: SQL Database Single/Elastic Pool General Purpose - Compute Gen5
SkuName: 2 vCore
MeterName: vCore

### Storage (use Quantity for provisioned GB)

ServiceName: SQL Database
ProductName: SQL Database Single/Elastic Pool General Purpose - Storage
MeterName: General Purpose Data Stored
Quantity: 256

> For Business Critical: use `ProductName: ...Business Critical - Storage` and `MeterName: Business Critical Data Stored`.

## Key Fields

| Parameter     | How to determine                                  | Example values                             |
| ------------- | ------------------------------------------------- | ------------------------------------------ |
| `serviceName` | Always `SQL Database`                             | `SQL Database`                             |
| `productName` | Deployment type + tier + generation               | See Product Names section below            |
| `skuName`     | vCore count, selects the size                     | `1 vCore`, `2 vCore`, `4 vCore`, `8 vCore` |
| `meterName`   | Always `vCore` for compute, or storage meter name | `vCore`, `General Purpose Data Stored`     |

## Meter Names

| Meter                           | unitOfMeasure | Notes                                  |
| ------------------------------- | ------------- | -------------------------------------- |
| `vCore`                         | `1 Hour`      | Compute meter for all tiers            |
| `Zone Redundancy vCore`         | `1 Hour`      | GP zone-redundancy compute surcharge   |
| `General Purpose Data Stored`   | `1 GB/Month`  | Storage for General Purpose tier       |
| `Business Critical Data Stored` | `1 GB/Month`  | Storage for Business Critical tier     |
| `Hyperscale Data Stored`        | `1 GB/Month`  | Storage for Hyperscale tier            |

## Cost Formula

```
Monthly Compute = retailPrice × 730 | Monthly Storage = storage_retailPrice × sizeInGB
Total = Compute + Storage
Zone-Redundant GP = (base_retailPrice + zr_retailPrice) × 730 + zr_storage_retailPrice × sizeInGB
```

## Notes

- **Storage**: GP and BC storage billed separately per-GB for configured max size (not usage). Default 32 GB. Backup storage equal to max data size is free.
- **DTU model**: Basic (5 DTU), Standard (S0–S12), Premium (P1–P15): `1/Day` billing; compute+storage bundled
- **Tier guide**: GP for standard workloads; BC includes zone-redundant HA in base price; Hyperscale for up to 100 TB with log-based architecture
- **Serverless**: License-included pricing (higher per-vCore rate); no separate SQL License query needed
- **Capacity**: vCore count determines compute capacity; double vCores for ~2× throughput

## Reserved Instance Pricing

### RI compute (omit SkuName; unitPrice is per-vCore; swap productName for BC/Hyperscale)

ServiceName: SQL Database
ProductName: SQL Database Single/Elastic Pool General Purpose - Compute Gen5
MeterName: vCore
PriceType: Reservation

> **Trap (RI skuName)**: RI `skuName='vCore'` (no count prefix). `-SkuName '8 vCore'` returns zero results. Calculate: `unitPrice × vCoreCount ÷ 12` (1Y) or `÷ 36` (3Y). RI prices are already license-excluded; do NOT subtract SQL License.

## Product Names

| Config                                       | productName                                                                  |
| -------------------------------------------- | ---------------------------------------------------------------------------- |
| Single/Elastic Pool, General Purpose, Gen5   | `SQL Database Single/Elastic Pool General Purpose - Compute Gen5`            |
| Single/Elastic Pool, Business Critical, Gen5 | `SQL Database Single/Elastic Pool Business Critical - Compute Gen5`          |
| Serverless, General Purpose, Gen5            | `SQL Database General Purpose - Serverless - Compute Gen5`                   |
| Hyperscale, Gen5                             | `SQL Database SingleDB/Elastic Pool Hyperscale - Compute Gen5`               |
| Storage (General Purpose)                    | `SQL Database Single/Elastic Pool General Purpose - Storage`                 |
| Storage (Business Critical)                  | `SQL Database Single/Elastic Pool Business Critical - Storage`               |
| Storage (Hyperscale SingleDB)                | `SQL Database SingleDB Hyperscale - Storage`                                 |

## Azure Hybrid Benefit

ServiceName: SQL Database
ProductName: SQL Database Single/Elastic Pool General Purpose - SQL License
Region: Global

> AHUB: compute `retailPrice` IS the AHUB rate. PAYG = compute + `sql_license_retailPrice` per vCore. **Do NOT subtract.** Swap productName for BC. See shared.md AHUB section.
