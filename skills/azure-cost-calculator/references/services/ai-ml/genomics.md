---
serviceName: Microsoft Genomics
category: ai-ml
aliases: [Genomics Workspace]
billingNeeds: [Storage]
primaryCost: "genome_retailPrice × genomeCount + gigabase_retailPrice × incrementalGB"
---

# Microsoft Genomics

> **Trap (unitOfMeasure)**: Both meters use `unitOfMeasure: "1"` (flat rate per unit), not hourly. The script treats this as unitless (monthly multiplier `1`, not `730`). `MonthlyCost` reflects a single unit only. Always set `Quantity` to the actual count of genomes or gigabases.

## Query Pattern

### Alignment and Variant Calling: per genome

ServiceName: Microsoft Genomics
ProductName: Microsoft Genomics
SkuName: Alignment and Variant Calling
MeterName: Alignment and Variant Calling Genome
Quantity: 5 # genomes processed this month

### Alignment and Variant Calling: per incremental gigabase

ServiceName: Microsoft Genomics
ProductName: Microsoft Genomics
SkuName: Alignment and Variant Calling
MeterName: Alignment and Variant Calling Incremental Gigabase
Quantity: 10 # incremental gigabases above the included 10 per genome

## Key Fields

| Parameter     | How to determine                                   | Example values                                                                               |
| ------------- | -------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `serviceName` | Always `Microsoft Genomics`                        | `Microsoft Genomics`                                                                         |
| `productName` | Always `Microsoft Genomics`                        | `Microsoft Genomics`                                                                         |
| `skuName`     | Always `Alignment and Variant Calling`             | `Alignment and Variant Calling`                                                              |
| `meterName`   | Processing model, per genome or per incremental GB | `Alignment and Variant Calling Genome`, `Alignment and Variant Calling Incremental Gigabase` |

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

## Notes

- Single product with only 2 meters. No tiers, no reserved instances, no savings plans
- Prices are identical across all returned Genomics regions; a standard regional query returns the same two meters
- `unitOfMeasure` is `1` for both meters; Quantity parameter equals the actual count of genomes or gigabases
- Billing model: genome rate covers first 10 gigabases per workflow; incremental rate applies to each additional gigabase
- Input/output data stored in Azure Blob Storage; billed separately under Storage
