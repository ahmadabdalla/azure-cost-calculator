# Shared Reference: Constants, Service Categories, Pricing Factors

## Constants

| Constant        | Value                                        | Notes                                                                   |
| --------------- | -------------------------------------------- | ----------------------------------------------------------------------- |
| Hours per month | 730                                          | 365.25 × 24 ÷ 12                                                        |
| Days per month  | 30                                           | Simplified                                                              |
| API Base URL    | `https://prices.azure.com/api/retail/prices` | No auth required                                                        |
| API Version     | `2023-01-01-preview`                         | Current preview version                                                 |
| GB per TB       | **1,000**                                    | Decimal (SI): 1 TB = 1,000 GB. Use when `unitOfMeasure` says **GB**.    |
| GiB per TiB     | **1,024**                                    | Binary (IEC): 1 TiB = 1,024 GiB. Use when `unitOfMeasure` says **GiB**. |

> **`unitOfMeasure` is authoritative.** Azure mixes decimal (GB) and binary (GiB) units; even within the same service (e.g., Premium Files uses `1 GB/Month` for provisioned capacity but `1 GiB` for burst). Always check the `unitOfMeasure` field in the API response before converting. **TB vs TiB context:** GiB-billed services (Ultra Disks, NetApp Files, etc.) use TiB in Azure's own portal and documentation; when a user specifies "TB" for these services, treat it as TiB and convert with × 1,024. For GB-billed services, "TB" means decimal TB and converts with × 1,000. Never cross-convert (e.g., TB → GiB directly).

For region names, currency conversion, and API-unavailable services, see [regions-and-currencies.md](regions-and-currencies.md).

## Service Categories

Service reference files are organized by category. To find a service file:

1. **File search**: search for files matching `services/**/*<keyword>*.md`
2. **Routing map**: if search returns 0 or ambiguous results, grep [service-routing.md](service-routing.md) for the name/alias and open the reference file path embedded in the matching line; do not read the map in full
3. **Category browse**: pick the category below and list the directory
4. **Broad search**: list `services/**/*.md` to see all files
5. **Discovery**: use the explore script for services not yet documented

> Each service file contains its own `serviceName`, `category`, and `aliases` metadata. For the full routing map of services to reference file paths, see [service-routing.md](service-routing.md).

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

Some services have **no data** in the Retail Prices API; scripts return zero results. Do NOT query them; use the manual fallback in each service file. Treat each service file's front matter (`pricingRegion: api-unavailable`, `hasKnownRates`) as the source of truth for API availability and manual-rate handling. See [regions-and-currencies.md](regions-and-currencies.md#known-api-unavailable-services) for shared examples and for converting USD manual fallback rates to the user's currency.

### Global/Empty-Region Services

Some services use `Global` or empty `armRegionName` instead of standard regions; querying a standard region returns nothing silently. See [pitfalls.md](pitfalls.md) for handling details and [regions-and-currencies.md](regions-and-currencies.md) for the affected-services list.

### Currency Is Independent of Region Scoping

`currencyCode` is a top-level query parameter, unaffected by `armRegionName`. Request the user's target currency and use the returned price directly, including for `pricingRegion: global` and `empty-region` services. Derive an FX factor only for manual USD rates the API does not publish: [regions-and-currencies.md](regions-and-currencies.md#deriving-a-usdlocal-currency-conversion-factor).

### Sub-Cent Pricing ($0.00 Display)

Consumption-based meters (Functions, Container Apps) have sub-cent unit prices. Scripts display `$0.00`; this is display rounding, not the price. Query in the user's target currency and use the returned `unitPrice`/`retailPrice` directly; the API returns six decimal places in every currency. A `retailPrice` of `0.0` is a genuine free-grant tier (`tierMinimumUnits: 0`), not a missing price: take the paid rate from the higher `tierMinimumUnits` row. Do NOT report `$0.00` to the user. Apply free grant deductions per each service file.

### Reserved Instance MonthlyCost

RI queries return the **total prepaid cost** for the full term in `unitPrice`.
The script automatically converts this to monthly cost: `unitPrice ÷ 12` (1-Year), `÷ 36` (3-Year), or `÷ 60` (5-Year).
See [reserved-instances.md](reserved-instances.md) for full RI traps.

## Pricing Factor Rules

### Disambiguation Protocol

