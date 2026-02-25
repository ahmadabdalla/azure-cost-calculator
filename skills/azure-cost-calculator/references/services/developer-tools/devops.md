---
serviceName: Azure DevOps
category: developer-tools
aliases: [ADO, VSTS, Repos, Pipelines, Boards, Artifacts]
billingConsiderations: [M365 / Windows per-user licensing]
primaryCost: "Per-user/month license (Basic/Test Plans) + parallel jobs + Artifacts storage per-GB beyond free tier"
pricingRegion: global
hasKnownRates: true
hasFreeGrant: true
---

# Azure DevOps

> **Note**: All Azure DevOps meters are Global-only (`armRegionName: Global`). For Artifacts, the API returns tiered pricing — use the first tier for estimates under 10 GB.

> **Trap**: Do not confuse `Azure DevOps` (this service — DevOps platform) with `Azure DevOps Server` (on-premises, licensed separately) or `Azure Synapse Pipelines` (data integration — separate service with consumption meters in the API).

## Query Pattern

### Basic user license — most common query

ServiceName: Azure DevOps
ProductName: Azure Repos and Boards (Basic)
MeterName: Basic User
Region: Global
Quantity: 10

### MS-Hosted parallel jobs (additional beyond free grant)

ServiceName: Azure DevOps
ProductName: Azure Pipelines
MeterName: Microsoft-hosted CI/CD Concurrent Job
Region: Global
InstanceCount: 3

### Artifacts storage

ServiceName: Azure DevOps
ProductName: Azure Artifacts
MeterName: Standard Data Stored
Region: Global

## Key Fields

| Parameter     | How to determine        | Example values                                                                             |
| ------------- | ----------------------- | ------------------------------------------------------------------------------------------ |
| `serviceName` | Always `Azure DevOps`   | `Azure DevOps`                                                                             |
| `productName` | Match billing component | `Azure Repos and Boards (Basic)`, `Azure Pipelines`, `Azure Test Plans`, `Azure Artifacts` |
| `skuName`     | Varies by product       | `Basic`, `Microsoft-hosted CI/CD`, `Self-hosted CI/CD`, `Standard`                         |
| `meterName`   | Specific meter          | `Basic User`, `Microsoft-hosted CI/CD Concurrent Job`, `Standard Data Stored`              |

## Meter Names

| Meter                                   | productName                      | unitOfMeasure | Notes              |
| --------------------------------------- | -------------------------------- | ------------- | ------------------ |
| `Basic User`                            | `Azure Repos and Boards (Basic)` | `1/Month`     | Per-user license   |
| `Standard User`                         | `Azure Test Plans`               | `1/Month`     | Test Plans license |
| `Microsoft-hosted CI/CD Concurrent Job` | `Azure Pipelines`                | `1/Month`     | Parallel job       |
| `Self-hosted CI/CD Concurrent Job`      | `Azure Pipelines`                | `1/Month`     | Parallel job       |
| `Standard Data Stored`                  | `Azure Artifacts`                | `1 GB/Month`  | Tiered storage     |

> Also in API: `Advanced User` (enterprise SKU), `Microsoft-hosted CI/CD XAML` (legacy per-minute), `Cloud-Based Load Testing` (deprecated).

## Cost Formula

```
Monthly = (basic_users × basic_retailPrice) + (testplan_users × testplan_retailPrice)
        + (ms_hosted_jobs × ms_hosted_retailPrice) + (self_hosted_jobs × self_hosted_retailPrice)
        + max(0, artifacts_gb - 2) × artifacts_retailPrice
```

## Notes

- **Free tier**: First 5 Basic users free, 1 MS-Hosted parallel job (1,800 min/month) free, 1 Self-Hosted parallel job free (unlimited for public projects), 2 GB Artifacts storage free
- **Stakeholder access** is free and unlimited — provides work item tracking and dashboards only
- Parallel jobs are billed per-job/month, not per-minute — one parallel job allows one concurrent pipeline run
- **Artifacts tiered pricing**: 0–8 GB at first-tier rate, 8–98 GB, 98–998 GB, 998+ GB — tiers from API `tierMinimumUnits`
- Related services billed separately: build agent VMs (if self-hosted on Azure VMs), Azure Test Plans load testing infrastructure

## Known Rates

| Component                  | Unit           | Rate (USD) | Free Grant                            |
| -------------------------- | -------------- | ---------- | ------------------------------------- |
| Basic user license         | per-user/month | $6.00      | First 5 users                         |
| Basic + Test Plans license | per-user/month | $52.00     | N/A                                   |
| MS-Hosted parallel job     | per-job/month  | $40.00     | 1 job (1,800 min/month)               |
| Self-Hosted parallel job   | per-job/month  | $15.00     | 1 job (unlimited for public projects) |
| Artifacts storage          | per-GB/month   | $2.00      | 2 GB                                  |

> These rates match `retailPrice` values from the API. Published at the [Azure DevOps pricing page](https://azure.microsoft.com/pricing/details/devops/azure-devops-services/). For non-USD currencies, use the currency derivation method in [regions-and-currencies.md](../../regions-and-currencies.md).
