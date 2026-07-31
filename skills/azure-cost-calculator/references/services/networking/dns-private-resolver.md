---
serviceName: DNS Private Resolver
category: networking
aliases: [Private Resolver, DNS Resolver, Azure DNS Private Resolver]
apiServiceName: Azure DNS
primaryCost: "Per inbound/outbound endpoint per month + per DNS forwarding ruleset per month"
pricingRegion: empty-region
---

# DNS Private Resolver

> **Trap (mixed meters)**: The API `serviceName` "Azure DNS" returns meters across five `skuName` groups: `Public`, `Private`, `Private Resolver`, `DNS Security Policy Domains`, and `DNS Security Policy Queries`. Always filter with `skuName eq 'Private Resolver'` to isolate DNS Private Resolver pricing.

> **Warning**: **Empty-region pricing**: scripts require a Region filter. Run the pricing script with `Region: Zone 1`; fall back to the `API:` query below only if it returns nothing.

> **Agent instruction**: All three meters use `unitOfMeasure: "1"`. This is a per-month per-unit charge. Multiply by endpoint/ruleset count only. Do not apply the 730-hour multiplier and ignore the script's auto-calculated MonthlyCost for these meters.

## Query Pattern

### All Private Resolver meters (direct API)

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Azure DNS' and skuName eq 'Private Resolver' and armRegionName eq ''&currencyCode={currencyCode}
Fields: meterName, unitPrice, unitOfMeasure

### Inbound endpoints (Quantity = number of endpoints)

ServiceName: Azure DNS
SkuName: Private Resolver
MeterName: Private Resolver Inbound Endpoint
Region: Zone 1
Quantity: 2

### Outbound endpoints

ServiceName: Azure DNS
SkuName: Private Resolver
MeterName: Private Resolver Outbound Endpoint
Region: Zone 1

### DNS forwarding rulesets

ServiceName: Azure DNS
SkuName: Private Resolver
MeterName: Private Resolver DNS Forwarding Ruleset
Region: Zone 1

## Key Fields

| Parameter       | How to determine                                    | Example values                      |
| --------------- | --------------------------------------------------- | ----------------------------------- |
| `serviceName`   | Always `Azure DNS` (shared with public/private DNS) | `Azure DNS`                         |
| `productName`   | Single product                                      | `Azure DNS`                         |
| `skuName`       | `Private Resolver` for this service                 | `Private Resolver`                  |
| `armRegionName` | Empty string or delivery zone, not ARM regions      | `''`, `Zone 1`, `Zone 2`            |
| `meterName`     | Endpoint type or ruleset                            | `Private Resolver Inbound Endpoint` |

## Meter Names

| Meter                                     | unitOfMeasure | Notes                  |
| ----------------------------------------- | ------------- | ---------------------- |
| `Private Resolver Inbound Endpoint`       | `1`           | Per endpoint per month |
| `Private Resolver Outbound Endpoint`      | `1`           | Per endpoint per month |
| `Private Resolver DNS Forwarding Ruleset` | `1`           | Per ruleset per month  |

## Cost Formula

```
Inbound  = inbound_retailPrice × inboundEndpointCount
Outbound = outbound_retailPrice × outboundEndpointCount
Rulesets = ruleset_retailPrice × rulesetCount
Monthly  = Inbound + Outbound + Rulesets
```

## Notes

- The resolver resource itself is free. You only pay for endpoints and forwarding rulesets
- DNS query processing is included in the endpoint price. No per-query charges (unlike Public/Private DNS Zones)
- Each endpoint handles up to 10,000 QPS; max 5 inbound + 5 outbound endpoints per resolver
- Each endpoint requires a dedicated subnet (minimum /28) within the VNet
- Endpoints and rulesets are billed monthly, prorated to hours if deleted mid-month
- Each forwarding ruleset supports max 2 outbound endpoints, 1,000 forwarding rules, and 500 VNet links. Plan for multiple rulesets in large deployments
- Prices are uniform across all delivery zones. No regional variance
- See `networking/dns.md` and `networking/private-dns.md` for Public DNS and Private DNS Zone pricing (shared `serviceName`)
