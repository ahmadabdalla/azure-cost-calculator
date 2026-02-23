---
serviceName: Application Gateway
category: networking
aliases: [App Gateway, AGW, WAF, Azure WAF, WAF v2, Web Application Firewall, WAF Policy]
primaryCost: "Gateway hours (fixed cost) + capacity units processed"
privateEndpoint: true
---

# Application Gateway

> **Trap**: Product names do NOT have the "Azure" prefix — use `'Application Gateway WAF v2'`, not `'Azure Application Gateway WAF v2'`.
> **Trap**: You need TWO separate queries — one for the fixed hourly cost and one for capacity units. A single unfiltered query returns both meters mixed together.

## Query Pattern

Substitute `{Variant}` with `WAF v2`, `Standard v2`, or `Basic v2` (see Product Names table). WAF v2 and Standard v2 use `Standard` meter prefix; Basic v2 uses `Basic` meter prefix. Run **two queries per variant**:

### {Variant} — fixed cost

ServiceName: Application Gateway
ProductName: Application Gateway {Variant}
MeterName: {MeterPrefix} Fixed Cost

### {Variant} — capacity units

ServiceName: Application Gateway
ProductName: Application Gateway {Variant}
MeterName: {MeterPrefix} Capacity Units

## Cost Formula

```
Monthly = (fixedCost_unitPrice × 730) + (capacityUnit_unitPrice × estimatedCUs × 730)
```

## Notes

- **Default CU assumption (MANDATORY)**: When the user does NOT specify expected traffic or CU count, use a default of **10 CUs** (light-to-moderate workload baseline). Do NOT use 0 CUs and do NOT omit CU costs — the fixed cost alone underestimates real-world spend. Always state the CU assumption to the user.
- Capacity Units (CU) are consumption-based — if the user specifies their expected traffic, calculate CUs from that instead of using the default
- A CU measures: ~2,500 concurrent connections, ~2.22 Mbps throughput, or ~1 compute unit
- **CU from data volume**: 1 CU ≈ 2.22 Mbps sustained ≈ 0.98 GB/hr. For monthly data: `CUs = dataGB / (0.98 × 730)`. Example: 5 TB (5,000 GB) → ~7 CU average. Add headroom for burst — use 1.5–2× for production.
- For light workloads, estimate ~5-10 CU average; for moderate, ~10-30 CU
- WAF v2 fixed cost is ~1.8× Standard v2 fixed cost; CU price is also higher. WAF v2 also has `Standard Captcha Sessions` (per 1K) for CAPTCHA challenges
- **Front Door WAF**: Front Door has its own WAF meters (policies, rulesets, bot protection) — see `networking/front-door.md`
- **App Gateway for Containers WAF**: Separate product (`Application Gateway for Containers WAF`) with different meters (AGC, Frontend, Association, Capacity Units)

## Product Names

| Variant     | productName                       | MeterPrefix | Fixed Cost Meter      | CU Meter                  |
| ----------- | --------------------------------- | ----------- | --------------------- | ------------------------- |
| WAF v2      | `Application Gateway WAF v2`      | `Standard`  | `Standard Fixed Cost` | `Standard Capacity Units` |
| Standard v2 | `Application Gateway Standard v2` | `Standard`  | `Standard Fixed Cost` | `Standard Capacity Units` |
| Basic v2    | `Application Gateway Basic v2`    | `Basic`     | `Basic Fixed Cost`    | `Basic Capacity Units`    |
