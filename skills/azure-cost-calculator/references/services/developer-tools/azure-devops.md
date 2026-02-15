---
serviceName: Azure DevOps
category: developer-tools
aliases: [ADO, Repos, Pipelines, Boards, Artifacts]
billingConsiderations: [M365 / Windows per-user licensing]
---

# Azure DevOps

**Primary cost**: Per-user/month license fee (Basic/Basic+Test Plans) + parallel job fees + Artifacts storage per-GB beyond free tier

> **Warning**: Azure DevOps has **no meters** in the Azure Retail Prices API. Pricing is subscription-based (per-user, per-parallel-job), not consumption-metered. Use the Known Rates table below.
>
> **Agent instruction**: Do NOT query the pricing scripts — they return zero results. Use the Known Rates table to estimate. Multiply per-user rates by user count, add parallel job costs, and add Artifacts storage beyond the 2 GB free tier.

> **Trap**: Do not confuse `Azure DevOps` (this service — DevOps platform, no API meters) with `Azure DevOps Server` (on-premises, licensed separately) or `Azure Synapse Pipelines` (data integration — separate service with consumption meters in the API).

## Query Pattern

### No pricing meters exist — included for validation only

ServiceName: Azure DevOps
Quantity: 1

### Expected: 0 results — this service has no retail meters

## Key Fields

| Parameter     | How to determine          | Example values    |
| ------------- | ------------------------- | ----------------- |
| `serviceName` | Always `Azure DevOps`     | `Azure DevOps`    |
| `productName` | N/A — no meters in API    | N/A               |
| `skuName`     | N/A — no meters in API    | N/A               |

## Cost Formula

```
Monthly = (basic_users × basic_rate) + (testplan_users × testplan_rate)
        + (ms_hosted_jobs × ms_hosted_rate) + (self_hosted_jobs × self_hosted_rate)
        + max(0, artifacts_gb - 2) × artifacts_rate
```

## Notes

- **Free tier**: First 5 Basic users free, 1 MS-Hosted parallel job (1,800 min/month) free, 1 Self-Hosted parallel job free (unlimited for public projects), 2 GB Artifacts storage free
- **Stakeholder access** is free and unlimited — provides work item tracking and dashboards only
- Azure Pipelines parallel jobs are billed per-job/month, not per-minute — a parallel job allows one concurrent pipeline run
- Artifacts storage is billed per-GB/month beyond the 2 GB free grant across the organization
- Related services billed separately: build agent VMs (if self-hosted on Azure VMs), Azure Test Plans load testing infrastructure

## Known Rates

| Component | Unit | Rate (USD) | Free Grant |
| --------- | ---- | ---------- | ---------- |
| Basic user license | per-user/month | $6.00 | First 5 users |
| Basic + Test Plans license | per-user/month | $52.00 | N/A |
| MS-Hosted parallel job | per-job/month | $40.00 | 1 job (1,800 min/month) |
| Self-Hosted parallel job | per-job/month | $15.00 | 1 job (unlimited for public projects) |
| Artifacts storage | per-GB/month | $2.00 | 2 GB |

> These rates are from the [Azure DevOps pricing page](https://azure.microsoft.com/pricing/details/devops/azure-devops-services/). For non-USD currencies, use the currency derivation method in [regions-and-currencies.md](../../regions-and-currencies.md).
