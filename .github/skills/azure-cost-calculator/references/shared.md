# Shared Reference — Constants, Service Categories, Pricing Factors

## Constants

| Constant        | Value                                        | Notes                   |
| --------------- | -------------------------------------------- | ----------------------- |
| Hours per month | 730                                          | 365.25 × 24 ÷ 12        |
| Days per month  | 30                                           | Simplified              |
| API Base URL    | `https://prices.azure.com/api/retail/prices` | No auth required        |
| API Version     | `2023-01-01-preview`                         | Current preview version |

For region names, currency conversion, and API-unavailable services, see [regions-and-currencies.md](regions-and-currencies.md).

## Service Categories

Service reference files are organized by category. To find a service file:

1. **File search** — search for files matching `services/**/*<keyword>*.md`
2. **Category browse** — pick the category below and list the directory
3. **Broad search** — list `services/**/*.md` to see all files
4. **Discovery** — use `scripts/Explore-AzurePricing.ps1` for services not yet documented

| Category    | Path                    | Examples                                                             |
| ----------- | ----------------------- | -------------------------------------------------------------------- |
| Compute     | `services/compute/`     | VMs, AKS, App Service, Functions, Container Apps, Container Registry |
| Databases   | `services/databases/`   | SQL Database, Cosmos DB, PostgreSQL, Redis Cache                     |
| Networking  | `services/networking/`  | Load Balancer, Firewall, Private Link, DDoS                          |
| Storage     | `services/storage/`     | Blob/File/Table, Managed Disks                                       |
| Security    | `services/security/`    | Key Vault, Defender for Cloud                                        |
| Monitoring  | `services/monitoring/`  | App Insights, Log Analytics                                          |
| Integration | `services/integration/` | API Management, Service Bus                                          |

> Each service file contains its own `serviceName`, `category`, and `aliases` metadata. The routing information lives with the service it describes — no central lookup needed.

## Pricing Factors

- **Reserved Instances**: 1yr/3yr commitments save 30-70%. Use `-PriceType Reservation`.
- **Savings Plans**: Flexible compute commitment, 11-65% savings
- **Azure Hybrid Benefit**: Existing Windows/SQL licenses reduce costs 40-55%
- **Dev/Test**: Use `-PriceType DevTestConsumption` for dev/test subscriptions
- **Regional variance**: Same resource can vary ~9%+ across regions
- **Data transfer**: Intra-region free, inter-region ~$0.02/GB, outbound ~$0.087/GB (first 5GB free)
