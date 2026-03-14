---
serviceName: DNS Private Resolver
category: networking
aliases: [Private Resolver, DNS Resolver, Azure DNS Private Resolver]
apiServiceName: Azure DNS
primaryCost: "Per inbound/outbound endpoint per month + per DNS forwarding ruleset per month"
pricingRegion: empty-region
---

# DNS Private Resolver

> **Trap (mixed meters)**: The API `serviceName` "Azure DNS" returns meters for Public DNS, Private DNS, Private Resolver, and DNS Security Policy. Always filter with `skuName eq 'Private Resolver'` to isolate DNS Private Resolver pricing.

> **Warning**: **Empty-region pricing** — scripts require a Region filter. Use `Region: Zone 1` as a workaround, or query the API directly with `armRegionName eq ''`. Prices are USD-only.

## Query Pattern

### All Private Resolver meters (direct API)

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Azure DNS' and skuName eq 'Private Resolver' and armRegionName eq ''
Fields: meterName, unitPrice, unitOfMeasure

### Inbound endpoints (Quantity = number of endpoints)

ServiceName: Azure DNS  <!-- cross-service -->
SkuName: Private Resolver
MeterName: Private Resolver Inbound Endpoint
Region: Zone 1
Quantity: 2

### Outbound endpoints

ServiceName: Azure DNS  <!-- cross-service -->
SkuName: Private Resolver
MeterName: Private Resolver Outbound Endpoint
Region: Zone 1

### DNS forwarding rulesets

ServiceName: Azure DNS  <!-- cross-service -->
SkuName: Private Resolver
MeterName: Private Resolver DNS Forwarding Ruleset
Region: Zone 1

## Key Fields

| Parameter       | How to determine                                    | Example values                              |
| --------------- | --------------------------------------------------- | ------------------------------------------- |
| `serviceName`   | Always `Azure DNS` (shared with public/private DNS) | `Azure DNS`                                 |
| `productName`   | Single product                                      | `Azure DNS`                                 |
| `skuName`       | `Private Resolver` for this service                 | `Private Resolver`                          |
| `armRegionName` | Empty string or delivery zone — not ARM regions     | `''`, `Zone 1`, `Zone 2`                    |
| `meterName`     | Endpoint type or ruleset                            | `Private Resolver Inbound Endpoint`         |

## Meter Names

| Meter                                      | unitOfMeasure | Notes                  |
| ------------------------------------------ | ------------- | ---------------------- |
| `Private Resolver Inbound Endpoint`        | `1`           | Per endpoint per month |
| `Private Resolver Outbound Endpoint`       | `1`           | Per endpoint per month |
| `Private Resolver DNS Forwarding Ruleset`  | `1`           | Per ruleset per month  |

## Cost Formula

```
Inbound  = inbound_retailPrice × inboundEndpointCount
Outbound = outbound_retailPrice × outboundEndpointCount
Rulesets = ruleset_retailPrice × rulesetCount
Monthly  = Inbound + Outbound + Rulesets
```

## Notes

- The resolver resource itself is free — you only pay for endpoints and forwarding rulesets
- DNS query processing is included in the endpoint price — no per-query charges (unlike Public/Private DNS Zones)
- Each endpoint handles up to 10,000 QPS; max 5 inbound + 5 outbound endpoints per resolver
- Each endpoint requires a dedicated subnet (minimum /28) within the VNet
- Prices are uniform across all delivery zones — no regional variance
- See `networking/dns.md` and `networking/private-dns.md` for Public DNS and Private DNS Zone pricing (shared `serviceName`)
