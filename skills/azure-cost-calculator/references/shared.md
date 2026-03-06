# Shared Reference — Constants, Service Categories, Pricing Factors

## Constants

| Constant        | Value                                        | Notes                                                                  |
| --------------- | -------------------------------------------- | ---------------------------------------------------------------------- |
| Hours per month | 730                                          | 365.25 × 24 ÷ 12                                                       |
| Days per month  | 30                                           | Simplified                                                             |
| API Base URL    | `https://prices.azure.com/api/retail/prices` | No auth required                                                       |
| API Version     | `2023-01-01-preview`                         | Current preview version                                                |
| GB per TB       | **1,000**                                    | **DECIMAL: 1 TB = 1,000 GB (NOT 1,024). Azure billing uses SI units.** |

For region names, currency conversion, and API-unavailable services, see [regions-and-currencies.md](regions-and-currencies.md).

## Service Categories

Service reference files are organized by category. To find a service file:

1. **File search** — search for files matching `services/**/*<keyword>*.md`
2. **Routing map** — if search returns 0 or ambiguous results, check [service-routing.md](service-routing.md) for the authoritative category and filename
3. **Category browse** — pick the category below and list the directory
4. **Broad search** — list `services/**/*.md` to see all files
5. **Discovery** — use the explore script for services not yet documented

> Each service file contains its own `serviceName`, `category`, and `aliases` metadata. For the full routing map of services to categories and filenames, see [service-routing.md](service-routing.md).

### Category Index

17 categories. Each maps to one or more API `serviceFamily` values.

> **Mandatory:** Use these exact category names in all output. Do not paraphrase, abbreviate, or rename them. These names are mirrored in [service-routing.md](service-routing.md) section headers.

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
| Web             | `services/web/`             | Web                                                                                                 |
| Communication   | `services/communication/`   | Azure Communication Services, Telecommunications                                                    |
| Specialist      | `services/specialist/`      | Blockchain, Mixed Reality, Quantum Computing, Azure Stack, Azure Arc, Power Platform, Gaming, Other |

## Common Traps (read once, apply to all affected services)

### API-Unavailable Services

Some services have **no data** in the Retail Prices API at all. Scripts return zero results.
**Do NOT** query via the pricing/explore scripts — use the manual fallback table in the service file.
Affected: Defender CSPM.
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

Consumption-based meters (Functions, Container Apps) have sub-cent unit prices. Scripts display `$0.00` — this is a rounding issue, not the actual price. Always query in the user's target currency first — if the Retail Prices API returns a non-zero `unitPrice`/`retailPrice` value, use that API value directly (Azure publishes rounded non-USD rates that can differ significantly from direct FX conversion). If it returns zero, fall back to the USD rate and convert via [regions-and-currencies.md](regions-and-currencies.md). Do NOT report `$0.00` to the user. Apply free grant deductions per each service file.

### Reserved Instance MonthlyCost

RI queries return the **total prepaid cost** for the full term in `unitPrice`.
The script automatically converts this to monthly cost: `unitPrice ÷ 12` (1-Year), `÷ 36` (3-Year), or `÷ 60` (5-Year).
See [reserved-instances.md](reserved-instances.md) for full RI traps.

## Pricing Factor Rules

### Disambiguation Protocol

Before querying prices, classify every sizing parameter against this table. Missing never-assume params → stop and ask. Missing safe-default params → use default and disclose.

| Category         | Parameters                                                                                            | Rule                                       |
| ---------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| **Never-assume** | tier, SKU, vCores, instance count, storage size, node count, DTU, throughput (RU/s), PE sub-resources | MUST ask user — do not guess               |
| **Safe-default** | region, zone redundancy, storage redundancy, reserved term, hybrid benefit                            | Use default below, disclose in assumptions |

**Safe defaults when unspecified:** region = eastus, zone redundancy = disabled, storage redundancy = LRS, commitment = PAYG, AHUB = none.

#### Modifier Query Methods

