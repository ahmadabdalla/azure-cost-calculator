---
serviceName: Application Gateway for Containers
category: networking
aliases: [AGfC, AGC, App Gateway for Containers]
apiServiceName: Application Gateway
billingNeeds: [IP Addresses]
primaryCost: "AGC + frontend + association hours (fixed) + capacity unit hours (variable) per variant"
---

# Application Gateway for Containers

> **Trap**: API `serviceName` is `Application Gateway` (shared with App Gateway v2). Every query MUST include `ProductName` to isolate AGfC meters — without it, results mix 27+ meters from all Application Gateway products.
> **Trap**: AGfC has no `Fixed Cost` meter. Instead, three fixed hourly meters (AGC, Frontend, Association) replace the single fixed meter in App Gateway v2. Query each meter separately with `MeterName` filter.

## Query Pattern

Substitute `{Variant}` with `Application Gateway for Containers` (Standard) or `Application Gateway for Containers WAF` (WAF). Meter names are identical across variants; only `productName` changes. Run **four queries per variant**:

### {Variant}: AGC resource (fixed hourly)

ServiceName: Application Gateway
ProductName: {Variant}
MeterName: Standard AGC

### {Variant}: frontend (Quantity = number of frontends)

ServiceName: Application Gateway
ProductName: {Variant}
MeterName: Standard Frontend
Quantity: 2

### {Variant}: association (Quantity = number of associations)

ServiceName: Application Gateway
ProductName: {Variant}
MeterName: Standard Association
Quantity: 1

### {Variant}: capacity units (Quantity = estimated average CUs)

ServiceName: Application Gateway
ProductName: {Variant}
MeterName: Standard Capacity Units
Quantity: 10

## Meter Names

| Variant  | productName                              | AGC Meter      | Frontend Meter      | Association Meter      | CU Meter                  |
| -------- | ---------------------------------------- | -------------- | ------------------- | ---------------------- | ------------------------- |
| Standard | `Application Gateway for Containers`     | `Standard AGC` | `Standard Frontend` | `Standard Association` | `Standard Capacity Units` |
| WAF      | `Application Gateway for Containers WAF` | `Standard AGC` | `Standard Frontend` | `Standard Association` | `Standard Capacity Units` |

> **Note**: Meter names are identical across variants. Only `productName` changes. WAF rates are ~1.8× Standard rates.

## Cost Formula

```
Monthly = agc_retailPrice × 730
        + frontend_retailPrice × frontendCount × 730
        + association_retailPrice × associationCount × 730
        + cu_retailPrice × estimatedCUs × 730
```

## Notes

- **Default CU assumption (MANDATORY)**: When the user does NOT specify expected traffic or CU count, use a default of **10 CUs**. Do NOT omit CU costs. Always disclose the CU assumption.
- 1 CU ≈ 2,500 persistent connections or 2.22 Mbps throughput; scale CU count to match expected traffic
- Standard vs WAF: WAF adds web application firewall protection; all 4 meters are priced higher. No mixed billing — all meters use the same variant
- AGfC is a separate product from Application Gateway v2; see `networking/application-gateway.md` for the v2 reference
- Typical deployment: 1 AGC, 1+ frontends, 1+ associations. Frontend and association counts are never-assume parameters
- **Public IPs billed separately**: Internet-facing AGfC frontends require Standard SKU Public IP addresses, billed under IP Addresses
- `skuName` is `Standard` for both variants; only `productName` distinguishes Standard from WAF
