---
serviceName: Azure Data Explorer
category: analytics
aliases: [ADX, Kusto]
billingNeeds: [Virtual Machines]
billingConsiderations: [Reserved Instances]
primaryCost: "Per-vCore hourly engine markup × cluster vCores + VM compute billed separately under Virtual Machines"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Data Explorer

> **Trap (markup only)**: The `Azure Data Explorer` serviceName returns only the engine cluster markup fee (per vCore per hour). The bulk of ADX cost comes from underlying Linux VM compute, billed separately under `Virtual Machines`. An estimate using only this serviceName will dramatically understate total cluster cost.

> **Trap (per-vCore)**: The markup is charged per **vCore**, not per VM instance. A node with 8 vCores incurs 8× the per-hour markup rate. Total markup = `markup_retailPrice × totalEngineVCores × 730`.

## Query Pattern

### Engine cluster markup — Standard (per vCore, hourly)

ServiceName: Azure Data Explorer
ProductName: Azure Data Explorer
SkuName: Standard
MeterName: Standard Engine Cluster Markup

### Engine cluster markup — 3-node cluster with 8 vCores each (Quantity = total vCores)

ServiceName: Azure Data Explorer
ProductName: Azure Data Explorer
SkuName: Standard
MeterName: Standard Engine Cluster Markup
Quantity: 24

## Key Fields

| Parameter     | How to determine                        | Example values                   |
| ------------- | --------------------------------------- | -------------------------------- |
| `serviceName` | Always `Azure Data Explorer`            | `Azure Data Explorer`            |
| `productName` | Always `Azure Data Explorer`            | `Azure Data Explorer`            |
| `skuName`     | Always `Standard` (production clusters) | `Standard`                       |
| `meterName`   | Single meter for engine markup          | `Standard Engine Cluster Markup` |

## Meter Names

| Meter                            | skuName    | unitOfMeasure | Notes                                                             |
| -------------------------------- | ---------- | ------------- | ----------------------------------------------------------------- |
| `Standard Engine Cluster Markup` | `Standard` | `1 Hour`      | Per engine vCore; no charge for Dev/Test or Data Management nodes |

## Cost Formula

```
Markup Monthly  = markup_retailPrice × totalEngineVCores × 730
VM Monthly      = vm_retailPrice × 730 × nodeCount   (billed under Virtual Machines)
Total Monthly   = Markup Monthly + VM Monthly + Storage + Networking
```

## Notes

- **Dev/Test tier**: No markup charge — only VM compute costs apply; uses D11 v2 or E2a v4 SKUs (single node, no SLA)
- **Stopped clusters**: Compute and markup billing stops; storage charges continue
- **Data Management nodes**: Auto-provisioned Da_v4 series VMs billed under Virtual Machines with no ADX markup
- **Capacity**: Engine node families include Compute Optimized (D/E-series) and Storage Optimized (L-series); minimum 2 engine + 2 Data Management nodes for production
- **Free cluster**: Trial cluster available (~100 GB storage, up to 10 databases, 1-year, no SLA) — not reflected in the API

## Reserved Instance Pricing

ServiceName: Azure Data Explorer
ProductName: Azure Data Explorer
SkuName: Standard
PriceType: Reservation
Region: westus2

> **Trap (RI region)**: RI pricing only appears in `westus2` in the API, but the reservation applies globally to all clusters per Microsoft documentation.
