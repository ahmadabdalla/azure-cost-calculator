# Azure Cost Calculator — Usage Guide

Write prompts that produce deterministic cost estimates. A/B testing showed vague prompts cause $9K–$131K variance; fully-specified prompts produced 0% variance across 32 agent runs.

## Architect's Quick Start

### Platform Invocation

| Platform        | How to invoke                                                 | Notes                                                                         |
| --------------- | ------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| **Claude Code** | `/estimate-cost <description or @file>`                       | Slash command — runs in forked context                                        |
| **Copilot CLI** | `@cost-analyst estimate the costs for <description or @file>` | Address the agent directly — CLI does not support slash commands from plugins |

Both methods invoke the same **cost-analyst** agent and follow the same workflow. Invocation syntax differs by platform, and output phrasing/token usage may vary slightly.

**Step 1: Identify your architecture pattern**

| Pattern              | Key Cost Drivers                                                   |
| -------------------- | ------------------------------------------------------------------ |
| Lift-and-shift VMs   | VM SKUs, managed disks, AHUB licensing, RI commitment              |
| SQL modernization    | SQL MI tier/vCores, storage per instance, AHUB, zone redundancy    |
| Hub-spoke networking | Firewall SKU, data processed, VPN/ExpressRoute, Private Endpoints  |
| SIEM/Security        | Sentinel ingestion volume, Defender plan, Key Vault HSM            |
| DR/BCDR              | Site Recovery VM count, SQL failover groups, geo-redundant storage |

**Step 2: Group by environment tier**

| Environment  | Commitment Strategy | Rationale                                    |
| ------------ | ------------------- | -------------------------------------------- |
| Production   | 3-Year RI           | Maximum savings for predictable workloads    |
| Pre-prod/UAT | 1-Year RI or PAYG   | Shorter commitment for changing requirements |
| Dev/Test     | PAYG or Spot        | No commitment for ephemeral workloads        |

**Step 3: State what you know — if no SKU, describe requirements**

```
Production (Australia East, AUD, 3-Year RI):
- 10× D4s_v5 VMs, Windows Server, AHUB enabled
- 5× SQL MI General Purpose Gen5 8 vCores, 500 GB storage each, SQL AHUB
- 100 TB Blob Storage, Hot tier, LRS

Dev/Test (Australia East, AUD, PAYG):
- 5× B4ms VMs, Linux — need 16 GB RAM, 4 cores for CI runners
- Or if unsure: "Need VMs with 64 GB RAM, 8 cores, 10K IOPS — recommend SKU"
```

The agent performs a **Specification Review** before pricing — verifying inputs and disclosing defaults.

## Required Parameters by Category

| Category         | Must Specify                                             | Omission Impact      |
| ---------------- | -------------------------------------------------------- | -------------------- |
| **VMs**          | SKU (e.g., D4s_v5), OS, count, AHUB yes/no, RI/PAYG      | AHUB: +$9K–$115K     |
| **SQL MI**       | Tier (GP/BC), Gen, vCores, storage GB/instance, AHUB, ZR | Storage: +$30K–$63K  |
| **SQL Database** | Tier, vCores or DTUs, max storage GB, AHUB               | Tier: ±$20K+         |
| **Storage**      | Redundancy (LRS/ZRS/GRS), tier (Hot/Cool), capacity GB   | GRS vs LRS: 2×       |
| **Sentinel**     | Pricing model (PAYG/commitment), daily ingestion GB      | PAYG override: ~$57K |
| **Defender**     | Plan (P1/P2), server count                               | Plan: ~50% swing     |
| **Networking**   | SKU, capacity units, data processed GB/month             | SKU: 3–10×           |
| **Key Vault**    | Tier (Standard/Premium), ops/month, HSM key count        | Premium+HSM: 5×+     |

Always specify: **region** and **currency**.

## Good vs Bad Examples

| Category | ❌ Bad                            | ✅ Good                                              | Variance  |
| -------- | --------------------------------- | ---------------------------------------------------- | --------- |
| Database | "Some SQL MI with Hybrid Benefit" | "30× SQL MI BC Gen5 8 vCores, 512 GB each, SQL AHUB" | $131K     |
| Compute  | "Windows VMs with AHUB"           | "80× D4s_v5 Windows, AHUB, PAYG"                     | $9K–$115K |
| Security | "Sentinel for SIEM"               | "Sentinel: 500 GB/day, PAYG"                         | ~$57K     |

## Pre-flight Checklist

- [ ] **Region** stated (e.g., `Australia East`, `UK South`, `East US`)
- [ ] **Currency** stated (e.g., `AUD`, `GBP`, `USD`)
- [ ] Every service has a **SKU or tier**
- [ ] **Instance/resource counts** explicit for every line item
- [ ] **Storage capacity** in GB for databases and storage accounts
- [ ] **AHUB** explicitly yes/no for each Windows or SQL resource
- [ ] **Commitment type** per resource: PAYG, 1-Year RI, or 3-Year RI
- [ ] **Zone redundancy** scoped to specific instances
- [ ] **Sentinel pricing model** stated: PAYG or commitment tier
- [ ] **DR topology** clear: which resources replicate, to which region
- [ ] **Environment tier strategy** (Prod/Non-Prod/Dev) with commitment per tier

