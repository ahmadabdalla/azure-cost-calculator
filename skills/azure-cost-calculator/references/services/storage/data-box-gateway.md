---
serviceName: Data Box Gateway
category: storage
aliases: [Data Box Virtual Appliance, Hybrid Data Transfer Gateway]
billingNeeds: [Storage]
apiServiceName: Data Box
primaryCost: "Standard daily service fee × 30 days/month; Azure Storage billed separately"
---

# Data Box Gateway

> **Trap (shared serviceName)**: API `serviceName` is `Data Box`, shared with Data Box physical devices (Data Box, Data Box V2, Data Box Disk, Data Box Heavy). Always filter by `ProductName: Data Box Gateway` to isolate.

> **Trap (daily billing)**: The meter uses `unitOfMeasure: 1 Day` (not `1/Day`), so the script does not auto-multiply to monthly — `MonthlyCost` shows only the daily rate. Pass `Quantity: 30` to get the correct monthly total.

## Query Pattern

### Standard daily service fee — monthly total

ServiceName: Data Box <!-- cross-service -->
ProductName: Data Box Gateway
SkuName: Standard
MeterName: Standard Service Fee
Quantity: 30 # 30 days/month for monthly cost

## Key Fields

| Parameter     | How to determine                               | Example values           |
| ------------- | ---------------------------------------------- | ------------------------ |
| `serviceName` | Always `Data Box` (shared)                     | `Data Box`               |
| `productName` | Always `Data Box Gateway` for this sub-product | `Data Box Gateway`       |
| `skuName`     | Always `Standard`                              | `Standard`               |
| `meterName`   | Daily appliance fee                            | `Standard Service Fee`   |

## Meter Names

| Meter                  | unitOfMeasure | Notes                           |
| ---------------------- | ------------- | ------------------------------- |
| `Standard Service Fee` | `1 Day`       | Flat daily fee per gateway unit |

## Cost Formula

```
Monthly per gateway = retailPrice × 30
Multiple gateways  = retailPrice × 30 × gatewayCount
```

## Notes

- Single SKU (`Standard`) with one meter — no tier selection needed
- Virtual appliance runs on-premises (Hyper-V or VMware); the daily fee covers the Azure management service only
- Azure Storage charges (Blob, Files, transactions) are billed separately under `serviceName: Storage` — see `storage/storage.md`
- Shares `serviceName: Data Box` with physical transfer devices — see `storage/data-box.md` for offline Data Box products
- Price is uniform across all regions — no regional variance
