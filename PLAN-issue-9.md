# Issue #9 Execution Plan: Reduce service-routing.md Token Footprint by 35%

**Issue**: https://github.com/ahmadabdalla/azure-cost-calculator-skill/issues/9
**Target**: Reduce ~8,500 tokens → ~5,525 tokens (35% reduction)
**File**: `.github/skills/azure-cost-calculator/references/service-routing.md`
**Baseline**: 365 lines / 4,164 words / 37,989 bytes

---

## Critical Constraints

- **DO NOT split the file** — single authoritative source must remain
- **DO NOT remove any of the 217 service entries** — all services stay
- **DO NOT remove the 36 non-obvious filename mappings** (acronyms like `aks.md`, simplifications like `cassandra.md`, renames like `spring-apps.md`)
- **DO NOT remove genuinely useful aliases** — acronyms (AKS, ACR, APIM), legacy names (DocumentDB, OMS), and genuinely different names must stay
- **Skill routing accuracy must be unaffected** — this is a formatting change, not a content change

---

## Agent Architecture

Spin up **5 sub-agents** that execute sequentially (Agent 1-4 transform, Agent 5 validates). Each agent receives the full issue context and operates on the file directly.

---

### Agent 1: Convert Markdown Tables to YAML (~1,700 tokens saved)

**Goal**: Replace all markdown table sections with compact YAML format.