## Strategic Do's and Don'ts

| ✅ DO                                                                            | ❌ DON'T                                                                |
| -------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Separate environments into distinct sections (different commitment strategies)   | Apply 3-Year RI to Dev/Test environments                                |
| State licensing position up front (EA/CSP with core counts, not just "AHUB yes") | Mix primary and DR costs in one flat list                               |
| Specify DR topology explicitly (active-active vs warm standby vs cold DR)        | Just say "migrate 400 VMs" — tier by workload, OS, sizing               |
| Request comparative scenarios ("SQL MI vs SQL DB — give me both")                | Assume AHUB applies universally — it's constrained by license inventory |

## Ambiguity Traps (by Dollar Impact)

| Trap                       | Variance  | Fix                               |
| -------------------------- | --------- | --------------------------------- |
| AHUB method unspecified    | $9K–$115K | State "AHUB enabled" per service  |
| SQL MI storage omitted     | $30K–$63K | "X GB storage per instance"       |
| Sentinel tier vague        | ~$57K     | "PAYG" or "X GB/day commitment"   |
| Zone redundancy scope      | ±$30K     | "ZR on primary BC instances only" |
| SQL DB vs SQL MI confused  | ±$20K+    | Use exact service name            |
| Storage redundancy missing | up to 2×  | Always specify LRS/ZRS/GRS        |
| Companion services omitted | varies    | See Hidden Dependencies below     |

## Hidden Cost Dependencies

These services bill companion components separately — include them or the estimate is incomplete:

| Service                 | Also Include                      | Why                                    |
| ----------------------- | --------------------------------- | -------------------------------------- |
| SQL MI                  | Storage (per-GB)                  | Storage billed separately from compute |
| AKS                     | VMs, Load Balancer, Managed Disks | Node pool compute billed as VMs        |
| App Service             | App Service Plan                  | Plan is the compute layer              |
| Azure Firewall          | Public IP, data processing        | Each component billed separately       |
| Application Gateway     | Capacity Units, data processed    | Base + consumption billing             |
| Site Recovery           | Storage replication               | Replicated data storage costs          |
| Azure Backup            | Protected instance fee + storage  | Two billing components                 |
| Virtual Network Gateway | Per-tunnel charges, data egress   | S2S/P2S tunnels billed per connection  |
| Private Endpoints       | Per-endpoint + data processed     | Inbound and outbound data charges      |

## DR Topology Cost Patterns

Your disaster recovery strategy dramatically affects costs. State it explicitly in your prompt:

| Strategy                | Compute in DR     | Storage in DR | Cost vs Primary | Typical RTO |
| ----------------------- | ----------------- | ------------- | --------------- | ----------- |
| Active-Active           | 100%              | 100%          | ~100%           | <1 min      |
| Warm Standby            | 50% (scaled down) | 100%          | ~30–60%         | Minutes     |
| Cold DR (Site Recovery) | 0% standing       | Replica only  | ~5–15%          | Hours       |
| Backup Only             | 0%                | GRS backup    | ~3–5%           | Hours–Days  |

**Critical billing notes:**

- SQL MI failover groups bill secondary compute even when passive — this is "warm standby" cost
- SQL DB geo-replication bills the readable secondary at full compute rate
- Site Recovery charges per protected VM + replica storage, but no standing compute
- GRS storage replication is built into the redundancy tier — no separate DR cost

## How the Agent Works

The agent analyzes your prompt and presents a **Specification Review** — what it found, what's missing, and defaults it will use. Review before pricing runs.

**Refine with specific follow-ups:**

| ✅ Good Follow-ups                              | ❌ Bad Follow-ups            |
| ----------------------------------------------- | ---------------------------- |
| "Switch all VMs to 3-year RI"                   | "Make it cheaper"            |
| "Add zone redundancy to the 8 BC instances"     | "Add some redundancy"        |
| "Change Sentinel to 400 GB/day commitment tier" | "Use a better Sentinel tier" |
| "Remove the DR region"                          | "Change stuff"               |

## Reference Architectures

Well-specified architecture prompts follow a consistent pattern: group by environment tier, specify every SKU/count/storage parameter, state licensing and commitment strategy per tier, and separate DR resources from primary. See the [Good vs Bad Examples](#good-vs-bad-examples) and [Architect's Quick Start](#architects-quick-start) sections above for structural guidance.

Complete example architectures are available in [`references/examples/`](references/examples/):

| Example                                                                   |
| ------------------------------------------------------------------------- |
| [3-Tier Web App](references/examples/3-tier-web-app.md)                   |
| [Event-Driven Serverless](references/examples/event-driven-serverless.md) |
| [Data Analytics Platform](references/examples/data-analytics-platform.md) |

Each example is a self-contained architecture prompt ready to paste into the agent. They demonstrate the fully-specified format that produces deterministic results (0% cost variance across paired runs).
