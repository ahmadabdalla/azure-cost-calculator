---
serviceName: Azure DNS
category: networking
aliases: [private DNS, DNS zones]
---

````markdown
# Private DNS Zones

**Primary cost**: Zone hosting (per-zone/month) + DNS queries

> ⚠ **Global-only pricing / USD-only** — see shared.md § Common Traps. Scripts require `-Region` and return nothing; call the API directly using query below.
> **Trap**: Zone pricing is **tiered** — first 25 zones at $0.50/zone/month, additional at $0.10/zone/month. Pick the tier matching expected zone count, do NOT sum all tiers.

## Query Pattern

```powershell
# Private Zone hosting cost
$uri = "https://prices.azure.com/api/retail/prices?`$filter=serviceName eq 'Azure DNS' and productName eq 'Azure DNS' and meterName eq 'Private Zone'"
(Invoke-RestMethod -Uri $uri).Items | Select-Object meterName, unitPrice, unitOfMeasure, currencyCode, armRegionName

# Private DNS queries
$uri = "https://prices.azure.com/api/retail/prices?`$filter=serviceName eq 'Azure DNS' and productName eq 'Azure DNS' and meterName eq 'Private Queries'"
(Invoke-RestMethod -Uri $uri).Items | Select-Object meterName, unitPrice, unitOfMeasure, currencyCode, armRegionName
```

## Key Fields

| Parameter       | Value                      |
| --------------- | -------------------------- |
| `serviceName`   | `Azure DNS`                |
| `productName`   | `Azure DNS`                |
| `armRegionName` | `''` (empty) or `'Global'` |

## Meter Names

| Meter             | Unit Price (USD) | unitOfMeasure | Notes                                    |
| ----------------- | ---------------- | ------------- | ---------------------------------------- |
| `Private Zone`    | $0.50/zone       | `1/Month`     | First 25 zones; $0.10/zone for 26+ zones |
| `Private Queries` | $0.40/1M         | `1M`          | Per million DNS queries                  |

> **Note**: Zone pricing is **tiered** — first 25 zones at $0.50/zone/month, additional zones at $0.10/zone/month.

## Cost Formula

```
Monthly = zonePrice × zoneCount + queryPrice × (queriesInMillions)
```

For 25+ zones:

```
Monthly = ($0.50 × 25) + ($0.10 × (zoneCount - 25)) + queryPrice × queriesInMillions
```

## Example (10 zones, 5M queries/month)

```
Zones: $0.50 × 10 = $5.00/month
Queries: $0.40 × 5 = $2.00/month
Total: $7.00/month (USD)
```

## Notes

- USD-only (Global region) — see shared.md § Common Traps for mandatory currency conversion
- Private DNS zones are commonly paired with Private Endpoints (one zone per service type)
- Typical private endpoint zones: `privatelink.database.windows.net`, `privatelink.blob.core.windows.net`, etc.
- Query volume is usually very low — the zone hosting fee dominates for most deployments
````
