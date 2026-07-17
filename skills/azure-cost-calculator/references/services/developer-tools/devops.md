---
serviceName: Azure DevOps
category: developer-tools
aliases: [ADO, VSTS, Repos, Pipelines, Boards, Artifacts]
billingConsiderations: [M365 / Windows per-user licensing]
primaryCost: "Per-user/month license (Basic/Test Plans) + parallel jobs (per-job or per-minute) + Artifacts storage/GB"
pricingRegion: global
hasKnownRates: true
hasFreeGrant: true
---

# Azure DevOps

> **Note**: All Azure DevOps meters are Global-only (`armRegionName: Global`); always pass `Region: Global` or queries return nothing. Artifacts storage is tiered — use the first tier for estimates under 8 GB.

> **Trap (service-confusion)**: Do not confuse `Azure DevOps` (this SaaS platform) with `Azure DevOps Server` (on-premises, licensed separately) or `Azure Synapse Pipelines` (data integration, separate consumption meters). GitHub Advanced Security / Copilot "for AzDO" bill under `serviceName: GitHub`, not here.

## Query Pattern

### Basic user license: most common query

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

### Per-minute hosted agent (pay-per-use, no parallel-job slot)

ServiceName: Azure DevOps
ProductName: Azure Pipelines
SkuName: Linux 8-core
MeterName: Linux 8-core Job
Region: Global

### Artifacts storage

ServiceName: Azure DevOps
ProductName: Azure Artifacts
MeterName: Standard Data Stored
Region: Global

## Key Fields

| Parameter     | How to determine        | Example values                                                                             |
| ------------- | ----------------------- | ------------------------------------------------------------------------------------------ |
| `serviceName` | Always `Azure DevOps`   | `Azure DevOps`                                                                              |
| `productName` | Match billing component | `Azure Repos and Boards (Basic)`, `Azure Pipelines`, `Azure Test Plans`, `Azure Artifacts` |
| `skuName`     | Varies by product       | `Basic`, `Microsoft-hosted CI/CD`, `Self-hosted CI/CD`, `Linux 8-core`, `Standard`         |
| `meterName`   | Specific meter          | `Basic User`, `Microsoft-hosted CI/CD Concurrent Job`, `Linux 8-core Job`, `Standard Data Stored` |

## Meter Names

| Meter                                                       | productName                      | unitOfMeasure | Notes                              |
| ----------------------------------------------------------- | -------------------------------- | ------------- | ---------------------------------- |
| `Basic User`                                                | `Azure Repos and Boards (Basic)` | `1/Month`     | Per-user license                   |
| `Standard User`                                             | `Azure Test Plans`               | `1/Month`     | Basic + Test Plans license         |
| `Microsoft-hosted CI/CD Concurrent Job`                     | `Azure Pipelines`                | `1/Month`     | Parallel job (per-job/month)       |
| `Self-hosted CI/CD Concurrent Job`                          | `Azure Pipelines`                | `1/Month`     | Parallel job (per-job/month)       |
| `{Linux/Windows} {8/16}-core Job`, `macOS {Standard/XL} Job`| `Azure Pipelines`                | `1/Minute`    | Per-minute hosted agents (no slot) |
| `Standard Data Stored`                                      | `Azure Artifacts`                | `1 GB/Month`  | Tiered storage (0/8/98/998 GB)     |

> Also in API: `Advanced User` (`Azure Repos and Boards`, legacy enterprise SKU), `Microsoft-hosted CI/CD XAML` (legacy per-minute), `Cloud-Based Load Testing` (deprecated, sub-cent).

## Cost Formula

```
Monthly = (basic_users × basic_retailPrice) + (testplan_users × testplan_retailPrice)
        + (ms_hosted_jobs × ms_hosted_retailPrice) + (self_hosted_jobs × self_hosted_retailPrice)
        + (agent_minutes × per_minute_retailPrice)
        + max(0, artifacts_gb - 2) × artifacts_retailPrice
```

## Notes

- **Free tier**: First 5 Basic users free, 1 MS-Hosted parallel job (1,800 min/month) free, 1 Self-Hosted parallel job free (unlimited for public projects), 2 GB Artifacts storage free
- **Stakeholder access** is free and unlimited; provides work item tracking and dashboards only
- **Two pipeline billing models**: classic parallel jobs bill per-job/month (one job = one concurrent run); per-minute hosted agents (`1/Minute` SKUs, added 2026-05-01) bill only for minutes used, with no free grant and no slot to purchase
- **Artifacts tiered pricing**: 0–8 GB first tier, then 8–98 GB, 98–998 GB, 998+ GB from API `tierMinimumUnits`; the script sums all tiers, so compute the marginal GB per bracket manually
- Related services billed separately: self-hosted agent VMs (`Virtual Machines`), Azure Load Testing (replaces deprecated Cloud-Based Load Testing), and GitHub Advanced Security / Copilot for AzDO (`serviceName: GitHub`)

## Known Rates

| Component                       | Unit           | Rate (USD) | Free Grant                            |
| ------------------------------- | -------------- | ---------- | ------------------------------------- |
| Basic user license              | per-user/month | $6.00      | First 5 users                         |
| Basic + Test Plans license      | per-user/month | $52.00     | N/A                                   |
| MS-Hosted parallel job          | per-job/month  | $40.00     | 1 job (1,800 min/month)               |
| Self-Hosted parallel job        | per-job/month  | $15.00     | 1 job (unlimited for public projects) |
| Per-minute agent (Linux 8-core) | per-minute     | $0.022     | None                                  |
| Artifacts storage               | per-GB/month   | $2.00      | 2 GB                                  |

> Rates match `retailPrice` values from the API. Per-minute agents also cover Linux/Windows 16-core and macOS Standard/XL at higher rates. Published at the [Azure DevOps pricing page](https://azure.microsoft.com/pricing/details/devops/azure-devops-services/). For non-USD currencies, use the derivation method in [regions-and-currencies.md](../../regions-and-currencies.md).
