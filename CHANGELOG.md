# Changelog

All notable changes to the Azure Cost Calculator skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

<!-- versions -->

## [1.10.1] - 2026-07-31

### Fixed

- Service references no longer claim the Retail Prices API returns USD-only pricing. `currencyCode` is a top-level query parameter honoured independently of `armRegionName`, so `Global` and empty-region services (`load-balancer.md`, `nat-gateway.md`, `route-server.md`, `private-dns.md`, `dns-private-resolver.md`, `scom-managed-instance.md`, `container-storage.md`) return the target currency directly instead of requiring a derived FX factor.
- `container-apps.md`, `functions.md`, `app-configuration.md`, `devops.md`, `entra-external-id.md`, `automation.md`, and `netapp-files.md` now query the target currency and use the returned value rather than converting from USD.
- Direct `API:` URLs in five networking references carry `&currencyCode={currencyCode}`; omitting the parameter or sending it empty silently returns USD with no error.
- `functions.md`: a `retailPrice` of `0.0` is the free-grant tier (`tierMinimumUnits: 0`), not a missing price.

### Changed

- `shared.md` and `regions-and-currencies.md`: FX derivation is scoped to manual USD rates the API does not publish. The empty API-unavailable table and the USD-only services table are removed in favour of service file front matter.
- `pitfalls.md`: API-unavailable guidance points at front matter (`pricingRegion: api-unavailable`).


## [1.10.0] - 2026-07-20

### Changed

- Context-management uplift across `SKILL.md`, `shared.md`, and `service-routing.md`: routing map entries now embed each reference file's full relative path so an alias resolves to a file in one hop, and batch service-file reads are bounded to the `## Query Pattern` section. Reduces throwaway context the agent builds while capturing cost figures, with no change to estimated costs.
- `pitfalls.md`: removed the redundant Troubleshooting section and trimmed over-explained cells; all unique traps and the discovery workflow are retained.

## [1.9.0] - 2026-07-19

### Added

- Microsoft Entra External ID (`entra-external-id.md`): new service reference replacing Azure AD B2C
- `service-routing.md`: routing entry and aliases for Microsoft Entra External ID

### Changed

- Refreshed service references against the live Azure Retail Prices API across service groups: ai-ml, analytics, communication, compute, containers, databases, developer-tools, identity, integration, iot, management, monitoring, networking, security, specialist, storage, and web
- Azure Health Bot (`health-bot.md`): updated service reference against current API data

### Fixed

- Azure Container Apps (`container-apps.md`): audit corrections
- Azure AI Content Understanding (`ai-content-understanding.md`): corrected service reference data

### Removed

- Azure AD B2C (`aad-b2c.md`): removed; capability uplifted to Microsoft Entra External ID

## [1.8.0] - 2026-06-03

### Added

- Microsoft Discovery (`discovery.md`): new service reference for the Microsoft Discovery scientific platform
- `SKILL.md`: new optional front matter field `queryServiceNames` for declaring additional allowed `ServiceName` values in query patterns
- `service-routing.md`: routing entry and aliases for Microsoft Discovery
- `pitfalls.md`: documented unsupported OData `not()` negation in the Retail Prices API (returns HTTP 400)
- Azure AI Translator (`translator.md`): undocumented Translator (Global) meters and hourly billing formula
- Azure Document Intelligence (`document-intelligence.md`): missing S0 batch meters
- Azure App Service (`app-service.md`): Meter Names section
- Azure Functions (`functions.md`): Key Fields section
- Azure Container Apps (`container-apps.md`): Key Fields section
- Azure Cosmos DB (`cosmos-db.md`): free-tier formula branch
- Azure Cosmos DB Garnet Cache (`cosmos-db-garnet-cache.md`): missing General Purpose Burstable meter
- Azure Kubernetes Service (`kubernetes-service.md`): Public IP billing dependency note

### Changed

