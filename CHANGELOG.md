# Changelog

All notable changes to the Azure Cost Calculator skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.1.0] - 2026-03-01

### Added

- New service: Virtual Network Manager (`virtual-network-manager.md`)
- Unit testing framework for core skill scripts (Pester 5 + bats-core) with 159 total tests
- New Bash helper: `get-reservation-term-months.sh` for reservation pricing calculations

### Fixed

- Reservation Instance (RI) pricing calculation in `get-azure-pricing.sh`: `MonthlyCost` now correctly divides by term months instead of multiplying by 730
- PowerShell 5.1 compatibility regressions in `Get-AzurePricing.ps1` and array parameter handling
- VM deduplication bug in `Get-AzurePricing.ps1` when multiple primary meters exist
- OData `contains` filters now case-insensitive using `tolower()` wrapper in both PowerShell and Bash

### Changed

- Updated `SKILL.md` to clarify PowerShell `-Command` vs `-File` usage for array parameters on PS 5.1
- Updated service routing to include Virtual Network Manager aliases (AVNM, VNet Manager, Network Manager)

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