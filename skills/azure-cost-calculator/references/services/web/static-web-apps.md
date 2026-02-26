---
serviceName: Azure Static Web Apps
category: web
aliases: [SWA, JAMstack]
billingNeeds: [Azure App Service]
apiServiceName: Azure App Service
primaryCost: "Fixed monthly per-app fee (Standard) + bandwidth overage per-GB + optional Azure Front Door add-on hourly"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Static Web Apps

> **Trap (serviceName mismatch)**: The API `serviceName` is `Azure App Service`, not `Azure Static Web Apps`. You **must** include `ProductName: Static Web Apps` to isolate SWA meters from regular App Service meters.

> **Trap (Region availability)**: SWA pricing is not available in `eastus`. Use `Region: eastus2` or another supported region (centralus, westus2, westeurope, etc.).

> **Trap (Inflated totals)**: Omitting `MeterName` returns app + AFD + bandwidth meters summed together. Always filter by `MeterName` to get individual component costs.

> **Trap (Bandwidth tiered pricing)**: The script returns two rows — one at zero price (`tierMinimumUnits=0`, first 100 GB free) and one at the overage rate (`tierMinimumUnits=100`). The script multiplies `Quantity` × `unitPrice` per row without subtracting the free tier. Ignore `totalMonthlyCost` — manually calculate overage: `max(0, totalGB - 100) × overage_retailPrice`.

## Query Pattern

### Standard plan — per-app monthly fee (use Region eastus2; eastus has no data)

ServiceName: Azure App Service
ProductName: Static Web Apps
MeterName: Standard App
Region: eastus2

### Bandwidth — pass Quantity with total GB to see per-tier unit prices

ServiceName: Azure App Service
ProductName: Static Web Apps
MeterName: Standard Bandwidth Usage
Quantity: 500
Region: eastus2

### Azure Front Door add-on (enterprise-grade edge, hourly)

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

| Meter                              | unitOfMeasure | Notes                                          |
| ---------------------------------- | ------------- | ---------------------------------------------- |
| `Standard App`                     | `1/Month`     | Fixed per-app fee                              |
| `Standard Bandwidth Usage`         | `1 GB`        | Tiered: first 100 GB free, then overage per GB |
| `Standard Azure Front Door Add-on` | `1 Hour`      | Optional enterprise-grade edge network         |

## Cost Formula

```
App         = app_retailPrice × appCount
Bandwidth   = max(0, totalGB - 100) × overage_retailPrice  (manual calc — see trap)
AFD Add-on  = afd_retailPrice × 730 (if enabled)
Total       = App + Bandwidth + AFD Add-on
```

## Notes

- **Free tier**: Includes 2 custom domains, 100 GB bandwidth/month, built-in auth, and serverless APIs. No meters in the API — zero cost.
- **Standard tier**: Query API with eastus2 for current per-app monthly fee. Adds custom auth, SLA, and more APIs.
- **Bandwidth**: Standard includes 100 GB/month free. Query API for overage rate per GB — the API returns two bandwidth rows per region (free tier and overage tier).
- **Azure Front Door add-on**: Optional. Provides enterprise-grade edge with WAF, custom rules, and bot protection. Query API for current hourly rate.
- **Tier limitations**: Free tier — 2 custom domains, 0.5 GB storage, community support. Standard tier — 5 custom domains, 2 GB storage, SLA-backed.
- **Private Endpoints**: Supported on Standard tier only — not available on the Free tier.
