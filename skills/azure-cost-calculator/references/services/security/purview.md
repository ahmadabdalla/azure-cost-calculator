---
serviceName: Microsoft Purview
category: security
aliases: [Data Governance, Data Catalog, Azure Purview, Purview Data Map, Data Estate Scanning]
primaryCost: "Per-asset daily rates + per-unit processing (DSPU/DGPU) + hourly capacity units (classic)"
hasFreeGrant: true
privateEndpoint: true
---

# Microsoft Purview

> **Trap (two serviceNames)**: Spans `Microsoft Purview` (current — Data Security, Governance, Compliance) and `Azure Purview` (classic — Data Map, Scanning). Query each separately — an unfiltered query on one misses the other's meters entirely.

> **Trap (inflated total)**: Multiple `productName` values with different billing units per `serviceName`. Always filter by `ProductName` and `MeterName` — never rely on `totalMonthlyCost`.

## Query Pattern

### Data Governance — per-asset catalog

ServiceName: Microsoft Purview
ProductName: Microsoft Purview Data Governance
SkuName: Data Catalog Standard
MeterName: Data Catalog Standard Asset
Quantity: 1000

> `Quantity` = governed asset count. Billed per asset per day (`1/Day` unit).

### Data Security — at-rest protection per asset

ServiceName: Microsoft Purview
ProductName: Microsoft Purview Data Security
SkuName: Standard
MeterName: Standard Asset

### Data Security — Insider Risk Management (per DSPU)

ServiceName: Microsoft Purview
ProductName: Microsoft Purview Data Security
SkuName: Standard
MeterName: Standard Data Security Processing Unit

### Classic Data Map — capacity units (hourly)

ServiceName: Azure Purview <!-- cross-service -->
ProductName: Azure Purview Data Map
SkuName: Standard
MeterName: Standard Capacity Unit
InstanceCount: 2

> 2 CUs — each supports ~25 data map ops/sec and 10 GB metadata.

### Classic Scanning — per vCore

ServiceName: Azure Purview <!-- cross-service -->
ProductName: Azure Purview Scanning Ingestion and Classification
SkuName: Standard
MeterName: Standard vCore

## Key Fields

| Parameter | How to determine | Example values |
| --- | --- | --- |
| `serviceName` | `Microsoft Purview` (current) or `Azure Purview` (classic) | `Microsoft Purview`, `Azure Purview` |
| `productName` | Feature area within the platform | `Microsoft Purview Data Governance`, `Azure Purview Data Map` |
| `skuName` | Tier or feature being billed | `Data Catalog Standard`, `Standard`, `Data Management Basic` |
| `meterName` | Billing dimension | `Data Catalog Standard Asset`, `Standard Capacity Unit` |

## Meter Names

| Meter | productName | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- | --- |
| `Data Catalog Standard Asset` | `Microsoft Purview Data Governance` | `Data Catalog Standard` | `1/Day` | Per governed asset |
| `Standard Asset` | `Microsoft Purview Data Security` | `Standard` | `1/Day` | At Rest Protection |
| `Standard Data Security Processing Unit` | `Microsoft Purview Data Security` | `Standard` | `1` | DSPU — Insider Risk |
| `Data Management Basic Data Governance Processing Unit` | `Microsoft Purview Data Governance` | `Data Management Basic` | `1` | DGPU — also Standard and Advanced tiers |
| `Standard Capacity Unit` | `Azure Purview Data Map` | `Standard` | `1 Hour` | Classic Data Map CU |
| `Standard vCore` | `Azure Purview Scanning Ingestion and Classification` | `Standard` | `1 Hour` | Classic scanning |
| `Standard Assets` | `Microsoft Purview On-Demand Classification` | `Standard` | `10K` | Per 10K classified |

> Other meters: Audit Standard Asset (1K), Communication Compliance Standard/Premium (1K), eDiscovery Premium GB (1/Day), eDiscovery Graph API Export (1 GB — first 50 GB free), In Transit Protection Request (sub-cent), Investigations Compute Unit (1 Hour) and GB (1/Day), OCR Transaction (first 2,500 free then sub-cent), Data Lifecycle Management Premium (1K/Day, sub-cent).

## Cost Formula

```
Governance: Monthly = asset_retailPrice × assetCount × 30 + dgpu_retailPrice × dgpuCount
Security:   Monthly = asset_retailPrice × assetCount × 30 + dspu_retailPrice × dspuCount
Classic:    Monthly = cu_retailPrice × 730 × cuCount + vcore_retailPrice × 730 × vcoreCount
```

> Use 30 days for `1/Day` meters, 730 hours for `1 Hour` meters. Processing units (DSPU/DGPU) are per-unit consumed, not per-hour.

## Notes

- **Free grants**: eDiscovery Graph API first 50 GB export free; OCR first 2,500 transactions free; Power BI and SQL Server scanning free for a limited time
- **Uniform pricing**: `Microsoft Purview` meters are identical across all commercial regions; classic `Azure Purview` meters have government-region premium
- **Processing units**: DGPU (Data Governance) has 3 tiers — Basic, Standard, Advanced. DSPU (Data Security) covers Insider Risk Management. These are distinct billing concepts.
- **Classic vs current**: `Azure Purview` = original Data Map and Scanning; `Microsoft Purview` = current products. Customers may use either or both.
- **PE sub-resources** (never-assume): account, portal, ingestion