- Azure AI Content Understanding (`ai-content-understanding.md`): meter name word-order fix, YAML cleanup, audited for happy-path eval
- Azure AI Foundry Agents (`foundry-agents.md`): metadata refactor replacing cross-service markers
- Azure Bot Service (`bot-service.md`): global-only trap expanded to include US Gov sovereign regions
- Azure Machine Learning (`machine-learning.md`): trap wording refreshed, missing meters added, `primaryCost` shortened
- Azure Machine Learning Studio (`machine-learning-studio.md`): stale regions list refreshed
- Azure OpenAI Service (`openai-service.md`): YAML convention fix, undocumented products added, mixed-units trap clarified
- Azure Managed Grafana (`managed-grafana.md`): audited and aligned with happy-path eval
- Azure Managed Airflow (`managed-airflow.md`): audited and aligned with happy-path eval
- Azure DNS Private Resolver (`dns-private-resolver.md`): audited for happy-path eval
- Azure DNS Security Policy (`dns-security-policy.md`): audited for happy-path eval
- Azure Private DNS (`private-dns.md`): audited for happy-path eval
- Azure Virtual Network Manager (`virtual-network-manager.md`): audited for happy-path eval
- Azure Public IP Addresses (`ip-addresses.md`): audited for happy-path eval
- Microsoft Purview (`purview.md`): audited for happy-path eval
- Microsoft Defender EASM (`defender-easm.md`): audited for happy-path eval
- Azure Data Box Gateway (`data-box-gateway.md`): audited for happy-path eval
- Azure Health Bot (`health-bot.md`): audited for happy-path eval
- Azure Monitor SCOM Managed Instance (`scom-managed-instance.md`): audited for happy-path eval
- Microsoft Entra Domain Services (`entra-domain-services.md`): clarified agency boundary
- Service reference files across `ai-ml/`, `compute/`, `databases/`, `monitoring/`, `networking/`, `storage/`, `web/`: replaced cross-service comment markers with front matter metadata for consistency

### Fixed

- Azure Virtual Desktop (`windows-virtual-desktop.md`): H1 aligned with `serviceName`, missing billing caveats added
- Azure Database for PostgreSQL (`database-for-postgresql.md`): stale Single Server status corrected
- Azure Database for MySQL (`database-for-mysql.md`): retired Single Server wording removed, RI query guidance added
- Azure Database for MariaDB (`database-for-mariadb.md`): updated to reflect retired status
- Azure Redis Cache (`redis-cache.md`): title, Key Fields, Meter Names, and Cost Formula corrected
- Azure SQL Managed Instance (`sql-managed-instance.md`): PAYG/AHUB formula double-counting fixed
- Azure Database Migration Service (`database-migration-service.md`): clarified paid vs free meters and Premium free-period model
- HorizonDB (`horizondb.md`): replaced underspecified limited-preview guidance
- PowerShell scripts (`Get-AzurePricing.ps1`, `Explore-AzurePricing.ps1`, `lib/Build-ODataFilter.ps1`, `lib/Get-MonthlyMultiplier.ps1`, `lib/Invoke-RetailPricesQuery.ps1`): stripped UTF-8 BOM that broke `pwsh` execution on some platforms

## [1.7.3] - 2026-05-02

### Changed