| Modifier    | How to Query                                                                                               | Monthly Calculation               |
| ----------- | ---------------------------------------------------------------------------------------------------------- | --------------------------------- |
| AHUB (VMs)  | Query Linux meter for same SKU — see [Azure Hybrid Benefit](#azure-hybrid-benefit-ahub) below              | Linux rate IS the AHUB rate       |
| AHUB (SQL)  | Query `SQL License` product (Global region) — see [Azure Hybrid Benefit](#azure-hybrid-benefit-ahub) below | `(Base − license) × vCores × 730` |
| Reserved 1Y | Add `PriceType: Reservation`                                                                               | `unitPrice ÷ 12`                  |
| Reserved 3Y | Add `PriceType: Reservation`                                                                               | `unitPrice ÷ 36`                  |
| Spot        | Filter `skuName` contains "Spot"                                                                           | Use returned rate directly        |
| Dev/Test    | Add `PriceType: DevTestConsumption`                                                                        | Use returned rate directly        |

#### Assumptions Disclosure

Every estimate MUST begin with an assumptions block before presenting cost numbers:

**Assumptions**

- Region: {region used}
- Commitment: {PAYG | 1-Year RI | 3-Year RI}
- Hybrid Benefit: {Applied | Not applied} per service
- Zone Redundancy: {Enabled | Disabled}
- {any other safe-defaults used}

Omit lines where the user explicitly specified the value. Only disclose values that were defaulted.

### Azure Hybrid Benefit (AHUB)

AHUB means the customer already owns Windows Server or SQL Server licenses. The API returns the correct AHUB price directly — **NEVER manually compute a percentage discount**.

| Workload                                | How to query                                                                                                                                                                                                                   | Why                                                                                                     |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------- |
| **Windows VMs**                         | Query the **Linux** (base OS) meter for the same VM SKU. Filter on the same `productName` / `armSkuName` but select the result where `productName` does NOT contain `"Windows"`.                                               | AHUB removes the Windows license cost. The Linux rate IS the AHUB rate — no math needed.                |
| **SQL Database / SQL Managed Instance** | Query the `SQL License` product (Global-only, per-vCore): e.g., `"SQL Managed Instance General Purpose - SQL License"`. AHUB per-vCore rate = `retailPrice − sql_license_retailPrice`. Monthly = AHUB rate × vCoreCount × 730. | The API has no regional AHUB SKU. The SQL License product gives the per-vCore license cost to subtract. |

**Rules:**

1. NEVER apply a percentage discount (40%, 55%, etc.) to a non-AHUB price. The API gives the exact AHUB price.
2. NEVER double-apply: if you queried the Linux meter or the AHUB `productName`, the price already reflects the benefit — do not reduce it further.
3. For VMs: AHUB rate = Linux rate for the same SKU. Do NOT start from the Windows rate and subtract.

### Zone Redundancy (ZR)

**Default rule:** Assume **non-zone-redundant** unless the user explicitly requests zone redundancy.

**Rules:**

1. ZR surcharge is a **separate additive meter** in the API (a distinct `meterName`), NOT a percentage multiplier on the base price. Query it separately and add it.
2. DR / failover / geo-secondary replicas do **NOT** include ZR surcharge unless the user explicitly states the secondary is also zone-redundant.
3. If the user says "zone redundant" for a primary instance only, query the ZR meter and add it to the primary base cost. Do NOT propagate ZR to other instances.

### Other Pricing Factors

- **Reserved Instances**: Use `PriceType: Reservation`. See [reserved-instances.md](reserved-instances.md) for RI traps and monthly calculation rules.
- **Savings Plans**: Flexible compute commitment. Not queryable via scripts — note to user if requested.
- **Dev/Test**: Use `PriceType: DevTestConsumption` for dev/test subscriptions.
- **Regional variance**: Same SKU can vary ~9%+ across regions — always query the user's specified region.
- **Data transfer**: Intra-region free, inter-region ~$0.02/GB, outbound ~$0.087/GB (first 5 GB/month free).
