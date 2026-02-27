---
serviceName: Private DNS
category: networking
aliases: [Private DNS, Private DNS Zones]
apiServiceName: Azure DNS
primaryCost: "Per-zone/month (tiered: first 25 zones, then lower rate) + per million DNS queries"
pricingRegion: empty-region
---

# Private DNS Zones

> **Trap (mixed SKUs)**: The API `serviceName` "Azure DNS" returns Public, Private, Private Resolver, and DNS Security Policy meters. Filter with `skuName eq 'Private'` to isolate Private DNS pricing.
>
> **Trap (tiered pricing)**: Zone pricing returns two API rows (`tierMinimumUnits` 0 and 25). For ≤25 zones, use tier-1 `retailPrice` only. For 26+ zones, apply tier-1 to the first 25 and tier-2 to the remainder. Do NOT sum all tiers.

> **Warning**: **Empty-region pricing** — scripts require a Region filter and return nothing for Private DNS. Use `Region: Zone 1` as a workaround, or query the API directly with `armRegionName eq ''`. Prices are USD-only.

## Query Pattern

### Private Zone hosting (Quantity = number of zones)

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Azure DNS' and skuName eq 'Private' and meterName eq 'Private Zone' and armRegionName eq ''
Fields: meterName, unitPrice, unitOfMeasure, tierMinimumUnits

### Private DNS queries

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Azure DNS' and skuName eq 'Private' and meterName eq 'Private Queries' and armRegionName eq ''
Fields: meterName, unitPrice, unitOfMeasure

### Script workaround (Zone 1)

ServiceName: Azure DNS  <!-- cross-service -->
SkuName: Private
MeterName: Private Zone
Region: Zone 1
Quantity: 10

## Key Fields

| Parameter       | How to determine                                    | Example values                    |
| --------------- | --------------------------------------------------- | --------------------------------- |
| `serviceName`   | Always `Azure DNS` (shared with public DNS)         | `Azure DNS`                       |
| `productName`   | Single product                                      | `Azure DNS`                       |
| `skuName`       | `Private` for Private DNS zones                     | `Private`, `Public`               |
| `armRegionName` | Empty string or delivery zone — **not** ARM regions | `''`, `Zone 1`, `Zone 2`         |
| `meterName`     | Zone hosting or query volume                        | `Private Zone`, `Private Queries` |

## Meter Names

| Meter             | unitOfMeasure | Tier     | Notes                           |
| ----------------- | ------------- | -------- | ------------------------------- |
| `Private Zone`    | `1`           | First 25 | Per zone per month              |
| `Private Zone`    | `1`           | 26+      | Lower rate for additional zones |
| `Private Queries` | `1M`          | —        | Per million DNS queries         |

## Cost Formula

```
Zones   = zonePrice × zoneCount
Queries = queryPrice × queriesInMillions
Monthly = Zones + Queries
```

For 25+ zones:

```
Zones   = (tier1_retailPrice × 25) + (tier2_retailPrice × (zoneCount − 25))
Queries = queryPrice × queriesInMillions
Monthly = Zones + Queries
```

## Notes

- Private DNS zones are commonly paired with Private Endpoints — one zone per distinct service type, not per endpoint. See `networking/private-link.md` for PE billing
- AMPLS (Azure Monitor Private Link Scope) requires 5 Private DNS zones (monitor, oms, ods, agentsvc, blob) — AMPLS itself is a free grouping resource
- For the full list of `privatelink.*` zone names by service, see [Private Endpoint DNS](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)
- Query volume is usually very low — the zone hosting fee dominates for most deployments