**Instructions**:
1. Read `.github/skills/azure-cost-calculator/references/service-routing.md`
2. For each category section (Compute, Containers, Databases, etc.):
   - Replace the markdown table with a YAML block inside a fenced code block (```yaml)
   - Use this compact schema per entry:
     ```yaml
     - s: "Virtual Machines"           # API serviceName (exact, case-sensitive)
       f: "virtual-machines.md"        # filename (ONLY for non-derivable names — the 36 exceptions)
       a: [VMs, VMSS, Dedicated Host]  # aliases (non-trivial only — see Agent 2's rules)
     ```
   - For entries where the filename IS derivable (83.4% of entries), **omit the `f:` field entirely**
   - Keep the `s:` field always (it's the primary key)
   - Keep the `a:` field only when there are non-trivial aliases remaining after Agent 2's pruning
3. Add a single derivation rule at the top of the file:
   ```
   Filename convention: strip "Azure"/"Microsoft" prefix → kebab-case → .md
   Example: "Azure Data Factory" → data-factory.md
   Only entries with explicit `f:` field deviate from this convention.
   ```
4. Remove all markdown table formatting (pipe chars `|`, separator rows `---`, alignment padding)
5. Keep all section headers (`## Compute`, `## Containers`, etc.) — just replace the table under each
6. Remove section description lines (e.g., "Services billed primarily on compute hours..." — they add ~100 tokens and zero routing value)

**What IS derivable** (omit `f:`): "Azure Data Factory" → `data-factory.md`, "Application Gateway" → `app-gateway.md` — drop Azure/Microsoft, kebab-case the rest.

**What is NOT derivable** (keep `f:`): These 36 exceptions — the filename doesn't match the kebab-case of the serviceName:
- `Azure Kubernetes Service` → `aks.md` (acronym)
- `Azure Container Apps` → `container-apps.md` (dropped "Azure")  
- `Azure Managed Instance for Apache Cassandra` → `cassandra.md` (simplified)
- `Azure Spring Cloud` → `spring-apps.md` (renamed)
- `Azure Active Directory B2C` → `aad-b2c.md` (acronym)
- etc. — Agent 1 must identify ALL 36 by testing each serviceName against the derivation rule

**Validation check**: Count entries before and after — must remain exactly 217.

---

### Agent 2: Prune Self-Referencing Aliases (~650 tokens saved)

**Goal**: Remove aliases that are trivially derivable from the serviceName.

**Instructions**:
1. Read the file (now in YAML format from Agent 1)
2. For each service entry, remove aliases that match these self-referencing patterns:
   - **±Azure/Microsoft prefix**: if serviceName is "Azure X", remove alias "X". If serviceName is "X", remove alias "Azure X" or "Microsoft X"
   - **Exact match**: alias that is identical to serviceName
   - **Trivial restatement**: alias that is just the serviceName with minor word reordering
3. **KEEP these alias types** — they are NOT self-referencing:
   - Acronyms: AKS, ACR, APIM, VMs, VMSS, ANF, ADX, ASR, etc.
   - Legacy names: DocumentDB, OMS, Azure AD, AAD
   - Genuinely different names: "Kubernetes", "K8s", "Postgres", "Redis"
   - Portal-specific names that differ substantively
   - Common shorthand: "App Service Plan" → "ASP"
4. If removing all self-referencing aliases leaves an entry with zero aliases, omit the `a:` field entirely
5. Document the count: how many aliases removed vs kept

**Examples of removals**:
- `Azure Batch` has alias `Batch` → REMOVE (trivial ±Azure)
- `Azure NetApp Files` has alias `Azure NetApp` → REMOVE (substring of serviceName)
- `Key Vault` has alias `Azure Key Vault` → REMOVE (trivial +Azure)

**Examples of keeps**:
- `Azure Kubernetes Service` has alias `AKS` → KEEP (acronym)
- `Azure Cosmos DB` has alias `DocumentDB` → KEEP (legacy name)
- `Log Analytics` has alias `OMS` → KEEP (legacy name)

---

### Agent 3: Condense Note Blocks (~800 tokens saved)

**Goal**: Consolidate 12 verbose multi-sentence note blocks into terse annotations.

**Instructions**:
1. Read the file
2. Identify all 12 `> **Note**` blocks
3. Extract the **recurring patterns** that appear across multiple notes:
   - `serviceFamily eq 'X'` routing hints (appears in ~8 notes) → consolidate into a single top-level note
   - `separate serviceName` guidance (appears in ~5 notes) → consolidate
   - `Reference files should` instructions (appears in ~2 notes) → consolidate
4. Create ONE compact top-level guidance block (max 3-4 lines) after the derivation rule:
   ```
   ## Routing Notes
   - Some services share a serviceName; use productName filters (Storage, Managed Disks, Data Lake)
   - serviceFamily in API may differ from category here (e.g., Event Hubs → IoT, APIM → Developer Tools, Sentinel → Management). Always use the category listed in this file.
   - Services with no retail meter (Policy, Advisor, Cost Mgmt) still need reference files to document that fact.
   ```
5. For section-specific notes that contain **unique, non-repeated information**, condense to a single terse line (max 15 words) as a YAML comment within that section. Example:
   - Original: "Azure OpenAI Service and Azure AI Services may appear under `Foundry Models`..." 
   - Condensed: `# OpenAI/AI Services may appear as Foundry Models/Tools in newer API responses`
6. Delete all original `> **Note**` blocks after consolidation

**Key principle**: If the information appears in 3+ notes, it goes in the top-level block. If it's section-unique, it becomes a terse inline comment. If it's obvious to any Azure practitioner, delete it.

---

### Agent 4: Final Cleanup & Measurement

**Goal**: Measure final token count, apply any remaining optimizations, verify structure.

**Instructions**:
1. Read the final file
2. Measure:
   - Line count (target: <240)
   - Word count (target: <2,700)
   - Byte count (target: <24,700 — 35% reduction from 37,989)
   - Estimate token count using: `bytes ÷ 4` method → target <6,175; `words × 1.3` method → target <3,510. Average of methods should be ≤5,525.
3. If target not met, apply these additional micro-optimizations:
   - Shorten any remaining verbose alias lists (keep max 4 most-useful aliases per entry)
   - Remove any whitespace padding in YAML
   - Use shorter section headers if possible (e.g., `## AI + ML` → `## AI/ML`)
4. Run `wc -l -w -c` on the final file and report the metrics
5. Create a summary comment on the file showing:
   - Before/after metrics
   - Number of entries (must be 217)
   - Number of exception filenames preserved (must be 36)
   - Number of aliases before/after pruning

---

### Agent 5: Validation & Acceptance Criteria Verification

**Goal**: Verify ALL acceptance criteria from the issue are met. This agent is the quality gate — it must be thorough.

**Instructions**:

1. **Token count reduced by >= 35%**
   - Run `wc -l -w -c` on the original and new file
   - Calculate: `(original_bytes - new_bytes) / original_bytes * 100`
   - Calculate token estimates using both methods
   - PASS if reduction >= 35%

2. **All 217 service entries preserved**
   - Parse the YAML and extract all `s:` values
   - Compare against the original 217 serviceName values extracted from the markdown tables
   - PASS if exact 1:1 match (no additions, no deletions, no typos)
   - Script approach:
     ```bash
     # Extract original serviceNames from git history
     git show HEAD:".github/skills/azure-cost-calculator/references/service-routing.md" | \
       grep -oP '^\| [^|]+' | sed 's/^| //' | sed 's/ *$//' | \
       grep -v '^---' | grep -v '^API serviceName' | sort > /tmp/original_services.txt
     
     # Extract new serviceNames from YAML
     grep '  - s: ' service-routing.md | sed 's/.*s: "//' | sed 's/".*//' | sort > /tmp/new_services.txt
     
     diff /tmp/original_services.txt /tmp/new_services.txt
     ```

3. **All 36 non-obvious filename mappings preserved**
   - Extract all entries that have an explicit `f:` field
   - Verify there are exactly 36 (or the validated count from Agent 1)
   - Spot-check 10 of them against the original file:
     - `aks.md` for Azure Kubernetes Service
     - `cassandra.md` for Azure Managed Instance for Apache Cassandra
     - `spring-apps.md` for Azure Spring Cloud
     - `aad-b2c.md` for Azure Active Directory B2C
     - `openshift.md` for Azure Red Hat OpenShift
     - `service-fabric.md` for Service Fabric Mesh
     - `postgresql-flexible.md` for Azure Database for PostgreSQL
     - `openai.md` for Azure OpenAI Service
     - `private-5g-core.md` for Private Mobile Network
     - `advanced-cni.md` for Advanced Container Networking Services

4. **All non-trivial aliases preserved**
   - Verify these specific aliases exist in the new file:
     - AKS, ACR, APIM, VMs, VMSS, ACI
     - DocumentDB (under Cosmos DB)
     - OMS (under Log Analytics)
     - Kubernetes, K8s (under AKS)
     - AAD, Azure AD (under identity services)
     - DMS, ASR, ADX, ADF
   - Count total aliases before/after and verify reduction is ~28-32% (matching the self-referencing ratio)

5. **Validation scripts pass**
   - Run the existing `scripts/Validate-ServiceReference.ps1` if it references service-routing.md
   - If the validation script only validates individual service .md files (not the routing map), note this as N/A

6. **Skill routing accuracy spot-check**
   - For each of these 12 services, verify the YAML entry has:
     - Correct serviceName (case-sensitive exact match)
     - Correct category/section placement
     - At least the essential aliases
   - Services to check:
     1. Virtual Machines (Compute)
     2. Azure Cosmos DB (Databases)
     3. Azure Kubernetes Service (Containers → should be Compute)
     4. Application Gateway (Networking)
     5. Azure OpenAI Service (AI/ML)
     6. Event Hubs (IoT)
     7. Service Bus (Integration)
     8. Azure Monitor (Monitoring)
     9. Sentinel (Management — NOT Security)
     10. Azure Active Directory B2C (Identity)
     11. Container Instances (Containers)
     12. Azure Data Factory (Analytics)

7. **Structural integrity**
   - Verify all 18 category sections are present
   - Verify the derivation rule is at the top
   - Verify the consolidated routing notes block exists
   - Verify the YAML is valid (no syntax errors)
   - Run: `python3 -c "import yaml; yaml.safe_load(open('service-routing.md').read())"` — note this won't work directly since it's mixed markdown+YAML, so instead extract each YAML block and validate individually

8. **If ANY check fails**: 
   - Document exactly what failed
   - Fix it directly (do not just report)
   - Re-run the failed check to confirm the fix
   - Only mark the acceptance criterion as passed after the fix is verified

---

## Execution Order

```
Agent 1 (Tables → YAML + filename derivation) 
  → Agent 2 (Prune self-referencing aliases)
    → Agent 3 (Condense note blocks)
      → Agent 4 (Cleanup + measurement)
        → Agent 5 (Validation — quality gate)
```

Each agent should:
1. Read the file at the start of their work
2. Make changes
3. Run `wc -l -w -c` to measure progress
4. Commit or save their changes before handing off

## Token Efficiency Strategy

The approach is layered for maximum token savings with minimum risk:

| Technique | Est. Savings | Risk |
|---|---|---|
| Markdown tables → YAML | ~1,700 tokens | Low — YAML is native to LLMs |
| Remove self-referencing aliases | ~650 tokens | Low — no routing information lost |
| Condense note blocks | ~800 tokens | Low — information consolidated, not deleted |
| Remove derivable filenames | ~400 tokens | Low — derivation rule provided |
| Remove section descriptions | ~100 tokens | None — zero routing value |
| **Total** | **~3,650 tokens** | **42% reduction** (exceeds 35% target) |

## Files Referenced

- `.github/skills/azure-cost-calculator/references/service-routing.md` — **primary target**
- `.github/skills/azure-cost-calculator/SKILL.md` — references service-routing.md (read-only, no changes needed)
- `.github/skills/azure-cost-calculator/references/shared.md` — references service-routing.md (read-only, no changes needed)
- `.github/skills/azure-cost-calculator/scripts/Validate-ServiceReference.ps1` — validation script (may need format-aware updates)

## Success Criteria Summary

| Criterion | Measurement |
|---|---|
| ≥35% token reduction | `wc` metrics + token estimation |
| 217 services preserved | Automated diff against original |
| 36 filename exceptions preserved | Count `f:` fields in YAML |
| Non-trivial aliases preserved | Spot-check 15+ known acronyms/legacy names |
| Validation scripts pass | Run existing scripts |
| Routing accuracy | Manual spot-check 12 services across categories |
