# Redis Cache

**Primary cost**: Cache instance hours based on tier and size

## Query Pattern

```powershell
.\Get-AzurePricing.ps1 `
    -ServiceName 'Redis Cache' `
    -MeterName 'C1 Cache Instance'
```

> **Note:** The Azure Portal calls this "Azure Cache for Redis" but the Retail Prices API uses `Redis Cache` as the `serviceName`. Verified 2026-02-06.

## Reserved Instance Pricing

```powershell
# RI for Premium P2 (returns both 1-Year and 3-Year terms)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Redis Cache' `
    -MeterName 'P2 Cache Instance' `
    -PriceType Reservation

# RI for Premium P4
.\Get-AzurePricing.ps1 `
    -ServiceName 'Redis Cache' `
    -MeterName 'P4 Cache Instance' `
    -PriceType Reservation
```

> **Note**: Reserved Instances are available for **Premium tier only** (P1-P5). Basic and Standard tiers do not support reservations. The API returns the **total prepaid cost** for the reservation term. To get monthly cost, divide the `retailPrice` by 12 (1-Year) or 36 (3-Years). Both 1-Year and 3-Year results are returned in a single query — select the desired term from the results.
>
> **Trap (RI MonthlyCost — verified 2026-02-06)**: The script’s `MonthlyCost` is **wildly wrong** for Reservation items. It multiplies the total term price by 730 hours, producing absurd values (e.g., £million+). **Always ignore the script’s `MonthlyCost`** for Reservation items and manually calculate: `unitPrice ÷ 12` for 1-Year monthly cost, or `unitPrice ÷ 36` for 3-Year monthly cost.

## Key Meter Name Pattern

Format: `{tier_prefix}{size} Cache Instance`

- Basic: `C0`, `C1`, `C2`, `C3`, `C4`, `C5`, `C6`
- Standard: same sizes, different product filter
- Premium: `P1`, `P2`, `P3`, `P4`, `P5`

## Cost Formula

```
Monthly = retailPrice × 730 hours × shardCount × (1 + replicas)
```
