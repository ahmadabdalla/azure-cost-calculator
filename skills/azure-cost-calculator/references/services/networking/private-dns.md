---
serviceName: Azure DNS
category: networking
aliases: [private DNS, Private DNS Zones]
primaryCost: "Zone hosting (per-zone/month) + DNS queries"
pricingRegion: global
---

# Private DNS Zones

> **Warning**: **Global-only pricing / USD-only** — see shared.md & Common Traps. Scripts require a Region filter and return nothing; call the API directly using query below.
> **Trap**: Zone pricing is **tiered** — the API returns two rows per region (`tierMinimumUnits` 0 and 25). For ≤25 zones, use tier-1 `retailPrice` only. For 25+ zones, apply tier-1 `retailPrice` to the first 25 and tier-2 `retailPrice` to the remainder. Do NOT sum all tiers as a flat total.

## Query Pattern

### Private Zone hosting cost

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Azure DNS' and productName eq 'Azure DNS' and meterName eq 'Private Zone'
Fields: meterName, unitPrice, unitOfMeasure, currencyCode, armRegionName

### Private DNS queries

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Azure DNS' and productName eq 'Azure DNS' and meterName eq 'Private Queries'
Fields: meterName, unitPrice, unitOfMeasure, currencyCode, armRegionName

## Key Fields

| Parameter       | Value                      |
| --------------- | -------------------------- |
| `serviceName`   | `Azure DNS`                |
| `productName`   | `Azure DNS`                |
| `armRegionName` | `''` (empty) or `'Global'` |

## Meter Names

| Meter             | unitOfMeasure | Tier     | Notes                           |
| ----------------- | ------------- | -------- | ------------------------------- |
| `Private Zone`    | `1/Month`     | First 25 | Per zone per month              |
| `Private Zone`    | `1/Month`     | 26+      | Lower rate for additional zones |
| `Private Queries` | `1M`          | —        | Per million DNS queries         |

> **Note**: Zone pricing is **tiered** — first 25 zones at tier-1 `retailPrice`, additional zones at tier-2 `retailPrice` (based on `tierMinimumUnits`).

## Cost Formula

```
Monthly = zonePrice × zoneCount + queryPrice × (queriesInMillions)
```

For 25+ zones:

```
Monthly = (tier1_retailPrice × 25) + (tier2_retailPrice × (zoneCount - 25)) + queryPrice × queriesInMillions
```

## Example (10 zones, 5M queries/month)

```
Zones:   tier1_retailPrice × 10
Queries: queryPrice × 5
Total:   Zones + Queries (USD)
```

## Notes

- USD-only (Global region) — see shared.md & Common Traps for mandatory currency conversion
- Private DNS zones are commonly paired with Private Endpoints — one zone per distinct service type, not per endpoint. See `networking/private-link.md` for PE billing
- AMPLS (Azure Monitor Private Link Scope) requires 5 Private DNS zones (monitor, oms, ods, agentsvc, blob) — AMPLS itself is a free grouping resource
- For the full list of `privatelink.*` zone names by service, see [Private Endpoint DNS](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)
- Query volume is usually very low — the zone hosting fee dominates for most deployments