- Azure AI Services (`ai-services.md`): clarified shared `apiServiceName` scope across AI services
- Azure AI Speech (`speech.md`): reviewed and improved meter coverage and traps
- Azure Batch (`batch.md`): reviewed and improved billing documentation
- Azure Bot Service (`bot-service.md`): rewritten to document Bot Framework channel pricing; removed duplicated Health Bot content
- Azure Container Apps (`container-apps.md`): documented Dynamic Sessions on Dedicated plan edge case
- Azure Container Instances (`container-instances.md`): added `billingConsiderations` section
- Azure Container Registry (`container-registry.md`): reviewed and improved meter coverage
- Azure Data Explorer (`data-explorer.md`): reviewed and improved billing documentation
- Azure Database for MySQL (`database-for-mysql.md`): reviewed and improved meter coverage
- Azure Database for PostgreSQL (`database-for-postgresql.md`): added v6 `skuName` trap and expanded product coverage
- Azure Databricks (`databricks.md`): improved meter coverage and documentation
- Azure Document Intelligence (`document-intelligence.md`): added batch meters and casing trap
- Azure Event Hubs (`event-hubs.md`): reviewed and improved billing documentation
- Azure ExpressRoute Gateway (`expressroute-gateway.md`): reviewed and improved meter coverage
- Azure Front Door (`front-door.md`): added Edge Actions meters
- Azure HDInsight (`hdinsight.md`): reviewed and improved billing documentation
- Azure Kubernetes Service (`kubernetes-service.md`): added Anyscale Global meters trap
- Azure Maps (`maps.md`): reviewed and improved meter coverage
- Azure Monitor (`monitor.md`): reviewed and improved billing documentation
- Azure NAT Gateway (`nat-gateway.md`): clarified Key Fields table
- Azure Private Link (`private-link.md`): added Service endpoint Standard meter and `skuName` filters
- Azure Service Bus (`service-bus.md`): added missing meters and billing notes
- Azure SignalR Service (`signalr.md`): reviewed and improved billing documentation
- Azure Site Recovery (`site-recovery.md`): reviewed and improved meter coverage
- Azure SQL Database (`sql-database.md`): added Zone Redundancy, Hyperscale storage, and Serverless tier documentation
- Azure SQL Managed Instance (`sql-managed-instance.md`): reviewed and improved billing documentation
- Azure Stream Analytics (`stream-analytics.md`): reviewed and improved meter coverage
- Azure Traffic Manager (`traffic-manager.md`): added inflated totals trap and Non-Azure premium endpoint note
- Azure Virtual Desktop (`windows-virtual-desktop.md`): added Private Endpoint support and duplicate meter trap
- Azure Virtual Machines (`virtual-machines.md`): added v7 naming pattern, v6 SKUs, and Low Priority availability documentation
- Azure Virtual WAN (`virtual-wan.md`): split P2S meters documentation and added route maps context
- Microsoft Defender for Cloud (`defender-for-cloud.md`): reviewed and improved billing documentation
- Microsoft Fabric (`fabric.md`): reviewed and improved meter coverage

### Fixed

- Azure AI Foundry Agents (`foundry-agents.md`): corrected API filter values and added missing meters
- Azure AI Vision (`vision.md`): added missing meters and updated traps
- Azure App Configuration (`app-configuration.md`): added missing Replica Snapshots Overage meter
- Azure App Service (`app-service.md`): added missing SKUs and corrected meter naming documentation
- Azure Application Insights (`application-insights.md`): corrected API filter values for Azure Retail Prices API
- Azure Cache for Redis (`redis-cache.md`): corrected Standard tier dual meters, added missing Isolated product, and improved RI specificity
- Azure Cosmos DB (`cosmos-db.md`): fixed table header and clarified RI region trap
- Azure Data Factory (`data-factory.md`): corrected RI claim, free tier meter, and added missing meters
- Azure Data Lake Storage (`data-lake-storage.md`): corrected API filter values for Azure Retail Prices API
- Azure Databricks (`databricks.md`): added missing meters including Global-only meters
- Azure Functions (`functions.md`): fixed cost formula ambiguity and trap format
- Azure HorizonDB (`horizondb.md`): added compute meters and corrected inaccurate traps
- Azure Key Vault (`key-vault.md`): corrected `unitOfMeasure` values
- Azure Log Analytics (`log-analytics.md`): switched to correct ingestion meter and fixed traps and `unitOfMeasure` values
- Azure Logic Apps (`logic-apps.md`): fixed Standard tier cost formula
- Azure Migrate (`migrate.md`): corrected DMS tier terminology
- Azure Route Server (`route-server.md`): added 4 missing API meters
- Azure VMware Solution (`vmware-solution.md`): corrected outdated region counts, RI terms, and SQL Server billing note
- Azure VPN Gateway (`vpn-gateway.md`): added missing `hasFreeGrant` field
- Azure Virtual Desktop (`windows-virtual-desktop.md`): corrected `billingNeeds` front matter

## [1.7.2] - 2026-04-30

### Fixed

- Azure AI Search service reference (`cognitive-search.md`): added Agentic Retrieval and Semantic Ranker query meters
- Azure Spring Apps service reference (`spring-apps.md`): added missing Standard Consumption tier meters
- Azure Static Web Apps service reference (`static-web-apps.md`): removed incorrect `billingNeeds` front matter and added cross-service markers

## [1.7.1] - 2026-04-20

### Changed

- API Management service reference: added Workspace Gateway Standard and Premium SKUs to Meter Names table and workspace packs availability note
- NAT Gateway service reference: added Global-only region warning
- Service Bus service reference: added brokered connections query pattern and meter table row, updated cost formula

### Fixed

