---
initiative: mcp-poc
artifact: requirements
status: accepted
owner: repository maintainer
authority: [requirements, api-contract, security, evaluation-contract]
---

# Hosted Azure Cost MCP PoC requirements

This document owns required product behaviour and success criteria. Technology
rationale belongs in [decisions.md](decisions.md), delivery sequencing belongs
in [work-packages.md](work-packages.md), and dated claims belong in
[evidence.md](evidence.md).

## REQ-001 — Product boundary and inference ownership

**Status:** Accepted

The PoC must expose a deterministic Azure cost engine, not a hosted
conversational agent or generic model proxy.

- The user's MCP host and model own natural-language interpretation, service
  identification, tool selection, construction of canonical arguments, and
  presentation of results.
- The hosted service owns authentication, validation, live price resolution,
  deterministic calculation, bounded persistence, caching, usage metering, and
  structured evidence.
- The default path must run without a model-provider credential and must make
  zero server-funded model calls.
- MCP sampling and any server-side natural-language interpretation are out of
  scope.
- The experiment is independent of the separate agent-orchestration v2
  proposal. The current v1.10 skill is only the measurement baseline.

## REQ-002 — Intended users, hosts, and golden path

**Status:** Accepted

The primary user is an Azure architect or consultant. Claude Code is the
primary host; GitHub Copilot in Visual Studio Code and Codex are compatibility
hosts.

The supported golden path is:

1. The host identifies services in a user-provided architecture.
2. The host requests requirements only for those services.
3. The host maps the architecture to a canonical structured request and asks
   the user for any never-assume values.
4. The host submits one synchronous estimate request.
5. The server validates, resolves live prices, calculates, and returns bounded
   structured evidence.
6. The host presents the result.

An installed plugin or skill must not be required. An optional discovery
adapter may contain prompting guidance but no pricing rules or second
calculation implementation.

## REQ-003 — PoC scope

**Status:** Accepted

### In scope

- A publicly reachable remote MCP endpoint using the standard remote transport.
- Invite-only API-key access with configurable weekly allowances.
- Short-window rate limiting and per-key concurrency control.
- Exactly two compact MCP tools.
- Deterministic alias resolution, validation, categorization, price lookup, and
  calculation.
- Versioned machine-readable rules for every service required by the two
  end-to-end fixtures.
- Live Azure Retail Prices API access and a shared public-price cache with
  strict freshness behaviour.
- Tenant-scoped idempotency and usage metering.
- Compatibility, correctness, determinism, context, latency, reliability,
  security, and operating-cost measurements.
- Maintainer operations documentation and an evidence-backed go/no-go
  recommendation.

### Out of scope

- Hosted inference, MCP sampling, and server-side natural-language parsing.
- Paid subscriptions, checkout, invoicing, overage, or public self-service
  signup.
- A user or administrator portal, a public REST product, or complete OAuth
  onboarding.
- Durable estimate history, estimate retrieval, and estimate revision.
- A tool per Azure service or migration of the entire service corpus.
- Customer Azure credentials, subscription data, negotiated prices, or private
  rate cards.
- Stale-price fallback, multi-region availability, or a production SLA.
- Replacement of the existing plugin or unrelated plugin refactoring.

## REQ-004 — Service-requirements tool contract

**Status:** Accepted

The service must expose `get_service_requirements`.

Input accepts one or more service names, aliases, or stable service IDs and an
optional rule-release version.

Output contains only the requested services and required dependencies:

- resolved stable service ID and exact category;
- required inputs, never-assume fields, safe defaults, and allowed values or
  bounded examples;
- billing dependencies and rule version;
- bounded ambiguous matches; and
- unsupported services.

Alias matching is deterministic and case-normalized. An alias resolving to more
than one service returns ambiguity. The response must not expose a complete
Azure service or SKU catalogue. Calls do not consume estimate allowance.

## REQ-005 — Architecture-estimate tool contract

