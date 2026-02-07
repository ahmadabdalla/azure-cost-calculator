---
serviceName: Azure DNS
category: networking
aliases: [private DNS, DNS zones]
---

````markdown
# Private DNS Zones

**Primary cost**: Zone hosting (per-zone/month) + DNS queries

> **Critical trap**: Private DNS pricing is **NOT available under any standard region** (e.g., `eastus`, `australiaeast`). The data is listed under `armRegionName = 'Global'` or an empty string. The `Get-AzurePricing.ps1` script requires a `-Region` parameter and will silently return no results. **You must call the API directly** to get these prices.
> **Trap**: Prices returned from the Global region are in **USD only**, regardless of any currency parameter. Always note this caveat to the user.
> **Trap**: Zone pricing is **tiered** — the API returns multiple items with different `tierMinimumUnits`. First 25 zones at $0.50/zone/month, additional zones at $0.10/zone/month. Do NOT sum all tiers — pick the tier matching the expected zone count.
>
> **Agent instruction**: Do NOT use `Get-AzurePricing.ps1` or `Explore-AzurePricing.ps1` — they will silently return nothing. Copy the direct API query below into PowerShell. Prices are always USD regardless of currency parameter.
>
> **Currency instruction (MANDATORY)**: If the user's requested currency is NOT USD, you **MUST** convert the USD prices using the currency derivation method in [regions-and-currencies.md](../../regions-and-currencies.md#deriving-a-usdlocal-currency-conversion-factor). Do NOT present USD prices when the user requested a different currency.

## Query Pattern

```powershell
# Private Zone hosting cost
$uri = "https://prices.azure.com/api/retail/prices?`$filter=serviceName eq 'Azure DNS' and productName eq 'Azure DNS' and meterName eq 'Private Zone'"
(Invoke-RestMethod -Uri $uri).Items | Select-Object meterName, unitPrice, unitOfMeasure, currencyCode, armRegionName

# Private DNS queries
$uri = "https://prices.azure.com/api/retail/prices?`$filter=serviceName eq 'Azure DNS' and productName eq 'Azure DNS' and meterName eq 'Private Queries'"
(Invoke-RestMethod -Uri $uri).Items | Select-Object meterName, unitPrice, unitOfMeasure, currencyCode, armRegionName
```

## Key Fields

| Parameter       | Value                      |
| --------------- | -------------------------- |
| `serviceName`   | `Azure DNS`                |
| `productName`   | `Azure DNS`                |
| `armRegionName` | `''` (empty) or `'Global'` |

## Meter Names

| Meter             | Unit Price (USD) | unitOfMeasure | Notes                                    |
| ----------------- | ---------------- | ------------- | ---------------------------------------- |
| `Private Zone`    | $0.50/zone       | `1/Month`     | First 25 zones; $0.10/zone for 26+ zones |
| `Private Queries` | $0.40/1M         | `1M`          | Per million DNS queries                  |

> **Note**: Zone pricing is **tiered** — first 25 zones at $0.50/zone/month, additional zones at $0.10/zone/month.

## Cost Formula

```
Monthly = zonePrice × zoneCount + queryPrice × (queriesInMillions)
```

For 25+ zones:

```
Monthly = ($0.50 × 25) + ($0.10 × (zoneCount - 25)) + queryPrice × queriesInMillions
```

## Example (10 zones, 5M queries/month)

```
Zones: $0.50 × 10 = $5.00/month
Queries: $0.40 × 5 = $2.00/month
Total: $7.00/month (USD)
```

## Notes

- Prices returned from the Global region are in **USD** regardless of the `currencyCode` parameter. If the user requested a non-USD currency, you **MUST** convert using the derivation method in [regions-and-currencies.md](../../regions-and-currencies.md#deriving-a-usdlocal-currency-conversion-factor).
- Private DNS zones are commonly paired with Private Endpoints (one zone per service type)
- Typical private endpoint zones: `privatelink.database.windows.net`, `privatelink.blob.core.windows.net`, etc.
- Query volume is usually very low — the zone hosting fee dominates for most deployments
````
