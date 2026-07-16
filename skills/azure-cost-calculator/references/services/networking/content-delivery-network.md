---
serviceName: Content Delivery Network
category: networking
aliases: [CDN, Azure CDN, CDN Classic, Azure CDN Classic, Content Delivery]
primaryCost: "Data transfer out per-GB (tiered) + HTTP requests per-million, priced by delivery zone"
---

# Content Delivery Network

> **Trap (Zone regions)**: CDN uses delivery zones (`Zone 1`, `Zone 2`, etc.), not ARM regions. Queries MUST use `-Region 'Zone 1'`. The default `eastus` returns zero results. Zone 1 = North America/Europe, Zone 2 = Asia Pacific, Zone 3 = South America, Zone 4 = Middle East/Africa, Zone 5 = Australia/India.
>
> **Trap (Tiered pricing)**: Data transfer has volume tiers (0–10 TB, 10–50 TB, etc.). The script returns all tiers. Use `tierMinimumUnits` to identify the correct tier for the customer's expected volume. Do NOT sum all tiers.
>
> **Warning**: Azure CDN is retired or retiring. Azure CDN from Akamai (2023-10-31) and Azure CDN from Verizon/Edgio (2025-01-15) are fully shut down and no longer bill. Azure CDN from Microsoft (classic) is blocked for new profiles since 2025-08-15 and retires 2027-09-30. For new workloads use Azure Front Door; see `networking/front-door.md`. Use this file only to estimate existing Azure CDN from Microsoft resources.

> **Trap (Multiple providers)**: The API still returns three `productName` values: `Azure CDN from Microsoft`, `Azure CDN from Verizon`, `Azure CDN from Akamai`. Verizon and Akamai meters are legacy billing residue only. Always filter by `productName` and use `Azure CDN from Microsoft` for any current estimate.

## Query Pattern

### Standard Microsoft: data transfer (Zone 1, most common)

ServiceName: Content Delivery Network
ProductName: Azure CDN from Microsoft
SkuName: Standard
MeterName: Standard Data Transfer
Region: Zone 1
Quantity: 10000

### Standard Microsoft: request pricing (per 1M requests)

ServiceName: Content Delivery Network
ProductName: Azure CDN from Microsoft
SkuName: Standard
MeterName: Standard Requests
Region: Zone 1

## Key Fields

| Parameter     | How to determine                  | Example values                                                                |
| ------------- | --------------------------------- | ----------------------------------------------------------------------------- |
| `serviceName` | Always `Content Delivery Network` | `Content Delivery Network`                                                    |
| `productName` | CDN provider chosen by user       | `Azure CDN from Microsoft`, `Azure CDN from Verizon`, `Azure CDN from Akamai` |
| `skuName`     | Tier selected                     | `Standard`, `Premium`, `WAF` (Microsoft WAF add-on)                           |
| `Region`      | Delivery zone (not ARM region)    | `Zone 1`, `Zone 2`, `Zone 3`, `Zone 4`, `Zone 5`                              |

## Meter Names

| Meter                                 | skuName    | productName              | unitOfMeasure | Notes                          |
| ------------------------------------- | ---------- | ------------------------ | ------------- | ------------------------------ |
| `Standard Data Transfer`              | `Standard` | All three providers      | 1 GB          | Tiered by volume               |
| `Standard Requests`                   | `Standard` | Azure CDN from Microsoft | 1M/Month      | HTTP request count             |
| `Standard Acceleration Data Transfer` | `Standard` | Akamai / Verizon         | 1 GB          | DSA acceleration traffic       |
| `Premium Data Transfer`               | `Premium`  | Verizon / Akamai         | 1 GB          | Premium tier, tiered by volume |

> WAF and Custom meters also exist under `Azure CDN from Microsoft`. Query with `-SkuName 'WAF'` for WAF policy/rule/request pricing.

## Cost Formula

```
Data transfer  = data_retailPrice × estimatedGB  (use tier matching customer volume)
Requests       = request_retailPrice × (requests / 1,000,000)
Monthly        = Data transfer + Requests
```

## Notes

- All CDN providers are retired or retiring for new deployments (see Warning). Only existing Azure CDN from Microsoft (classic) resources still bill, through 2027-09-30
- Azure CDN from Verizon/Edgio and Azure CDN from Akamai are fully shut down; their API meters are legacy residue and no longer generate charges
- Azure CDN from Microsoft includes a rules engine (first 5 rules free); the API `Standard Rule` meter currently returns zero price
- Data transfer is tiered: 0–10 TB, 10–50 TB, 50–150 TB, 150–500 TB, 500 TB–1 PB, 1 PB+ (Microsoft returns 6 tiers)
- Zone 1 (North America/Europe) typically has the lowest per-GB rates
- **Azure Front Door Standard/Premium** is the successor for new deployments; see `networking/front-door.md`