- Azure Databricks service reference: added missing meters, DBCU reservations, serverless billing clarity, and corrected primaryCost billing boundary
- Azure Front Door service reference: corrected zone mapping to document all 8 zones, added tiered pricing trap for data transfer and requests, added Classic routing rules meters, and added Private Link origins note
- Microsoft Fabric service reference: updated stale OneLake meter names (renamed by API), added storage temperature tiers (Hot/Cool/Cold), added Private Endpoint support, and documented BCDR storage casing trap
- Virtual WAN service reference: fixed blockquote format and reduced line count within budget

## [1.7.0] - 2026-04-13

### Added

- New service: Azure Database for MariaDB (`database-for-mariadb.md`)
- Service routing: added Azure Database for MariaDB with aliases `MariaDB`, `Azure MariaDB`

### Fixed

- App Service reference: added Isolated v1 coverage and corrected RI availability details

## [1.6.0] - 2026-04-08

### Added

- New service: Application Gateway for Containers (`application-gateway-for-containers.md`)

### Changed

- Application Gateway service reference: added AGIC (Application Gateway Ingress Controller) alias and billing note explaining AGIC costs flow through linked App Gateway v2
- Video Indexer service reference: added `privateEndpoint: true` support and missing query patterns for Standard Audio/Video and Advanced Audio indexing
- Service routing: updated to reflect new Application Gateway for Containers service and AGIC alias for Application Gateway

### Removed

- Intelligent Recommendations service reference (retired service)

## [1.5.4] - 2026-03-30

### Fixed

- Refreshed Azure Genomics service reference: added trap guidance, SkuName column, and eval task

## [1.5.3] - 2026-03-30

### Fixed

- Fixed AI Services service reference: updated meter counts, added tiered meter handling guidance, expanded meter table with 6 new sub-services
- Fixed Bot Service service reference: added deprecated Standard tier notice, clarified Agent Tier recommended pricing, added MeterName filters to all query patterns, added RI verification note
- Fixed Content Safety service reference: added commitment tier overage query patterns for Text Azure 1M and Image Azure 250K tiers
- Fixed Document Intelligence service reference: clarified Key Fields `serviceName` label, added unit context to commitment tier query, added tiered scaling guidance to Read query
- Fixed Foundry Agents service reference: corrected `InstanceCount` to `Quantity` for vCPU meter, clarified `apiServiceName` usage in Key Fields
- Fixed Language service reference: added `billingNeeds: [Azure Cognitive Search]` dependency, added agent instruction for Question Answering scenarios
- Fixed OpenAI service reference: added PTU reservation trap note, restructured meter discovery guidance, updated Key Fields table
- Fixed Speech service reference: added Fast Transcription query pattern, expanded meter table with hosting meters and custom model variants, clarified hosting cost formulas
- Fixed Translator service reference: added Global product query pattern (`S1 Standard`), added `skuName` column to Meter Names table, added 8 missing meter rows
- Fixed Vision service reference: added `skuName` column to Meter Names table, added P-series daily billing meter row
- Fixed Container Apps service reference: clarified GPU billing (replaces vCPU/memory), updated management fee formula (additive for PE/maintenance), improved cost formula structure
- Fixed AKS service reference: clarified LTS billing (replaces Standard fee, not additive), updated Meter Names table with consistent `unitOfMeasure` column

## [1.5.2] - 2026-03-23

### Changed

- Improved text formatting and punctuation consistency across all skill documentation and service reference files (120 service files updated with em dash to colon/semicolon/comma conversions)

## [1.5.1] - 2026-03-19

### Changed

- **CI/CD**: Replaced squash-based release workflow with merge-based flow to preserve commit history
- **CI/CD**: Refactored release scripts into testable modules under `.github/scripts/release/`
- **Documentation**: Updated operational guides for merge-based release process

## [1.4.0] - 2026-03-15

### Added

- New service: DNS Private Resolver (`dns-private-resolver.md`)
- New service: DNS Security Policy (`dns-security-policy.md`)
- New service: Azure Route Server (`route-server.md`)
- **Examples**: Enterprise datacenter migration example with 100-VM multi-tier architecture (`enterprise-datacenter-migration.md`)
- **Scripts**: Compact output format (`OutputFormat: Compact` or `--output-format Compact`) returns only 9 essential fields for batch queries; reduces token usage by ~70% compared to full JSON output

