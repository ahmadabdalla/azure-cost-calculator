# Option B+ — YAML Schema Expansion Plan

> Issue: #157 — Explore expanding YAML front matter to improve token efficiency
> Branch: `feature/157-yaml-schema-expansion`
> Status: Schema design phase — no code changes until schema is validated

---

## Goal

Reduce average token consumption by ≥5% per estimation run by expanding YAML front matter with structured metadata that enables smarter agent routing. No script or validation changes until functional requirements are validated through A/B testing.

## Philosophy

YAML describes **what kind of service this is** (routing, classification, capabilities), not **how to price it** (meters, formulas, traps). Token savings come from agents making smarter routing decisions upfront — skipping irrelevant sections, avoiding unnecessary API calls, and reading only what's needed based on front matter signals.

---

## Phase 1 — Schema Design

### Proposed Schema (Option B+)

```yaml
---
# ── Identity (existing, unchanged) ────────────────────────
serviceName: Virtual Machines                                    # required — exact API value
category: compute                                                # required — folder name enum
aliases: [VMs, VM, VMSS, VM Scale Sets]                          # required — search index

# ── Billing Graph (existing, unchanged) ───────────────────
billingNeeds: [Managed Disks]                                    # optional
billingConsiderations: [Reserved Instances, Spot, Azure Hybrid Benefit]  # optional

# ── NEW: API Identity ────────────────────────────────────
apiServiceName: Specialized Compute                              # optional — only when API serviceName ≠ display serviceName
                                                                 #   e.g., VMware Solution, Static Web Apps, AI Services
                                                                 #   omit if identical to serviceName

# ── NEW: Pricing Profile ─────────────────────────────────
primaryCost: "Compute hours × 730 × instanceCount"              # required — one-line billing summary (max 120 chars)
                                                                 #   moves from bold markdown line to YAML
                                                                 #   batch mode reads this from frontmatter directly

hasMeters: true                                                  # optional — default: true
                                                                 #   false for API-unavailable services
                                                                 #   (Management Groups, DDoS Protection, Entra ID partial)

pricingRegion: regional                                          # optional — default: regional
                                                                 #   enum: regional | global | empty-region | api-unavailable
                                                                 #   drives region parameter in API queries

hasKnownRates: false                                             # optional — default: false
                                                                 #   true when file has Known Rates table
                                                                 #   (manual pricing for API-unavailable services)

# ── NEW: Service Capabilities ─────────────────────────────
hasFreeGrant: false                                              # optional — default: false
                                                                 #   true when service has free tier or included units
                                                                 #   signals agent to look for grant deduction logic

privateEndpoint: false                                           # optional — default: false
                                                                 #   boolean only — tier restrictions stay in Notes section
                                                                 #   enables cross-service PE cost aggregation
---
```

### Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Required vs optional | **Optional with defaults** (except `primaryCost`) | Avoids 65-file migration for every future field addition |
| `billingModel` enum | **Deferred** | >30% of services map to `composite` catch-all, destroying routing signal. Revisit after consumer changes exist |
| `privateEndpoint` type | **Boolean** | Tier restrictions are prose-heavy and variable; they belong in Notes. Boolean answers the PE audit question |
| `apiServiceName` | **Included** (from Option A) | Fills a real gap — display name ≠ API name for ~5-10 services |
| `primaryCost` | **Included, required** | Strongest unique field — machine-queryable billing summary moves from body to YAML |
| `hasKnownRates` | **Included** (from Option A) | Correlates with `hasMeters: false` but captures the 2 extra cases (Communication Services, DevOps) |
| `crossServiceNames` | **Deferred** | Overlaps with `billingNeeds`; subtle distinction confuses contributors |
| Default elision | **Omit when matching default** | Minimizes author burden; only exceptions are explicit |

### Fields NOT Included (and why)

| Field | Source | Why deferred |
|-------|--------|-------------|
| `billingModel` / `pricingModel` | Both options | Ambiguity problem: >30% → `composite`. No routing consumer exists yet |
| `crossServiceNames` | Option A | Overlaps with `billingNeeds`; semantic distinction is confusing |
| `regionType` (2-value) | Option A | Superseded by `pricingRegion` (4-value) from Option B |

### Line Budget Impact

| Scenario | Current YAML lines | B+ YAML lines | Delta |
|----------|:--:|:--:|:--:|
| Minimal (all defaults) | 5-6 | 7-8 | +2 |
| Typical (some optional) | 6-7 | 9-11 | +3-4 |
| Full (all fields) | 7-8 | 13-15 | +6-7 |

> **Open question:** Should the 100-line cap be raised to 105 to accommodate? Or should YAML not count? Decision deferred until A/B results are in.

---

## Phase 2 — Prototype on Candidate Services

Apply the schema to 6 candidate files covering all archetypes. These files will be modified on this branch for A/B testing.

### Candidate Services

Focus: **bulky files near or at the 100-line cap** — these are the ones where schema expansion creates real pressure and real opportunity.

| # | Service | File | Lines | Archetype | Why chosen |
|---|---------|------|:-----:|-----------|------------|
| 1 | Virtual Machines | `compute/virtual-machines.md` | 90 | Standard hourly | Highest-traffic, RI/AHUB/Spot complexity |
| 2 | Azure SQL Database | `databases/sql-database.md` | 82 | Hourly + tiered | Multi-tier, RI, geo-replication |
| 3 | Storage (Blob) | `storage/storage.md` | 90 | Per-GB + tiered | Per-GB billing, PE support, complex tiers |
| 4 | Azure Functions | `compute/functions.md` | 93 | Composite + free grant | Multi-plan, free tier, cross-billing (App Service) |
| 5 | Redis Cache | `databases/redis-cache.md` | 99 | Hourly + RI | At the cap (99 lines), RI, multiple tiers |
| 6 | App Service | `compute/app-service.md` | 73 | Fixed hourly | RI, PE tier-restricted, plan SKU complexity |
| 7 | Private Link | `networking/private-link.md` | 77 | Global / PE pricing | Global region, PE-specific billing |

