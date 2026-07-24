---
initiative: mcp-poc
artifact: decisions
status: accepted
owner: repository maintainer
authority: [technical-decisions]
---

# Hosted Azure Cost MCP PoC decisions

These records own selected technical choices and their rationale. Behavioural
authority remains in [requirements.md](requirements.md). Current external
support claims are linked to [evidence.md](evidence.md).

## ADR-001 — Keep inference in the client host

**Status:** Accepted
**Date:** 2026-07-24
**Requirement references:** `REQ-001`, `REQ-002`

**Context:** A server-side model would add latency, privacy exposure, variable
unit cost, and another source of nondeterminism.

**Decision:** The remote service accepts canonical structured requests and
performs no model inference. The user's host interprets architecture prose.

**Alternatives:** Hosted parsing and MCP sampling were considered and excluded
from this PoC.

**Consequences:** Missing and ambiguous values must return structured outcomes.
Host interpretation quality becomes a measured compatibility concern.

**Reversal:** A later separately metered, consented product operation may use a
model without changing this deterministic base path.

## ADR-002 — Expose two synchronous tools without estimate history

**Status:** Accepted
**Date:** 2026-07-24
**Requirement references:** `REQ-004`, `REQ-005`, `REQ-006`

**Context:** Tool definitions and round trips consume model context. Durable
estimate storage expands the privacy and operational boundary.

**Decision:** Expose `get_service_requirements` and
`estimate_azure_architecture`. Return summary or bounded line items
synchronously; the client owns the returned result.

**Alternatives:** A tool per service, retrieval tool, revision tool, and
paginated estimate store were rejected for the PoC.

**Consequences:** Clients needing evidence request `line_items` on the estimate
call. Idempotent replay exists only for short failure recovery.

**Reversal:** Add retrieval only after evidence shows a user need that
outweighs retention and schema costs.

## ADR-003 — Use a bounded machine-readable rule registry

**Status:** Accepted
**Date:** 2026-07-24
**Requirement references:** `REQ-007`, `REQ-012`

**Context:** Existing Markdown service references are optimized for agent
interpretation, not deterministic server execution.

**Decision:** Create versioned rules only for the two fixture cohorts, with
ordinary reviewed code handlers for complex calculations. Publish immutable,
checksummed releases from Git and activate them by pointer.

**Alternatives:** Parsing Markdown at runtime, migrating the full corpus, and
inventing an expression language were rejected.

**Consequences:** The PoC tests the representation without declaring it the
permanent v2 source of truth. Release publication is a separate operational
boundary.

**Reversal:** A later format may replace the registry if fixture evidence shows
poor maintainability; stable service IDs and contract tests form the migration
boundary.

## ADR-004 — Cache public price records with strict freshness

**Status:** Accepted
**Date:** 2026-07-24
**Requirement references:** `REQ-008`

**Context:** Live pricing is required, while repeated identical API queries add
latency and upstream load.

**Decision:** Cache only normalized API-derived price records with a
dimension-complete key. Default to a configurable 15-minute TTL and never use
expired data for a new estimate.

**Alternatives:** Static prices, cached estimates, architecture caching, and
stale-on-error were rejected.

**Consequences:** An upstream outage with no valid entry is an explicit failure.
Public price cache entries may be shared because they contain no tenant data.

**Reversal:** Adjust TTL through configuration after `OPEN-004` is measured.
Changing stale-on-error policy requires approval because it changes
`REQ-008`.

## ADR-005 — Meter successful logical estimates per API-key tenant

**Status:** Accepted
**Date:** 2026-07-24
**Requirement references:** `REQ-009`, `REQ-010`, `REQ-011`

**Context:** Agent hosts retry and may call concurrently. Raw request metering
would charge failures and double-count retries.

**Decision:** Use one invited key as the tenant boundary, default to 30
successful estimates per Monday-to-Monday UTC week, and atomically
reserve/commit allowance around a tenant-scoped idempotency key and fingerprint.

**Alternatives:** Monthly raw-call quotas, gateway counters as the usage ledger,
and OAuth onboarding were rejected for the private PoC.

**Consequences:** The application, not the gateway, owns allowance and durable
usage events. Compatibility testing must establish the practical header form
for each host.

**Reversal:** OAuth may replace key authentication behind the same tenant and
authorization boundary. Allowances remain configuration.

## ADR-006 — Use two complete existing architectures as tracer fixtures

