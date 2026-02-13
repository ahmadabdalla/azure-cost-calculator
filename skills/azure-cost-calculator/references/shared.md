# Shared Reference — Constants, Service Categories, Pricing Factors

## Constants

| Constant        | Value                                        | Notes                         |
| --------------- | -------------------------------------------- | ----------------------------- |
| Hours per month | 730                                          | 365.25 × 24 ÷ 12              |
| Days per month  | 30                                           | Simplified                    |
| API Base URL    | `https://prices.azure.com/api/retail/prices` | No auth required              |
| API Version     | `2023-01-01-preview`                         | Current preview version       |
| GB per TB       | **1,000**                                    | **DECIMAL: 1 TB = 1,000 GB (NOT 1,024). Azure billing uses SI units.** |

For region names, currency conversion, and API-unavailable services, see [regions-and-currencies.md](regions-and-currencies.md).

## Service Categories

Service reference files are organized by category. To find a service file:

1. **File search** — search for files matching `services/**/*<keyword>*.md`
2. **Category browse** — pick the category below and list the directory
3. **Broad search** — list `services/**/*.md` to see all files
4. **Discovery** — use the explore script for services not yet documented

> Each service file contains its own `serviceName`, `category`, and `aliases` metadata. The routing information lives with the service it describes — no central lookup needed.

### Category Index

18 categories. Each maps to one or more API `serviceFamily` values.

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

## Common Traps (read once, apply to all affected services)

### API-Unavailable Services

Some services have **no data** in the Retail Prices API at all. Scripts return zero results.
**Do NOT** query via the pricing/explore scripts — use the manual fallback table in the service file.
Affected: DDoS Protection, Defender CSPM.
Full list: [regions-and-currencies.md & Known API-Unavailable Services](regions-and-currencies.md#known-api-unavailable-services).

### Global/Empty-Region Services

Some services have pricing only under `Global`/empty `armRegionName`, not standard regions.
For services that use `armRegionName = 'Global'` (e.g., Load Balancer, Private Link), pass `Region: Global` to the scripts — they work normally.
For services that use empty `armRegionName` (e.g., Private DNS), scripts cannot query them — **query the Retail Prices API directly** (see each service file for the query). Prices are USD-only.
Affected (script workaround needed): Private DNS.

### USD-Only Prices — Mandatory Conversion

API-unavailable and Global-region services return **USD-only** prices. If the user requested a non-USD currency, you **MUST** derive a conversion factor and apply it. Do NOT leave prices in USD. Do NOT direct users to the Azure pricing calculator.
Method: [regions-and-currencies.md & Deriving a USD→local currency conversion factor](regions-and-currencies.md#deriving-a-usdlocal-currency-conversion-factor).

### Sub-Cent Pricing ($0.00 Display)

Consumption-based meters (Functions, Container Apps) have sub-cent unit prices. Scripts display `$0.00` — this is a rounding issue, not the actual price. Use the **Known Rates table** in each service file and calculate manually. Do NOT report `$0.00` to the user. Apply free grant deductions per each service file.

### Reserved Instance MonthlyCost

RI queries return the **total prepaid cost** for the full term, not monthly. The script's `MonthlyCost` is wrong for RIs.
Manually calculate: `unitPrice ÷ 12` (1-Year) or `÷ 36` (3-Year). See [reserved-instances.md](reserved-instances.md) for full RI traps.

## Pricing Factors

- **Reserved Instances**: 1yr/3yr commitments save 30-70%. Use `PriceType: Reservation`.
- **Savings Plans**: Flexible compute commitment, 11-65% savings
- **Azure Hybrid Benefit**: Existing Windows/SQL licenses reduce costs 40-55%
- **Dev/Test**: Use `PriceType: DevTestConsumption` for dev/test subscriptions
- **Regional variance**: Same resource can vary ~9%+ across regions
- **Data transfer**: Intra-region free, inter-region ~$0.02/GB, outbound ~$0.087/GB (first 5GB free)
