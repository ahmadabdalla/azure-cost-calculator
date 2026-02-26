---
serviceName: Microsoft Entra ID
category: identity
aliases: [Azure AD, Azure Active Directory, AAD, Directory]
billingConsiderations: [M365 / Windows per-user licensing]
primaryCost: "Per-user/month license fee for premium tiers (P1/P2); Free tier has no cost"
hasMeters: false
pricingRegion: api-unavailable
hasKnownRates: true
---

# Microsoft Entra ID

> **Warning**: Microsoft Entra ID has **no meters** in the Azure Retail Prices API. All tiers (Free, P1, P2) return zero results. Use the published rates below.
>
> **Agent instruction**: Do NOT query the pricing scripts — they return zero results. Use the Known Rates table to estimate. Report 0 cost for Free tier. For P1/P2, multiply the per-user rate by user count.

> **Trap**: Do not confuse `Microsoft Entra ID` (this service — identity platform, no API meters) with `Microsoft Entra` (External ID / CIAM — separate service with consumption meters) or `Microsoft Entra Domain Services` (managed AD DS — separate service with hourly meters).

## Query Pattern

### No pricing meters exist — included for validation only

ServiceName: Microsoft Entra ID
Quantity: 50  # number of licensed users

### Expected: 0 results — this service has no retail meters

## Key Fields

| Parameter     | How to determine            | Example values       |
| ------------- | --------------------------- | -------------------- |
| `serviceName` | Always `Microsoft Entra ID` | `Microsoft Entra ID` |
| `productName` | N/A — no meters in API      | N/A                  |
| `skuName`     | N/A — no meters in API      | N/A                  |

## Cost Formula

```
Monthly(tier) = per_user_rate(tier) × userCount
P1:   Monthly(P1)   = per_user_rate(P1)   × userCount
P2:   Monthly(P2)   = per_user_rate(P2)   × userCount
Free: Monthly(Free) = per_user_rate(Free) × userCount
```

## Notes

- **Free tier** is included with every Azure subscription — covers SSO for unlimited apps, basic MFA via security defaults, and self-service password change
- **P1/P2 licensing**: Sold per-user/month with annual commitment; also bundled in M365 E3/E5 — check existing licenses before estimating standalone cost
- P1 adds Conditional Access policies, group-based MFA, SSPR writeback, and App Proxy
- P2 adds risk-based Conditional Access (Identity Protection), Privileged Identity Management (PIM), and access reviews
- Related services billed separately: `Microsoft Entra Domain Services` (managed AD DS), `Microsoft Entra` (External ID / CIAM), `Multi-Factor Authentication` (legacy per-authentication billing)

## Known Rates

| Tier | Per-User/Month (USD) | Included With             | Key Features                                                     |
| ---- | -------------------- | ------------------------- | ---------------------------------------------------------------- |
| Free | $0.00                | All Azure subscriptions   | SSO, basic MFA, security defaults                                |
| P1   | $6.00                | M365 E3, Business Premium | Conditional Access, SSPR, dynamic groups, hybrid identity        |
| P2   | $9.00                | M365 E5                   | Identity Protection, PIM, access reviews, entitlement management |

> These rates are from the [Microsoft Entra pricing page](https://www.microsoft.com/en-us/security/business/microsoft-entra-pricing). For non-USD currencies, use the currency derivation method in [regions-and-currencies.md](../../regions-and-currencies.md).
