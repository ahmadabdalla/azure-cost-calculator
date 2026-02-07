# Azure Cosmos DB
- **serviceName**: `Azure Cosmos DB`
- **category**: databases
- **aliases**: [CosmosDB, Cosmos, documentdb]

**Primary cost**: Provisioned throughput (RU/s per-hour) + storage

> **Trap**: The storage meter is `'Data Stored'` (not `'1 GB Data Stored'`). You also need `-ProductName 'Azure Cosmos DB'` and `-SkuName 'RUs'` to filter to the transactional storage meter and avoid free-tier/multi-master variants.

## Query Pattern

```powershell
# Provisioned throughput (use -Quantity for multiples of 100 RU/s)
# Example: 400 RU/s = -Quantity 4
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Cosmos DB' `
    -MeterName '100 RU/s' `
    -SkuName 'RUs' `
    -Quantity 4

# Storage (transactional)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Azure Cosmos DB' `
    -ProductName 'Azure Cosmos DB' `
    -MeterName 'Data Stored' `
    -SkuName 'RUs'
```

## Meter Names

| What           | meterName               | skuName | productName                  | Notes                                   |
| -------------- | ----------------------- | ------- | ---------------------------- | --------------------------------------- |
| Throughput     | `100 RU/s`              | `RUs`   | `Azure Cosmos DB`            | Use `-Quantity N` where N = RU/s ÷ 100  |
| Multi-master   | `100 Multi-master RU/s` | `mRUs`  | `Azure Cosmos DB`            | For multi-region writes                 |
| Storage        | `Data Stored`           | `RUs`   | `Azure Cosmos DB`            | Per GB/month for provisioned throughput |
| Serverless ops | `1M RUs`                | —       | `Azure Cosmos DB serverless` | Per million RU consumed                 |

## Cost Formula

```
Monthly Throughput = retailPrice_per_100RUs × (provisionedRUs / 100) × 730 hours
Monthly Storage    = storage_retailPrice × sizeInGB
Total              = Throughput + Storage
```

## Notes

- Free tier available (1000 RU/s + 25 GB free, one account per subscription)
- **Free tier guidance**: Do NOT deduct the free tier (1000 RU/s + 25 GB) from estimates unless the user explicitly confirms they are using a free-tier-eligible account. Production workloads typically do not use the free tier (only one free-tier account per subscription). Always ask the user if uncertain.
- Serverless pricing: per-RU consumed (different meter: `1M RUs` under productName `Azure Cosmos DB serverless`)
- Multi-region: multiply throughput cost by number of regions
- The storage query returns multiple skuName variants (`RUs`, `mRUs`, `RUm`, `Free Tier`) — filter to `RUs` for standard provisioned
- **Multi-region write (multi-master) costs ~2× single-region**: The `100 Multi-master RU/s` meter (skuName `mRUs`) is approximately double the price of the standard `100 RU/s` meter (skuName `RUs`). Always inform users about this multiplier when they request multi-region writes. For cost comparison, query both meters and show the per-region price difference.
