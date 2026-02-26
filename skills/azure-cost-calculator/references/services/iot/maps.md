---
serviceName: Azure Maps
category: iot
aliases: [Location Services, Geospatial]
primaryCost: "Per 1K transactions by API category with free grants; Creator Map Provisioning billed hourly"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Maps

> **Trap (tiered free grants)**: Most Gen2 meters return **two rows** per meterName — a free tier (`tierMinimumUnits=0`, zero price) and a paid tier. The `totalMonthlyCost` sums both rows and does not subtract free grants. Use only the paid-tier `retailPrice` and manually deduct the free grant: `max(0, transactions - freeGrant) / 1000 × retailPrice`.

> **Trap (unfiltered query)**: Querying with only `ServiceName: Azure Maps` returns 69+ meters across five SKUs (Location Insights, Maps, Azure Maps Creator, Standard, Standard S1). Always filter with `SkuName` and `MeterName` to isolate specific API categories.

## Query Pattern

### Gen2 Search transactions (Quantity in 1K units)

ServiceName: Azure Maps
SkuName: Location Insights
MeterName: Location Insights Search
Quantity: 10

### Gen2 Base Map Tiles

ServiceName: Azure Maps
SkuName: Maps
MeterName: Maps Base Map Tiles

### Gen2 Routing transactions

ServiceName: Azure Maps
SkuName: Location Insights
MeterName: Location Insights Routing

### Creator Map Provisioning (hourly resource)

ServiceName: Azure Maps
SkuName: Azure Maps Creator
MeterName: Azure Maps Creator Map Provisioning

## Key Fields

| Parameter     | How to determine       | Example values                                    |
| ------------- | ---------------------- | ------------------------------------------------- |
| `serviceName` | Always `Azure Maps`    | `Azure Maps`                                      |
| `skuName`     | API category group     | `Location Insights`, `Maps`, `Azure Maps Creator` |
| `meterName`   | Specific API operation | `Location Insights Search`, `Maps Base Map Tiles` |

## Meter Names

| Meter | SKU | unitOfMeasure | Notes |
| ----- | --- | ------------- | ----- |
| `Location Insights Search` | Location Insights | 1K | 5K free, then paid per 1K |
| `Location Insights Routing` | Location Insights | 1K | 1K free, then paid per 1K |
| `Location Insights Weather` | Location Insights | 1K | 1K free, then paid per 1K |
| `Location Insights Geolocation` | Location Insights | 1K | 5K free, then paid per 1K |
| `Location Insights Elevation` | Location Insights | 1K | 1K free, higher paid rate |
| `Maps Base Map Tiles` | Maps | 1K | 5K free, then paid per 1K |
| `Maps Imagery Tiles` | Maps | 1K | 1K free, then paid per 1K |
| `Azure Maps Creator Map Provisioning` | Azure Maps Creator | 1/Hour | Hourly — always-on resource |
| `Azure Maps Creator Web Feature (WFS)` | Azure Maps Creator | 1K | No free grant, high rate per 1K |

## Cost Formula

```
Transaction monthly    = max(0, transactions - freeGrant) / 1000 × retailPrice
Creator Prov monthly   = retailPrice × 730
Total                  = Σ(per-category transaction costs) + Creator costs (if used)
```

## Notes

- Gen2 SKUs (`Location Insights`, `Maps`, `Azure Maps Creator`) are current; Gen1 (`Standard`, `Standard S1`) deprecated — retiring 9/15/2026
- Free grants vary per meter: 5K free for Search/Geolocation/Data/Timezone/Spatial/Base Map/Traffic Tiles; 1K free for Routing/Traffic/Weather/Elevation/Imagery/Static Map/Weather Tiles
- Capacity: each API category has independent free grants and per-1K-transaction pricing
- Creator Map Provisioning is the only hourly meter — billed at retailPrice × 730 hours/month (always-on)
- Creator Web Feature (WFS) has the highest rate — verify expected transaction volume before provisioning
- Transaction counting: tile loads may count 15 tiles = 1 transaction; batch operations count each query separately
- Supports private endpoints — see `networking/private-link.md` for PE and DNS zone pricing
