---
serviceName: Azure SCOM Managed Instance
category: monitoring
aliases: [SCOM MI, Operations Manager, System Center Operations Manager]
billingNeeds: [SQL Managed Instance, Virtual Machines, Load Balancer, Virtual Network, Key Vault]
apiServiceName: Azure Monitor
primaryCost: "Per-endpoint/month management fee; Azure-benefit endpoints free"
pricingRegion: global
hasFreeGrant: true
---

# Azure SCOM Managed Instance

> **Trap (serviceName)**: API `serviceName` is `Azure Monitor`, shared with all Azure Monitor products. An unfiltered query returns hundreds of unrelated meters. Always filter by `ProductName: Azure Monitor SCOM Managed Instance` to isolate SCOM MI pricing.

> **Warning**: **Global-only pricing** — all meters use `armRegionName = 'Global'`. Standard region queries (e.g., `eastus`) return zero results. Use `Region: Global`. Prices are USD-only; for non-USD currencies, derive a conversion factor per [regions-and-currencies.md](../../regions-and-currencies.md).

## Query Pattern

### Paid endpoint (InstanceCount = number of non-Azure endpoints)

ServiceName: Azure Monitor <!-- cross-service -->
ProductName: Azure Monitor SCOM Managed Instance
SkuName: Basic
MeterName: Basic Endpoint
Region: Global
InstanceCount: 10 # billable non-Azure endpoints

### Free Azure-benefit endpoint (zero cost)

ServiceName: Azure Monitor <!-- cross-service -->
ProductName: Azure Monitor SCOM Managed Instance
SkuName: Free Benefit- Azure
MeterName: Free Benefit- Azure Endpoint
Region: Global

## Key Fields

| Parameter     | How to determine                     | Example values                                        |
| ------------- | ------------------------------------ | ----------------------------------------------------- |
| `serviceName` | Always `Azure Monitor`               | `Azure Monitor`                                       |
| `productName` | Fixed — single product               | `Azure Monitor SCOM Managed Instance`                 |
| `skuName`     | Tier: `Basic` (paid) or free benefit | `Basic`, `Free Benefit- Azure`                        |
| `meterName`   | Matches the endpoint billing meter   | `Basic Endpoint`, `Free Benefit- Azure Endpoint`      |

## Meter Names

| Meter                          | skuName                | unitOfMeasure | Notes                            |
| ------------------------------ | ---------------------- | ------------- | -------------------------------- |
| `Basic Endpoint`               | `Basic`                | `1/Month`     | Per monitored non-Azure endpoint |
| `Free Benefit- Azure Endpoint` | `Free Benefit- Azure`  | `1/Month`     | Azure-native endpoints — free    |

## Cost Formula

```
Monthly = paidEndpoints × retailPrice
```

Azure-benefit endpoints (Azure VMs connected via managed identity) incur no SCOM MI per-endpoint charge.

## Notes

- **Free tier**: Azure-native endpoints monitored via managed identity are free (`Free Benefit- Azure` SKU); non-Azure and on-premises endpoints billed at retailPrice per endpoint per month
- **Platform fee only**: The per-endpoint meter covers the SCOM MI management fee only — underlying infrastructure (SQL MI, VMSS, Load Balancer, VNet, Key Vault) is billed separately under their respective Azure services
- **Endpoint count** is a never-assume parameter — always ask the user for the number of monitored endpoints
- For other Azure Monitor meters (custom metrics, Basic Logs, archive), see `monitor.md`; for Log Analytics workspace pricing, see `log-analytics.md`
