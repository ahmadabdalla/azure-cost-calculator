---
initiative: mcp-poc
artifact: entrypoint
status: proposed
owner: repository maintainer
authority: []
---

# Hosted Azure Cost MCP PoC

## Purpose

Determine whether the Azure Cost Calculator can be offered as a bounded remote
MCP tool with lower model-visible context, deterministic pricing, acceptable
interactive performance, and no server-funded inference.

## Lifecycle

- **Status:** Proposed
- **Owner:** Repository maintainer

## Reading order

1. [Requirements](requirements.md)
2. [Decisions](decisions.md)
3. [Evidence and open questions](evidence.md)
4. [Work packages](work-packages.md)

## Artifact inventory

| Artifact | Category | Status |
| --- | --- | --- |
| [Requirements](requirements.md) | Authoritative | Accepted |
| [Decisions](decisions.md) | Authoritative | Accepted |
| [Evidence and open questions](evidence.md) | Authoritative for evidence | Active |
| [Work packages](work-packages.md) | Authoritative | Proposed |
| [Issue #1035](https://github.com/ahmadabdalla/azure-cost-calculator/issues/1035) | Tracking issue aligned with this initiative | Open |

## Authority and ownership matrix

| Knowledge | Authoritative owner |
| --- | --- |
| Product behaviour, scope, MCP/API contract, security, and evaluation gates | [Requirements](requirements.md) |
| Architecture and technology choices | [Decisions](decisions.md) |
| Delivery scope, sequence, assignment, and completion evidence | [Work packages](work-packages.md) |
| Dated claims, cost observations, experiment results, and unresolved questions | [Evidence and open questions](evidence.md) |
| Deployed operating procedures | Future operations guide required by `REQ-017` and `WP-006` |

## Active open questions

- [`OPEN-001` — APIM-to-origin restriction](evidence.md#open-001--apim-to-container-apps-origin-restriction)
- [`OPEN-002` — host compatibility](evidence.md#open-002--end-to-end-host-compatibility)
- [`OPEN-003` — bounded request and response limits](evidence.md#open-003--request-query-line-item-and-response-bounds)
- [`OPEN-004` — price-cache TTL](evidence.md#open-004--acceptable-price-cache-ttl)
- [`OPEN-005` — deployment-time Azure availability and cost](evidence.md#open-005--deployment-time-azure-availability-and-cost)
- [`OPEN-006` — legal and data-use review](evidence.md#open-006--data-use-pricing-disclaimer-redistribution-and-trademark-review)

## Current delivery position

No MCP implementation has started under this initiative model. The first
assignable package is [`WP-001`](work-packages.md#wp-001--lock-contracts-fixtures-and-baseline-measurements).
