---
serviceName: DNS Security Policy
category: networking
aliases: [DNS Security, DNS Filtering, DNS Threat Intelligence]
apiServiceName: Azure DNS
primaryCost: "Per 1K managed domains/month + per million DNS security queries"
---

# DNS Security Policy

> **Trap (mixed SKUs)**: The API `serviceName` "Azure DNS" returns Public, Private, Private Resolver, and DNS Security Policy meters. Filter with `skuName` containing `DNS Security Policy` to isolate.
>
> **Trap (domain unit)**: The domains meter `unitOfMeasure` is `1` but each unit represents 1,000 domain entries per the pricing page. Use `Quantity = ceil(totalDomains / 1000)` to avoid overcharging by 1,000×.

> **Warning**: **Zone-based regions**: standard ARM regions (e.g., `eastus`) return nothing. Use `Region: Zone 1` with scripts or `armRegionName eq 'Zone 1'` with the API. Prices are uniform across commercial zones (Zone 1–4); Azure Government zones (`US Gov Zone 1`/`2`) carry a premium.

## Query Pattern

### Managed domains (1 unit = 1,000 domains)

ServiceName: Azure DNS
SkuName: DNS Security Policy Domains
MeterName: DNS Security Policy Domains Managed Domain
Region: Zone 1
Quantity: 5

### DNS security queries (per million)

ServiceName: Azure DNS
SkuName: DNS Security Policy Queries
MeterName: DNS Security Policy Queries
Region: Zone 1

### Direct API (both meters, Zone 1)

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Azure DNS' and contains(skuName, 'DNS Security Policy') and armRegionName eq 'Zone 1'
Fields: meterName, skuName, unitPrice, unitOfMeasure

## Key Fields

| Parameter     | How to determine                                    | Example values                                                              |
| ------------- | --------------------------------------------------- | --------------------------------------------------------------------------- |
| `serviceName` | Always `Azure DNS` (shared with public/private DNS) | `Azure DNS`                                                                 |
| `productName` | Single product                                      | `Azure DNS`                                                                 |
| `skuName`     | Meter family for DNS Security Policy                | `DNS Security Policy Domains`, `DNS Security Policy Queries`                |
| `Region`      | Delivery zone (Zone 1–4, US Gov), **not** ARM regions | `Zone 1`, `Zone 2`, `Zone 3`, `Zone 4`, `US Gov Zone 1`                     |
| `meterName`   | Domains or queries dimension                        | `DNS Security Policy Domains Managed Domain`, `DNS Security Policy Queries` |

## Meter Names

| Meter                                        | unitOfMeasure | Notes                             |
| -------------------------------------------- | ------------- | --------------------------------- |
| `DNS Security Policy Domains Managed Domain` | `1`           | Per 1,000 domains in domain lists |
| `DNS Security Policy Queries`                | `1M`          | Per million filtered DNS queries  |

## Cost Formula

```
Domains = domainUnit_retailPrice × ceil(totalDomains / 1000)
Queries = query_retailPrice × queriesInMillions
Monthly = Domains + Queries
```

## Notes

- 1 domain unit = 1,000 domain entries across all domain lists; charges are prorated to hours
- Queries are only billed when DNS traffic rules are configured in the policy
- Policies are region-scoped; costs multiply if deployed across multiple regions
- Diagnostic logging (Log Analytics, Storage, Event Hub) incurs separate costs from those services
- See `dns.md` for public DNS zone pricing and `private-dns.md` for Private DNS pricing
