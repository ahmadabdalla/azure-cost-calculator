# Hosted Azure Cost MCP PoC — Provisional Technology Notes

**Status:** Suggestions only; not an approved architecture decision  
**Last reviewed:** 2026-07-24  
**Product plan:** [MCP-POC-PLAN.md](MCP-POC-PLAN.md)

## Purpose

Capture a plausible low-complexity implementation stack without coupling the product plan to it.

Every suggestion in this document must be reverified immediately before implementation. MCP SDKs, host support, cloud capabilities, package maturity, security guidance, and pricing can change.

If verification identifies a simpler or safer option that still satisfies the plan's contracts and success gates, use that option and record the choice in an architecture decision record.

## Current candidate

| Concern | Provisional suggestion | Why it is a candidate |
| --- | --- | --- |
| Application language | TypeScript on a maintained Node.js LTS release | Small MCP ecosystem distance and straightforward JSON/schema work |
| MCP SDK | Exact-pinned stable v1.x TypeScript SDK | The official repository currently recommends v1.x while its v2 line remains pre-release |
| Validation | A compact runtime schema library compatible with the selected SDK | One source for tool schema and runtime validation |
| MCP transport | Stateless Streamable HTTP with JSON responses | Fits the synchronous two-tool API and avoids session/resumability scope |
| Compute | Azure Container Apps | Managed HTTPS container hosting, revision model, scaling controls, and managed identity |
| Minimum replicas | One during benchmark and beta periods | Avoids scale-from-zero latency contaminating the interactive latency gate |
| Persistent state | Azure Table Storage | Candidate for small key, quota, usage, rule, cache, and idempotency records |
| Process cache | Bounded in-memory LRU cache | Low-latency first-level price-cache lookup |
| Infrastructure definition | Bicep | Azure-native, reviewable infrastructure changes |
| Build and deployment | GitHub Actions | Fits the repository's existing automation surface |
| Telemetry | Platform logs and metrics plus minimal structured application telemetry | Avoids introducing a separate observability product into the PoC |

This candidate is intentionally not optimized for every future scale or feature.

## Suggested repository isolation

```text
poc/hosted-mcp/       # isolated application and infrastructure package
tests/mcp-poc/        # maintainer-only tests and benchmarks
docs/ops/             # deployment and operational guide
```

The root repository currently has no general application runtime or deployment package. The PoC should therefore avoid changing the current skill's runtime, scripts, or reference-loading behavior unless required for the optional thin adapter.

## Candidate runtime shape

```text
remote MCP request
       |
       v
stateless MCP transport adapter
       |
       v
authentication and request limits
       |
       v
application services
  |       |       |       |
rules   quota   pricing   idempotency
  |       |       |       |
       persistent tables
               |
       in-memory price cache
               |
      Azure Retail Prices API
```

Application code should depend on small interfaces:

- `RuleRegistry`
- `RetailPriceClient`
- `PriceCache`
- `ApiKeyStore`
- `QuotaStore`
- `UsageLedger`
- `IdempotencyStore`

The PoC should provide one real implementation for each interface. Do not add alternative providers solely for architectural purity.

## Candidate Table Storage layout

The following is a starting point, not a finalized physical model:

| Table | Candidate key shape | Purpose |
| --- | --- | --- |
| `ApiKeys` | key lookup ID / environment | Hashed key, status, tenant, quota override |
| `QuotaWindows` | tenant or key ID / week start | Reserved, committed, and allowance counters |
| `UsageEvents` | tenant-week / usage event ID | Append-only successful-estimate event |
| `Idempotency` | tenant / idempotency-key hash | Fingerprint, state, replay expiry, encrypted response |
| `RuleReleases` | release / version | Checksum, state, included rule versions |
| `ServiceRules` | service ID / rule version | Validated immutable rule definition |
| `ServiceAliases` | normalized alias / service ID | Deterministic alias index |
| `PriceCache` | hash prefix / canonical-query hash | API-derived price records and expiry |

Questions that must be proven in a spike:

- Can one quota-window entity plus optimistic concurrency safely reserve and commit usage?
- Can idempotency and quota transitions be colocated in one partition or do they require a compensating workflow?
- Do ten concurrent retries produce one usage event under forced interleavings?
- Are cached price payloads comfortably below entity and property limits?
- What cleanup mechanism is required for expired idempotency and price-cache entities?
- Does the selected client library expose conditional updates and opaque ETags correctly?
- Does partition selection avoid a hot partition during the expected beta load?

Azure Table Storage documents ETag-based optimistic concurrency and a 1 MiB maximum entity size. These are reasons to test the design, not proof that the proposed multi-record workflow is automatically atomic:

- https://learn.microsoft.com/en-us/rest/api/storageservices/Update-Entity2
- https://learn.microsoft.com/en-us/azure/storage/tables/scalability-targets

## Candidate hosting configuration

- One containerized, stateless application.
- One active revision.
- Public HTTPS ingress only on the MCP endpoint and health endpoints.
- One minimum replica for benchmark comparability.
- Small bounded maximum replica count during beta.
- System-assigned managed identity.
- Least-privilege data access.
- No storage account keys in application configuration.
- Explicit request-body limit.
- Explicit allowed-host and Origin validation.
- Outbound access limited to required platform services and the Azure pricing endpoint where practical.
- Readiness and liveness checks.
- Deployment revision and rule-release version included in telemetry.

