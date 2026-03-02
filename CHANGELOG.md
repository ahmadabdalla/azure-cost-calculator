# Changelog

All notable changes to the Azure Cost Calculator skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

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