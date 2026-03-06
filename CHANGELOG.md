# Changelog

All notable changes to the Azure Cost Calculator skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

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

- **New plugin agent**: `cost-analyst` — primary user-facing agent for architecture cost assessments
- **New command**: `estimate-cost` — CLI command that invokes the cost-analyst agent for quick estimations

### Changed

- **Category naming enforcement**: SKILL.md now mandates using exact Category Index names from shared.md in all output (e.g., "Compute", "Databases") — no paraphrasing allowed
- **Sub-cent pricing logic**: Updated Functions and shared.md to query in target currency first; Azure publishes rounded non-USD rates that differ from manual FX conversion (e.g., AUD 0.0001 vs ~0.00005)
- **Currency conversion**: Replaced flexible anchor SKU with mandatory fixed anchor (VM Standard_B2s from BS Series) to eliminate non-deterministic conversion factors
- **Service routing**: Added service-routing.md to file search workflow as authoritative category/filename map when glob returns ambiguous results
- **Plugin manifest**: Moved plugin.json to `.claude-plugin/plugin.json` and added agents, commands, keywords, category, homepage, and repository fields

### Fixed

- **Functions free grant**: Clarified that Consumption plan's 1M executions + 400K GB-s are per-subscription (not per-app) and added GiB conversion formula
- **Cosmos DB PITR pricing**: Added trap note distinguishing native PITR (~9× rate, billed under Databases) from Azure Backup vault storage (Storage category)
- **Sentinel + App Insights billing**: Clarified that Sentinel simplified pricing absorbs all workspace data including App Insights telemetry — no separate ingestion charges
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