**Status:** Accepted

The service must expose `estimate_azure_architecture`, which validates and
calculates one complete canonical architecture synchronously.

Input includes:

- schema version and tenant-scoped idempotency key;
- region and currency;
- canonical resources with stable service IDs;
- service-specific price parameters, quantities, and usage volumes;
- commitment and benefit selections where applicable;
- optional rule-release version; and
- result view `summary` or `line_items`, defaulting to `summary`.

A successful summary includes:

- request fingerprint and rule-release version;
- price retrieval timestamp and oldest price age;
- currency, monthly total, annual total, category totals, and line-item count;
- assumptions, applied safe defaults, and warnings;
- cache-hit metadata;
- remaining weekly allowance and reset time.

The `line_items` view additionally includes the bounded complete ledger:
categories, unit prices, quantities, calculation evidence, and available meter
IDs.

Non-success outcomes are typed and bounded: missing requirement, ambiguity,
unsupported service, invalid input, idempotency conflict, quota or rate limit,
and pricing-upstream unavailable.

Never-assume inputs are not guessed. Unsupported inputs do not produce a
fabricated partial estimate. There is no retrieval endpoint; callers needing
the ledger request it on this call.

## REQ-006 — Context and response budgets

**Status:** Accepted

- Exactly two tools are exposed.
- Combined tool names, descriptions, and schemas are no more than 2,000
  estimated tokens; the target is below 1,000.
- Default successful output is no more than 500 estimated tokens; the target is
  below 250.
- The complete `line_items` response is structured and bounded by a reviewed
  maximum line-item count.
- The complex fixture's ledger budget and all request/query/line-item bounds
  must be fixed before implementation.
- Tool definitions contain no full service catalogue, SKU catalogue, or pricing
  reference corpus.

## REQ-007 — Deterministic rule registry

**Status:** Accepted

The model-free server requires versioned machine-readable rules for the bounded
fixture cohort. Each rule defines:

- stable service ID, aliases, and exact category;
- input schema, never-assume fields, safe defaults, and allowed values;
- billing dependencies;
- exact Retail Prices API query templates;
- named calculation strategy or reviewed calculation handler;
- output units and required evidence; and
- rule version compatible with an immutable rule-release version.

Git is the authoring and audit source of truth. CI validates schema, aliases,
categories, formulas, and fixtures. Runtime releases are checksummed,
immutable, read-only, separately published, and activated by pointer. Rollback
selects a previously validated release. Every estimate identifies the release
used. Direct production edits are prohibited.

The PoC must not invent an expression language merely to avoid ordinary code
and must not claim the new format as the permanent v2 canonical representation.

## REQ-008 — Live pricing and cache semantics

**Status:** Accepted

Every price for a new estimate originates from the Azure Retail Prices API or a
still-valid API-derived cache entry. No manually maintained price catalogue is
allowed.

Evidence includes available meter ID, effective date, region, currency, and
retrieval timestamp. Recorded fixtures isolate deterministic tests; separate
live smoke tests verify the upstream contract.

Only normalized public price records are cached. Architecture requests,
tenant identity, quantities, and calculated estimates are not shared. The
canonical key includes every price-affecting query dimension:

- cache-contract and normalizer version;
- currency, service, and region;
- price type;
- ARM SKU, SKU, product, and meter.

Retrieval checks process-local then shared cache, collapses concurrent identical
misses, retries and completes pagination, validates the complete response, and
calculates request-specific quantities outside the shared cache.

The positive TTL defaults to 15 minutes and is configurable. Valid zero-results
may be cached for at most 60 seconds. HTTP failures, timeouts, incomplete
pagination, invalid JSON, and ambiguous selection are never valid cache
entries. Expired entries are ignored. With no valid price during an upstream
failure, the service returns `pricing_upstream_unavailable` and consumes no
allowance.

## REQ-009 — API keys and tenant boundary

**Status:** Accepted

