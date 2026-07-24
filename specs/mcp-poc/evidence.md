---
initiative: mcp-poc
artifact: evidence
status: active
owner: repository maintainer
authority: [external-evidence, evaluation-results, cost-estimates]
---

# Hosted Azure Cost MCP PoC evidence and open questions

Evidence here is dated and does not silently change
[requirements](requirements.md) or [decisions](decisions.md). Product
documentation shows configuration capability; only the planned E2E tests can
confirm interoperability.

## EVID-001 — MCP TypeScript SDK release status

**Status:** Verified
**As of:** 2026-07-24
**Source:** [Official MCP TypeScript SDK repository](https://github.com/modelcontextprotocol/typescript-sdk)
**Method:** Reviewed the repository's current branch and release guidance.

**Finding:** The main branch contains a pre-alpha v2 and states that v1.x
remains recommended for production until the anticipated stable v2 release.
The repository lists thin Express, Hono, and Node HTTP middleware packages,
including Streamable HTTP and Host-header helpers.

**Inference:** `ADR-007` should select the recommended stable line at
implementation time, not pin today's status in a timeless requirement.

**Reverify when:** Starting `WP-001`, upgrading the SDK, or after a stable v2
release.

## EVID-002 — Remote transport and server security requirements

**Status:** Verified
**As of:** 2026-07-24
**Source:** [MCP Streamable HTTP transport specification](https://modelcontextprotocol.io/specification/2025-11-25/basic/transports)
**Method:** Reviewed the current protocol transport and security guidance.

**Finding:** Streamable HTTP is the specified remote transport. The
specification requires Origin validation to prevent DNS rebinding, recommends
localhost binding for local servers, and requires proper authentication for
remote connections. Sessions are optional.

**Reverify when:** Locking the protocol version in `WP-001` or upgrading it.

## EVID-003 — MCP authorization interoperability baseline

**Status:** Verified
**As of:** 2026-07-24
**Source:** [MCP authorization specification](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization)
**Method:** Reviewed current HTTP authorization requirements.

**Finding:** Authorization is optional for MCP implementations, but protected
HTTP servers following the specification use OAuth 2.1-related flows and
Protected Resource Metadata. Access tokens use the Authorization Bearer header
and must be audience-bound.

**Inference:** API keys are a bounded private-beta experiment, not evidence of
broad MCP authorization interoperability. The OAuth gap assessment remains
mandatory.

**Reverify when:** Starting host compatibility work or changing protocol
version.

## EVID-004 — Claude Code remote header configuration

**Status:** Verified
**As of:** 2026-07-24
**Source:** [Anthropic Claude Code MCP documentation](https://docs.anthropic.com/en/docs/claude-code/mcp)
**Method:** Reviewed remote HTTP server examples and configuration fields.

**Finding:** Claude Code documents remote HTTP MCP servers, custom headers,
environment expansion in header values, and OAuth authentication.

**Limitation:** Documentation capability does not prove this PoC's complete
initialize, discovery, tool-call, structured-output, and error flow.

**Reverify when:** Executing `WP-001` and `WP-005`.

## EVID-005 — GitHub Copilot remote header configuration

**Status:** Verified
**As of:** 2026-07-24
**Source:** [GitHub MCP setup documentation](https://docs.github.com/en/copilot/how-tos/provide-context/use-mcp-in-your-ide/set-up-the-github-mcp-server?tool=vscode)
**Method:** Reviewed the remote MCP configuration examples.

**Finding:** GitHub documents remote HTTP MCP configuration in Visual Studio
Code with request headers, including an Authorization Bearer example.

**Limitation:** The target version and the complete PoC flow still require an
empirical compatibility test.

**Reverify when:** Executing `WP-001` and `WP-005`.

## EVID-006 — Codex remote authentication configuration

**Status:** Verified locally
**As of:** 2026-07-24
**Source:** Installed `codex mcp add --help`
**Method:** Inspected the locally installed Codex CLI command contract.

**Finding:** Codex supports a Streamable HTTP URL, a bearer token read from an
environment variable, and OAuth client/resource options. The command does not
expose a general arbitrary-header flag.

**Inference:** The PoC should prefer an Authorization Bearer representation of
the invite key if all hosts accept it. A fixed `X-API-Key` assumption would
remain unverified for Codex.

**Reverify when:** Executing `WP-001` and `WP-005`, using the exact release under
test.

## EVID-007 — PostgreSQL Flexible Server HA constraint

**Status:** Verified
**As of:** 2026-07-24
**Source:** [Azure Database for PostgreSQL high availability](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-high-availability)
**Method:** Reviewed Microsoft product documentation.

**Finding:** Flexible Server supports managed zonal and zone-redundant HA, but
the Burstable compute tier does not support HA.

**Inference:** The PoC can start Burstable without HA, but enabling HA requires
changing compute tier first; documentation must not imply HA is a Burstable
toggle.

**Reverify when:** Selecting the deployment SKU.

## EVID-008 — Azure Managed Redis non-HA development mode

**Status:** Verified
**As of:** 2026-07-24
**Source:** [Azure Managed Redis overview](https://learn.microsoft.com/en-us/azure/redis/overview)
**Method:** Reviewed Microsoft tier and high-availability guidance.

**Finding:** Azure Managed Redis permits disabling HA for development/test to
reduce price, warns of downtime/data loss, and supports enabling HA on an
instance created without it.

**Inference:** Non-HA is acceptable only for this no-SLA PoC and Redis remains
disposable.

**Reverify when:** Selecting region/SKU and before any production use.

## EVID-009 — APIM Developer price observation

**Status:** Verified
**As of:** 2026-07-24
**Source:** [Azure Retail Prices API](https://prices.azure.com/api/retail/prices)
**Method:** Queried service `API Management`, SKU `Developer`, meter
`Developer Unit`, region `australiaeast`, currency `AUD` with the repository
pricing script.

**Finding:** The API returned AUD 0.0954 per hour, or AUD 69.64 for 730 hours,
for one Developer unit. This confirms the interview's dated observation, not a
future budget guarantee.

**Reverify when:** Preparing an estimate, provisioning, or reporting measured
operating cost.

## OPEN-001 — APIM-to-Container Apps origin restriction

**Status:** Open
**Owner:** Repository maintainer
**Blocks:** `WP-003`

Determine the lowest-cost supported way for public APIM in Australia East to
reach Container Apps while preventing direct origin bypass. Test private
networking and IP allowlisting options on the selected tiers. If those are not
viable, require a separately rotated gateway-to-backend credential and document
the residual exposure.

## OPEN-002 — End-to-end host compatibility

**Status:** Open
**Owner:** Repository maintainer
**Blocks:** `WP-003`, `WP-005`

Confirm exact versions and full remote connection behaviour for Claude Code,
GitHub Copilot in Visual Studio Code, and Codex: Streamable HTTP, secret
handling, initialize/discovery, structured output, error rendering, and OAuth
expectations. Configuration documentation alone is insufficient.

## OPEN-003 — Request, query, line-item, and response bounds

**Status:** Open
**Owner:** Repository maintainer
**Blocks:** `WP-002`, `WP-003`

Canonicalize the complete complex fixture, review its ledger, then set limits
that admit the fixture with measured headroom while rejecting unbounded work.
Fix the complex `line_items` token budget at the same time.

## OPEN-004 — Acceptable price-cache TTL

**Status:** Open
**Owner:** Repository maintainer
**Blocks:** None.

Measure cache hit rate, user expectations, and live API latency. The accepted
starting value is 15 minutes, configurable; changing stale-price behaviour
requires approval because it changes `REQ-008`.

## OPEN-005 — Deployment-time Azure availability and cost

**Status:** Open
**Owner:** Repository maintainer
**Blocks:** `WP-003`

Before provisioning, reverify Australia East availability, quotas, SKU
capabilities, and current Retail Prices API observations for Container Apps,
APIM, PostgreSQL Flexible Server, Azure Managed Redis, Key Vault, and telemetry.
Record the exact IaC selections and dated monthly estimate.

## OPEN-006 — Data-use, pricing-disclaimer, redistribution, and trademark review

**Status:** Open
**Owner:** Repository maintainer
**Blocks:** `WP-006`

Establish what Microsoft terms, attribution, pricing disclaimer, data-use, and
trademark review is required before any beta or broader launch. Do not infer
legal approval from technical API availability.