**Status:** Accepted
**Date:** 2026-07-24
**Requirement references:** `REQ-012`, `REQ-013`, `REQ-014`

**Context:** A hand-picked list of isolated services would not test dependency
expansion or real architecture completeness.

**Decision:** Use the existing 3-tier example as the small vertical slice and
the entire event-driven serverless example as the complex slice. Maintain
Markdown and canonical representations.

**Alternatives:** A six-service illustrative cohort and single-resource-only
tests were rejected.

**Consequences:** Implementation is bounded by actual fixture needs, and no
fixture line item can be silently deferred.

**Reversal:** Fixtures may be added after the PoC; removing scope requires an
explicit requirement change.

## ADR-007 — Use TypeScript with a thin Express transport shell

**Status:** Accepted
**Date:** 2026-07-24
**Requirement references:** `REQ-003`, `REQ-016`
**Evidence:** `EVID-001`, `EVID-002`

**Context:** The service needs a supported Streamable HTTP implementation while
keeping pricing, quota, validation, and caching framework-independent.

**Decision:** Use the production-recommended MCP TypeScript SDK line and
Express integration available at implementation time. Keep Express as a thin
transport shell around TypeScript domain modules.

**Alternatives:** NestJS adds structure and ceremony; Hono is a smaller
first-party adapter; Fastify is lightweight but was not the selected SDK-native
path.

**Consequences:** Module boundaries require explicit tests. SDK version and
middleware APIs must be reverified when implementation starts.

**Reversal:** The thin transport boundary permits another supported adapter
without rewriting domain logic.

## ADR-008 — Separate durable PostgreSQL state from disposable Redis cache

**Status:** Accepted
**Date:** 2026-07-24
**Requirement references:** `REQ-008`, `REQ-011`
**Evidence:** `EVID-007`, `EVID-008`

**Context:** Key, quota, usage, and idempotency transitions are relational and
transactional; public price cache state is ephemeral and shared.

**Decision:** Use Azure Database for PostgreSQL Flexible Server for
authoritative operational state and Azure Managed Redis for public price cache
entries and request coalescing. Begin with low-cost non-HA development
configurations.

**Alternatives:** MongoDB is a weaker match for relational transitions, SQLite
does not provide shared remote persistence, and Redis alone cannot be the
authoritative ledger.

**Consequences:** The PoC operates two data services. PostgreSQL must move off
Burstable before HA can be enabled; Managed Redis can enable HA later.

**Reversal:** Both are behind repository interfaces. A simpler cache may replace
Redis if measurements do not justify the managed component.

## ADR-009 — Deploy a stateless Azure Container Apps service behind APIM

**Status:** Accepted
**Date:** 2026-07-24
**Requirement references:** `REQ-003`, `REQ-009`, `REQ-016`
**Evidence:** `EVID-006`, `EVID-009`

**Context:** The private beta needs a public managed endpoint, coarse gateway
controls, and a path to scale without storing MCP session state.

**Decision:** Run a JSON-only, stateless Streamable HTTP service on Azure
Container Apps in Australia East behind an APIM Developer instance. Do not use
MCP session affinity, server-sent notifications, or resumability. Keep key
lifecycle and successful-estimate allowance in the application.

**Alternatives:** Direct public Container Apps ingress and richer stateful MCP
transport were rejected for the initial design.

**Consequences:** APIM adds fixed PoC cost. The origin-bypass restriction must
be resolved by `OPEN-001` before deployment.

**Reversal:** APIM can be changed or removed without changing domain metering.
Compute can move behind the same stateless transport contract.

## ADR-010 — Use Azure-native secrets, telemetry, backup, and delivery

**Status:** Accepted
**Date:** 2026-07-24
**Requirement references:** `REQ-016`, `REQ-017`

**Context:** A production-shaped slice needs repeatable deployment, secret
handling, diagnostics, and recovery without expanding the product surface.

**Decision:** Use Bicep and GitHub Actions, Azure Key Vault, Application
Insights/Azure Monitor with payload and secret redaction, and PostgreSQL managed
backups. Redis remains disposable.

**Alternatives:** Manual portal deployment, repository secrets embedded in
configuration, and Redis persistence were rejected.

**Consequences:** Infrastructure changes require an operations guide and
recovery test. Telemetry schemas must exclude prompt and response payloads.

**Reversal:** Each operational component is replaceable behind IaC and
documented procedures; changing cloud provider is outside the PoC.
