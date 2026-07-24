# Hosted Azure Cost MCP PoC Plan

**Status:** Proposed  
**Last updated:** 2026-07-24  
**Related issue:** [#1035 — poc: hosted subscription MCP for Azure cost estimation](https://github.com/ahmadabdalla/azure-cost-calculator/issues/1035)  
**Technology choices:** Deliberately excluded from this plan. See [MCP-POC-TECH-STACK-NOTES.md](MCP-POC-TECH-STACK-NOTES.md).

## 1. Purpose

Prove that the Azure Cost Calculator can be exposed as a small remote MCP tool that Azure architects and consultants can use from multiple agent hosts without loading the full plugin, scripts, and pricing references into the agent's context window.

The PoC must establish whether this approach:

1. materially reduces model-visible context and token usage;
2. preserves or improves deterministic pricing results;
3. remains fast enough for interactive use;
4. works across independent MCP hosts;
5. enforces API-key access and weekly usage allowances correctly;
6. keeps all natural-language inference and its cost with the user's agent host; and
7. can be operated as a bounded free beta without introducing unnecessary product features.

This is an independent MCP product and protocol experiment. It does not depend on, compare with, or choose an architecture for the separate agent-orchestration v2 proposal. The current v1.10 plugin is used only as the operational baseline for measuring context, correctness, and speed.

## 2. Product hypothesis

The hosted MCP is a deterministic Azure cost engine, not a hosted conversational agent and not a generic proxy to a model.

```text
Azure architect or consultant
        |
        | natural-language architecture
        v
user's agent host and model
        |
        | canonical structured request
        v
hosted Azure Cost MCP
        |
        | validation, live price resolution, calculation
        v
structured, evidenced estimate
        |
        v
user's agent host and model presents the result
```

The user pays for or supplies the inference used to interpret their architecture. The hosted service pays only for deterministic request processing, pricing API access, limited persistence, caching, and telemetry.

The default path must run without any model-provider credential and must make zero server-funded model calls.

## 3. Intended user and golden path

### Primary user

An Azure architect or consultant who needs to turn a described Azure architecture into an itemized cost estimate from within an agent host.

### Primary host

Claude Code.

### Compatibility hosts

- GitHub Copilot in Visual Studio Code.
- Codex.

### Golden path

1. The user provides an Azure architecture to their agent.
2. The host model identifies the Azure services in scope.
3. The host calls `get_service_requirements` for only those services.
4. The host maps the architecture to the returned versioned requirements.
5. If required pricing inputs are absent or ambiguous, the host asks the user.
6. The host calls `estimate_azure_architecture` with a canonical structured request.
7. The MCP validates the request, resolves live Azure pricing, calculates the estimate, and returns compact structured evidence.
8. The host model explains the result to the user.

The MCP must also work without an installed plugin or skill. A thin skill may improve discovery and tool-call behavior, but it is optional and must not contain pricing rules or a second calculation implementation.

## 4. Decisions established by the design interview

| Area | Decision |
| --- | --- |
| Natural-language interpretation | Owned by the user's host/model |
| Server-funded inference | Prohibited in the PoC |
| MCP sampling | Out of scope |
| Plugin/skill | Optional thin adapter |
| Product mode | Free, invite-only beta |
| API-key allowance | 30 successful estimates per week by default |
| Quota reset | Monday at 00:00 UTC |
| Configuration | Default and per-key allowances must be easy to change |
| MCP tools | Exactly two |
| Estimate retrieval | Not included |
| Estimate behavior | Synchronous; client owns the returned result |
| Durable architecture storage | Not included |
| Price source | Live Azure Retail Prices API |
| Price cache | Allowed; 15-minute default TTL, configurable |
| Stale prices | Never used for a new estimate |
| Rule authoring | Versioned, machine-readable, reviewed through Git and CI |
| Rule runtime | Validated immutable releases |
| PoC fixtures | Complete 3-tier web app and complete event-driven serverless examples |
| Primary comparison | Current v1.10 behavior on the same fixtures |
| Delivery style | Narrow but production-shaped vertical slice |

## 5. Scope

### In scope

- A remote MCP endpoint using the standard remote MCP transport.
- API-key authentication for an invite-only beta.
- Configurable weekly successful-estimate quota.
- Short-window rate limiting and concurrency control.
- Two compact MCP tools.
- Deterministic alias resolution, validation, categorization, pricing queries, and calculations.
- Machine-readable service rules for every service needed by the two E2E fixtures.
- Live Azure Retail Prices API retrieval.
- Shared public-price caching with strict freshness behavior.
- Tenant-scoped idempotency and usage metering.
- Optional thin skill for the primary host.
- Compatibility tests across the three selected hosts.
- Context, token, correctness, latency, reliability, and operating-cost measurements.
- Maintainer operations documentation.
- A final evidence-backed go/no-go recommendation.

### Explicitly out of scope

- Server-side natural-language interpretation.
- Any hosted LLM, model credential, or server-funded inference.
- MCP sampling.
- A paid subscription, checkout, billing, invoicing, or overage.
- Public self-service signup.
- A customer or administrator portal.
- A public REST API product.
- Full OAuth implementation.
- Durable estimate history or estimate retrieval.
- A revise-estimate tool.
- A tool per Azure service.
- Migrating every existing Azure service.
- Accepting customer Azure credentials, subscription data, negotiated prices, or private rate cards.
- Serving an expired price as current during an upstream outage.
- Multi-region availability or a production SLA.
- Replacing or deprecating the current plugin.
- Making an architectural decision for the separate agent-orchestration v2 proposal.

## 6. MCP contract

### 6.1 `get_service_requirements`

Purpose: give the host only the pricing requirements needed for explicitly requested services.

Input:

- one or more service names, aliases, or stable service IDs;
- optional rule-release version for reproducibility.

Output:

- resolved stable service ID;
- exact category;
- required inputs;
- never-assume fields;
- safe defaults;
- allowed values or bounded examples;
- billing dependencies;
- rule version;
- ambiguous matches; and
- unsupported services.

Rules:

- Alias matching is deterministic and case-normalized.
- One alias resolving to multiple services returns a bounded ambiguity result.
- No full Azure service or SKU catalogue is returned.
- The response includes only requested services and their required dependencies.
- Calls do not consume estimate quota.

### 6.2 `estimate_azure_architecture`

Purpose: validate and calculate one complete canonical architecture specification.

Minimum input concepts:

- schema version;
- idempotency key;
- region;
- currency;
- canonical resources;
- stable service IDs;
- service-specific pricing parameters;
- quantities and usage volumes;
- commitment and benefit selections where applicable; and
- result view (`summary` or `line_items`, defaulting to `summary`); and
- optional rule-release version.

Successful output:

- request fingerprint;
- rule-release version;
- price retrieval timestamp;
- oldest price age used;
- currency;
- monthly and annual totals;
- category totals and line-item count;
- assumptions and applied safe defaults;
- warnings;
- cache-hit metadata;
- remaining weekly allowance; and
- quota reset time.

The `line_items` view additionally returns the complete bounded ledger, including:

- categorized line items;
- unit prices and quantities;
- formulas or calculation evidence; and
- meter IDs where available.

Non-success output:

- typed missing-requirement result;
- typed ambiguity result;
- typed unsupported-service result;
- typed invalid-input result;
- typed idempotency conflict;
- typed quota or rate-limit result; or
- typed pricing-upstream-unavailable result.

Rules:

- A missing never-assume input is never guessed.
- Unsupported inputs never produce a fabricated partial estimate.
- A newly completed logical estimate consumes one quota unit.
- Validation and upstream failures consume no quota.
- Reusing an idempotency key with the same request fingerprint replays the prior response without consuming quota.
- Reusing an idempotency key with a different fingerprint returns a conflict.
- The client receives the selected result view synchronously.
- There is no follow-up retrieval endpoint. A caller that needs line items must request the `line_items` view on the estimate call.

### 6.3 Tool efficiency budgets

- Exactly two tools are exposed.
- Combined tool names, descriptions, and schemas must be no more than 2,000 estimated tokens.
- Target combined footprint is below 1,000 estimated tokens.
- Default successful output must be no more than 500 estimated tokens.
- Target default output is below 250 estimated tokens.
- The complete `line_items` view must remain structured and bounded by the pre-registered maximum line-item count.
- The event-driven fixture's `line_items` token budget must be fixed in Phase 0 after its canonical ledger is reviewed.
- No service catalogue or pricing reference corpus is embedded in tool definitions.

## 7. Deterministic service-rule model

The existing Markdown service references are designed for agent interpretation. The model-free server therefore requires a machine-readable rule registry for the bounded PoC cohort.

Each service rule must define:

- stable service ID;
- aliases;
- exact category;
- input schema;
- never-assume fields;
- safe defaults;
- allowed values;
- billing dependencies;
- Azure Retail Prices API query templates;
- calculation strategy or named calculation handler;
- output units and required evidence;
- rule version; and
- compatibility with a rule-release version.

Complex calculations may use reviewed calculation handlers. The PoC must not invent an expression language merely to avoid ordinary code.

### Rule lifecycle

```text
Git change
   |
   v
schema, alias, formula, and fixture validation
   |
   v
immutable checksummed rule release
   |
   v
publish to runtime rule store
   |
   v
hosted E2E verification
   |
   v
activate release pointer
```

Requirements:

- Git is the authoring and audit source of truth.
- Runtime rule records are immutable.
- Direct production edits are prohibited.
- The runtime receives read-only access to rules.
- A separate release process publishes and activates rules.
- Rollback changes the active pointer to a previously validated release.
- Every estimate identifies its rule-release version.
- Alias uniqueness and category assignments are validated in CI.

The PoC does not migrate every service reference or establish machine-readable files as the permanent v2 canonical format. It proves whether this model works for the selected fixtures.

## 8. Live pricing and cache behavior

### 8.1 Price-source policy

- Every price used by a new estimate originates from the Azure Retail Prices API.
- No static or manually entered price catalogue is maintained.
- API evidence includes meter ID where available, effective date, region, currency, and retrieval timestamp.
- Tests may use recorded API fixtures to isolate deterministic behavior.
- Separate live smoke tests verify that current queries and parsers still match the upstream contract.

### 8.2 What is cached

Cache API-derived price records, not architecture requests or calculated estimates.

The canonical cache key must include every query dimension that can affect the returned price:

- cache-contract and normalizer version;
- currency;
- service name;
- region;
- price type;
- ARM SKU name;
- SKU name;
- product name; and
- meter name.

The cached value contains only the normalized API fields needed for later calculation:

- meter ID and meter name;
- service, product, SKU, and ARM SKU;
- region and currency;
- retail price and unit of measure;
- price type and reservation term;
- tier minimum units;
- primary-meter-region indicator;
- effective start date; and
- retrieval timestamp.

It contains no user architecture, API-key identity, quantity, computed total, or arbitrary text. Public price entries may therefore be shared across tenants.

### 8.3 Retrieval algorithm

1. Construct an exact price query from a validated service rule.
2. Canonicalize filter names while preserving case-sensitive values.
3. Hash the canonical query.
4. Check the process-local cache.
5. Check the shared price cache.
6. On a miss, collapse concurrent identical requests into one upstream request.
7. Apply retry and complete-pagination behavior.
8. Validate the complete response before caching it.
9. Store successful pricing records for the configured TTL.
10. Calculate request-specific quantities outside the shared cache.

### 8.4 Freshness and failure

- Default positive TTL: 15 minutes, configurable.
- A valid zero-result may be cached for no more than 60 seconds to prevent retry storms.
- HTTP failures, timeouts, incomplete pagination, invalid JSON, and ambiguous selection are never cached as valid prices.
- Expired entries are ignored.
- A new estimate never uses an expired entry.
- If the upstream API is unavailable and no valid cache exists, return `pricing_upstream_unavailable`.
- An upstream failure consumes no quota.
- Each estimate reports the retrieval time and cache status of its prices.

## 9. API keys, quotas, and idempotency

### 9.1 API-key beta

- Access is invite-only.
- Keys are generated through a maintainer operation.
- Full secret value is displayed only once.
- Stored secrets use a one-way salted hash.
- Keys have a non-secret lookup identifier.
- Keys can be revoked and replaced.
- Keys never appear in query strings, logs, traces, or error messages.
- One key is the tenant boundary and may be shared by one invited team.
- Authentication uses a secret request header supported by the selected hosts.

### 9.2 Weekly allowance

- Default allowance: 30 successful estimates.
- Window: Monday 00:00 UTC to the following Monday 00:00 UTC.
- Default allowance is configuration, not code.
- A key may have an explicit allowance override.
- Each response reports remaining estimates and the reset timestamp.
- There is no billing, overage, or automatic plan upgrade.
- A user who exhausts the allowance may request an extension or self-host.

### 9.3 Billable event

One quota unit is committed only when:

1. authentication succeeds;
2. allowance is available;
3. input validation succeeds;
4. pricing resolution succeeds;
5. calculation succeeds; and
6. the successful logical estimate is returned or durably recoverable for an idempotent retry.

These operations do not consume quota:

- MCP initialization;
- tool discovery;
- `get_service_requirements`;
- authentication failure;
- schema or business validation failure;
- missing or ambiguous requirements;
- unsupported services;
- rate-limit rejection;
- quota rejection;
- idempotent retry;
- client disconnect before a logical estimate is committed;
- upstream failure; and
- internal server failure.

### 9.4 Concurrency-safe flow

The server must:

1. atomically reserve allowance at request admission;
2. reject admission when no allowance is available;
3. bind the reservation to tenant, week, idempotency key, and request fingerprint;
4. commit the reservation after successful calculation;
5. release it after a non-billable failure;
6. return the committed response for an identical retry;
7. reject the same key with a different fingerprint; and
8. prevent concurrent requests from producing negative allowance or duplicate usage events.

Only minimal operational state is retained:

- API-key metadata and hash;
- quota-window counters;
- append-only usage event;
- idempotency key and request fingerprint; and
- encrypted response replay data for no more than 24 hours.

No raw user prompt or durable architecture history is retained.

### 9.5 Abuse controls

Initial defaults:

- five estimate attempts per minute per key;
- two concurrent estimates per key; and
- bounded maximum resources, queries, and line items per estimate.

The exact resource and line-item limits must be fixed after canonicalizing the full event-driven fixture. They must permit that fixture while preventing unbounded work in one quota unit.

## 10. End-to-end fixtures

The existing examples become the PoC's primary E2E specifications.

### 10.1 Simple fixture: 3-tier web application

Source: `skills/azure-cost-calculator/references/examples/3-tier-web-app.md`

Full scope:

- Linux Virtual Machines;
- Premium SSD managed disks;
- Azure SQL Managed Instance;
- East US;
- USD;
- pay-as-you-go; and
- no Azure Hybrid Benefit or zone redundancy.

Purpose:

- smoke-test the complete path;
- validate provisioned hourly and storage calculations;
- establish warm and uncached latency;
- provide a small debugging fixture; and
- compare basic context overhead with v1.10.

### 10.2 Complex fixture: event-driven serverless platform

Source: `skills/azure-cost-calculator/references/examples/event-driven-serverless.md`

The entire documented architecture is in scope, including:

- Event Grid;
- Service Bus;
- all four Functions workloads;
- Cosmos DB;
- SQL Database;
- Redis;
- hot and cool Blob Storage;
- Cosmos DB backup;
- Key Vault;
- Sentinel;
- Application Insights;
- Azure Monitor Private Link Scope;
- all documented private endpoints;
- all documented private DNS zones;
- internet bandwidth; and
- the stated Australia East, AUD, and commitment parameters.

Purpose:

- stress-test context efficiency;
- exercise consumption, provisioned, reserved, storage, monitoring, networking, and tiered meters;
- validate dependency expansion;
- test concurrent price lookups and cache reuse;
- test complete structured output under the token budget; and
- prove that a substantial architecture can be calculated without loading the pricing corpus into the host context.

### 10.3 Dual fixture representation

Each architecture must have:

1. its existing Markdown representation, used for full host-agent-to-MCP tests; and
2. a reviewed canonical structured representation, used for deterministic engine and MCP contract tests.

This creates a clear diagnostic boundary:

- canonical request fails: deterministic service or rule defect;
- Markdown fails but canonical request passes: host interpretation or thin-skill defect;
- both pass but the user-facing answer fails: host presentation defect.

## 11. Benchmark design

### 11.1 Compared paths

Run the same architecture through:

1. current v1.10 skill;
2. MCP directly with no helper skill; and
3. MCP with the optional thin skill.

The comparison is against current v1.10 only. It is not a comparison with the separate v2 orchestration proposal.

### 11.2 Controls

- Same host and model for compared paths.
- Fresh conversation for each run.
- Identical architecture text.
- Identical region, currency, and pricing assumptions.
- Recorded upstream price fixtures for correctness and deterministic runs.
- Live upstream retrieval for operational latency runs.
- Explicit cold, warm, cache-hit, and cache-miss cohorts.
- Ten repetitions per path and fixture.
- Raw machine-readable measurements retained without prompts, credentials, or customer data.

### 11.3 Measurements

#### Model-visible context

- Tool-definition bytes and estimated tokens.
- Skill instruction and loaded-reference tokens.
- Tool request and response tokens.
- Total model-visible input and output tokens.
- Model turns.
- Tool calls.
- Whether a host reinjects or caches tool definitions.

#### Correctness

- Service identification.
- Required-input classification.
- Applied defaults.
- Query parameters.
- Meter and SKU resolution.
- Unit prices.
- Formula arithmetic.
- Line-item totals.
- Monthly and annual totals.
- Categories.
- Assumptions and warnings.
- Evidence completeness.

#### Determinism

- Canonical request equivalence across repeated calls.
- Normalized result equivalence.
- Host conversion from Markdown to canonical input.
- Behavior for missing, ambiguous, invalid, and unsupported inputs.

#### Speed

- Host inference time.
- Connection and tool-discovery time.
- Authentication.
- quota reservation and commit;
- validation;
- local and shared cache lookup;
- live upstream retrieval;
- calculation;
- serialization;
- full tool-call time; and
- user-visible end-to-end time.

#### Reliability and security

- Retry behavior.
- Concurrent duplicate behavior.
- Rate-limit behavior.
- quota exhaustion;
- upstream failure;
- invalid and revoked keys;
- key redaction;
- Origin and host validation;
- cross-tenant attempts; and
- oversized inputs.

#### Operating cost

- Fixed service cost.
- Request-processing cost.
- persistent-state operations;
- cache operations;
- telemetry;
- outbound traffic;
- upstream calls per estimate;
- estimated cached and uncached cost per successful estimate; and
- projected free-beta cost at representative usage levels.

There is no paid-tier or revenue-ratio gate in this PoC.

## 12. Pre-registered success gates

### 12.1 Mandatory: inference boundary

- Zero server-funded model calls and model tokens.
- The hosted service runs without a model-provider credential.
- No fallback silently invokes a model.
- The host owns all natural-language interpretation.

### 12.2 Mandatory: context efficiency

- At least 60% fewer total model-visible tokens than v1.10 for the complete event-driven architecture.
- Exactly two tools.
- Combined tool definitions and schemas at or below 2,000 estimated tokens.
- Default successful result at or below 500 estimated tokens.
- No full service or SKU catalogue in tool context.

### 12.3 Mandatory: correctness and determinism

- Canonical structured calls produce 100% identical normalized estimates across ten fixed-fixture runs.
- Markdown E2E runs produce the same supported resources and pricing parameters in at least nine of ten runs.
- No reviewed-fixture arithmetic or total errors.
- No material correctness regression against the reviewed v1.10 baseline.
- All deliberately missing, ambiguous, and unsupported inputs return bounded structured outcomes.
- Every returned price includes available SKU/meter evidence and retrieval time.
- Full-ledger comparisons use the synchronous `line_items` view; the 500-token gate applies to the default `summary` view.

### 12.4 Mandatory: speed

- Warm cached tool-call latency: P50 at or below 500 ms and P95 at or below 1.5 seconds.
- Median user-visible E2E time no more than 20% slower than v1.10.
- Any regression is attributed between host inference, transport, upstream retrieval, and deterministic processing.
- Cold and uncached results are reported separately and are not excluded from the report.

### 12.5 Mandatory: authentication, quota, and idempotency

- Valid keys succeed; invalid and revoked keys fail.
- Default and per-key weekly allowances are configurable.
- Weekly reset occurs at Monday 00:00 UTC.
- Only successful logical estimates consume quota.
- Ten sequential and ten concurrent identical retries produce one committed usage event.
- Same idempotency key plus different request fingerprint returns a conflict.
- Allowance never becomes negative under concurrency.
- Failed and rejected calls never consume quota.
- Rate limiting and weekly allowance are independently observable.

### 12.6 Mandatory: pricing and caching

- All new-estimate prices originate from the live Azure Retail Prices API or a still-valid API-derived cache entry.
- Region, currency, price type, product, SKU, meter, reservation, and tier data never cross cache keys incorrectly.
- Expired prices are never served as current.
- Upstream failure with no valid entry returns a typed unavailable result and consumes no quota.
- Cache hit rate, entry age, upstream call count, and live-query latency are measured.

### 12.7 Mandatory: compatibility

- Both E2E architectures complete in Claude Code.
- Both E2E architectures complete in GitHub Copilot in Visual Studio Code.
- Both E2E architectures complete in Codex.
- Each host's remote transport, secret-header configuration, structured output, and error behavior are documented.
- Any host-specific workaround is thin and contains no pricing logic.
- An OAuth gap assessment records what would be needed beyond the API-key beta.

### 12.8 Mandatory: scope integrity

- Both fixtures are priced in full.
- No third MCP tool is added.
- No hosted model is added.
- No paid-subscription feature is added.
- No estimate-history feature is added.
- No unrelated plugin refactor is required.
- Tests and operational documentation follow repository conventions.

## 13. Delivery phases

Each phase is a vertical slice with explicit exit criteria. Later features do not begin until the current phase demonstrates its required evidence.

### Phase 0 — lock contracts and measurements

Work:

- Canonicalize both architecture fixtures.
- Inventory every required service, input, dependency, price query, and formula.
- Review expected line items and totals using recorded price fixtures.
- Draft the two MCP schemas and compact result contract.
- Fix the full event-driven `line_items` response budget.
- Fix request, resource, query, and line-item bounds.
- Define normalized volatile fields for deterministic comparison.
- Build the v1.10 benchmark harness before MCP implementation.
- Confirm that all three hosts can connect to a minimal authenticated remote MCP endpoint.

Exit criteria:

- Both canonical fixtures reviewed.
- Baseline raw results captured.
- Two tool schemas fit the token budget.
- Host/header compatibility spike completed.
- No unresolved requirement changes the product boundary.

### Phase 1 — deterministic calculation core

Work:

- Define the service-rule schema and validation.
- Implement immutable rule-release loading.
- Implement alias and category resolution.
- Implement query planning.
- Implement calculation handlers.
- Complete the 3-tier fixture first.
- Add recorded-price correctness, ambiguity, and unsupported-service tests.

Exit criteria:

- 3-tier canonical fixture passes ten-run deterministic testing.
- Missing and invalid input behavior is structured.
- No model credential or natural-language component exists in the core.

### Phase 2 — remote MCP vertical slice

Work:

- Expose the two tool contracts.
- Add API-key authentication.
- Add weekly quota, rate limit, concurrency protection, and idempotency.
- Add live pricing client.
- Add local and shared price caches.
- Add compact structured output and telemetry.
- Run the complete 3-tier fixture through the primary host.

Exit criteria:

- Authenticated 3-tier E2E succeeds.
- Quota and idempotency concurrency tests pass.
- Live and cached price paths succeed.
- Warm latency is measured.

### Phase 3 — complex architecture completion

Work:

- Add only the rules and calculation handlers required by the event-driven fixture.
- Implement every documented dependency, private networking component, monitoring item, and bandwidth line item.
- Enforce the pre-registered per-estimate bounds.
- Tune compact output without removing evidence.

Exit criteria:

- Complete canonical event-driven fixture passes.
- Full Markdown E2E succeeds in the primary host.
- Event-driven output remains within the result budget.
- No unsupported fixture line item is silently omitted.

### Phase 4 — compatibility and thin adapter

Work:

- Run both fixtures directly in all three hosts.
- Record connection, authentication, schema, output, and error behavior.
- Add the optional thin skill only if direct behavior needs guidance.
- Ensure the skill contains no pricing rules.
- Produce the OAuth interoperability gap assessment.

Exit criteria:

- All mandatory host scenarios pass or a mandatory gate is explicitly failed.
- Direct and thin-skill measurements are available.
- Host-specific workarounds are documented.

### Phase 5 — benchmarks, operations, and decision

Work:

- Execute all ten-run benchmark cohorts.
- Run security, failure, concurrency, and quota scenarios.
- Measure operating cost.
- Complete maintainer operations documentation.
- Publish raw results and the human-readable report.
- Mark each hypothesis confirmed or refuted.

Exit criteria:

- Every mandatory gate has evidence.
- Failures and timeouts remain in the dataset.
- Final recommendation is one of:
  - proceed to limited API-key beta;
  - revise and repeat a bounded experiment;
  - pause pending authentication interoperability work; or
  - stop because benefits do not justify the hosted service.

## 14. Test plan

Tests belong under `tests/`, never under `skills/`.

Required layers:

- Service-rule schema and alias validation.
- Calculation-handler unit tests.
- Recorded Retail Prices API contract fixtures.
- Cache canonicalization and isolation tests.
- Tool input/output contract tests.
- API-key hashing, lookup, revocation, and redaction tests.
- Weekly boundary and per-key override tests.
- Rate-limit and maximum-concurrency tests.
- Idempotency conflict, retry, and replay tests.
- Ten-way quota concurrency tests.
- Upstream timeout, error, malformed response, and incomplete-pagination tests.
- Oversized request and response tests.
- Full canonical 3-tier E2E.
- Full canonical event-driven E2E.
- Markdown-to-MCP host E2E for all three hosts.
- Token and latency benchmark harness.

Live tests must be separated from recorded-fixture tests so upstream variance does not make deterministic CI unreliable.

## 15. Operational documentation

Because the PoC introduces hosted infrastructure and automation, an operations guide must be created under `docs/ops/`.

It must cover:

- what the PoC does and does not do;
- prerequisites;
- deployment and rollback;
- rule-release publication and activation;
- key creation, replacement, revocation, and extension;
- default and per-key quota changes;
- weekly reset behavior;
- rate-limit changes;
- price-cache TTL and purge;
- live pricing outage behavior;
- observability and alert interpretation;
- data retained and expiry;
- incident handling;
- troubleshooting;
- compatibility limitations;
- test and benchmark execution; and
- external protocol and Azure references.

## 16. Security and privacy requirements

- Validate authentication before processing tool inputs.
- Validate Origin and expected host behavior for remote transport.
- Use strict request schemas and maximum body sizes.
- Do not accept arbitrary upstream URLs, OData expressions, formulas, or executable code.
- Permit outbound pricing calls only to the expected Azure endpoint.
- Redact secret headers before all logging and tracing.
- Use non-secret trace and key identifiers.
- Isolate tenant quota and idempotency records.
- Share only public price-cache entries across tenants.
- Do not receive the original conversation.
- Reject or strip resource names, project names, and arbitrary descriptive text not needed for pricing.
- Retain replay data for no more than 24 hours.
- Record no durable architecture history.
- Scan dependencies and deployment artifacts.
- Document residual API-key and team-sharing risks.

## 17. Deliverables

- Two versioned MCP tool contracts.
- Deterministic calculation core with no model dependency.
- Machine-readable rules for the complete two-fixture cohort.
- Immutable rule-release validation and publication process.
- API-key issuance and revocation operation.
- Configurable weekly quota and short-window rate limiting.
- Concurrency-safe idempotent usage metering.
- Live pricing client and bounded price cache.
- Complete canonical and Markdown E2E fixtures.
- Optional thin skill, only if evidence shows it is needed.
- Compatibility matrix for the three target hosts.
- OAuth gap assessment.
- Raw benchmark results.
- Human-readable PoC findings report.
- Security and retention notes.
- Maintainer operations guide under `docs/ops/`.
- Final go/no-go recommendation.

## 18. Risks and open questions

These are questions to answer through the PoC, not invitations to expand the initial feature set:

- Can all three hosts configure a remote secret header consistently?
- Does one host require OAuth earlier than expected?
- Can host models reliably identify service names before calling `get_service_requirements`?
- Does the requirements response remain compact for the complete event-driven fixture?
- Can the full event-driven output remain below its pre-registered `line_items` token budget without losing evidence?
- Which service rules require code handlers rather than declarative calculation metadata?
- What resource/query/line-item bound safely contains the complex fixture?
- What cache hit rate appears under realistic repeated architecture work?
- Is a 15-minute price TTL acceptable in actual use?
- What latency comes from the host versus the remote service?
- Does the optional thin skill materially improve 9-of-10 host interpretation consistency?
- What operational cost does the free weekly allowance create?
- Is API-key team sharing acceptable for a limited beta?
- What data-use, pricing-disclaimer, redistribution, and trademark review is needed before any broader launch?

## 19. Issue reconciliation required

Issue #1035 predates the design interview and should be updated after this plan is accepted. The issue currently contains assumptions superseded by this plan, including:

- subscription and paid-tier framing;
- monthly rather than weekly quota;
- up to three tools;
- estimate retrieval and storage;
- stale-price fallback;
- an illustrative six-service cohort instead of the two complete fixtures;
- optional MCP sampling; and
- a paid-tier revenue-ratio success gate.

The issue update should link to this plan and preserve the decision history rather than erasing it.

## 20. Definition of done

The PoC is complete when:

- both full fixtures pass the canonical and host E2E paths;
- all three target hosts are tested;
- all mandatory gates have raw evidence;
- zero server-funded model calls are demonstrated;
- the token-reduction and speed comparisons against v1.10 are published;
- deterministic, quota, idempotency, cache, and failure tests pass;
- operating cost for the free beta is measured;
- the operations guide is complete;
- issue #1035 reflects the accepted design; and
- a clear go/no-go recommendation is recorded.

Any implementation PR resulting from this plan must target the `dev` branch.