- Access is invite-only.
- Each key has a non-secret lookup identifier and forms one tenant boundary; a
  key may be shared by one invited team.
- Secret material is shown only once and stored as a one-way salted hash.
- Keys can be issued, replaced, and revoked.
- Keys never appear in URLs, logs, traces, or errors.
- Authentication uses a secret HTTP header supported by the host. The exact
  header convention must be confirmed by compatibility testing.

## REQ-010 — Allowance, rate limiting, and bounded work

**Status:** Accepted

The default allowance is 30 newly completed logical estimates per key per week,
resetting Monday at 00:00 UTC. The default and per-key overrides are
configuration, not code. Responses report remaining allowance and reset time.

One quota unit commits only after authentication, allowance admission, input
validation, successful price resolution, successful calculation, and a
response that is returned or durably recoverable for retry.

Initialization, discovery, service-requirement calls, authentication failures,
validation or ambiguity results, unsupported services, rate or quota
rejections, retries, upstream failures, and internal failures consume no quota.

Initial protection defaults are five estimate attempts per minute and two
concurrent estimates per key. A reviewed maximum for resources, price queries,
and line items must contain the complex fixture while preventing unbounded work
within one unit.

## REQ-011 — Idempotency and minimal persistence

**Status:** Accepted

Allowance admission, usage, and replay must remain correct under concurrency.
The server atomically reserves allowance, binds the reservation to tenant,
week, idempotency key, and request fingerprint, commits after success, and
releases after non-billable failure.

The same tenant/key/fingerprint replays the committed response without consuming
another unit. The same key with a different fingerprint returns a conflict.
Concurrent identical requests produce one usage event and allowance never
becomes negative.

Retained operational state is limited to:

- API-key metadata and hash;
- quota-window counters and append-only usage events;
- idempotency key and request fingerprint; and
- encrypted response replay data retained for no more than 24 hours.

Raw prompts and durable architecture history are not retained.

## REQ-012 — End-to-end fixtures

**Status:** Accepted

The simple fixture is the complete
[3-tier web application](../../skills/azure-cost-calculator/references/examples/3-tier-web-app.md):
Linux VMs, Premium SSD managed disks, Azure SQL Managed Instance, East US, USD,
pay-as-you-go, without Hybrid Benefit or zone redundancy.

The complex fixture is the complete
[event-driven serverless platform](../../skills/azure-cost-calculator/references/examples/event-driven-serverless.md),
including all documented workloads, data stores, monitoring, backup, private
networking, DNS, bandwidth, Australia East, AUD, and commitment parameters.
No documented line item may be silently omitted.

Each fixture has:

1. the existing Markdown architecture for host-to-MCP tests; and
2. a reviewed canonical structured request for deterministic engine and
   contract tests.

This separates deterministic defects from host interpretation and presentation
defects.

## REQ-013 — Benchmark method

**Status:** Accepted

Compare the same fixtures through current v1.10, MCP without a helper, and MCP
with the optional thin adapter. Use the same host/model, fresh conversations,
identical inputs and assumptions, recorded price fixtures for reproducibility,
live retrieval for operational latency, and explicit cold/warm/cache cohorts.

Run ten repetitions per path and fixture. Preserve raw machine-readable
measurements without prompts, credentials, or customer data.

Measure:

- model-visible tool, instruction, request, and response bytes/tokens, turns,
  calls, and host reinjection behaviour;
- service/input/query/meter/formula/total/category/evidence correctness;
- canonical and normalized result equivalence;
- host inference, connection, discovery, authentication, quota, validation,
  cache, upstream, calculation, serialization, tool-call, and user-visible
  latency;
- retry, concurrency, rate, quota, upstream, key, redaction, origin, tenant, and
  oversized-input security behaviour; and
- fixed and marginal compute, state, cache, telemetry, traffic, upstream-call,
  and successful-estimate costs.

Errors and timeouts remain in the dataset.

