# Azure Cost Calculator — GitHub Copilot Skill

A [GitHub Copilot Skill](https://docs.github.com/en/copilot/customizing-copilot/copilot-extensions/building-copilot-skills) that gives Copilot the ability to estimate Azure resource costs using **live pricing data** from the [Azure Retail Prices API](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices).

No guessing, no stale spreadsheets — just real-time price lookups and clear cost breakdowns.

## Supported Services (20+)

| Category        | Services                                                                                       |
| --------------- | ---------------------------------------------------------------------------------------------- |
| **Compute**     | Virtual Machines, App Service, Azure Functions, Container Apps, AKS                            |
| **Databases**   | SQL Database, Cosmos DB, PostgreSQL Flexible Server, Redis Cache                               |
| **Storage**     | Blob / File / Queue / Table Storage                                                            |
| **Networking**  | Application Gateway, Load Balancer, Azure Firewall, Private Link, Private DNS, DDoS Protection |
| **Security**    | Key Vault, Defender for Cloud                                                                  |
| **Integration** | API Management, Service Bus                                                                    |
| **Monitoring**  | Application Insights / Azure Monitor                                                           |
| **Containers**  | Container Registry                                                                             |

## Installation

### Via Copilot Chat (recommended)

1. Open **GitHub Copilot Chat** in VS Code
2. Type: `install skill ahmadabdalla/azure-cost-calculator-skill`
3. The skill is now available in all Copilot Chat sessions

### Manual install

Add the skill to your VS Code settings or `.github/copilot-skills.yml`:

```yaml
skills:
  - repo: ahmadabdalla/azure-cost-calculator-skill
```

## Usage

Once installed, just ask Copilot about Azure costs in natural language. The skill automatically activates when it detects pricing-related questions.

### Example prompts

```
How much does a D4s v5 VM cost per month in East US?
```

```
Compare App Service pricing tiers for a production web app
```

```
Estimate the monthly cost of a Standard_B2s VM with a P30 managed disk in Australia East in AUD
```

```
What's the cost of a General Purpose SQL Database with 4 vCores in West Europe in EUR?
```

```
Budget a Kubernetes cluster with 3 D4s v5 nodes in Canada Central
```

```
How much would Azure Cosmos DB with 1000 RU/s and 100 GB storage cost?
```

### Sample interaction

**You:** _How much does a Standard_D4s_v5 VM cost per month in East US?_

**Copilot:** Queries the live Azure Retail Prices API and returns:

> **Azure VM Cost Estimate — Standard_D4s_v5 (East US)**
>
> | Item         | Value           |
> | ------------ | --------------- |
> | SKU          | Standard_D4s_v5 |
> | Region       | eastus          |
> | OS           | Linux           |
> | Unit Price   | $0.192 /hour    |
> | Monthly Cost | **$140.16**     |
>
> **Assumptions:** Pay-as-you-go pricing, Linux OS, 730 hours/month, no reserved instances.

## How It Works

1. **Identifies** the Azure resource type(s) from your question
2. **Looks up** the correct query parameters from built-in service references
3. **Runs** a PowerShell script (`Get-AzurePricing.ps1`) that calls the [Azure Retail Prices REST API](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices)
4. **Presents** a structured estimate with unit price, monthly cost, and stated assumptions

All prices come directly from Microsoft's public API — no hardcoded values.

## Features

- **Live pricing** — always queries the Azure Retail Prices API at runtime
- **Multi-currency** — supports USD, AUD, EUR, GBP, JPY, CAD, INR, and more
- **All regions** — works with any Azure region
- **Comparison mode** — compare SKUs, tiers, or regions side-by-side
- **Transparent assumptions** — every estimate states region, OS, commitment type, and instance count
- **Exploration script** — includes `Explore-AzurePricing.ps1` for discovering available SKUs and pricing options

## Prerequisites

- **PowerShell 5.1+** (pre-installed on Windows; available on macOS/Linux via [PowerShell Core](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell))
- **Internet access** to reach `https://prices.azure.com`
- No Azure subscription or authentication required — the Retail Prices API is public

## Repository Structure

```
.github/skills/azure-cost-calculator/
├── SKILL.md                          # Skill definition and workflow
├── scripts/
│   ├── Get-AzurePricing.ps1          # Main pricing query script
│   ├── Explore-AzurePricing.ps1      # SKU/pricing discovery script
│   └── lib/                          # Shared helper functions
│       ├── Invoke-RetailPricesQuery.ps1
│       ├── Build-ODataFilter.ps1
│       └── Get-MonthlyMultiplier.ps1
└── references/
    ├── shared.md                     # Service routing table, constants
    ├── workflow.md                   # Detailed script parameters
    ├── pitfalls.md                   # Known issues and troubleshooting
    └── services/                     # Per-service query references
        ├── virtual-machines.md
        ├── app-service.md
        ├── sql-database.md
        └── ... (20+ service files)
```

## Contributing

Contributions are welcome! If you'd like to add support for a new Azure service or improve an existing one:

1. Fork this repository
2. Add or update the service reference in `references/services/`
3. Update the routing table in `references/shared.md`
4. Submit a pull request

## License

This project is licensed under the [MIT License](LICENSE).
