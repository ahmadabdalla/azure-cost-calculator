---
serviceName: Azure Migrate
category: management
aliases: [Server Assessment, Migration Tools]
billingNeeds: [Azure Site Recovery, Azure Database Migration Service]
primaryCost: "Free hub — no direct meters. Costs flow through dependent services (Site Recovery, DMS, target infrastructure)."
hasMeters: false
pricingRegion: api-unavailable
hasKnownRates: true
privateEndpoint: true
---

# Azure Migrate

> **Warning**: Azure Migrate has **no meters** in the Azure Retail Prices API. All queries return zero results. Estimate costs via the dependent services listed in `billingNeeds`.
>
> **Agent instruction**: Do NOT query the pricing scripts for Azure Migrate — they return zero results. Use the Known Rates below for migration-specific costs. For target infrastructure (VMs, storage, networking), query those services directly.

> **Trap**: Do not confuse the free Azure Migrate hub with the paid services it orchestrates. Server replication costs are billed under `Azure Site Recovery`; database migration costs are billed under `Azure Database Migration Service`.

## Query Pattern

### No pricing meters exist — included for validation only

ServiceName: Azure Migrate
Quantity: 1

### Expected: 0 results — this service has no retail meters

## Key Fields

| Parameter     | How to determine         | Example values    |
| ------------- | ------------------------ | ----------------- |
| `serviceName` | Always `Azure Migrate`   | `Azure Migrate`   |
| `productName` | N/A — no meters in API   | N/A               |
| `skuName`     | N/A — no meters in API   | N/A               |
| `meterName`   | N/A — no meters in API   | N/A               |

## Cost Formula

```
Monthly = 0 (hub is free)

Migration project costs come from dependent services:
  Replication  = Site Recovery retailPrice × replicatedVMCount
  DB Migration = DMS_SKU_retailPrice × 730  (Premium tier only)
  Target infra = sum of VM, storage, and networking costs in target region
```

## Notes

- Azure Migrate hub (discovery, assessment, business case) is **completely free**
- Server replication uses Azure Site Recovery — first **180 days free** per instance (migration-specific benefit via Azure Migrate; standalone ASR for disaster recovery offers only 31 days free), then standard ASR rates
- Database Migration Service Standard tier (offline) is **always free**; Premium tier (online) has vCore billing after 180 days
- Storage consumed during replication and network egress are billed under their respective services regardless of free periods
- Third-party ISV tools (Carbonite, Cloudamize, etc.) have separate vendor licensing outside Azure billing
- Log Analytics data ingestion for Azure Migrate discovery is no longer complimentary; standard Azure Monitor rates apply for agent-based dependency analysis

## Known Rates

| Component | Rate (USD) | Free Period | Billed Under |
| --------- | ---------- | ----------- | ------------ |
| Server replication (per VM/month) | $25.00 | 180 days | Azure Site Recovery |
| DMS Standard (offline, per vCore/hr) | $0.00 | Always free | Azure Database Migration Service |
| DMS Premium 4 vCore (per hr) | $0.308 | 180 days | Azure Database Migration Service |

> These rates are from the [Azure Migrate pricing page](https://azure.microsoft.com/pricing/details/azure-migrate/). For Site Recovery and DMS details, see the respective service reference files.
