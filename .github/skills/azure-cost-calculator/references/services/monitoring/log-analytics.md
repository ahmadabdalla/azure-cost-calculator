---
serviceName: Log Analytics
category: monitoring
aliases: [OMS, Workspace, Logs, Log Analytics Workspace, Azure Monitor Logs, Operations Management Suite]
---

# Log Analytics

**Primary cost**: Data ingestion per-GB + retention beyond 31 days

> **Trap**: The meter names `'Pay-as-you-go Data Ingested'` and `'Data Ingestion'` do NOT exist in `australiaeast`. The correct Log Analytics meter is `'Analytics Logs Data Analyzed'` with skuName `'Analytics Logs'`.
> **Trap (ingestion free tier)**: The first **5 GB/month** of ingestion is free (Log Analytics workspace). Always deduct this from the billable total: `billable_GB = total_GB - 5`.
> **Trap (retention calculation)**: The first **31 days** of retention are free. For extended retention (e.g., 90 days), the chargeable window is `retentionDays - 31`. At steady-state ingestion of X GB/day, the retained data volume is `X × (retentionDays - 31)`. This is the most commonly miscalculated component — agents often forget to subtract the 31 free days or miscalculate the data volume in the chargeable window.

## Query Pattern

```powershell
# Log Analytics — pay-as-you-go ingestion (per GB)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Log Analytics' `
    -SkuName 'Analytics Logs' `
    -MeterName 'Analytics Logs Data Analyzed'

# Log Analytics — data retention (beyond 31 days free)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Log Analytics' `
    -SkuName 'Analytics Logs' `
    -MeterName 'Analytics Logs Data Retention'
```

## Key Fields

| Parameter     | How to determine                                  | Example values                      |
| ------------- | ------------------------------------------------- | ----------------------------------- |
| `serviceName` | Fixed value for Log Analytics workspace pricing  | `Log Analytics`                     |
| `skuName`     | Fixed value for pay-as-you-go tier                | `Analytics Logs`                    |
| `meterName`   | Either ingestion or retention meter               | `Analytics Logs Data Analyzed`, `Analytics Logs Data Retention` |

## Meter Names

| Meter                              | skuName         | unitOfMeasure | Notes                                     |
| ---------------------------------- | --------------- | ------------- | ----------------------------------------- |
| `Analytics Logs Data Analyzed`     | `Analytics Logs` | `1 GB`       | Pay-as-you-go data ingestion              |
| `Analytics Logs Data Retention`    | `Analytics Logs` | `1 GB`       | Data retention beyond 31 days free        |

## Cost Formula

```
Monthly Ingestion = retailPrice_per_GB × max(0, estimatedGB_per_month - 5)
Monthly Retention = retention_price_per_GB × retainedGB
Total = Monthly Ingestion + Monthly Retention
```

### Retention Calculation Detail

The first 31 days of retention are **free**. Charges apply for data retained beyond 31 days (up to the configured retention period, max 730 days).

**How to calculate retained GB**: For steady-state ingestion of X GB/day, the volume of data in the chargeable retention window (days 32 to configured max) is:

```
Retained GB = dailyIngestionGB × chargeableDays
where chargeableDays = min(retentionPeriodDays - 31, actualDaysOfData - 31)
```

For example, with 90-day retention and 5 GB/day steady ingestion:

```
Chargeable days = 90 - 31 = 59 days
Retained GB = 5 × 59 = 295 GB
Monthly retention cost = retentionPrice × 295
```

## Commitment Tiers (optional, for high-volume)

For 100+ GB/day, commitment tiers (100, 200, 300, 400, 500, 1000, 2000, 5000) offer discounts:

```powershell
# Example: 100 GB/day commitment tier
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Monitor' `
    -SkuName '100 GB Commitment Tier' `
    -MeterName '100 GB Commitment Tier Capacity Reservation'
```

> **Trap**: Commitment tier meters have `unitOfMeasure = '1/Day'`. The script's `MonthlyCost` reports the **daily price**. **Always ignore** and manually calculate: `unitPrice × 30`.

## Notes

- First 5 GB/month ingestion free per workspace
- First 31 days of retention included free; longer retention charged per-GB/month
- Maximum retention period: 730 days (2 years)
- Application Insights data flows into Log Analytics workspace when using workspace-based Application Insights
- Sentinel uses Log Analytics workspaces and meters for its data ingestion and retention
- Commitment tiers require 100+ GB/day ingestion and provide volume discounts
- Data export and archive features have separate pricing
