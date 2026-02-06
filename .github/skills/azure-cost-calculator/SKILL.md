---
name: azure-cost-calculator
description: Helps estimate and calculate Azure resource costs. Use this skill when users ask about Azure pricing, cost estimation, resource sizing costs, comparing pricing tiers, budgeting for Azure deployments, or understanding Azure billing. Triggers include questions like "how much will this cost in Azure", "estimate Azure costs", "compare Azure pricing", "budget for Azure resources", "how much does a D2s v5 cost", or "compare VM pricing across regions". Covers 20+ resource types including VMs, App Service, SQL Database, Storage, Functions, Cosmos DB, Key Vault, AKS, API Management, Service Bus, Redis, Application Gateway, Container Apps, Application Insights, Load Balancer, PostgreSQL Flexible Server, Azure Firewall, Container Registry, Private Link, Private DNS, Defender for Cloud, and DDoS Protection.
---

# Azure Cost Calculator

Deterministic Azure cost estimation using the public Retail Prices API. Never guess prices — always query the live API via the scripts.

## Workflow

1. **Identify** the resource type(s) the user wants to estimate
2. **Look up** the service reference — read [references/shared.md](references/shared.md) for the service routing table, then open **only** the matching service reference file(s) for exact query parameters and cost formula
3. **Run** `scripts/Get-AzurePricing.ps1` with the parameters from the service reference
4. **Present** the estimate with breakdown: unit price, multiplier, monthly cost, assumptions

For detailed script parameters and output formats, see [references/workflow.md](references/workflow.md).
For known traps and troubleshooting, see [references/pitfalls.md](references/pitfalls.md).
For constants, regions, pricing factors, service routing, and service name lookup, see [references/shared.md](references/shared.md).

## Critical Rules

1. **Never guess prices** — always run the script against the live API
2. **Filter values are case-sensitive** — use exact values from the service reference file
3. **Infer currency and region from user context** — if unspecified, ask the user or default to USD and eastus. The API supports all major currencies (USD, AUD, EUR, GBP, JPY, CAD, INR, etc.) via the `-Currency` parameter.
4. **State assumptions** — always declare: region, OS, commitment type, instance count
5. **Default output format is Json** — do not use Summary (invisible to agents)
6. **Lazy-load service references** — only read files from `references/services/` that are directly required by the user's query. Never bulk-read all service files. Use the Service Routing table in `references/shared.md` to identify which specific file(s) to open. If the user asks about App Service and SQL Database, read only `app-service.md` and `sql-database.md` — not the other 20+ files.
