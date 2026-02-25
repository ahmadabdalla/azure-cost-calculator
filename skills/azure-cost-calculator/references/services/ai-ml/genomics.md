---
serviceName: Microsoft Genomics
category: ai-ml
aliases: [Genomics Workspace]
billingNeeds: [Storage]
primaryCost: "Per-genome flat rate + per-incremental-gigabase volume fee"
---

# Microsoft Genomics

## Query Pattern

### Alignment and Variant Calling — per genome

ServiceName: Microsoft Genomics
ProductName: Microsoft Genomics
MeterName: Alignment and Variant Calling Genome
Quantity: 5

### Alignment and Variant Calling — per incremental gigabase

ServiceName: Microsoft Genomics
ProductName: Microsoft Genomics
MeterName: Alignment and Variant Calling Incremental Gigabase
Quantity: 10

## Key Fields

| Parameter     | How to determine                                    | Example values                                                                               |
| ------------- | --------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `serviceName` | Always `Microsoft Genomics`                         | `Microsoft Genomics`                                                                         |
| `productName` | Always `Microsoft Genomics`                         | `Microsoft Genomics`                                                                         |
| `skuName`     | Always `Alignment and Variant Calling`              | `Alignment and Variant Calling`                                                              |
| `meterName`   | Processing model — per genome or per incremental GB | `Alignment and Variant Calling Genome`, `Alignment and Variant Calling Incremental Gigabase` |

## Meter Names

| Meter                                                | unitOfMeasure | Notes                           |
| ---------------------------------------------------- | ------------- | ------------------------------- |
| `Alignment and Variant Calling Genome`               | `1`           | Flat rate per genome processed  |
| `Alignment and Variant Calling Incremental Gigabase` | `1`           | Per additional gigabase of data |

## Cost Formula

```
incrementalGB = max(totalGigabases - (10 × genomeCount), 0)
Monthly = (genome_retailPrice × genomeCount) + (gigabase_retailPrice × incrementalGB)
```

`Quantity` maps directly to number of genomes or gigabases (`unitOfMeasure` is `1`).

## Notes

- Single product with only 2 meters — no tiers, no reserved instances, no savings plans
- `unitOfMeasure` is `1` for both meters — Quantity parameter equals the actual count of genomes or gigabases
- Billing model: genome rate covers first 10 gigabases per workflow; incremental rate applies to each additional gigabase
- Input/output data stored in Azure Blob Storage — billed separately under Storage