### Changed

- **shared.md**: Distinguished GB (decimal: 1 TB = 1,000 GB) from GiB (binary: 1 TiB = 1,024 GiB) with authoritative `unitOfMeasure` guidance. Added both conversion factors to Constants table
- **pitfalls.md**: Added GB/GiB distinction trap with cross-service examples (Blob Storage vs Ultra Disks). Clarified `currencyCode` must be a top-level query parameter (not inside `$filter`)
- **regions-and-currencies.md**: Documented USD-only service boundaries; Global-region services and Private DNS consistently return USD-only pricing

### Fixed

- **Virtual Machines**: Made `ProductName` filter mandatory in all VM queries to prevent Low Priority rate selection when querying by `ArmSkuName` alone. Documented capital-S casing rule for pre-v4 series (FSv2, DSv2, ESv3) vs lowercase `s` for v4+ series (Dsv5, Esv5)
- **SQL Managed Instance**: Corrected AHUB formula: compute meter `retailPrice` IS the AHUB rate (base infrastructure only). For PAYG, add the separate SQL License meter; for AHUB, use compute only. **Do NOT subtract**. Added missing vCore sizes (24, 40)
- **Cosmos DB**: Fixed serverless `skuName` pattern, corrected storage billing boundary for serverless, added missing add-ons (Continuous Backup, Analytical Storage, Availability Zones)
- **Sentinel**: Added pricing model default trap: Sentinel defaults to simplified pricing when enabling Microsoft Defender for Cloud on a Log Analytics workspace without explicitly selecting classic meters
- **Azure NetApp Files**: Added missing CRR (Cross-Region Replication) meter, corrected ZRS surcharge formula, documented CRR naming convention (`-CRR` suffix)
- **Scripts (PowerShell)**: `Explore-AzurePricing.ps1` catch blocks now exit with code 1 on Azure Retail Prices API failures (previously exited 0). On zero results in `Json` mode, emits parseable empty JSON array `[]` before clean exit
- **Scripts (Bash)**: On zero results in JSON mode, emit parseable empty JSON envelope (`{"results": []}`) instead of exiting with code 2

## [1.3.1] - 2026-03-13

### Fixed

- **Scripts**: Fixed "Argument list too long" crash in `invoke-retail-prices-query.sh` and `get-azure-pricing.sh` on broad queries by piping large JSON arrays via stdin instead of CLI arguments
- **Infrastructure**: Enforced LF line endings for shell scripts (`.sh`, `.bash`, `.bats`) via `.gitattributes` to prevent CRLF-related failures on Linux/macOS when checked out on Windows

## [1.3.0] - 2026-03-08

### Added

- **AI Services**: New Observability product with evaluations input/output token meters

### Changed

- **Azure OpenAI Service**: Updated model catalog to include third-party families (DeepSeek, Grok, Mistral, Phi, Llama, Cohere, Kimi, Qwen, BFL Flux). Added dual embeddings query patterns for Data Zone text-embedding-3 models under separate `Azure OpenAI Embedding` product

### Fixed

- **Load Balancer**: Added missing Global Overage meter for rules beyond 5 included. Clarified Private Endpoint support (Standard Internal only) and bandwidth charging

## [1.2.4] - 2026-03-08

### Fixed

- **Scripts**: Added `--currency-code` as an alias for `--currency` parameter across all pricing scripts (Get-AzurePricing, Explore-AzurePricing, both PowerShell and Bash versions) for improved usability
- **Scripts**: Enhanced error messages in Bash scripts to list all valid flags when an unknown argument is provided

### Changed

- **Examples**: Updated workflow.md example to explicitly show Currency parameter usage in multi-region VM price comparison

## [1.2.3] - 2026-03-07

### Fixed

- **Azure Functions**: Added caveat for Flex Consumption non-USD rate inflation when total GB-s exceeds 1M/month; API-published rates may overstate cost by ~4× vs USD-derived rate
- **Cosmos DB**: Added disambiguation heuristics to clarify PITR (native continuous backup) vs Azure Backup vault backup
- **Application Insights**: Clarified that when Microsoft Sentinel simplified pricing is enabled on a shared workspace, App Insights ingestion is absorbed into Sentinel meters (no separate charge)

## [1.2.2] - 2026-03-06