Azure Container Apps supports configurable minimum replicas and managed identities for access to Azure Storage:

- https://learn.microsoft.com/en-us/azure/container-apps/scale-app
- https://learn.microsoft.com/en-us/azure/container-apps/managed-identity

The latency and cost consequences of keeping one replica active must be measured. If the fixed cost is disproportionate for a free beta, compare it with scale-to-zero using a separately reported cold-start cohort rather than silently changing the latency gate.

## MCP SDK caution

As of 2026-07-24, the official TypeScript SDK repository states that its v2 line is still in development and recommends v1.x for production use until v2 stabilizes:

- https://github.com/modelcontextprotocol/typescript-sdk

This SDK version has no relationship to the Azure Cost Calculator product's proposed “v2” name.

Before implementation:

1. Recheck the official SDK recommendation.
2. Select a stable exact version.
3. Confirm its security advisories.
4. Confirm Streamable HTTP and JSON-response behavior.
5. Confirm structured tool output support.
6. Confirm abort, timeout, body-size, and error behavior.
7. Pin the exact package and lockfile.
8. Record an upgrade policy for the PoC period.

The standard remote transport and its security requirements should be checked against the current MCP specification:

- https://modelcontextprotocol.io/specification/2025-11-25/basic/transports

## Authentication suggestion

For the private beta:

- Generate opaque high-entropy API keys.
- Use a non-secret prefix or lookup identifier.
- Store only a salted one-way hash.
- Accept the key only through a configured secret header.
- Redact the header before request logging.
- Avoid cookies, query-string credentials, and browser-local storage.
- Provide a maintainer CLI for generation, revocation, replacement, and quota override.

Do not finalize the header name until the three-host spike proves which secret-header configuration works consistently. Supporting two header conventions may be acceptable if both enter the same authentication path and do not complicate documentation.

Full OAuth, public onboarding, delegated consent, and token refresh are not part of this PoC. The findings report must still document the OAuth gap for broader interoperability.

## Price-cache suggestion

Use two levels:

1. bounded process-local LRU;
2. shared persistent price cache.

Both are addressed by the same canonical query hash. The persistent cache stores only normalized public pricing data and explicit expiry metadata.

Implementation details to verify:

- Maximum exact-filter result size.
- Complete pagination behavior.
- Single-flight behavior within one process.
- Cross-replica cache stampede behavior.
- Whether a short distributed lock is necessary or duplicate upstream requests are acceptable.
- Expired-entry cleanup.
- Encryption and integrity behavior.
- Cache-key versioning.
- Metrics for hit, miss, age, item count, and upstream latency.

Do not add a dedicated distributed cache product before measurements show the table-backed cache is insufficient. Do not place request-specific quantities or architecture content in the shared price cache.

## Deployment and CI suggestion

Keep workflows path-scoped so ordinary plugin changes do not build or deploy the PoC unnecessarily.

Candidate stages:

1. format and static analysis;
2. unit tests;
3. recorded-price contract tests;
4. service-rule validation;
5. container build and vulnerability scan;
6. deploy an isolated test revision;
7. publish an immutable rule release;
8. run canonical fixture E2E tests;
9. activate the rule release;
10. run live pricing smoke tests;
11. retain benchmark artifacts; and
12. require an explicit approval before any shared beta deployment.

Deployment credentials should use workload identity or another short-lived federation mechanism rather than a long-lived cloud secret where supported.

## Components not recommended for the first PoC

- API gateway product.
- Dedicated distributed cache.
- Hosted model or model gateway.
- OAuth authorization server.
- Queue or asynchronous worker.
- Durable estimate database.
- Search index.
- Event-streaming platform.
- Multi-region traffic manager.
- Customer or administrator web portal.
- General-purpose API product.
- Per-service microservices.

These may become reasonable only after evidence identifies a need.

## Required verification spike

Before building the calculation service, implement a disposable endpoint with one harmless tool and verify:

| Check | Claude Code | Copilot in VS Code | Codex |
| --- | --- | --- | --- |
| Remote Streamable HTTP connection | Pending | Pending | Pending |
| Secret header configuration | Pending | Pending | Pending |
| Tool discovery | Pending | Pending | Pending |
| Structured input | Pending | Pending | Pending |
| Structured output | Pending | Pending | Pending |
| Typed error rendering | Pending | Pending | Pending |
| Stateless request behavior | Pending | Pending | Pending |
| Timeout and retry behavior | Pending | Pending | Pending |

If one required host cannot configure the chosen authentication or transport, stop and reassess before building the pricing engine around that assumption.

## Decision criteria

Adopt the candidate stack only if the verification work shows that it:

- supports both tool contracts without host-specific business logic;
- can enforce weekly quota safely under concurrency;
- meets the cache and latency gates;
- keeps deployment and operations proportional to a free beta;
- can be isolated from the current plugin;
- can be tested with recorded and live price paths;
- has a credible security and maintenance story; and
- does not require a broad refactor when adding only the two selected fixtures.

Otherwise, record the failed assumption and choose the smallest alternative that satisfies the technology-neutral plan.
