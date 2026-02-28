---
serviceName: Azure Managed Airflow
category: analytics
aliases: [ADF Airflow, Apache Airflow, Data Factory Airflow]
apiServiceName: Azure Data Factory v2
primaryCost: "vCore hourly rate × 730 per Airflow environment (Small or Large SKU)"
---

# Azure Managed Airflow

> **Trap (serviceName)**: API `serviceName` is `Azure Data Factory v2`, NOT `Azure Managed Airflow`. Always use `ServiceName: Azure Data Factory v2` with `ProductName: Azure Data Factory v2 - Managed Airflow` to isolate Managed Airflow meters. An unfiltered ADF v2 query returns hundreds of pipeline, SSIS, and Data Flow meters — totals inflate by orders of magnitude.

> **Trap (skuName required)**: Both Small and Large SKUs share `meterName: vCore`. Without a `SkuName` filter, the query returns both and the script sums them. Always specify `SkuName: Small` or `SkuName: Large`.

## Query Pattern

### Small environment — per vCore-hour

ServiceName: Azure Data Factory v2 <!-- cross-service -->
ProductName: Azure Data Factory v2 - Managed Airflow
SkuName: Small
MeterName: vCore

### Large environment — multiple Airflow environments

ServiceName: Azure Data Factory v2 <!-- cross-service -->
ProductName: Azure Data Factory v2 - Managed Airflow
SkuName: Large
MeterName: vCore
InstanceCount: 2 # number of Airflow environments

## Key Fields

| Parameter | How to determine | Example values |
| --- | --- | --- |
| `serviceName` | Always `Azure Data Factory v2` | `Azure Data Factory v2` |
| `productName` | Always the Managed Airflow product | `Azure Data Factory v2 - Managed Airflow` |
| `skuName` | Environment size selected by user (never-assume) | `Small`, `Large` |
| `meterName` | Always `vCore` | `vCore` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- |
| `vCore` | `Small` | `1 Hour` | Per vCore-hour for Small environment |
| `vCore` | `Large` | `1 Hour` | Per vCore-hour for Large environment |

## Cost Formula

```
Monthly = retailPrice × 730 × environmentCount
```

## Notes

- **Capacity planning**: Small environments support up to 50 DAGs; Large environments support up to 1,000 DAGs — ask user for environment size (never-assume parameter)
- **Split-product**: Managed Airflow (Workflow Orchestration Manager) is a sub-product of Azure Data Factory — ADF pipeline runs triggered by Airflow DAGs incur separate charges under the base ADF product; see `data-factory.md`
- **No RI or DevTest pricing**: Only consumption (PAYG) pricing is available — no reservations or dev/test discounts
- **30 regions**: Available in fewer regions than base ADF; notable absences include centralus, japaneast, koreacentral, canadacentral
