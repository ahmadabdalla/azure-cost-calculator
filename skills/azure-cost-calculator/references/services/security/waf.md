---
serviceName: Application Gateway
category: security
aliases: [WAF, Azure WAF, WAF v2, Web Application Firewall, WAF Policy, Front Door WAF]
billingNeeds: [Azure Front Door Service]
---

# Azure Web Application Firewall (WAF)

**Primary cost**: App Gateway WAF — fixed hourly + capacity units; Front Door WAF — per-policy monthly + per-request

> **Trap (two services)**: WAF has no dedicated serviceName — meters split across `Application Gateway` (gateway WAF) and `Azure Front Door Service` (CDN WAF). Query each separately.
> **Trap (Front Door productName)**: All listed WAF meters use productName `Azure Front Door Service` (Classic). Front Door Premium includes WAF in its base fee — only `Premium Captcha Sessions` exists separately under productName `Azure Front Door`.

## Query Pattern

### App Gateway WAF v2 — fixed cost

ServiceName: Application Gateway
ProductName: Application Gateway WAF v2
MeterName: Standard Fixed Cost

### App Gateway WAF v2 — capacity units

ServiceName: Application Gateway
ProductName: Application Gateway WAF v2
MeterName: Standard Capacity Units

### Front Door Classic WAF — policy and rules

ServiceName: Azure Front Door Service
ProductName: Azure Front Door Service
MeterName: Standard Policy

### Front Door WAF — per-request (use Quantity for monthly millions)

ServiceName: Azure Front Door Service
ProductName: Azure Front Door Service
MeterName: Standard Default Request
Quantity: 10

## Key Fields

| Parameter | How to determine | Example values |
| --- | --- | --- |
| `serviceName` | `Application Gateway` or `Azure Front Door Service` | `Application Gateway`, `Azure Front Door Service` |
| `productName` | WAF variant determines product | `Application Gateway WAF v2`, `Azure Front Door Service` |
| `meterName` | Fixed cost, capacity units, policy, or requests | `Standard Fixed Cost`, `Standard Policy` |

## Meter Names

### App Gateway WAF v2 (productName: `Application Gateway WAF v2`)

| Meter | unitOfMeasure | Notes |
| --- | --- | --- |
| `Standard Fixed Cost` | `1/Hour` | Per-gateway hourly |
| `Standard Capacity Units` | `1/Hour` | Per-CU hourly |
| `Standard Captcha Sessions` | `1K` | CAPTCHA challenges |

### Front Door WAF (productName: `Azure Front Door Service`)

| Meter | unitOfMeasure | Notes |
| --- | --- | --- |
| `Standard Policy` | `1/Month` | Per WAF policy |
| `Standard Rule` | `1/Month` | Per custom rule |
| `Standard Default Ruleset` | `1/Month` | Managed ruleset (DRS) |
| `Standard Default Request` | `1M/Month` | DRS evaluation |
| `Standard Bot Protection Ruleset` | `1/Month` | Bot protection add-on |
| `Standard Bot Protection Request` | `1M/Month` | Bot protection requests |

## Cost Formula

```
App Gateway WAF v2:
Monthly = (fixedCost_retailPrice × 730) + (capacityUnit_retailPrice × estimatedCUs × 730)

Front Door WAF:
Monthly = policy_retailPrice × policyCount
        + rule_retailPrice × customRuleCount
        + ruleset_retailPrice × rulesetCount
        + request_retailPrice × (requests / 1,000,000)
```

## Notes

- **Two pricing models**: App Gateway WAF = hourly (fixed + CU); Front Door WAF = monthly (policy + rules + per-request). See `app-gateway.md` for full App Gateway pricing and `front-door.md` for full Front Door pricing.
- **Default CU assumption**: For App Gateway WAF, use 10 CUs baseline when user doesn't specify traffic.
- **Custom vs managed rules (Front Door)**: Custom rules and managed rulesets billed separately. Bot protection is an additional add-on.
- **Sub-cent per-request**: Front Door WAF request meters are sub-cent per million — use `Quantity` to calculate meaningful costs.
- **App Gateway for Containers WAF**: Uses productName `Application Gateway for Containers WAF` — separate product with different meters.
- **Front Door Premium WAF**: Included in base fee. Only `Premium Captcha Sessions` (productName `Azure Front Door`) is billed separately.
- **Azure CDN WAF**: Separate service under `Content Delivery Network` serviceName with its own WAF meters — not covered here.