### What changes per file

For each candidate:
1. Add new YAML fields per schema above
2. Remove the bold `**Primary cost**` line from body (moved to `primaryCost` YAML field)
3. No other markdown body changes
4. Record before/after token counts

---

## Phase 3 — A/B Testing Plan

### Objective

Validate that the schema expansion achieves ≥5% token reduction in a real estimation run by comparing identical prompts against `main` (current format) and this branch (B+ format).

### Test Architecture — "Startup SaaS Platform"

A deliberately diverse architecture that exercises all 7 candidate archetypes, focusing on bulky services near the 100-line cap:

```
Architecture: Multi-tier SaaS platform on Azure (East US)

Components:
- 4× Standard_D4s_v5 VMs (Linux) for backend API tier
  - Reserved Instances (1-Year)
  - Each with P30 managed disk
- 1× App Service Plan (Premium v3 P1v3) for web frontend
  - 3 instances (auto-scale)
  - Reserved Instance (1-Year)
- Azure SQL Database — General Purpose, 8 vCores, 500 GB
  - Geo-replication to West US 2
  - Reserved Instance (3-Year)
- Azure Cache for Redis — Premium P1 (6 GB)
  - 2 replicas, clustering enabled
  - Reserved Instance (1-Year)
- 2× Storage Accounts (LRS)
  - Hot tier, 5 TB blob storage each
  - 10 million read + 1 million write operations/month
  - Private endpoints enabled
- Azure Functions — Consumption plan
  - 5 million executions/month, 256 MB memory, 500ms avg duration
- 8 private endpoints total (PaaS only:
  2× Storage, 1× SQL, 1× Redis, 1× Functions,
  1× App Service, 1× Key Vault, 1× ACR)
  - 5 Private DNS zones
```

This scenario forces the agent to:
- Read Virtual Machines (hourly × 730, RI, managed disk dependency) — 90 lines
- Read App Service (fixed hourly, RI, PE tier-restricted) — 73 lines
- Read SQL Database (vCore pricing, geo-replication, RI) — 82 lines
- Read Redis Cache (hourly, RI, tiers, clustering) — 99 lines ⚠️ at cap
- Read Storage (per-GB tiered, operations, PE) — 90 lines
- Read Functions (consumption with free grant deduction) — 93 lines
- Read Private Link (global region, PE + DNS zone pricing) — 77 lines

### Test Protocol

1. **Baseline measurement (main branch)**
   - Run the test architecture prompt against `main` branch service files
   - Record: total tokens consumed, per-service token breakdown, API calls made, total cost estimate
   - Run twice for consistency check

2. **Candidate measurement (this branch)**
   - Apply schema changes to 6 candidate files
   - Run identical prompt against modified files
   - Record same metrics
   - Run twice for consistency check

3. **Comparison metrics**

   | Metric | Target | How measured |
   |--------|--------|-------------|
   | Total input tokens | ≥5% reduction | Token counter on service ref content |
   | Cost estimate accuracy | ±2% vs baseline | Compare line items |
   | API calls made | Same or fewer | Count script invocations |
   | Free grant correctly deducted | Yes | Check Functions line item |
   | No-meter service skipped API | Yes | Check Management Groups |
   | Global region handled | Yes | Check Private Link query |

4. **Token counting method**
   - Use `tiktoken` (cl100k_base) to count tokens in each service reference file before/after
   - Measure full-file token count AND lines-1-to-45 token count (batch mode window)
   - Record the delta per file and in aggregate across the 7 candidates
   - Total candidate lines today: 604 (90+82+90+93+99+73+77) — target ≤574 after changes

### A/B Test Prompt (to be placed in `prompts/`)

The prompt will be a vanilla estimation request using the architecture above, with NO hints about the schema change. The agent should produce identical results regardless of which branch's files it reads. The only difference should be token efficiency.

---

## Phase 4 — Schema Refinement

Based on A/B results:
- If ≥5% reduction achieved → finalize schema, proceed to Phase 5
- If <5% reduction → analyze where tokens are spent, consider:
  - Adding `billingModel` if routing savings justify it
  - Compressing meter tables (the 44% structural redundancy)
  - More aggressive `primaryCost` usage to skip body sections
- Document any schema adjustments and re-test

---

## Phase 5 — Migration & Tooling (future — after schema is validated)

> **Not started until Phases 1-4 are complete and we're comfortable with the schema.**

1. Update `Validate-ServiceReference.ps1` to handle new YAML fields
2. Update `docs/TEMPLATE.md` with new schema
3. Update `CONTRIBUTING.md` with field definitions
4. Migrate remaining ~65 files (incremental, by category)
5. Update `SKILL.md` batch mode to exploit metadata for routing

---

## Parking Lot (decisions deferred)

- [ ] Should 100-line cap be raised to 105?
- [ ] Should `billingModel` be added in v2?
- [ ] Should `crossServiceNames` be added for multi-serviceName services?
- [ ] Should `primaryCost` have a max character limit?
- [ ] How should SKILL.md batch mode change to exploit the new metadata?
- [ ] Can we get >5% savings by also compressing meter tables in YAML?

---

## Success Criteria

| Criterion | Threshold |
|-----------|-----------|
| Token reduction (7-file aggregate) | ≥5% |
| Cost estimate accuracy | ±2% vs baseline per line item |
| No regression in API call correctness | 0 failures |
| Schema is additive (no breaking changes) | All existing files pass current validation on main |
| Contributors can fill new fields without training | Fields are self-evident from names + template |
