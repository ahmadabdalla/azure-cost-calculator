---
serviceName: Storage
category: storage
aliases: [Hybrid File Sync, File Server Sync, Cloud Tiering]
primaryCost: "Per registered server/month; first server free per Storage Sync Service"
hasFreeGrant: true
privateEndpoint: true
---

# Azure File Sync

> **Trap**: `serviceName: Storage` is shared across Blob, Files, Queue, Table, Managed Disks, Data Lake, and File Sync. Unfiltered queries return hundreds of unrelated meters. Always filter by `ProductName: File Sync`.

## Query Pattern

### Per-server sync fee — 5 registered servers (4 billable)

ServiceName: Storage
ProductName: File Sync
SkuName: Standard
MeterName: Standard Server
Quantity: 4 # billable servers (serverCount − 1; first is free)

## Key Fields

| Parameter     | How to determine                        | Example values                              |
| ------------- | --------------------------------------- | ------------------------------------------- |
| `serviceName` | Always `Storage`                        | `Storage`                                   |
| `productName` | Always `File Sync` for this sub-product | `File Sync`                                 |
| `skuName`     | Always `Standard`                       | `Standard`                                  |
| `meterName`   | Server sync fee or free grant           | `Standard Server`, `Standard Server - Free` |

## Meter Names

| Meter                    | unitOfMeasure | Notes                                           |
| ------------------------ | ------------- | ----------------------------------------------- |
| `Standard Server`        | `1/Month`     | Per registered server beyond the first free one |
| `Standard Server - Free` | `1/Month`     | One free server per Storage Sync Service        |

## Cost Formula

```
Monthly = max(0, serverCount - 1) × retailPrice
```

Where `serverCount` is total registered servers; first server is free per Storage Sync Service.

## Notes

- First registered server per Storage Sync Service is free; each additional server incurs the `Standard Server` rate
- Azure Files storage, transactions, and data transfer are billed separately under `serviceName: Storage` with Azure Files product names — see `storage/storage.md`
- Cloud tiering does not have a separate meter; recall operations generate Azure Files transactions and outbound data transfer charges
- Prices vary by region (up to ~2.3× the base rate) — always query the user's region
- US Gov regions may lack the `Standard Server - Free` meter; free grant may not apply in government cloud
- Private endpoints supported on the Storage Sync Service resource — see `networking/private-link.md` for PE and DNS zone pricing
