---
initiative: mcp-poc
artifact: delivery
status: proposed
owner: repository maintainer
authority: [delivery]
---

# Hosted Azure Cost MCP PoC work packages

Each package is independently assignable once its dependencies are complete.
Requirements and decisions are linked rather than restated.

## WP-001 — Lock contracts, fixtures, and baseline measurements

**Status:** Proposed

**Objective:** Produce reviewed canonical fixtures, versioned MCP schemas,
measurement definitions, a v1.10 baseline, and minimal authenticated transport
spikes before domain implementation.

**Requirement references:** `REQ-002`, `REQ-004`, `REQ-005`, `REQ-006`,
`REQ-012`, `REQ-013`

**Decision references:** `ADR-001`, `ADR-002`, `ADR-006`, `ADR-007`

**Dependencies and blockers:** None.

**In scope:**

- Canonical structured forms of both complete architecture fixtures.
- Inventory of required services, dependencies, inputs, queries, formulas, and
  expected ledger lines.
- Two draft tool schemas and compact result schemas.
- Fixed normalization rules for volatile output fields.
- Fixed request, query, resource, line-item, and complex-ledger token bounds.
- v1.10 benchmark harness and baseline raw results.
- Minimal authenticated remote MCP connection tests in all three target hosts.
- Resolution or evidence plan for `OPEN-002` and `OPEN-003`.

**Out of scope:**

- Calculation-engine implementation.
- Azure production infrastructure.
- Full key, quota, or cache behaviour.
- Optional thin skill.

**Expected files or outputs:**

- Canonical fixtures and reviewed expected ledgers under `tests/`.
- Versioned contract schemas in the future MCP source tree.
- Benchmark harness and raw baseline results under `tests/` or a dedicated
  benchmark directory outside `skills/`.
- Updated [evidence register](evidence.md) and compatibility observations.

**Acceptance criteria:**

- Both canonical fixtures are reviewed against their Markdown sources.
- Exactly two schemas fit `REQ-006`.
- The event-driven response and work bounds are fixed with evidence.
- Baseline raw results are retained without secrets or prompts.
- All three hosts either complete the minimal authenticated flow or produce a
  documented gate failure.
- No unresolved question can change the product boundary.

**Validation commands:**

```bash
python3 tests/docs/validate_documentation.py
waza check
```

Add contract, fixture, and benchmark commands created by this package to its
completion evidence.

**Operational or documentation updates:**

- Update the compatibility and external evidence in `evidence.md`.
- Update contracts in `requirements.md` only if explicitly approved.

**Permitted assumptions:**

- Recorded price responses may be used for deterministic baselines.
- The repository's existing two example architectures are the fixture sources.

**Approval-required decisions:**

- Changing tool count, fixture scope, inference boundary, success gates, or
  stale-price policy.
- Selecting a host-specific workaround that introduces pricing logic.

**Completion evidence:** Pending.

## WP-002 — Build the deterministic calculation core

**Status:** Proposed

**Objective:** Implement and verify the model-free rule registry, price-query
planning, and calculation engine for the simple fixture, then the bounded rule
cohort needed by the complex fixture.

**Requirement references:** `REQ-001`, `REQ-007`, `REQ-008`, `REQ-012`,
`REQ-015`

**Decision references:** `ADR-001`, `ADR-003`, `ADR-004`, `ADR-006`

**Dependencies and blockers:** `WP-001`; `OPEN-003`.

**In scope:**

- Rule schema, stable IDs, aliases, categories, dependencies, and validation.
- Immutable checksummed rule-release loading.
- Query planning and reviewed calculation handlers.
- Complete rules for both fixture cohorts.
- Recorded-price unit, contract, ambiguity, invalid, and unsupported tests.
- Complete deterministic canonical-fixture tests.

**Out of scope:**

- HTTP/MCP transport and host interpretation.
- Authentication, quota, rate limit, and idempotency.
- Shared live cache infrastructure.
- Services not used by the two fixtures.

**Expected files or outputs:**

- Domain source modules and machine-readable cohort rules outside `skills/`.
- Unit tests and recorded API fixtures under `tests/`.
- Canonical E2E tests for both architectures.

**Acceptance criteria:**

- The simple fixture passes ten identical normalized runs before complex work.
- Both full canonical fixtures pass without omitted line items.
- Missing, ambiguous, invalid, and unsupported cases are typed and bounded.
- Rule releases are immutable, checksummed, read-only at runtime, and
  rollback-selectable.
- The core contains no model dependency, natural-language parser, or model
  credential.

**Validation commands:**

```bash
python3 tests/docs/validate_documentation.py
pwsh tests/unit/Run-PesterTests.ps1
bash tests/unit/run-bats-tests.sh
```

Replace or extend these with the implementation-specific test command and
record it in completion evidence.

**Operational or documentation updates:**

- Document rule publication and rollback inputs for the operations guide.
- Update `evidence.md` with canonical-run results.

**Permitted assumptions:**

- Only fixture-required services must be supported.
- Complex formulas may use ordinary reviewed code handlers.

**Approval-required decisions:**