## REQ-014 — Mandatory success gates

**Status:** Accepted

The PoC passes only when all of these gates pass:

- zero server-funded model calls/tokens and no configured model credential;
- at least 60% fewer model-visible tokens than v1.10 for the complex fixture;
- the budgets in `REQ-006`;
- identical normalized canonical results across ten fixed-fixture runs;
- at least nine of ten Markdown runs produce the same supported resources and
  pricing parameters;
- no reviewed-fixture arithmetic or total errors and no material correctness
  regression from the reviewed v1.10 baseline;
- bounded typed outcomes for all missing, ambiguous, invalid, and unsupported
  cases;
- warm cached tool-call P50 at or below 500 ms and P95 at or below 1.5 seconds;
- median user-visible time no more than 20% slower than v1.10, with attribution;
- valid/revoked-key, allowance override/reset, rate/quota independence,
  ten-way sequential and concurrent retry, conflict, and failure-accounting
  tests pass;
- no cache-key leakage, expired-price use, fabricated upstream response, or
  quota consumption on upstream failure;
- both fixtures complete in all three hosts with transport, authentication,
  structured output, error behaviour, and OAuth gaps documented; and
- both fixtures remain complete without adding a third tool, hosted model,
  payment, history, or unrelated plugin refactor.

## REQ-015 — Test requirements

**Status:** Accepted

Tests belong under `tests/`, never `skills/`, and cover:

- rule schema, aliases, categories, release loading, and calculation handlers;
- recorded Retail Prices API responses and separate live smoke tests;
- cache canonicalization, isolation, pagination, malformed response, and
  failure behaviour;
- both tool input/output contracts;
- key hashing, lookup, revocation, and redaction;
- weekly boundaries, overrides, rate limits, and concurrency;
- idempotency conflict, retry, replay, and ten-way quota contention;
- oversized inputs and outputs;
- complete canonical and host E2E fixtures; and
- token and latency benchmark harnesses.

Deterministic CI must not depend on live upstream variance.

## REQ-016 — Security and privacy controls

**Status:** Accepted

- Authenticate before processing tool inputs.
- Validate Origin and expected host behaviour for the selected remote
  transport.
- Use strict schemas and maximum request/response sizes.
- Reject arbitrary upstream URLs, OData expressions, formulas, executable
  code, resource names, project names, and descriptive text not required for
  pricing.
- Allow outbound pricing traffic only to the expected Azure endpoint.
- Redact secrets before logging or tracing and use only non-secret identifiers.
- Isolate tenant quota and idempotency records.
- Share only public price records across tenants.
- Do not receive or persist the original conversation.
- Retain replay data no longer than 24 hours and no durable architecture
  history.
- Scan dependencies and deployment artifacts.
- Document residual API-key sharing and interoperability risks.

## REQ-017 — Deliverables and operations

**Status:** Accepted

Deliver:

- two versioned MCP contracts;
- deterministic calculation core and the complete two-fixture rule cohort;
- immutable rule validation, publication, activation, and rollback;
- key lifecycle, weekly allowance, rate limiting, concurrency-safe idempotency,
  and usage metering;
- live pricing client and bounded public-price cache;
- canonical and Markdown fixtures;
- optional thin adapter only if measurements justify it;
- three-host compatibility matrix and OAuth gap assessment;
- raw benchmarks and human-readable findings;
- security, privacy, retention, and operating-cost evidence; and
- final go/no-go recommendation.

The maintainer operations guide under `docs/ops/` must cover scope,
prerequisites, deployment/rollback, rule release, key lifecycle, quota/rate
configuration, cache TTL/purge, pricing outages, observability, retention,
incidents, recovery, troubleshooting, compatibility, tests, benchmarks, and
external sources.

The final recommendation is one of: proceed to limited API-key beta; revise and
repeat a bounded experiment; pause for authentication interoperability; or
stop because the benefits do not justify the service.

Implementation pull requests target `dev`.
