# Front Matter Schema (B+)

> Schema version: **1.0.0** · Source of truth: [`frontmatter-schema.psd1`](frontmatter-schema.psd1)

This directory defines the YAML front matter schema for service reference files. The machine-readable schema in `frontmatter-schema.psd1` is the canonical definition — the validation pipeline imports it, and this README documents it for contributors.

---

## Field Reference

### Identity (existing)

| Field         | Type   | Required | Default | Constraints      | Description                                                 |
| ------------- | ------ | :------: | ------- | ---------------- | ----------------------------------------------------------- |
| `serviceName` | string |    ✔     | —       | Exact API value  | Case-sensitive serviceName from the Azure Retail Prices API |
| `category`    | string |    ✔     | —       | Enum (see below) | Folder name under `references/services/`                    |
| `aliases`     | array  |    ✔     | —       | ≥ 1 item         | Common names, abbreviations, and synonyms for search        |

**`category` values:** `compute`, `containers`, `databases`, `networking`, `storage`, `security`, `monitoring`, `management`, `integration`, `analytics`, `ai-ml`, `iot`, `developer-tools`, `identity`, `migration`, `web`, `communication`, `specialist`

### Billing Graph (existing)

| Field                   | Type  | Required | Default | Constraints             | Description                                   |
| ----------------------- | ----- | :------: | ------- | ----------------------- | --------------------------------------------- |
| `billingNeeds`          | array |    —     | omit    | Free-form service names | Services billed under a different serviceName |
| `billingConsiderations` | array |    —     | omit    | Enum (see below)        | Pricing factors the agent asks the user about |

**`billingConsiderations` values:** `Reserved Instances`, `Spot Pricing`, `Azure Hybrid Benefit`, `M365 / Windows per-user licensing`

### API Identity (new)

| Field            | Type   | Required | Default | Constraints | Description                                           |
| ---------------- | ------ | :------: | ------- | ----------- | ----------------------------------------------------- |
| `apiServiceName` | string |    —     | omit    | —           | API serviceName when it differs from the display name |

Use only when the Retail Prices API uses a different `serviceName` than the service's display name (e.g., VMware Solution → `Specialized Compute`, Static Web Apps → `Azure App Service`).

### Pricing Profile (new)

| Field           | Type    | Required | Default    | Constraints      | Description                                                      |
| --------------- | ------- | :------: | ---------- | ---------------- | ---------------------------------------------------------------- |
| `primaryCost`   | string  |    ✔     | —          | Max 120 chars    | One-line billing summary (replaces `**Primary cost**` body line) |
| `hasMeters`     | boolean |    —     | `true`     | —                | `false` for services with no API meters                          |
| `pricingRegion` | string  |    —     | `regional` | Enum (see below) | How region affects API queries                                   |
| `hasKnownRates` | boolean |    —     | `false`    | —                | `true` when file contains a Known Rates table                    |

**`pricingRegion` values:**

| Value             | Meaning                                             | Example services                   |
| ----------------- | --------------------------------------------------- | ---------------------------------- |
| `regional`        | Standard region parameter in queries                | Virtual Machines, SQL Database     |
| `global`          | No region or `Global` in API — use direct API query | Private Link (data processing)     |
| `empty-region`    | API returns results with empty `armRegionName`      | —                                  |
| `api-unavailable` | No meters exist in the API at all                   | Management Groups, DDoS Protection |

### Service Capabilities (new)

| Field             | Type    | Required | Default | Constraints | Description                                         |
| ----------------- | ------- | :------: | ------- | ----------- | --------------------------------------------------- |
| `hasFreeGrant`    | boolean |    —     | `false` | —           | `true` when service has free tier or included units |
| `privateEndpoint` | boolean |    —     | `false` | —           | `true` when service supports private endpoints      |

> `privateEndpoint` is boolean only — tier restrictions (e.g., "Premium required") stay in the Notes section of the service reference file.

---

## Default Elision Rule

Optional fields whose value matches the default **should be omitted** from the YAML block. Only exceptions (non-default values) appear explicitly. This minimises author burden and keeps YAML blocks compact.

For example, a standard regional service with API meters does **not** write `hasMeters: true` or `pricingRegion: regional` — those are the defaults.

---

## Examples

### Minimal (all defaults apply)

```yaml
---
serviceName: Azure App Service
category: compute
aliases: [App Service, Web Apps, Web App]
billingConsiderations: [Reserved Instances]
primaryCost: "Fixed hourly rate for the plan SKU × 730"
privateEndpoint: true
---
```

### Typical (some non-default fields)

```yaml
---
serviceName: Functions
category: compute
aliases: [Azure Functions, Function Apps, Serverless Functions]
billingNeeds: [Azure App Service]
primaryCost: "Per-execution + GB-seconds (Consumption/Flex) or App Service Plan rate (Dedicated)"
hasFreeGrant: true
---
```

### Full (all fields explicit — for illustration only)

```yaml
---
serviceName: Specialized Compute
category: compute
aliases: [Azure VMware Solution, AVS, VMware]
apiServiceName: Specialized Compute
primaryCost: "Dedicated host hours (AV36P/AV48/AV52/AV64) × 730 × nodeCount"
hasMeters: true
pricingRegion: regional
hasKnownRates: false
hasFreeGrant: false
privateEndpoint: false
---
```

> In practice, the full example above would elide `hasMeters`, `pricingRegion`, `hasKnownRates`, `hasFreeGrant`, and `privateEndpoint` since they all match their defaults.

### No-meter service

```yaml
---
serviceName: Management Groups
category: management
aliases: [Management Groups]
primaryCost: "Free — no charge for management group operations"
hasMeters: false
pricingRegion: api-unavailable
hasKnownRates: false
---
```

---

## Line Budget Impact

| Scenario                   | Current YAML lines | B+ YAML lines | Delta |
| -------------------------- | :----------------: | :-----------: | :---: |
| Minimal (all defaults)     |        5–6         |      7–8      |  +2   |
| Typical (some non-default) |        6–7         |     9–11      | +3–4  |
| Full (all fields)          |        7–8         |     13–15     | +6–7  |

The `primaryCost` field absorbs the `**Primary cost**` body line, so the net body impact is typically +1–3 lines.

---

## Relationship to Validation

The validation pipeline (`tests/Validate-ServiceReference.ps1`) currently reads field rules from `tests/lib/validation/ValidationConfig.psd1`. The schema in this directory is designed to supersede the front matter portion of that config:

- `ValidationConfig.psd1` → `RequiredFrontMatterFields` will be derived from fields where `Required = $true` in `frontmatter-schema.psd1`
- `ValidationConfig.psd1` → `ValidCategories` will be derived from `category.AllowedValues` in `frontmatter-schema.psd1`
- New checks (e.g., `primaryCost` max length, `pricingRegion` enum, boolean type validation) will import `frontmatter-schema.psd1` directly

Until the validator is updated, this schema serves as the documented contract. The validator migration is a separate task.
