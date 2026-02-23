---
serviceName: Azure Front Door Service
category: networking
aliases: [AFD, Front Door, Front Door Premium/Standard, Front Door WAF]
primaryCost: "Base fee (flat monthly per profile) + data transfer out per-GB + requests per-10K"
privateEndpoint: true
---

# Azure Front Door

> **Trap (Zone regions)**: Front Door uses **zone-based regions** (`Zone 1`, `Zone 2`, etc.), not ARM regions. Queries MUST use `-Region 'Zone 1'` — the default `eastus` returns zero results.
> **Trap (Two productNames)**: Standard/Premium profile meters use productName `Azure Front Door`. Classic WAF/routing meters use productName `Azure Front Door Service`. Always filter by `ProductName` to avoid mixing them.

## Query Pattern

Substitute `{Tier}` with `Standard` or `Premium`.

### {Tier} profile — base fee (Zone 1 = US/Europe)

ServiceName: Azure Front Door Service
ProductName: Azure Front Door
SkuName: {Tier}
MeterName: {Tier} Base Fees
Region: Zone 1

### {Tier} — data transfer out (use Quantity for estimated monthly GB)

ServiceName: Azure Front Door Service
ProductName: Azure Front Door
SkuName: {Tier}
MeterName: {Tier} Data Transfer Out
Quantity: 500
Region: Zone 1

### {Tier} — requests (per 10K)

ServiceName: Azure Front Door Service
ProductName: Azure Front Door
SkuName: {Tier}
MeterName: {Tier} Requests
Region: Zone 1

### Classic WAF — policy and rules (productName: `Azure Front Door Service`)

ServiceName: Azure Front Door Service
ProductName: Azure Front Door Service
MeterName: Standard Policy
Region: Zone 1

### Classic WAF — managed ruleset requests (use Quantity for monthly millions)

ServiceName: Azure Front Door Service
ProductName: Azure Front Door Service
MeterName: Standard Default Request
Quantity: 10
Region: Zone 1

## Meter Names

| Meter                             | skuName    | unitOfMeasure | Notes                                   |
| --------------------------------- | ---------- | ------------- | --------------------------------------- |
| `Standard Base Fees`              | `Standard` | `1/Month`     | Flat monthly per profile                |
| `Standard Data Transfer Out`      | `Standard` | `1 GB`        | Tiered egress pricing                   |
| `Standard Data Transfer In`       | `Standard` | `1 GB`        | Ingress                                 |
| `Standard Requests`               | `Standard` | `10K`         | Per 10K requests                        |
| `Premium Base Fees`               | `Premium`  | `1/Month`     | Flat monthly per profile                |
| `Premium Data Transfer Out`       | `Premium`  | `1 GB`        | Tiered egress pricing                   |
| `Premium Data Transfer In`        | `Premium`  | `1 GB`        | Ingress                                 |
| `Premium Requests`                | `Premium`  | `10K`         | Per 10K requests                        |
| `Standard Policy`                 | `Standard` | `1/Month`     | WAF policy (Classic)                    |
| `Standard Rule`                   | `Standard` | `1/Month`     | WAF custom rule (Classic)               |
| `Standard Default Ruleset`        | `Standard` | `1/Month`     | Managed ruleset DRS (Classic)           |
| `Standard Default Request`        | `Standard` | `1M/Month`    | DRS evaluation (Classic)                |
| `Standard Bot Protection Ruleset` | `Standard` | `1/Month`     | Bot protection add-on (Classic)         |
| `Standard Bot Protection Request` | `Standard` | `1M/Month`    | Bot protection requests (Classic)       |
| `Premium Captcha Sessions`        | `Premium`  | `1K`          | CAPTCHA (only Premium WAF add-on meter) |

> **Trap (Tiered egress)**: Data transfer out queries return **multiple rows** with `tierMinimumUnits` (0 GB, 10 TB, 50 TB, etc.). The script's `totalMonthlyCost` sums `retailPrice × Quantity` per row without applying tier boundaries — ignore it. Manually calculate: sum each tier's volume × its `retailPrice`.

## Cost Formula

```
Monthly = baseFee_retailPrice × profileCount
        + Σ(dataOut_tier_retailPrice × GB_in_tier)
        + dataIn_retailPrice × estimatedInGB
        + requests_retailPrice × (estimatedRequests / 10,000)

Classic WAF add-on (if enabled):
        + policy_retailPrice × policyCount + rule_retailPrice × customRuleCount
        + ruleset_retailPrice × rulesetCount + wafRequest_retailPrice × (wafRequests / 1M)
        + botRuleset_retailPrice × botRulesetCount + botRequest_retailPrice × (botRequests / 1M)
Premium CAPTCHA: captcha_retailPrice × (captchaSessions / 1K)
```

## Notes

- **Zone mapping**: Zone 1 = US/Europe, Zone 2 = Asia Pacific/Japan/Australia, Zone 3 = South America/Africa/Middle East. Additional zones (4-8) exist for specific geographies
- **Standard vs Premium**: Premium adds Private Link origins, enhanced WAF with bot protection and managed rule sets, and Microsoft Threat Intelligence. Premium WAF is included in base fee — only `Premium Captcha Sessions` billed separately
- **Data transfer out is tiered** — the first 10 TB is the highest rate; volume discounts apply at 50 TB+
- **Classic WAF / Classic Front Door**: Custom rules, managed rulesets, and bot protection billed separately under productName `Azure Front Door Service`. Sub-cent per-request — use `Quantity`. Being retired in favor of Standard/Premium
