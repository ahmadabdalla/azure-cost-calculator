---
serviceName: Microsoft Fabric
category: analytics
aliases: [Fabric Capacity, OneLake, Lakehouse]
billingConsiderations: [Reserved Instances]
primaryCost: "Capacity Unit (CU) hours × 730 per F-SKU (F2–F2048) + OneLake storage per GB"
---

# Microsoft Fabric

> **Trap (inflated totals)**: Unfiltered `ServiceName 'Microsoft Fabric'` returns ~76 meters across 3 products (Fabric Capacity, OneLake, Fabric Capacity Reservation). The `totalMonthlyCost` is meaningless. Always filter by `ProductName` for the specific component.

> **Trap (uniform CU pricing)**: All 63 standard workload meters under `Fabric Capacity` share an identical per-CU-hour rate. Each meter tracks a different workload for billing attribution only — the rate does not vary. Use any single CU meter as the reference, multiply by the F-SKU's CU count.

> **Trap (Capacity Overage)**: The `Capacity Overage Capacity Usage` meter is 3× the standard CU rate and is not RI-eligible.

## Query Pattern

### Fabric Capacity — per CU-hour (all workloads share this rate)

ServiceName: Microsoft Fabric
ProductName: Fabric Capacity
SkuName: Power BI Capacity Usage
MeterName: Power BI Capacity Usage CU

### Fabric Capacity — F64 SKU full month (Quantity = CU count in SKU)

ServiceName: Microsoft Fabric
ProductName: Fabric Capacity
SkuName: Power BI Capacity Usage
MeterName: Power BI Capacity Usage CU
Quantity: 64

### OneLake Storage — primary storage per GB (Quantity = GB stored)

ServiceName: Microsoft Fabric
ProductName: OneLake
SkuName: OneLake Storage
MeterName: OneLake Storage Data Stored
Quantity: 500

### Capacity Overage — 3× standard CU rate

ServiceName: Microsoft Fabric
ProductName: Fabric Capacity
SkuName: Capacity Overage Capacity Usage
MeterName: Capacity Overage Capacity Usage CU

## Key Fields

| Parameter     | How to determine                        | Example values                                              |
| ------------- | --------------------------------------- | ----------------------------------------------------------- |
| `serviceName` | Always `Microsoft Fabric`               | `Microsoft Fabric`                                          |
| `productName` | Component: compute vs storage           | `Fabric Capacity`, `OneLake`, `Fabric Capacity Reservation` |
| `skuName`     | Workload type (compute) or storage tier | `Power BI Capacity Usage`, `OneLake Storage`, `BCDR Storage` |
| `meterName`   | CU meter or storage data meter          | `Power BI Capacity Usage CU`, `OneLake Storage Data Stored` |

## Meter Names

| Meter                                | skuName                           | productName       | unitOfMeasure | Notes                                      |
| ------------------------------------ | --------------------------------- | ----------------- | ------------- | ------------------------------------------ |
| `Power BI Capacity Usage CU`        | `Power BI Capacity Usage`         | `Fabric Capacity` | `1 Hour`      | Representative CU meter (all 63 identical) |
| `Data Warehouse Capacity Usage CU`  | `Data Warehouse Capacity Usage`   | `Fabric Capacity` | `1 Hour`      | Same rate as all standard CU meters        |
| `Capacity Overage Capacity Usage CU`| `Capacity Overage Capacity Usage` | `Fabric Capacity` | `1 Hour`      | 3× standard rate; not RI-eligible          |
| `OneLake Storage Data Stored`       | `OneLake Storage`                 | `OneLake`         | `1 GB/Month`  | Primary data lake storage                  |
| `OneLake Cache Data Stored`         | `OneLake Cache`                   | `OneLake`         | `1 GB/Month`  | KQL cache / Data Activator retained data   |
| `BCDR Storage Data Stored`          | `BCDR Storage`                    | `OneLake`         | `1 GB/Month`  | Disaster recovery storage                  |
| `Storage Mirroring Data Stored`     | `Storage Mirroring`               | `OneLake`         | `1 GB/Month`  | Beyond free SKU-based allowance            |

## Cost Formula

```
Capacity Monthly = capacity_retailPrice × 730 × cuCount   (cuCount = F-SKU number: F64 → 64)
Storage Monthly  = storage_retailPrice × sizeInGB
Overage Monthly  = overage_retailPrice × overageCUHours
Total Monthly    = Capacity + Storage + Overage
```

## Notes

- **F-SKU to CU mapping**: F2=2, F4=4, F8=8, F16=16, F32=32, F64=64, F128=128, F256=256, F512=512, F1024=1024, F2048=2048. Capacity: 1 CU ≈ shared compute across all Fabric workloads
- **SKU is never-assume**: Always ask the user for their F-SKU size (F2–F2048) — do not guess
- **OneLake storage billed separately**: Storage is not included in the CU-hour capacity rate; query the `OneLake` product for storage costs
- **Pause/resume**: Pausing a capacity stops CU billing; OneLake storage charges continue
- **Free mirroring storage**: Each F-SKU includes free mirroring equal to the SKU number in TB (e.g., F64 = 64 TB); excess at the `Storage Mirroring` rate
- **Cosmos DB / SQL in Fabric**: Dedicated OneLake storage meters exist for these features at higher per-GB rates than standard OneLake; query `ProductName: OneLake` with the specific `SkuName` (e.g., `Cosmos DB Storage`, `SQL Storage`)
- **Networking**: Data transfer billing is not yet active — Microsoft will provide 90 days notice before charges begin

## Reserved Instance Pricing

ServiceName: Microsoft Fabric
ProductName: Fabric Capacity Reservation
PriceType: Reservation

> **Note (RI per-CU)**: RI `unitPrice` is per single CU — multiply by the CU count for the chosen F-SKU.

> **Trap (RI 1Y ≈ 3Y)**: Both 1-Year and 3-Year terms yield nearly identical monthly rates per CU (~41% discount vs PAYG). Autoscale for Spark and Capacity Overage are not RI-eligible.
