---
serviceName: Azure Database for PostgreSQL
category: databases
aliases: [PostgreSQL, Postgres, Azure Postgres, PostgreSQL Flexible Server]
billingConsiderations: [Reserved Instances]
primaryCost: "vCore hourly rate × 730 + storage per-GB/month"
privateEndpoint: true
---

# Azure Database for PostgreSQL Flexible Server

**Multiple meters**: vCore compute (hourly) + storage (per-GB/month)

> **Trap**: `productName` has inconsistent hyphen usage across series. Some use `General Purpose - Ddsv5` (with hyphen) while others use `General Purpose Dadsv5` (no hyphen). Always use the exact string from discovery — do not construct productName by pattern.

## Query Pattern

### Compute cost (General Purpose, Ddsv5 series, 4 vCore)

ServiceName: Azure Database for PostgreSQL
ProductName: Azure Database for PostgreSQL Flexible Server General Purpose - Ddsv5 Series Compute
SkuName: 4 vCore
MeterName: vCore

### Storage cost

ServiceName: Azure Database for PostgreSQL
ProductName: Az DB for PostgreSQL Flexible Server Storage
SkuName: Storage
MeterName: Storage Data Stored

## Key Fields

| Parameter     | How to determine             | Example values                                      |
| ------------- | ---------------------------- | --------------------------------------------------- |
| `productName` | Tier + series (exact match)  | See Product Names table below                       |
| `skuName`     | vCore count string           | `'2 vCore'`, `'4 vCore'`, `'8 vCore'`, `'16 vCore'` |
| `meterName`   | Always `'vCore'` for compute | `'vCore'`, `'Storage Data Stored'`                  |
| `armSkuName`  | VM-like size                 | `Standard_D4ds_v5`, `Standard_D8ds_v5`              |

## Product Names (common, case-sensitive)

| Config                         | productName                                                                             |
| ------------------------------ | --------------------------------------------------------------------------------------- |
| General Purpose, Ddsv5 series  | `Azure Database for PostgreSQL Flexible Server General Purpose - Ddsv5 Series Compute`  |
| General Purpose, Ddsv4 series  | `Azure Database for PostgreSQL Flexible Server General Purpose - Ddsv4 Series Compute`  |
| General Purpose, Dadsv5 series | `Azure Database for PostgreSQL Flexible Server General Purpose Dadsv5 Series Compute`   |
| General Purpose, Dsv3 series   | `Azure Database for PostgreSQL Flexible Server General Purpose - Dsv3 Series Compute`   |
| Burstable, Bsv2 series         | `Azure Database for PostgreSQL Flexible Server Burstable - Bsv2 Series Compute`         |
| Memory Optimized, Edsv5 series | `Azure Database for PostgreSQL Flexible Server Memory Optimized - Edsv5 Series Compute` |
| Storage                        | `Az DB for PostgreSQL Flexible Server Storage`                                          |

> **Note**: The storage productName uses the abbreviation `Az DB for PostgreSQL` — not the full `Azure Database for PostgreSQL`.

## Cost Formula

```
Monthly Compute = unitPrice × 730
Monthly Storage = storagePrice × sizeGB
Total = Compute + Storage
```

Query storage rate from the API — it varies by region and currency.

## Notes

- `skuName` determines the vCore count — no quantity multiplier needed for compute
- Use the explore script with SearchTerm PostgreSQL Flexible to discover available series
- High Availability doubles the compute cost (deploys a standby replica)
- Backup storage: first backup equal to DB size is free; excess is charged per-GB/month
