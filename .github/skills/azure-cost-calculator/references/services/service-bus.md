# Service Bus

**Primary cost**: Namespace hours (Standard/Premium) + operations

## Query Pattern

```powershell
.\Get-AzurePricing.ps1 `
    -ServiceName 'Service Bus' `
    -ProductName 'Service Bus'
```

## Meter Names

| Tier     | meterName                |
| -------- | ------------------------ |
| Standard | `Standard Base Unit`     |
| Premium  | `Premium Messaging Unit` |

## Cost Formula

```
Monthly = hourly_rate × 730 + (operations/10M × operations_price)
```
