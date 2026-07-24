---
project_name: Hosted Azure Cost MCP PoC
run_id: 2026-07-24_mcp-poc-plan-sample-01
mode: sample
status: complete
decided: 2026-07-24
interview_duration: null

interviewer_model: "[[models/gpt-5]]"
interviewee_model: "[[models/human-engineer]]"
interviewer_runtime: "[[runtimes/codex]]"
interviewee_runtime: "[[runtimes/codex-user]]"
---

## Project Overview

| Question                  | Answer                                                                                                                                                                                                                                                                                        |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| What are you building     | A proof-of-concept remote MCP for the Azure Cost Calculator plugin in this repository.                                                                                                                                                                                                        |
| Customer profile          | solo founder                                                                                                                                                                                                                                                                                  |
| Decision-making authority | self                                                                                                                                                                                                                                                                                          |
| Platforms                 | Remote MCP for Claude Code (primary), GitHub Copilot in VS Code, and Codex.                                                                                                                                                                                                                   |
| Audience and scale        | Five initial invitees, each an Azure architect or consultant, with the key system designed to distribute and govern N invite-specific credentials.                                                                                                                                            |
| Public or private         | Publicly reachable HTTPS MCP endpoint with private, invite-only access enforced by individual API keys.                                                                                                                                                                                       |
| Data shape                | Structured operational records: invite and API-key metadata, per-key limits and quota counters, usage events, idempotency and short-lived replay state, immutable rule releases, and cached public prices. No user file or media uploads.                                                     |
| Real-time updates         | None; no live cross-user or cross-client updates are required.                                                                                                                                                                                                                                |
| AI features               | None in the hosted MCP; natural-language interpretation and all model inference remain in the user's agent host.                                                                                                                                                                              |
| Accounts                  | PoC access uses a 1:1 invitee-to-principal mapping with an individually governed API key for each of N invitees, per-key controls, and no login flow or OAuth. Key-management behavior is part of the PoC. The design must allow later user/OAuth support without a wholesale rearchitecture. |
| Constraints               | Deploy to an Azure region in Australia and create the required infrastructure as part of the PoC. Keep cost low, but choose components that can be extended or scaled through configuration and SKU upgrades where applicable, avoiding a later throwaway rearchitecture.                     |
| External systems          | Azure Retail Prices API only; no outbound email, SMS, or push notifications.                                                                                                                                                                                                                  |

## Recommended Stack

| Layer       | Choice       | Rationale                                                                                                                                                                      |
| ----------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `frontend`  | n/a          | No user-facing UI is in scope; clients interact through MCP hosts.                                                                                                             |
| `backend`   | `express`    | First-party MCP Streamable HTTP integration with a thin TypeScript transport shell and independently structured domain modules.                                                |
| `database`  | `postgresql` | Azure Database for PostgreSQL Flexible Server provides managed relational durability and an in-place Azure scaling path; Azure Managed Redis handles shared ephemeral caching. |
| `storage`   | n/a          | No file, image, document, or durable architecture-object storage is in scope.                                                                                                  |
| `ai`        | n/a          | The hosted MCP performs no semantic search, RAG, or conversational AI.                                                                                                         |
| `inference` | n/a          | The hosted MCP makes zero model-provider calls; inference remains with the client host.                                                                                        |
| `auth`      | n/a          | No user account or login system is in scope; invitee API-key validation remains a backend boundary.                                                                            |

## Decision Details

### frontend

N/A (No user-facing UI is in scope; clients interact through MCP hosts.)

### backend

**Choice:** `express`

**Why this:** The official MCP TypeScript SDK v1.x provides first-party Express middleware, Streamable HTTP support, host-header validation, and authorization resource-server helpers. Express can remain a thin transport shell while pricing, validation, quota, idempotency, and caching logic live in framework-independent TypeScript modules. This keeps the PoC small and leaves a direct path from API-key middleware to standards-based OAuth without replacing the domain architecture.

**Alternatives considered:** `nestjs` for stronger enforced application structure; `hono` for another first-party MCP adapter with a smaller cross-runtime surface; `fastify` for a lightweight, performance-focused API.

**Tradeoff accepted:** Express does not enforce module boundaries, so the project must establish and test those boundaries itself. In return, it uses the MCP SDK's supported integration directly and avoids framework-specific ceremony in a two-tool PoC.

**Assumptions:** [layer] [customer-confirm] Use the currently supported production MCP TypeScript SDK for the PoC rather than a pre-release SDK; at the time of this interview that means v1.x, which drove the first-party Express adapter choice over NestJS.

### database

