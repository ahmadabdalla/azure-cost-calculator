---
serviceName: Azure DNS
category: networking
aliases: [DNS Zones, Private DNS Zones]
---

# Azure DNS

**Primary cost**: Per hosted zone per month (tiered) + per million DNS queries (tiered)

> **Trap (mixed SKUs)**: Unfiltered queries return Public, Private, Private Resolver, and DNS Security Policy meters. Always filter with `SkuName: Public` for public DNS zones.
>
> **Trap (tiered pricing)**: Zone and query meters each have two tiers. First 25 zones at higher rate, zones 26+ at lower rate. First 1B queries at higher rate, 1B+ at lower rate. Do NOT sum both tiers — pick the tier matching expected volume.

> **Warning**: **Zone-based regions / Global pricing** — use `Region: Zone 1` (not ARM regions) or query the API directly with empty armRegionName.

## Query Pattern

### Public DNS zone hosting (10 zones)

ServiceName: Azure DNS
SkuName: Public
MeterName: Public Zone
Quantity: 10

### Public DNS queries

ServiceName: Azure DNS
SkuName: Public
MeterName: Public Queries

### Direct API (Global pricing)

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Azure DNS' and skuName eq 'Public' and armRegionName eq ''
Fields: meterName, unitPrice, unitOfMeasure, tierMinimumUnits

## Key Fields

| Parameter     | How to determine               | Example values           |
| ------------- | ------------------------------ | ------------------------ |
| `serviceName` | Always `Azure DNS`             | `Azure DNS`              |
| `productName` | Single product                 | `Azure DNS`              |
| `skuName`     | `Public` for public DNS zones  | `Public`, `Private`      |
| `meterName`   | Zone hosting or query volume   | `Public Zone`, `Public Queries` |

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

For 25+ zones (tiered):

```
Zones   = (tier1_retailPrice × 25) + (tier2_retailPrice × (zoneCount - 25))
Monthly = Zones + Queries
```

## Notes

- No reserved instance pricing available
- Zone pricing is per month; query pricing is per million queries
- First 25 zones are at the higher rate; zones 26+ at a lower rate
- First 1 billion queries at higher rate; queries beyond 1B at lower rate
- Query volume is typically low — zone hosting fee dominates most deployments
- See `private-dns.md` for Private DNS zone and Private Resolver pricing
