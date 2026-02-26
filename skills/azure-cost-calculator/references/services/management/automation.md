---
serviceName: Automation
category: management
aliases: [Runbooks, DSC, Update Management]
billingNeeds: [Log Analytics]
primaryCost: "Per-minute runbook jobs + per-node DSC + free watcher hours, all with subscription-level free grants"
hasKnownRates: true
hasFreeGrant: true
privateEndpoint: true
---

# Automation

> **Trap (multiple products)**: Unfiltered `ServiceName: Automation` returns meters from three products (Process Automation, Configuration Management, Update Management) with mixed units (minutes, hours, nodes/month). Always filter by `ProductName` to isolate each billing dimension.

> **Trap (sub-cent pricing)**: Basic Runtime and Watcher meters are sub-cent and display as zero cost in script output. Use the Known Rates table and calculate manually. Free grants are aggregated per subscription, not per Automation account.

> **Note**: Automation-based Update Management retired 2024-08-31; replaced by Azure Update Manager. The `Basic Node` meter remains in the API at zero cost but no new deployments are possible.

## Query Pattern

### Process Automation — runbook job minutes (Basic)

ServiceName: Automation
ProductName: Process Automation
SkuName: Basic
MeterName: Basic Runtime
Quantity: 1000

### Watcher task hours (Basic)

ServiceName: Automation
ProductName: Process Automation
SkuName: Basic
MeterName: Watcher

### DSC — Non-Azure managed nodes

ServiceName: Automation
ProductName: Configuration Management
SkuName: Non-Azure
MeterName: Non-Azure Node
Quantity: 10

## Key Fields

| Parameter     | How to determine         | Example values                                                        |
| ------------- | ------------------------ | --------------------------------------------------------------------- |
| `serviceName` | Always `Automation`      | `Automation`                                                          |
| `productName` | Billing dimension        | `Process Automation`, `Configuration Management`, `Update Management` |
| `skuName`     | SKU tier or node type    | `Basic`, `Free`, `Azure`, `Non-Azure`                                 |
| `meterName`   | Matches the billing unit | `Basic Runtime`, `Watcher`, `Azure Node`, `Non-Azure Node`            |

## Meter Names

| Meter            | skuName     | productName                | unitOfMeasure | Notes                          |
| ---------------- | ----------- | -------------------------- | ------------- | ------------------------------ |
| `Basic Runtime`  | `Basic`     | `Process Automation`       | `1 Minute`    | Runbook job execution time     |
| `Watcher`        | `Basic`     | `Process Automation`       | `1 Hour`      | Watcher task runtime           |
| `Non-Azure Node` | `Non-Azure` | `Configuration Management` | `1/Month`     | DSC-managed non-Azure nodes    |
| `Azure Node`     | `Azure`     | `Configuration Management` | `1/Month`     | DSC-managed Azure nodes — free |
| `Basic Node`     | `Basic`     | `Update Management`        | `1/Month`     | Update-assessed nodes — free   |

## Cost Formula

```
Runbooks  = max(0, totalMinutes - 500) × runtime_retailPrice
Watchers  = max(0, totalHours - 744) × watcher_retailPrice
DSC Nodes = max(0, nonAzureNodes - 5) × node_retailPrice
Azure DSC = 0 (always free)
Updates   = 0 (always free — costs via Log Analytics data ingestion)

Monthly = Runbooks + Watchers + DSC Nodes
```

## Notes

- Free grants per subscription per month: 500 runbook minutes, 744 watcher hours, 5 non-Azure DSC nodes, unlimited Azure DSC nodes
- Free grants are NOT available to subscribers with flat-discount or fixed-monthly-credit rate plans
- Update Management meter is always zero cost — actual cost is Log Analytics data ingestion (see `monitoring/log-analytics.md`)
- Capacity planning: 1 runbook minute = 60 seconds of job execution; typical short jobs consume 1–5 minutes each
- Free SKU (`Free Runtime`, `Watcher`) mirrors Basic with identical or zero rates — use Basic SKU for cost estimation
- **PE sub-resources** (never-assume): `DSCAndHybridWorker`, `Webhook` — see `networking/private-link.md` for PE and DNS zone pricing

## Known Rates

| Meter            | Unit     | Published Rate (USD) | Free Grant    |
| ---------------- | -------- | -------------------- | ------------- |
| `Basic Runtime`  | 1 Minute | $0.002               | 500 min/month |
| `Watcher`        | 1 Hour   | $0.002               | 744 hrs/month |
| `Non-Azure Node` | 1/Month  | $6.00                | 5 nodes/month |
| `Azure Node`     | 1/Month  | $0.00                | Unlimited     |

> These rates are from the [Azure Automation pricing page](https://azure.microsoft.com/pricing/details/automation/). The API returns them
> but per-minute and per-hour rates are below what the script rounds to — the script shows `$0.00`.
> For non-USD currencies, use the method in [regions-and-currencies.md](../../regions-and-currencies.md).