### Fixed

- **Plugin manifest**: Removed invalid fields (category, skills, agents, commands paths) from plugin.json that were blocking Claude Code plugin installation
- **Documentation**: Updated plugin-agents.md to reflect auto-discovery of agents and commands directories

## [1.2.1] - 2026-03-06

### Changed

- **Infrastructure**: Added marketplace.json for unified plugin install flow and enhanced create-release workflow to validate version sync across plugin.json and marketplace.json metadata
- **Documentation**: Updated README with marketplace-first install instructions and weekly-release workflow to include marketplace.json in version update steps

## [1.2.0] - 2026-03-06

### Added

- **New plugin agent**: `cost-analyst`: primary user-facing agent for architecture cost assessments
- **New command**: `estimate-cost`: CLI command that invokes the cost-analyst agent for quick estimations

### Changed

- **Category naming enforcement**: SKILL.md now mandates using exact Category Index names from shared.md in all output (e.g., "Compute", "Databases"); no paraphrasing allowed
- **Sub-cent pricing logic**: Updated Functions and shared.md to query in target currency first; Azure publishes rounded non-USD rates that differ from manual FX conversion (e.g., AUD 0.0001 vs ~0.00005)
- **Currency conversion**: Replaced flexible anchor SKU with mandatory fixed anchor (VM Standard_B2s from BS Series) to eliminate non-deterministic conversion factors
- **Service routing**: Added service-routing.md to file search workflow as authoritative category/filename map when glob returns ambiguous results
- **Plugin manifest**: Moved plugin.json to `.claude-plugin/plugin.json` and added agents, commands, keywords, category, homepage, and repository fields

### Fixed

- **Functions free grant**: Clarified that Consumption plan's 1M executions + 400K GB-s are per-subscription (not per-app) and added GiB conversion formula
- **Cosmos DB PITR pricing**: Added trap note distinguishing native PITR (~9× rate, billed under Databases) from Azure Backup vault storage (Storage category)
- **Sentinel + App Insights billing**: Clarified that Sentinel simplified pricing absorbs all workspace data including App Insights telemetry; no separate ingestion charges
- **Example architecture**: Corrected impossible Consumption plan + VNet integration combination in event-driven-serverless.md
- **argument-hint visibility**: Moved `argument-hint` to top-level frontmatter in SKILL.md for Claude Code compatibility

## [1.1.1] - 2026-03-02

### Changed

- Infrastructure and documentation updates: Unit testing workflow, validation workflow improvements, operations guide updates, agent documentation refinements, and CodeRabbit configuration

## [1.1.0] - 2026-03-01

### Added

- Unit testing framework: Pester 5 tests (PowerShell) and bats-core tests (bash) covering core pricing scripts and helper functions
- New service: Virtual Network Manager (`virtual-network-manager.md`)
- Helper script `get-reservation-term-months.sh` for bash Reserved Instance pricing logic

### Changed

- Updated README: Moved service reference comparison table from main content into FAQ section for better flow
- Updated SKILL.md: Added PowerShell 5.1 caveat for array parameter handling (use `-Command` instead of `-File` when passing array parameters like `-Region 'eastus','westus'`)

### Fixed

- Reserved Instance pricing in bash script (`get-azure-pricing.sh`): Monthly cost now correctly divides retailPrice by term months (12/36/60) instead of multiplying by hours
- PowerShell 5.1 compatibility: Fixed VM deduplication bug where `isPrimaryMeterRegion -eq $true` matched multiple items (`Get-AzurePricing.ps1`)
- OData filter case-insensitivity: Both PowerShell and bash now wrap `contains()` with `tolower()` for consistent search behavior across platforms

## [1.0.1] - 2026-03-01

### Fixed

- PowerShell 5.1 compatibility: Error handling in `Get-AzurePricing.ps1` and `Explore-AzurePricing.ps1` now uses generic catch blocks to avoid PS7-only exception types

### Changed

- Updated `SKILL.md` to document Windows PowerShell 5.1 support in runtime table and compatibility section

## [1.0.0] - 2026-03-01

### Added

- Initial versioned release of the Azure Cost Calculator skill
- Plugin manifest (`plugin.json`) for Copilot CLI and Claude Code plugin distribution
- Weekly automated release workflow using GitHub Agentic Workflows