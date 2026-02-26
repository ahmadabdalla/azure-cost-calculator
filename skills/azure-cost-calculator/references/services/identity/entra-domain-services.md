---
serviceName: Microsoft Entra Domain Services
category: identity
aliases: [AAD DS, Azure AD DS, Managed AD]
billingNeeds: [Load Balancer, IP Addresses]
primaryCost: "Hourly per-SKU rate × 730 × instanceCount (meterName = forest type)"
---

# Microsoft Entra Domain Services

> **Trap**: Do not confuse with `Microsoft Entra ID` (identity platform — no API meters, per-user licensing) or `Microsoft Entra` (External ID / CIAM — consumption meters). This service is managed AD DS with hourly billing.

> **Trap (forest type)**: Standard SKU only supports User Forest. Enterprise and Premium support both User Forest and Resource Forest. Without `SkuName` and `MeterName` filters, all 5 meters are returned and summed — always filter by SKU and forest type.

## Query Pattern

### Standard — User Forest (most common)

ServiceName: Microsoft Entra Domain Services
ProductName: Microsoft Entra Domain Services
SkuName: Standard
MeterName: Standard User Forest

### Enterprise — User Forest (InstanceCount = replica sets)

ServiceName: Microsoft Entra Domain Services
ProductName: Microsoft Entra Domain Services
SkuName: Enterprise
MeterName: Enterprise User Forest
InstanceCount: 2

### Enterprise — Resource Forest (swap MeterName for on-prem trust deployments)

ServiceName: Microsoft Entra Domain Services
ProductName: Microsoft Entra Domain Services
SkuName: Enterprise
MeterName: Enterprise Resource Forest

### Premium — User or Resource Forest (swap MeterName as above)

ServiceName: Microsoft Entra Domain Services
ProductName: Microsoft Entra Domain Services
SkuName: Premium
MeterName: Premium User Forest

## Key Fields

| Parameter | How to determine | Example values |
| --- | --- | --- |
| `serviceName` | Always `Microsoft Entra Domain Services` | `Microsoft Entra Domain Services` |
| `productName` | Single product — same as serviceName | `Microsoft Entra Domain Services` |
| `skuName` | SKU tier selected at deployment | `Standard`, `Enterprise`, `Premium` |
| `meterName` | SKU + forest type combination | `Standard User Forest`, `Enterprise Resource Forest` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- |
| `Standard User Forest` | `Standard` | `1/Hour` | Standard only supports User Forest |
| `Enterprise User Forest` | `Enterprise` | `1/Hour` | Default forest — syncs from Entra ID |
| `Enterprise Resource Forest` | `Enterprise` | `1/Hour` | Uses outbound trusts to on-prem AD |
| `Premium User Forest` | `Premium` | `1/Hour` | Default forest — syncs from Entra ID |
| `Premium Resource Forest` | `Premium` | `1/Hour` | Uses outbound trusts to on-prem AD |

## Cost Formula

```
Monthly = retailPrice × 730 × instanceCount
```

## Notes

- **SKU tiers**: Standard (backups every 5 days, no trusts), Enterprise (every 3 days, up to 5 trusts), Premium (daily backups, 7+ trusts) — SKU determines auth-load and object-count guidance
- **Forest type** (never-assume): User Forest syncs from Entra ID; Resource Forest uses outbound trusts to on-prem AD — Standard only supports User Forest; same price within a SKU
- **Billing dependency**: Azure auto-deploys a Standard Load Balancer and Public IP with every managed domain — billed separately under `Load Balancer` and `IP Addresses`
- **Replica sets**: Each additional replica set (up to 5 per domain) is billed at the full SKU hourly rate
- Related services billed separately: `Microsoft Entra ID` (identity platform), VMs that join the managed domain
