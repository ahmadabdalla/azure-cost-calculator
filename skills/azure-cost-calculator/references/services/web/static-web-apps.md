---
serviceName: Azure Static Web Apps
category: web
aliases: [SWA, JAMstack]
---

# Azure Static Web Apps

**Primary cost**: Fixed monthly per-app fee (Standard) + bandwidth overage per-GB + optional Azure Front Door add-on hourly

> **Trap (serviceName mismatch)**: The API `serviceName` is `Azure App Service`, not `Azure Static Web Apps`. You **must** include `ProductName 'Static Web Apps'` to isolate SWA meters from regular App Service meters.

> **Trap (Region availability)**: SWA pricing is not available in `eastus`. Use `Region 'eastus2'` or another supported region (centralus, westus2, westeurope, etc.).

> **Trap (Inflated totals)**: Omitting `MeterName` returns app + AFD + bandwidth meters summed together (~$26.72). Always filter by `MeterName` to get individual component costs.

## Query Pattern

# Standard plan — per-app monthly fee (use Region eastus2; eastus has no data)

ServiceName: Azure App Service
ProductName: Static Web Apps
MeterName: Standard App
Region: eastus2

# Bandwidth — pass Quantity with total GB to see per-tier unit prices

ServiceName: Azure App Service
ProductName: Static Web Apps
MeterName: Standard Bandwidth Usage
Quantity: 500
Region: eastus2

> **Trap (Bandwidth tiered pricing)**: The script returns two rows — one at $0.00 (`tierMinimumUnits=0`, first 100 GB) and one at $0.20 (`tierMinimumUnits=100`, overage). The script multiplies `Quantity` × `unitPrice` per row without subtracting the free tier. Ignore `totalMonthlyCost` — manually calculate overage: `max(0, totalGB - 100) × overage_retailPrice`.

# Azure Front Door add-on (enterprise-grade edge, hourly)

ServiceName: Azure App Service
ProductName: Static Web Apps
MeterName: Standard Azure Front Door Add-on
Region: eastus2

## Key Fields

| Parameter     | How to determine                         | Example values                             |
| ------------- | ---------------------------------------- | ------------------------------------------ |
| `serviceName` | Always `Azure App Service`               | `Azure App Service`                        |
| `productName` | Always `Static Web Apps`                 | `Static Web Apps`                          |
| `skuName`     | Only `Standard` has meters               | `Standard`                                 |
| `meterName`   | Component: app, bandwidth, or AFD add-on | `Standard App`, `Standard Bandwidth Usage` |

## Meter Names

| Meter                              | unitOfMeasure | Notes                                        |
| ---------------------------------- | ------------- | -------------------------------------------- |
| `Standard App`                     | `1/Month`     | Fixed per-app fee                            |
| `Standard Bandwidth Usage`         | `1 GB`        | Tiered: first 100 GB included, then $0.20/GB |
| `Standard Azure Front Door Add-on` | `1 Hour`      | Optional enterprise-grade edge network       |

## Cost Formula

```
App         = app_retailPrice × appCount
Bandwidth   = max(0, totalGB - 100) × overage_retailPrice  (manual calc — see trap)
AFD Add-on  = afd_retailPrice × 730 (if enabled)
Total       = App + Bandwidth + AFD Add-on
```

## Notes

- **Free tier**: Includes 2 custom domains, 100 GB bandwidth/month, built-in auth, and serverless APIs. No meters in the API — cost is $0.
- **Standard tier**: $9/mo per app (eastus2). Adds custom auth, SLA, and more APIs.
- **Bandwidth**: Standard includes 100 GB/month free. Overage is $0.20/GB (eastus2). The API returns two bandwidth rows per region — one at $0.00 (included) with `tierMinimumUnits=0` and one at the overage rate with `tierMinimumUnits=100`.
- **Azure Front Door add-on**: Optional. Provides enterprise-grade edge with WAF, custom rules, and bot protection. ~$17.52/mo (eastus2).
- **No reserved pricing**: RI queries return zero results. Do not attempt `-PriceType Reservation`.
- **Tier limitations**: Free tier — 2 custom domains, 0.5 GB storage, community support. Standard tier — 5 custom domains, 2 GB storage, SLA-backed.