Before querying prices, classify every sizing parameter against this table. Missing never-assume params → stop and ask. Missing safe-default params → use default and disclose.

| Category         | Parameters                                                                                            | Rule                                       |
| ---------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| **Never-assume** | tier, SKU, vCores, instance count, storage size, node count, DTU, throughput (RU/s), PE sub-resources | MUST ask user; do not guess                |
| **Safe-default** | region, zone redundancy, storage redundancy, reserved term, hybrid benefit                            | Use default below, disclose in assumptions |

**Safe defaults when unspecified:** region = eastus, zone redundancy = disabled, storage redundancy = LRS, commitment = PAYG, AHUB = none.

#### Modifier Query Methods

| Modifier    | How to Query                                                                                 | Monthly Calculation                      |
| ----------- | -------------------------------------------------------------------------------------------- | ---------------------------------------- |
| AHUB (VMs)  | Query Linux meter for same SKU; see [Azure Hybrid Benefit](#azure-hybrid-benefit-ahub) below | Linux rate IS the AHUB rate              |
| AHUB (SQL)  | Query compute meter only; see [Azure Hybrid Benefit](#azure-hybrid-benefit-ahub) below       | `compute_retailPrice × vCoreCount × 730` |
| Reserved 1Y | Add `PriceType: Reservation`                                                                 | `unitPrice ÷ 12`                         |
| Reserved 3Y | Add `PriceType: Reservation`                                                                 | `unitPrice ÷ 36`                         |
| Spot        | Filter `skuName` contains "Spot"                                                             | Use returned rate directly               |
| Dev/Test    | Add `PriceType: DevTestConsumption`                                                          | Use returned rate directly               |

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

AHUB means the customer already owns Windows Server or SQL Server licenses. The API returns the correct AHUB price directly; **NEVER manually compute a percentage discount**.

| Workload                                | How to query                                                                                                                                                                                                             | Why                                                                                                                                                        |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Windows VMs**                         | Query the **Linux** (base OS) meter for the same VM SKU. Filter on the same `productName` / `armSkuName` but select the result where `productName` does NOT contain `"Windows"`.                                         | AHUB removes the Windows license cost. The Linux rate IS the AHUB rate; no math needed.                                                                    |
| **SQL Database / SQL Managed Instance** | AHUB: compute meter only; compute `retailPrice` IS the AHUB rate. PAYG: also query `SQL License` product (Global, per-vCore); PAYG rate = compute `retailPrice` + `sql_license_retailPrice`. Monthly × vCoreCount × 730. | Compute and license are separate additive meters. AHUB drops the license to zero. **Do NOT subtract**; a negative result means the billing model is wrong. |

**Rules:**

1. NEVER apply a percentage discount (40%, 55%, etc.) to a non-AHUB price. The API gives the exact AHUB price.
2. NEVER double-apply: if you queried the Linux meter or the AHUB `productName`, the price already reflects the benefit; do not reduce it further.
3. For VMs: AHUB rate = Linux rate for the same SKU. Do NOT start from the Windows rate and subtract.
4. For SQL: compute IS the AHUB rate; never subtract the license rate. PAYG = compute + license; AHUB = compute only.

### Zone Redundancy (ZR)

**Default rule:** Assume **non-zone-redundant** unless the user explicitly requests zone redundancy.

**Rules:**

1. ZR surcharge is a **separate additive meter** in the API (a distinct `meterName`), NOT a percentage multiplier on the base price. Query it separately and add it.
2. DR / failover / geo-secondary replicas do **NOT** include ZR surcharge unless the user explicitly states the secondary is also zone-redundant.
3. If the user says "zone redundant" for a primary instance only, query the ZR meter and add it to the primary base cost. Do NOT propagate ZR to other instances.

### Other Pricing Factors

- **Reserved Instances**: Use `PriceType: Reservation`. See [reserved-instances.md](reserved-instances.md) for RI traps and monthly calculation rules.
- **Savings Plans**: Flexible compute commitment. Not queryable via scripts; note to user if requested.
- **Dev/Test**: Use `PriceType: DevTestConsumption` for dev/test subscriptions.
- **Regional variance**: Same SKU can vary ~9%+ across regions; always query the user's specified region.
- **Data transfer**: Intra-region free, inter-region ~$0.02/GB, outbound ~$0.087/GB (first 5 GB/month free).
