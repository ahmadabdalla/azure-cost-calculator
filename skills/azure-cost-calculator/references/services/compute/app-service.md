---
serviceName: Azure App Service
category: compute
aliases: [app service, web app, webapp]
billingConsiderations: [Reserved Instances]
---

# App Service Plans

**Primary cost**: Fixed hourly rate for the plan SKU × 730

## Query Pattern

### Linux (use InstanceCount for multiple instances)

ServiceName: Azure App Service
SkuName: P1 v3
ProductName: Azure App Service Premium v3 Plan - Linux
InstanceCount: 2

### Windows

ServiceName: Azure App Service
SkuName: P1 v3
ProductName: Azure App Service Premium v3 Plan

## Key Fields

| Parameter     | How to determine           | Example values                     |
| ------------- | -------------------------- | ---------------------------------- |
| `skuName`     | App Service Plan tier+size | `B1`, `B2`, `S1`, `P1 v3`, `P2 v3` |
| `productName` | Includes plan tier and OS  | See below                          |

## Cost Formula

```
Monthly = retailPrice × 730 hours × instanceCount
```

## Notes

- App Service Plans are billed whether or not apps are running on them — deleting all apps does not stop billing; delete the plan itself
- Multiple apps can share one plan; cost is per-plan, not per-app
- Windows plans omit the OS suffix in `productName` (e.g., `Azure App Service Premium v3 Plan`); Linux plans append `- Linux`
- Free (F1) and Shared (D1) tiers exist but are not recommended for production and may not appear in all regions
- **Functions on Dedicated plans** (B1/S1/P1v3) are billed entirely through App Service — no meters appear under `Functions`; see functions.md
- **Logic Apps Standard** creates WS-type App Service Plan resources in the portal, but billing flows through `Logic Apps` meters — not App Service; see logic-apps.md

## Product Names

| Tier       | Linux                                       | Windows                             |
| ---------- | ------------------------------------------- | ----------------------------------- |
| Basic      | `Azure App Service Basic Plan - Linux`      | `Azure App Service Basic Plan`      |
| Standard   | `Azure App Service Standard Plan - Linux`   | `Azure App Service Standard Plan`   |
| Premium v2 | `Azure App Service Premium v2 Plan - Linux` | `Azure App Service Premium v2 Plan` |
| Premium v3 | `Azure App Service Premium v3 Plan - Linux` | `Azure App Service Premium v3 Plan` |

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
