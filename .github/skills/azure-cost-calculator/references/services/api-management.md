# API Management

**Primary cost**: Unit hours based on tier

## Query Pattern

```powershell
.\Get-AzurePricing.ps1 `
    -ServiceName 'API Management' `
    -MeterName 'Developer Unit'
```

## Key Meter Names

| Tier      | meterName        |
| --------- | ---------------- |
| Developer | `Developer Unit` |
| Basic     | `Basic Unit`     |
| Standard  | `Standard Unit`  |
| Premium   | `Premium Unit`   |

## Cost Formula

```
Monthly = retailPrice × 730 hours × unitCount
```
