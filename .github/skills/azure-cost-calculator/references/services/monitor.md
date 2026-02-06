# Application Insights / Log Analytics

**Primary cost**: Data ingestion per-GB + retention

> **Trap**: The meter names `'Pay-as-you-go Data Ingested'` and `'Data Ingestion'` do NOT exist in `australiaeast`. The correct Log Analytics meter is `'Analytics Logs Data Analyzed'` with skuName `'Analytics Logs'`.
> **Trap**: Azure Monitor commitment tiers use per-day pricing (`1/Day` unit), not per-GB. Only use them if the user needs 100+ GB/day.
> **Trap (ingestion free tier)**: The first **5 GB/month** of ingestion is free (Log Analytics workspace). Always deduct this from the billable total: `billable_GB = total_GB - 5`.
> **Trap (retention calculation)**: The first **31 days** of retention are free. For extended retention (e.g., 90 days), the chargeable window is `retentionDays - 31`. At steady-state ingestion of X GB/day, the retained data volume is `X × (retentionDays - 31)`. This is the most commonly miscalculated component — agents often forget to subtract the 31 free days or miscalculate the data volume in the chargeable window.

## Query Pattern

```powershell
# Log Analytics — pay-as-you-go ingestion (per GB)
# This is the primary meter for Application Insights + Log Analytics data
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

## Cost Formula

```
Monthly Ingestion = retailPrice_per_GB × estimatedGB_per_month
Monthly Retention = retention_price_per_GB × retainedGB
Total = Ingestion + Retention
```

### Retention Calculation Clarification

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

> **Note**: The first 5 GB/month of ingestion is free (Log Analytics workspace). This applies to ingestion only, not retention.

## Commitment Tiers (optional, for high-volume)

For 100+ GB/day, commitment tiers offer discounts. Use this pattern:

```powershell
# Example: 100 GB/day commitment tier
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Monitor' `
    -SkuName '100 GB Commitment Tier' `
    -MeterName '100 GB Commitment Tier Capacity Reservation'
```

Available tiers: 100, 200, 300, 400, 500, 1000, 2000, 5000 GB/day.

> **Trap (verified 2026-02-06)**: Commitment tier meters have `unitOfMeasure = '1/Day'`. The script's `MonthlyCost` field reports the **daily price** (e.g., €869/day), NOT the monthly cost. **Always ignore the script's `MonthlyCost`** for commitment tiers and manually calculate: `unitPrice × 30`.

## Notes

- First 5 GB/month free (Log Analytics workspace)
- 31 days retention included free; longer retention charged per-GB/month
- Application Insights data flows into Log Analytics workspace
- **Workspace-based Application Insights has no additional cost** beyond Log Analytics ingestion. Do NOT query a separate Application Insights meter — all telemetry costs are captured by the Log Analytics workspace ingestion and retention charges above. Only classic (non-workspace-based) Application Insights has separate billing, and it is being retired.
- For a typical app ingesting 5 GB/day: monthly cost = ingestionPrice × 150 GB — query live price for current per-GB rate
