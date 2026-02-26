---
serviceName: Content Delivery Network
category: networking
aliases: [CDN, Azure CDN, CDN Classic, Azure CDN Classic, Content Delivery]
primaryCost: "Data transfer out per-GB (tiered) + HTTP requests per-million, priced by delivery zone"
---

# Content Delivery Network

> **Trap (Zone regions)**: CDN uses delivery zones (`Zone 1`, `Zone 2`, etc.), not ARM regions. Queries MUST use `-Region 'Zone 1'` — the default `eastus` returns zero results. Zone 1 = North America/Europe, Zone 2 = Asia Pacific, Zone 3 = South America, Zone 4 = Middle East/Africa, Zone 5 = Australia/India.
>
> **Trap (Tiered pricing)**: Data transfer has volume tiers (0–10 TB, 10–50 TB, etc.). The script returns all tiers — use `tierMinimumUnits` to identify the correct tier for the customer's expected volume. Do NOT sum all tiers.
>
> **Trap (Multiple providers)**: Three `productName` values exist — `Azure CDN from Microsoft`, `Azure CDN from Verizon`, `Azure CDN from Akamai`. Always filter by `productName` to avoid mixing providers.

## Query Pattern

### Standard Microsoft — data transfer (Zone 1, most common)

ServiceName: Content Delivery Network
ProductName: Azure CDN from Microsoft
SkuName: Standard
MeterName: Standard Data Transfer
Region: Zone 1

### Standard Microsoft — request pricing (per 1M requests)

ServiceName: Content Delivery Network
ProductName: Azure CDN from Microsoft
SkuName: Standard
MeterName: Standard Requests
Region: Zone 1

### Premium Verizon — data transfer with volume estimate

ServiceName: Content Delivery Network
ProductName: Azure CDN from Verizon
SkuName: Premium
MeterName: Premium Data Transfer
Quantity: 10000
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

- Three CDN providers available: Microsoft (most common for new deployments), Verizon (Standard/Premium), Akamai (Standard only for new profiles)
- Azure CDN from Microsoft includes rules engine (first 5 rules free, then per additional rule/month)
- Data transfer is tiered: 0–10 TB, 10–50 TB, 50–150 TB, 150–500 TB, 500 TB–1 PB, 1 PB+
- Zone 1 (North America/Europe) typically has the lowest per-GB rates
- **Azure Front Door Standard/Premium** is the recommended successor for new deployments
- 1 TB/month on Standard Microsoft (Zone 1) ≈ 1000 GB × the per-GB rate from the first tier
