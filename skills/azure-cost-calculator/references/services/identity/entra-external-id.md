---
serviceName: Microsoft Entra External ID
category: identity
aliases: [Entra External ID, CIAM, Microsoft Entra CIAM, AAD B2C, Azure AD B2C, External Identities B2C]
apiServiceName: Microsoft Entra
queryServiceNames: [Microsoft Entra, Azure Active Directory B2C]
primaryCost: "Per-MAU with 50K free/month (External ID CIAM); legacy B2C per-MAU/per-auth billed separately"
pricingRegion: global
hasKnownRates: true
hasFreeGrant: true
---

# Microsoft Entra External ID

> **Trap (service disambiguation)**: Distinct from `Microsoft Entra ID` (workforce licensing, no API meters), `Azure Active Directory for External Identities` (legacy B2B guest P1/P2), and `Microsoft Entra Domain Services` (managed AD DS). This file covers External ID CIAM for consumer-facing apps and the legacy Azure AD B2C billing model it succeeds.

> **Trap (display name vs API name)**: The API `serviceName` is `Microsoft Entra`, not `Microsoft Entra External ID` (that is the `productName`). Querying `serviceName eq 'Microsoft Entra External ID'` returns zero. Legacy B2C meters live under `serviceName` `Azure Active Directory B2C`.
> **Agent instruction**: Filter External ID queries by `serviceName eq 'Microsoft Entra' and productName eq 'Microsoft Entra External ID'`.

> **Trap (sub-cent tiered pricing, Global-only)**: All meters return at `Region: Global`; region-filtered queries return zero. MAU tiers and the M2M/SCIM rates are sub-cent, so the script shows zero and its `totalMonthlyCost` sums free and paid tiers. Use the Known Rates table and calculate billable units per tier. Do NOT report zero cost.

## Query Pattern

### External ID MAU (current CIAM billing model)

ServiceName: Microsoft Entra
ProductName: Microsoft Entra External ID
SkuName: Core
MeterName: Core Monthly Active Users
Region: Global
Quantity: 100000

### External ID phone authentication (add-on, per SMS)

ServiceName: Microsoft Entra
ProductName: Microsoft Entra External ID
SkuName: Phone Authentication Low Cost
MeterName: Phone Authentication Low Cost Transaction
Region: Global

### External ID machine-to-machine authentication (add-on)

ServiceName: Microsoft Entra
ProductName: Microsoft Entra External ID
SkuName: M2M Authentication
MeterName: M2M Authentication Token
Region: Global

### Legacy Azure AD B2C MAU (grandfathered tenants)

ServiceName: Azure Active Directory B2C
ProductName: Azure Active Directory B2C
SkuName: Standard
MeterName: Standard Monthly Active Users
Region: Global

## Meter Names

| Meter                                  | skuName                  | unitOfMeasure | Notes                                                  |
| -------------------------------------- | ------------------------ | ------------- | ------------------------------------------------------ |
| `Core Monthly Active Users`            | `Core`                   | `1/Month`     | External ID CIAM, 50K free, sub-cent above             |
| `Basic Monthly Active Users`           | `Basic`                  | `1/Month`     | External ID CIAM, 50K free, higher rate above          |
| `Go-Local Add-on Monthly Active Users` | `Go-Local Add-on`        | `1/Month`     | Data residency add-on, no free grant                   |
| `M2M Authentication Token`             | `M2M Authentication`     | `1`           | Per client-credentials token; not a MAU                |
| `Phone Authentication * Transaction`   | `Phone Authentication *` | `1`           | Per SMS; four country cost tiers                       |
| `Standard Transaction`                 | `Standard`               | `1`           | `SCIM provisioning API` product; per provisioning call |
| `Standard Monthly Active Users`        | `Standard`               | `1/Month`     | Legacy B2C, 50K free, tiered above                     |
| `Basic Multi-Factor Authentication`    | `Basic`                  | `1`           | Legacy B2C, per-attempt SMS/Voice MFA                  |

## Cost Formula

```
External ID MAU:  Billable = max(0, totalMAUs - 50,000) × mauRate (Core or Basic)
Phone auth:       Monthly = smsAttempts × countryTierRate
M2M:              Monthly = tokenRequests × m2mRate
Legacy B2C MAU:   Billable = max(0, totalMAUs - 50,000) then apply tiered rates progressively
Total:            Sum of the applicable components above
```

## Notes

- **Free grant**: First 50,000 MAUs/month are free for External ID (Core and Basic) and for legacy B2C Standard. Does not apply to add-ons or to free trial, credit-based, or sponsorship subscriptions
- **Core vs Basic**: Both are two-tier (free to 50K, flat above). `Core` bills lower than `Basic` and is absent from the public pricing page though present in the API; confirm the SKU before quoting
- **Add-ons have no free grant**: Go-Local, M2M, phone authentication, and SCIM provisioning bill from the first unit
- **Phone auth varies by country**: Four cost tiers (low to high); pick the tier matching the recipient geography. Charged per attempt whether or not sign-in succeeds
- **No Reserved Instances**: All meters are consumption-only
- **Legacy B2C**: Azure AD B2C is end-of-sale for new customers (May 2025); grandfathered tenants keep the B2C billing model above. New tenants use External ID

## Known Rates

| Meter                                     | Tier       | Unit Rate (USD) | Free Grant  |
| ----------------------------------------- | ---------- | --------------- | ----------- |
| `Core Monthly Active Users`               | 0–50K      | $0.0000         | 50,000 MAUs |
| `Core Monthly Active Users`               | 50K+       | $0.01625        | -           |
| `Basic Monthly Active Users`              | 0–50K      | $0.0000         | 50,000 MAUs |
| `Basic Monthly Active Users`              | 50K+       | $0.0300         | -           |
| `Go-Local Add-on Monthly Active Users`    | Flat       | $0.0200         | None        |
| `M2M Authentication Token`                | Flat       | $0.0010         | None        |
| `Phone Authentication Low Cost`           | Flat       | $0.0300         | None        |
| `Phone Authentication Mid Low Cost`       | Flat       | $0.0700         | None        |
| `Phone Authentication Mid High Cost`      | Flat       | $0.1500         | None        |
| `Phone Authentication High Cost`          | Flat       | $0.3500         | None        |
| `SCIM Standard Transaction`               | Flat       | $0.0020         | None        |
| `Standard Monthly Active Users` (B2C)     | 50K–100K   | $0.0055         | 50,000 MAUs |
| `Standard Monthly Active Users` (B2C)     | 100K–950K  | $0.0046         | -           |
| `Standard Monthly Active Users` (B2C)     | 950K–9.95M | $0.00325        | -           |
| `Standard Monthly Active Users` (B2C)     | 9.95M+     | $0.0025         | -           |
| `Basic Multi-Factor Authentication` (B2C) | Flat       | $0.0300         | None        |

> These rates are from the Azure Retail Prices API at `Global` region. The script shows zero for sub-cent rates. For non-USD currencies, use the method in [regions-and-currencies.md](../../regions-and-currencies.md).
