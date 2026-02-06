# Shared Reference — Constants, Regions, Service Names, Pricing Factors

## Constants

| Constant        | Value                                        | Notes                  |
| --------------- | -------------------------------------------- | ---------------------- |
| Hours per month | 730                                          | 365.25 × 24 ÷ 12       |
| Days per month  | 30                                           | Simplified             |
| API Base URL    | `https://prices.azure.com/api/retail/prices` | No auth required       |
| API Version     | `2023-01-01-preview`                         | Includes Savings Plans |

## Service Routing

Exact `serviceName` values (case-sensitive) and reference files for each supported resource:

| Resource                     | serviceName                       | Reference                                                 |
| ---------------------------- | --------------------------------- | --------------------------------------------------------- |
| Virtual Machines             | `Virtual Machines`                | [virtual-machines.md](services/virtual-machines.md)       |
| Managed Disks                | `Storage`                         | [managed-disks.md](services/managed-disks.md)             |
| App Service                  | `Azure App Service`               | [app-service.md](services/app-service.md)                 |
| SQL Database                 | `SQL Database`                    | [sql-database.md](services/sql-database.md)               |
| Blob/File/Table Storage      | `Storage`                         | [storage.md](services/storage.md)                         |
| Azure Functions              | `Functions`                       | [functions.md](services/functions.md)                     |
| Cosmos DB                    | `Azure Cosmos DB`                 | [cosmos-db.md](services/cosmos-db.md)                     |
| Key Vault                    | `Key Vault`                       | [key-vault.md](services/key-vault.md)                     |
| Application Gateway          | `Application Gateway`             | [app-gateway.md](services/app-gateway.md)                 |
| AKS                          | `Azure Kubernetes Service`        | [aks.md](services/aks.md)                                 |
| API Management               | `API Management`                  | [api-management.md](services/api-management.md)           |
| Service Bus                  | `Service Bus`                     | [service-bus.md](services/service-bus.md)                 |
| Redis Cache                  | `Redis Cache`                     | [redis-cache.md](services/redis-cache.md)                 |
| App Insights / Log Analytics | `Azure Monitor` / `Log Analytics` | [monitor.md](services/monitor.md)                         |
| Container Apps               | `Azure Container Apps`            | [container-apps.md](services/container-apps.md)           |
| Load Balancer                | `Load Balancer`                   | [load-balancer.md](services/load-balancer.md)             |
| PostgreSQL Flexible Server   | `Azure Database for PostgreSQL`   | [postgresql-flexible.md](services/postgresql-flexible.md) |
| Azure Firewall               | `Azure Firewall`                  | [azure-firewall.md](services/azure-firewall.md)           |
| Container Registry           | `Container Registry`              | [container-registry.md](services/container-registry.md)   |
| Private Link / Endpoints     | `Virtual Network`                 | [private-link.md](services/private-link.md)               |
| Private DNS Zones            | `Azure DNS`                       | [private-dns.md](services/private-dns.md)                 |
| Defender for Cloud           | `Microsoft Defender for Cloud`    | [defender-for-cloud.md](services/defender-for-cloud.md)   |
| DDoS Protection              | _(not in API — see below)_        | [ddos-protection.md](services/ddos-protection.md)         |

If the resource is not listed, use the discovery workflow in [pitfalls.md](pitfalls.md) with `scripts/Explore-AzurePricing.ps1`.

## Common Region Names

| Display Name        | armRegionName        |
| ------------------- | -------------------- |
| Australia East      | `australiaeast`      |
| Australia Southeast | `australiasoutheast` |
| East US             | `eastus`             |
| East US 2           | `eastus2`            |
| West US 2           | `westus2`            |
| West Europe         | `westeurope`         |
| North Europe        | `northeurope`        |
| UK South            | `uksouth`            |
| Southeast Asia      | `southeastasia`      |
| Japan East          | `japaneast`          |
| Central US          | `centralus`          |
| Canada Central      | `canadacentral`      |

> **Note**: Some services use non-standard regions. Private Link and Private DNS pricing is listed under `armRegionName = 'Global'` or an empty string — querying any standard region (e.g., `eastus`, `australiaeast`) returns **nothing**. See [pitfalls.md](pitfalls.md) for details.

## Known API-Unavailable Services

These services have **no pricing data** in the Azure Retail Prices API and must be estimated manually:

| Service                              | Manual Estimate               | Reference                                                                                           |
| ------------------------------------ | ----------------------------- | --------------------------------------------------------------------------------------------------- |
| DDoS Protection (Network Protection) | ~$2,944 USD/month flat fee    | [Azure DDoS Protection pricing](https://azure.microsoft.com/en-au/pricing/details/ddos-protection/) |
| DDoS Protection (IP Protection)      | ~$199 USD/month per public IP | [Azure DDoS Protection pricing](https://azure.microsoft.com/en-au/pricing/details/ddos-protection/) |

When encountering these services, note the limitation to the user and provide the manual fallback values above (in USD). If the user requires a different currency, use the currency derivation method below.

## USD-Only Services & Currency Conversion

Three service categories return pricing in **USD only** — either because they are API-unavailable or because they are listed under the `Global` region:

| Service              | Reason                                       | Reference                                         |
| -------------------- | -------------------------------------------- | ------------------------------------------------- |
| DDoS Protection      | Not in API at all                            | [ddos-protection.md](services/ddos-protection.md) |
| Private Link         | Global region, USD only                      | [private-link.md](services/private-link.md)       |
| Private DNS          | Global region, USD only                      | [private-dns.md](services/private-dns.md)         |
| Functions (sub-cent) | API returns `$0.00` in all currencies        | [functions.md](services/functions.md)             |
| Load Balancer        | No API data for public regions, USD fallback | [load-balancer.md](services/load-balancer.md)     |

### Deriving a USD→local currency conversion factor

To convert USD-only prices to the user's currency, derive a conversion factor from a service that IS available in both currencies:

```powershell
# Step 1: Get a known service price in USD
.\Get-AzurePricing.ps1 -ServiceName 'Virtual Machines' -ArmSkuName 'Standard_D2s_v5' -Region australiaeast -Currency USD
# → e.g., $0.1240/hr

# Step 2: Get the same service price in the target currency
.\Get-AzurePricing.ps1 -ServiceName 'Virtual Machines' -ArmSkuName 'Standard_D2s_v5' -Region australiaeast -Currency AUD
# → e.g., $0.1916/hr

# Step 3: Derive factor
# AUD/USD = 0.1916 / 0.1240 ≈ 1.545
```

Apply this factor to all USD-only prices. Always note the conversion caveat to the user — the derived factor is approximate and may differ from the actual exchange rate.

## Pricing Factors to Consider

When presenting estimates, note which of these apply:

- **Commitment discounts**: Reserved Instances (1yr/3yr) save 30-70%. Set `-PriceType Reservation`.
- **Savings Plans**: Flexible commitment across compute services (11-65% savings)
- **Azure Hybrid Benefit**: Existing Windows Server/SQL licenses reduce costs 40-55%
- **Dev/Test pricing**: Set `-PriceType DevTestConsumption` for dev/test subscriptions
- **Regional variance**: Same resource can vary ~9%+ across regions. Use multiple `-Region` values to compare.
- **Data transfer**: Intra-region free, inter-region ~$0.02/GB, internet outbound ~$0.087/GB (first 5GB free)
