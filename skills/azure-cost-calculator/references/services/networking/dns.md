---
serviceName: Azure DNS
category: networking
aliases: [DNS Zones, Public DNS Zones]
primaryCost: "Per hosted zone per month (tiered) + per million DNS queries (tiered)"
pricingRegion: empty-region
---

# Azure DNS

> **Trap (mixed SKUs)**: Unfiltered queries return Public, Private, Private Resolver, and DNS Security Policy meters. Always filter with `SkuName: Public` for public DNS zones.
>
> **Trap (tiered pricing)**: Zone and query meters each return two rows (one per tier). For zones: apply tier 1 rate to the first 25, tier 2 rate to the remainder. For queries: apply tier 1 rate to the first 1B, tier 2 to the remainder. Do NOT use a single tier's rate for all units.

> **Warning**: **Zone-based regions / Global pricing** — use `Region: Zone 1` (not ARM regions) or query the API directly with empty armRegionName.

## Query Pattern

### Public DNS zone hosting (10 zones)

ServiceName: Azure DNS
SkuName: Public
MeterName: Public Zone
Region: Zone 1
Quantity: 10

### Public DNS queries

ServiceName: Azure DNS
SkuName: Public
MeterName: Public Queries
Region: Zone 1

### Direct API (Global pricing)

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Azure DNS' and skuName eq 'Public' and armRegionName eq ''
Fields: meterName, unitPrice, unitOfMeasure, tierMinimumUnits

## Key Fields

| Parameter     | How to determine                                        | Example values                                    |
| ------------- | ------------------------------------------------------- | ------------------------------------------------- |
| `serviceName` | Always `Azure DNS`                                      | `Azure DNS`                                       |
| `productName` | Single product                                          | `Azure DNS`                                       |
| `skuName`     | `Public` for public DNS zones                           | `Public`, `Private`                               |
| `Region`      | Delivery zone (Zone 1–4 / US Gov), **not** ARM regions  | `Zone 1`, `Zone 2`, `Zone 3`, `Zone 4`, `US Gov Zone 1` |
| `meterName`   | Zone hosting or query volume                            | `Public Zone`, `Public Queries`                   |

## Meter Names

| Meter            | unitOfMeasure | Tier         | Notes                          |
| ---------------- | ------------- | ------------ | ------------------------------ |
| `Public Zone`    | `1`           | First 25     | Per zone per month             |
| `Public Zone`    | `1`           | 26+          | Lower rate for additional zones |
| `Public Queries` | `1M`          | First 1B     | Per million queries            |
| `Public Queries` | `1M`          | 1B+          | Lower rate for high volume     |

> **Note**: Private DNS, Private Resolver, and DNS Security Policy meters share the same serviceName — see `private-dns.md` for Private DNS pricing.

## Cost Formula

```
Zones   = zonePrice × zoneCount
Queries = queryPrice × queriesInMillions
Monthly = Zones + Queries
```

For 25+ zones or 1B+ queries (tiered):

```
Zones   = (tier1_retailPrice × 25) + (tier2_retailPrice × (zoneCount - 25))
Queries = (tier1_retailPrice × 1000) + (tier2_retailPrice × (queriesInMillions - 1000))
Monthly = Zones + Queries
```

## Notes

- Zone pricing is per month; query pricing is per million queries
- First 25 zones are at the higher rate; zones 26+ at a lower rate
- First 1 billion queries at higher rate; queries beyond 1B at lower rate
- Query volume is typically low — zone hosting fee dominates most deployments
- See `private-dns.md` for Private DNS zone and Private Resolver pricing