- Migrating the full Markdown corpus.
- Inventing an expression language.
- Changing stable IDs or accepted fixture scope.

**Completion evidence:** Pending.

## WP-003 — Deliver the authenticated remote vertical slice

**Status:** Proposed

**Objective:** Expose the deterministic core through the two remote MCP tools
with live pricing, cache, authentication, concurrency-safe allowance, telemetry,
and the complete simple-fixture primary-host flow.

**Requirement references:** `REQ-003`, `REQ-004`, `REQ-005`, `REQ-008`,
`REQ-009`, `REQ-010`, `REQ-011`, `REQ-014`, `REQ-016`

**Decision references:** `ADR-002`, `ADR-004`, `ADR-005`, `ADR-007`, `ADR-008`,
`ADR-009`, `ADR-010`

**Dependencies and blockers:** `WP-001`, simple-fixture portion of `WP-002`,
`OPEN-001`, `OPEN-002`, `OPEN-003`, `OPEN-005`.

**In scope:**

- Thin Express/Streamable HTTP adapter and exactly two tools.
- Live Retail Prices API client, pagination, retry, normalization, and
  local/shared price caches.
- Secret-header authentication, key lifecycle operations, rate limiting,
  concurrency control, weekly allowance, and idempotent replay.
- PostgreSQL authoritative state and disposable Redis cache integration.
- Bicep/GitHub Actions deployment for the Australia East PoC.
- Key Vault and redacted Application Insights/Azure Monitor telemetry.
- Complete 3-tier flow through Claude Code.
- Failure, cache, key, quota, concurrency, redaction, and origin tests.

**Out of scope:**

- Complex fixture completion.
- Paid billing, public signup, complete OAuth, and durable estimate history.
- A third tool, server-side model, or natural-language parser.
- Multi-region or production SLA.

**Expected files or outputs:**

- Hosted service source, schemas, database migrations, and infrastructure as
  code outside `skills/`.
- Tests under `tests/`.
- Initial MCP operations guide under `docs/ops/`.
- Dated deployment cost record and simple-fixture E2E evidence.

**Acceptance criteria:**

- Authenticated simple-fixture E2E succeeds in the primary host.
- Tool and default response budgets pass.
- Live and valid-cache paths succeed; expired or invalid entries never produce
  a current estimate.
- Ten sequential and ten concurrent duplicate calls commit one usage event.
- Conflicting idempotency keys fail and allowance never becomes negative.
- Failed/rejected calls do not consume allowance.
- Secrets and prohibited payloads are absent from telemetry.
- Warm cached latency is measured against `REQ-014`.
- Direct origin bypass is prevented or the mandatory gate is explicitly failed.

**Validation commands:**

```bash
python3 tests/docs/validate_documentation.py
pwsh tests/unit/Run-PesterTests.ps1
bash tests/unit/run-bats-tests.sh
```

Add service, IaC validation, contract, integration, security, and hosted-smoke
commands introduced by the implementation.

**Operational or documentation updates:**

- Create or update the MCP operations guide required by `REQ-017`.
- Record deployment configuration, cost, and host evidence in `evidence.md`.

**Permitted assumptions:**

- Non-HA development SKUs are acceptable for the no-SLA PoC when data-loss and
  recovery behaviour are documented.
- An invite key may be represented as an Authorization Bearer credential if
  compatibility evidence supports it.

**Approval-required decisions:**

- Accepting direct origin bypass.
- Adding stale-price fallback, model inference, another tool, durable history,
  paid features, or broader service scope.
- Weakening retention, redaction, or tenant isolation.

**Completion evidence:** Pending.

## WP-004 — Complete the complex architecture slice

**Status:** Proposed

**Objective:** Extend the hosted slice to every service, dependency, meter, and
line item in the event-driven fixture while preserving bounded output.

**Requirement references:** `REQ-005`, `REQ-006`, `REQ-007`, `REQ-008`,
`REQ-012`, `REQ-014`, `REQ-015`

**Decision references:** `ADR-002`, `ADR-003`, `ADR-004`, `ADR-006`

**Dependencies and blockers:** `WP-002`, `WP-003`.

**In scope:**

- Fixture-required rule and calculation-handler completion.
- All documented workloads, data stores, backup, monitoring, private
  networking, DNS, bandwidth, and commitment parameters.
- Enforcement of the bounds fixed in `WP-001`.
- Compact summary and complete bounded ledger output.
- Canonical and primary-host Markdown E2E tests.

**Out of scope:**

- Services outside the fixture.
- Changes to fixture scope or success thresholds.
- Other host compatibility and optional adapter work.

**Expected files or outputs:**

- Remaining cohort rules, handlers, and tests.
- Complex canonical and Markdown E2E results.
- Updated response-size and cache-reuse measurements.

**Acceptance criteria:**

- The complete canonical fixture passes deterministic testing.
- Primary-host Markdown E2E succeeds.
- Summary and ledger remain within their fixed budgets.
- No fixture dependency or line item is silently omitted.
- Failures identify whether the defect is canonical engine, host conversion, or
  presentation.

**Validation commands:**

```bash
python3 tests/docs/validate_documentation.py
waza check
```