**Choice:** `postgresql`

**Why this:** The operational data is structured and transactional: invite and API-key metadata, per-key limit and quota reservations and commits, append-only usage events, idempotency fingerprints, and short-lived response replay records. Azure Database for PostgreSQL Flexible Server in Australia East supplies a managed relational store within the committed cloud. Start on the smallest viable Burstable compute size without HA, parameterized in infrastructure as code; scale to General Purpose, enable HA, and add read replicas without changing the engine. Use an Australia East Azure Managed Redis instance as the companion store for shared public-price cache entries and cross-replica request coalescing; start with the smallest viable memory tier and HA disabled for the PoC, then scale the tier and enable HA in place.

**Alternatives considered:** `mongodb` was rejected because the records and atomic quota/idempotency transitions are structured rather than document-shaped. `sqlite` was rejected because a remotely hosted, horizontally scalable service needs shared persistence. `redis` alone was rejected because cache state is temporary and must not be the authoritative store for API keys, quota, usage, or idempotency.

**Tradeoff accepted:** Two managed data components cost and operate more than a single embedded store. In return, durable transactional state and disposable high-throughput cache state have explicit boundaries, and both components can be uplifted in Azure without replacing their roles.

**Assumptions:** [layer] [customer-confirm] The five-user PoC has no production SLA and can begin without database or cache HA; this drove low-cost Burstable PostgreSQL and non-HA Azure Managed Redis starting configurations, with HA enabled later through configuration rather than rearchitecture.

### storage

N/A (No file, image, document, or durable architecture-object storage is in scope.)

### ai

N/A (The hosted MCP performs no semantic search, RAG, or conversational AI.)

### inference

N/A (The hosted MCP makes zero model-provider calls; inference remains with the client host.)

### auth

N/A (No user account or login system is in scope; invitee API-key validation remains a backend boundary designed for later OAuth replacement.)

## Cross-Layer Assumptions

- [stage3] [customer-confirm] `container-service` (Azure Container Apps in Australia East): run the Express MCP as a stateless Streamable HTTP service using JSON-only responses, with no MCP session affinity, SSE notifications, or resumability. This constrains the backend transport and compute scaling model.
- [stage3] [customer-confirm] One invited individual maps to one principal with an independently issued, limited, rotated, revoked, and audited API key. This constrains the backend authorization boundary and the PostgreSQL key, quota, and usage schema.
- [stage3] [customer-confirm] `api-gateway` (Azure API Management Developer tier in Australia East): use APIM as a time-boxed MCP pass-through, policy, coarse rate-limit, and telemetry experiment at approximately A$69.64/month under the 2026-07-24 Retail Prices API rate. Keep key lifecycle and successful-estimate quota authority in the application so an APIM tier change or replacement does not alter domain logic.
- [stage3] [customer-confirm] Invitee credentials, quota, usage, idempotency, and response-replay records are isolated per invitee; immutable rule releases and public Azure price-cache entries are shared. Raw prompts are never stored. This constrains the backend authorization checks and database row-ownership model.
- [stage3] [customer-confirm] `public-endpoint` (Azure API Management): expose the MCP publicly over HTTPS with invitee API-key enforcement, while preventing clients from bypassing APIM to call the Azure Container Apps origin directly. This constrains gateway, backend ingress, and secret configuration.
- [stage3] [customer-confirm] `iac-declarative` (Bicep) and `pipeline-automated` (GitHub Actions): provision the Azure stack and deploy application and infrastructure changes from version-controlled automation. This constrains every Azure component and the repository delivery workflow.
- [stage3] [customer-confirm] `cloud-secrets-manager` (Azure Key Vault): keep APIM-to-backend credentials, database and cache credentials, and operational secrets out of source and deployment logs. This constrains gateway, compute, database, cache, and pipeline identity configuration.
- [stage3] [customer-confirm] `hosted-telemetry` (Application Insights and Azure Monitor): correlate MCP gateway and backend requests while disabling or redacting prompt, API-key, and response-payload capture. This constrains APIM, Container Apps, and incident diagnostics.
- [stage3] [customer-confirm] `managed-snapshots` (Azure Database for PostgreSQL automated backups): use the managed database recovery facility for authoritative operational state; Redis remains disposable and is rebuilt from live pricing. This constrains database operations and recovery procedures.

## Deferred Verifications

- Verify the lowest-cost APIM Developer-to-Container Apps origin-restriction mechanism supported in Australia East. Fallback: require a separately rotated APIM-to-backend credential at the application boundary and apply the strongest Container Apps ingress restriction available without moving to a materially more expensive APIM tier.
