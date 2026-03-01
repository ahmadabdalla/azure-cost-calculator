# Changelog

All notable changes to the Azure Cost Calculator skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.1] - 2026-03-01

### Fixed

- PowerShell 5.1 compatibility: Updated error handling in `Get-AzurePricing.ps1` and `Explore-AzurePricing.ps1` to use property-based HTTP error detection instead of PS7-only `HttpResponseException`

### Changed

- Added Windows PowerShell 5.1 (powershell.exe) as a supported runtime alongside PowerShell 7+ in compatibility notes

## [1.0.0] - 2026-03-01

### Added

- Initial versioned release of the Azure Cost Calculator skill
- Plugin manifest (`plugin.json`) for Copilot CLI and Claude Code plugin distribution
- Weekly automated release workflow using GitHub Agentic Workflows