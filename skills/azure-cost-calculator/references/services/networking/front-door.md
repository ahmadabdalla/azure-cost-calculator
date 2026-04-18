---
serviceName: Azure Front Door Service
category: networking
aliases: [AFD, Front Door, Front Door Premium/Standard, Front Door WAF]
primaryCost: "Base fee (flat monthly per profile) + data transfer out per-GB + requests per-10K"
privateEndpoint: true
---

# Azure Front Door

> **Trap (Zone regions)**: Front Door uses **zone-based regions** (`Zone 1`, `Zone 2`, etc.), not ARM regions. Queries MUST use `-Region 'Zone 1'`. The default `eastus` returns zero results.
> **Trap (Two productNames)**: Standard/Premium profile meters use productName `Azure Front Door`. Classic WAF/routing meters use productName `Azure Front Door Service`. Always filter by `ProductName` to avoid mixing them.
> **Trap (Tiered pricing)**: Data transfer out (7 tiers) and requests (4 tiers) return **multiple rows** with `tierMinimumUnits`. The script's `totalMonthlyCost` sums all tiers incorrectly. Manually calculate using tier boundaries.

## Query Pattern

Substitute `{Tier}` with `Standard` or `Premium`.
### {Tier} profile: base fee (Zone 1 = North America)

ServiceName: Azure Front Door Service
ProductName: Azure Front Door
SkuName: {Tier}
MeterName: {Tier} Base Fees
Region: Zone 1

### {Tier}: data transfer (out/in; use Quantity for estimated monthly GB)

ServiceName: Azure Front Door Service
ProductName: Azure Front Door
SkuName: {Tier}
MeterName: {Tier} Data Transfer Out
Quantity: 500
Region: Zone 1
Repeat with `MeterName: {Tier} Data Transfer In` to price ingress (`estimatedInGB`).

### {Tier}: requests (per 10K)

ServiceName: Azure Front Door Service
ProductName: Azure Front Door
SkuName: {Tier}
MeterName: {Tier} Requests
Region: Zone 1

### Classic WAF: policy and rules (productName: `Azure Front Door Service`)

ServiceName: Azure Front Door Service
ProductName: Azure Front Door Service
MeterName: Standard Policy
Region: Zone 1

### Classic WAF: managed ruleset requests (use Quantity for monthly millions)

ServiceName: Azure Front Door Service
ProductName: Azure Front Door Service
MeterName: Standard Default Request
Quantity: 10
Region: Zone 1

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- |
| `{Tier} Base Fees` | `{Tier}` | `1/Month` | Flat monthly per profile |
| `{Tier} Data Transfer Out` | `{Tier}` | `1 GB` | 7-tier volume pricing |
| `{Tier} Data Transfer In` | `{Tier}` | `1 GB` | Ingress; same price Standard and Premium |
| `{Tier} Requests` | `{Tier}` | `10K` | 4-tier volume pricing |
| `Premium Captcha Sessions` | `Premium` | `1K` | Premium-only CAPTCHA meter |
| `Standard Policy` | `Standard` | `1/Month` | WAF policy (Classic) |
| `Standard Rule` | `Standard` | `1/Month` | WAF custom rule (Classic) |
| `Standard Default Ruleset` | `Standard` | `1/Month` | Managed ruleset DRS (Classic) |
| `Standard Default Request` | `Standard` | `1M/Month` | DRS evaluation (Classic) |
| `Standard Bot Protection Ruleset` | `Standard` | `1/Month` | Bot protection add-on (Classic) |
| `Standard Bot Protection Request` | `Standard` | `1M/Month` | Bot protection requests (Classic) |
| `Standard Custom Domain` | `Standard` | `1/Month` | Per custom domain (Classic) |

> Classic also has `Standard Included Routing Rules` (first 5 free, then per-hour) and `Standard Overage Routing Rules`. Classic `Standard Requests` uses `1M/Month` unit (vs `10K` for Standard/Premium).

## Cost Formula

```
Monthly = baseFee_retailPrice × profileCount
        + Σ(dataOut_tier_retailPrice × GB_in_tier)
        + dataIn_retailPrice × estimatedInGB
        + Σ(requests_tier_retailPrice × requests_in_tier / 10,000)

Classic WAF add-on (if enabled):
        + policy_retailPrice × policyCount + rule_retailPrice × customRuleCount
        + ruleset_retailPrice × rulesetCount + wafRequest_retailPrice × (wafRequests / 1M)
        + botRuleset_retailPrice × botRulesetCount + botRequest_retailPrice × (botRequests / 1M)
Premium CAPTCHA: captcha_retailPrice × (captchaSessions / 1K)
```

## Notes

- **Zone mapping**: Zone 1 = North America, Zone 2 = Asia Pacific/Japan, Zone 3 = South America, Zone 4 = Australia, Zone 5 = India, Zone 6 = Europe, Zone 7 = Middle East/Africa, Zone 8 = Korea. Zone 1 and Zone 6 have identical prices
- **Standard vs Premium**: Premium adds Private Link origins, enhanced WAF with bot protection and managed rule sets, and Microsoft Threat Intelligence. Premium WAF is included in base fee; only `Premium Captcha Sessions` billed separately. Data transfer prices are identical between tiers
- **Data transfer out is tiered**: 7 tiers (0–10 TB, 10–50 TB, 50–150 TB, 150–500 TB, 500 TB–1 PB, 1–5 PB, 5 PB+). Requests also tiered (4 tiers)
- **Classic WAF / Classic Front Door**: Custom rules, managed rulesets, and bot protection billed separately under productName `Azure Front Door Service`. Sub-cent per-request; use `Quantity`. Being retired in favor of Standard/Premium
- **Private Link origins**: Premium tier only; see `networking/private-link.md` for PE and DNS zone pricing
