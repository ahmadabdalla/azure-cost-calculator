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

> Each service file contains its own `serviceName`, `category`, and `aliases` metadata. The routing information lives with the service it describes — no central lookup needed.

### Category Index

18 categories, designed to scale to 2000+ services. Each category maps to one or more API `serviceFamily` values. New API `serviceFamily` values (Azure Stack, Azure Arc, Power Platform, Gaming, Microsoft 365 Copilot) are routed to existing categories — primarily Specialist — to avoid category proliferation.

| Category        | Path                        | API serviceFamily                                                                                   |
| --------------- | --------------------------- | --------------------------------------------------------------------------------------------------- |
| Compute         | `services/compute/`         | Compute, Windows Virtual Desktop                                                                    |
| Containers      | `services/containers/`      | Containers                                                                                          |
| Databases       | `services/databases/`       | Databases                                                                                           |
| Networking      | `services/networking/`      | Networking                                                                                          |
| Storage         | `services/storage/`         | Storage                                                                                             |
| Security        | `services/security/`        | Security, Azure Security                                                                            |
| Monitoring      | `services/monitoring/`      | Management and Governance (monitoring subset)                                                       |
| Management      | `services/management/`      | Management and Governance (governance/ops subset)                                                   |
| Integration     | `services/integration/`     | Integration                                                                                         |
| Analytics       | `services/analytics/`       | Analytics, Data                                                                                     |
| AI + ML         | `services/ai-ml/`           | AI + Machine Learning                                                                               |
| IoT             | `services/iot/`             | Internet of Things                                                                                  |
| Developer Tools | `services/developer-tools/` | Developer Tools                                                                                     |
| Identity        | `services/identity/`        | Security (identity subset), Microsoft Syntex                                                        |
| Migration       | `services/migration/`       | Databases (migration subset), Other                                                                 |
| Web             | `services/web/`             | Web                                                                                                 |
| Communication   | `services/communication/`   | Azure Communication Services, Telecommunications                                                    |
| Specialist      | `services/specialist/`      | Blockchain, Mixed Reality, Quantum Computing, Azure Stack, Azure Arc, Power Platform, Gaming, Other |

### Category Design Principles

1. **API-aligned** — categories primarily map to the API `serviceFamily` field, so agents can use `serviceFamily` as a first-pass router to the correct folder.
2. **Routing over taxonomy** — the goal is _finding the right file_, not building a perfect ontology. When in doubt, place the service where users would look for it.
3. **Cross-references over duplication** — when a service spans categories (e.g., Site Recovery = Management + Migration), keep the primary file in one category and add a one-line cross-reference note in the other.
4. **Flat within categories** — no sub-folders within a category. A category with 100+ files is fine; a 3-level folder hierarchy is not.
5. **Aliases are first-class** — the `aliases` field in each service file's YAML front matter is the primary search index. Invest in comprehensive aliases over perfect folder structure.
6. **Free/no-meter services need files too** — services like Azure Policy, Advisor, and Cost Management have no retail price, but they still need reference files that say "this service is free" to prevent agents from wasting time querying the API.

## Pricing Factors

- **Reserved Instances**: 1yr/3yr commitments save 30-70%. Use `-PriceType Reservation`.
- **Savings Plans**: Flexible compute commitment, 11-65% savings
- **Azure Hybrid Benefit**: Existing Windows/SQL licenses reduce costs 40-55%
- **Dev/Test**: Use `-PriceType DevTestConsumption` for dev/test subscriptions
- **Regional variance**: Same resource can vary ~9%+ across regions
- **Data transfer**: Intra-region free, inter-region ~$0.02/GB, outbound ~$0.087/GB (first 5GB free)
