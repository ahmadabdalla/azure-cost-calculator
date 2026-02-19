---
serviceName: Azure Cosmos DB
category: databases
aliases: [CosmosDB, Cosmos, documentdb]
billingConsiderations: [Reserved Instances]
primaryCost: "Provisioned throughput (RU/s per-hour) + storage"
privateEndpoint: true
---

# Azure Cosmos DB

> **Trap**: The storage meter is `'Data Stored'` (not `'1 GB Data Stored'`). You also need `-ProductName 'Azure Cosmos DB'` and `-SkuName 'RUs'` to filter to the transactional storage meter and avoid free-tier/multi-master variants.

## Query Pattern

### Provisioned throughput (e.g., 400 RU/s → Quantity: 4)

ServiceName: Azure Cosmos DB
MeterName: 100 RU/s
SkuName: RUs
Quantity: 4

### Autoscale provisioned throughput (e.g., 10,000 max RU/s → Quantity: 100)

ServiceName: Azure Cosmos DB
ProductName: Azure Cosmos DB autoscale
MeterName: AP1 100 RUs
SkuName: AP1
Quantity: 100

### Storage (transactional)

ServiceName: Azure Cosmos DB
ProductName: Azure Cosmos DB
MeterName: Data Stored
SkuName: RUs

## Meter Names

| What           | meterName               | skuName | productName                  | Notes                                   |
| -------------- | ----------------------- | ------- | ---------------------------- | --------------------------------------- |
| Throughput     | `100 RU/s`              | `RUs`   | `Azure Cosmos DB`            | Use `-Quantity N` where N = RU/s ÷ 100  |
| Multi-master   | `100 Multi-master RU/s` | `mRUs`  | `Azure Cosmos DB`            | For multi-region writes                 |
| Storage        | `Data Stored`           | `RUs`   | `Azure Cosmos DB`            | Per GB/month for provisioned throughput |
| Serverless ops | `1M RUs`                | —       | `Azure Cosmos DB serverless` | Per million RU consumed                 |
| Autoscale      | `AP1 100 RUs`           | `AP1`   | `Azure Cosmos DB autoscale`  | 1.5× standard rate — already baked in   |

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
- **Autoscale provisioned throughput**: The API has a **separate product** (`Azure Cosmos DB autoscale`) with its own meter (`AP1 100 RUs`, skuName `AP1`). The autoscale rate is exactly 1.5× the standard provisioned rate and this premium is **already included** in the API price. Do NOT query the standard `100 RU/s` meter and manually multiply by 1.5 — instead query the autoscale product directly. With autoscale, billing is based on the maximum RU/s set; calculate as `autoscale_price × (maxRUs / 100) × 730`.
- Supports private endpoints — see `networking/private-link.md` for PE and DNS zone pricing. PE sub-resource matches the account API type (never-assume): `Sql`, `MongoDB`, `Cassandra`, `Gremlin`, or `Table`. Conditional: `SqlDedicated` (dedicated gateway), `Analytical` (Synapse Link).
