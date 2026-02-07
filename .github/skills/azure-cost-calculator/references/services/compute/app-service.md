# App Service Plans

**Primary cost**: Fixed hourly rate for the plan SKU × 730

## Query Pattern

```powershell
# Linux
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure App Service' `
    -SkuName 'P1 v3' `
    -ProductName 'Azure App Service Premium v3 Plan - Linux'

# Windows
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure App Service' `
    -SkuName 'P1 v3' `
    -ProductName 'Azure App Service Premium v3 Plan'
```

## Key Fields

| Parameter     | How to determine           | Example values                     |
| ------------- | -------------------------- | ---------------------------------- |
| `skuName`     | App Service Plan tier+size | `B1`, `B2`, `S1`, `P1 v3`, `P2 v3` |
| `productName` | Includes plan tier and OS  | See below                          |

## Product Names

| Tier       | Linux                                       | Windows                             |
| ---------- | ------------------------------------------- | ----------------------------------- |
| Basic      | `Azure App Service Basic Plan - Linux`      | `Azure App Service Basic Plan`      |
| Standard   | `Azure App Service Standard Plan - Linux`   | `Azure App Service Standard Plan`   |
| Premium v2 | `Azure App Service Premium v2 Plan - Linux` | `Azure App Service Premium v2 Plan` |
| Premium v3 | `Azure App Service Premium v3 Plan - Linux` | `Azure App Service Premium v3 Plan` |

## Cost Formula

```
Monthly = retailPrice × 730 hours × instanceCount
```

## Common SKUs

| SKU     | vCPUs | RAM (GB) | Tier       |
| ------- | ----- | -------- | ---------- |
| `B1`    | 1     | 1.75     | Basic      |
| `B2`    | 2     | 3.5      | Basic      |
| `S1`    | 1     | 1.75     | Standard   |
| `S2`    | 2     | 3.5      | Standard   |
| `P1 v2` | 1     | 3.5      | Premium v2 |
| `P2 v2` | 2     | 7        | Premium v2 |
| `P3 v2` | 4     | 14       | Premium v2 |
| `P1 v3` | 2     | 8        | Premium v3 |
| `P2 v3` | 4     | 16       | Premium v3 |
| `P3 v3` | 8     | 32       | Premium v3 |