Add the implementation-specific deterministic and hosted E2E commands.

**Operational or documentation updates:**

- Update supported cohort, bounds, and troubleshooting in the operations guide.
- Record result evidence in `evidence.md`.

**Permitted assumptions:**

- Bounds and reviewed ledger from `WP-001` are authoritative.
- Only fixture-required variants must be implemented.

**Approval-required decisions:**

- Omitting or substituting a fixture resource.
- Increasing bounds without measured abuse and cost review.

**Completion evidence:** Pending.

## WP-005 — Verify host compatibility and optional thin adapter

**Status:** Proposed

**Objective:** Run both complete fixtures directly in all target hosts, document
authentication and protocol behaviour, and add a thin adapter only if evidence
shows it is needed.

**Requirement references:** `REQ-002`, `REQ-006`, `REQ-012`, `REQ-013`,
`REQ-014`

**Decision references:** `ADR-001`, `ADR-002`, `ADR-005`, `ADR-006`

**Dependencies and blockers:** `WP-004`; `OPEN-002`.

**In scope:**

- Direct tests in Claude Code, GitHub Copilot in Visual Studio Code, and Codex.
- Exact host/version, transport, header, secret storage, output, error, and
  OAuth-gap records.
- Direct-versus-thin-adapter measurements.
- Optional prompting/discovery adapter with no pricing knowledge.

**Out of scope:**

- Complete OAuth implementation.
- Host-specific pricing rules or a local calculation fallback.
- New product capabilities.

**Expected files or outputs:**

- Compatibility matrix and raw host test results.
- OAuth interoperability gap assessment.
- Optional thin adapter only when justified by measurements.
- Host connection and troubleshooting procedures in the operations guide.

**Acceptance criteria:**

- Both fixtures complete in all three hosts or a mandatory gate is explicitly
  failed with reproducible evidence.
- Each host's remote transport, secret handling, structured output, and error
  behaviour are documented.
- Any adapter improves the measured interpretation target and contains no
  pricing rule or second implementation.

**Validation commands:**

```bash
python3 tests/docs/validate_documentation.py
waza check
```

Record exact host commands and versions with the completion evidence.

**Operational or documentation updates:**

- Complete compatibility and OAuth sections of the operations guide.
- Replace `OPEN-002` with dated findings.

**Permitted assumptions:**

- Host configuration examples are starting evidence, not E2E proof.

**Approval-required decisions:**

- Requiring an adapter for the primary product path.
- Relaxing the three-host gate or adding pricing logic to an adapter.

**Completion evidence:** Pending.

## WP-006 — Run benchmarks, complete operations, and decide

**Status:** Proposed

**Objective:** Execute every pre-registered cohort, finish operations and risk
documentation, publish raw and human-readable evidence, and make the final
go/no-go recommendation.

**Requirement references:** `REQ-013`, `REQ-014`, `REQ-015`, `REQ-016`,
`REQ-017`

**Decision references:** `ADR-004`, `ADR-005`, `ADR-006`, `ADR-008`, `ADR-009`,
`ADR-010`

**Dependencies and blockers:** `WP-005`; `OPEN-004`, `OPEN-006`.

**In scope:**

- Ten-run benchmark cohorts with cold, warm, hit, miss, and failure separation.
- Context, correctness, determinism, latency, security, reliability, and
  operating-cost measurements.
- Security/failure/concurrency/quota scenarios.
- Operations, retention, recovery, compatibility, OAuth-gap, and incident
  documentation.
- Final gate table and recommendation.

**Out of scope:**

- Hiding failed gates or excluding errors/timeouts.
- Implementing paid service features.
- Expanding the experiment to fix an unfavourable result without a new bounded
  decision.

**Expected files or outputs:**

- Raw machine-readable benchmark results.
- Human-readable findings and final recommendation.
- Complete MCP operations guide under `docs/ops/`.
- Updated `evidence.md` with all findings and closed/open questions.

**Acceptance criteria:**

- Every mandatory gate has linked evidence and an explicit pass/fail result.
- Fixed and marginal costs are separated; dated prices and assumptions are
  recorded.
- Failures and timeouts remain in raw data.
- Operations guide satisfies `REQ-017`.
- Each product hypothesis is confirmed or refuted.
- The recommendation uses one of the four outcomes in `REQ-017`.

**Validation commands:**

```bash
python3 tests/docs/validate_documentation.py
pwsh tests/unit/Run-PesterTests.ps1
bash tests/unit/run-bats-tests.sh
waza check
```

Add benchmark, load, security, deployment-smoke, and recovery commands created
by earlier packages.

**Operational or documentation updates:**

- Finalize the MCP operations guide and repository entry-point links.
- Mark completed packages with immutable completion evidence.
- Mark superseded proposal artifacts historical.

**Permitted assumptions:**

- Measured evidence may refute the product hypothesis.
- No gate failure must be repaired by unapproved scope expansion.

**Approval-required decisions:**

- Changing pre-registered gates after observing results.
- Proceeding to beta despite a failed mandatory security, correctness,
  compatibility, or inference-boundary gate.

**Completion evidence:** Pending.
