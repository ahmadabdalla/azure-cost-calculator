---
serviceName: Azure Active Directory B2C
category: identity
aliases: [AAD B2C, Azure AD B2C, External Identities B2C, Entra External ID]
primaryCost: "Per-MAU with 50K free/month (Standard); per-auth legacy model + MFA add-on billed separately"
pricingRegion: global
hasKnownRates: true
hasFreeGrant: true
---

# Azure Active Directory B2C

> **Trap**: Do not confuse with `Microsoft Entra ID` (per-user licensing, no API meters) or `Azure Active Directory for External Identities` (B2B guest users). B2C is CIAM for consumer-facing apps with per-MAU or per-authentication billing.

> **Trap (sub-cent tiered pricing)**: All tiered meters return sub-cent rates — the script displays zero cost and its `totalMonthlyCost` sums all tiers producing a meaningless number. Use the Known Rates table and calculate each tier bracket separately with progressive pricing. Do NOT report zero cost to the user.

## Query Pattern

### Standard MAU pricing (current billing model)

ServiceName: Azure Active Directory B2C
ProductName: Azure Active Directory B2C
SkuName: Standard
MeterName: Standard Monthly Active Users
Region: Global
Quantity: 100000

### MFA add-on (per-attempt)

ServiceName: Azure Active Directory B2C
ProductName: Azure Active Directory B2C
SkuName: Basic
MeterName: Basic Multi-Factor Authentication
Region: Global

### Legacy per-authentication pricing (pre-Nov 2019 tenants)

ServiceName: Azure Active Directory B2C
ProductName: Azure Active Directory B2C
SkuName: Basic
MeterName: Basic Authentication
Region: Global

## Key Fields

| Parameter     | How to determine                    | Example values                                                                                |
| ------------- | ----------------------------------- | --------------------------------------------------------------------------------------------- |
| `serviceName` | Always `Azure Active Directory B2C` | `Azure Active Directory B2C`                                                                  |
| `productName` | Single product                      | `Azure Active Directory B2C`                                                                  |
| `skuName`     | Billing model: MAU or per-auth      | `Standard`, `Basic`                                                                           |
| `meterName`   | Authentication type or MFA add-on   | `Standard Monthly Active Users`, `Basic Authentication`, `Basic Multi-Factor Authentication`  |

## Meter Names

| Meter                               | skuName    | unitOfMeasure | Notes                                      |
| ----------------------------------- | ---------- | ------------- | ------------------------------------------ |
| `Standard Monthly Active Users`     | `Standard` | `1/Month`     | Current MAU model — 50K free, tiered above |
| `Basic Authentication`              | `Basic`    | `1/Month`     | Legacy per-auth — 50K free, tiered above   |
| `Basic Multi-Factor Authentication` | `Basic`    | `1`           | Per-attempt flat rate for SMS/Voice MFA    |
| `Basic Stored User`                 | `Basic`    | `1/Month`     | Always zero at all tiers — tracking only   |

## Cost Formula

```
Standard MAU:  Billable = max(0, totalMAUs - 50,000) then apply tiered rates progressively
MFA add-on:    Monthly = mfa_retailPrice × mfaAttempts
Legacy auth:   Billable = max(0, totalAuths - 50,000) then apply tiered rates progressively
Total:         Monthly = MAU_or_Auth_cost + MFA_cost
```

## Notes

- **Free grant**: First 50,000 MAUs/month (Standard) or 50,000 authentications/month (Basic) are free — does not apply to free trial, credit-based, or sponsorship subscriptions
- **Two billing models**: Standard (per-MAU, current default) and Basic (per-authentication, legacy pre-Nov 2019) — switch to MAU is irreversible
- **P1 vs P2**: The API has a single `Standard` SKU — P1 and P2 differ in features (P2 adds Identity Protection, PIM), not per-MAU pricing
- **MFA is per-attempt**: Each SMS/Voice MFA challenge incurs a charge whether sign-in succeeds or fails
- **End-of-sale**: As of May 2025, not available for new customers — new implementations should use Microsoft Entra External ID
- Related services billed separately: `identity/entra-id.md` (Microsoft Entra ID), `Azure Active Directory for External Identities` (B2B)

## Known Rates

| Meter                               | Tier       | Unit Rate (USD) | Free Grant  |
| ----------------------------------- | ---------- | --------------- | ----------- |
| `Standard Monthly Active Users`     | 0–50K      | $0.0000         | 50,000 MAUs |
| `Standard Monthly Active Users`     | 50K–100K   | $0.0055         | —           |
| `Standard Monthly Active Users`     | 100K–950K  | $0.0046         | —           |
| `Standard Monthly Active Users`     | 950K–9.95M | $0.00325        | —           |
| `Standard Monthly Active Users`     | 9.95M+     | $0.0025         | —           |
| `Basic Multi-Factor Authentication` | Flat       | $0.0300         | None        |

> These rates are from the Azure Retail Prices API at `Global` region. The script shows zero for sub-cent rates. For non-USD currencies, use the method in [regions-and-currencies.md](../../regions-and-currencies.md).
