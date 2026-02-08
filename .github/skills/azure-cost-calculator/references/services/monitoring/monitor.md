---
serviceName: Azure Monitor
category: monitoring
aliases: [Azure Monitor Metrics, Metrics, Alerts, Diagnostics, Platform Metrics]
---

# Azure Monitor

> **Note**: Azure Monitor is the umbrella service for monitoring in Azure. For **Log Analytics** and **Application Insights** pricing, see their separate reference files: `log-analytics.md` and `app-insights.md`.

**Primary cost**: Platform metrics are free; custom metrics billed per time series

> **Trap**: Platform metrics (CPU, memory, network, etc.) emitted by Azure resources are **free** — do not include them in cost estimates. Only custom metrics published via the Azure Monitor API are billable.

## Query Pattern

```powershell
# Azure Monitor — custom metrics
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Monitor' `
    -MeterName 'Monitored Time Series'
```

## Key Fields

| Parameter     | How to determine                                  | Example values                      |
| ------------- | ------------------------------------------------- | ----------------------------------- |
| `serviceName` | Fixed value for Azure Monitor metrics             | `Azure Monitor`                     |
| `meterName`   | Custom metrics time series meter                  | `Monitored Time Series`             |

## Meter Names

| Meter                      | unitOfMeasure | Notes                                     |
| -------------------------- | ------------- | ----------------------------------------- |
| `Monitored Time Series`    | `10`          | Custom metrics - billed per 10 time series |

## Cost Formula

```
Monthly = (customTimeSeries / 10) × retailPrice
```

> **Note**: The first **10 time series** per resource are free. For example, if you have 45 custom time series, only 35 are billable: `billableTimeSeries = max(0, customTimeSeries - 10)`.

## Notes

- **Platform metrics are free**: All standard metrics emitted by Azure resources (CPU, memory, network, disk, etc.) have no cost
- **Custom metrics**: Metrics published via Azure Monitor API are billed per time series
- First 10 custom time series per resource are free
- **Alerts**: Basic metric alerts (platform metrics) are free; multi-resource, multi-condition, or custom metric alerts have separate pricing
- **Log Analytics and Application Insights** have separate pricing models - see `log-analytics.md` and `app-insights.md`
- **Diagnostic settings**: Routing platform metrics to destinations (Log Analytics, Storage, Event Hubs) is free, but destination storage/ingestion has costs
