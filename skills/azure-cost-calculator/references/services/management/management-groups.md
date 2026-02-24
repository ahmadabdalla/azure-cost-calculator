---
serviceName: Management Groups
category: management
aliases: [Management Group, Azure Management Groups, Subscription Organization]
primaryCost: "Free — no charges for creating or using management groups."
hasMeters: false
pricingRegion: api-unavailable
---

# Management Groups

> **Trap**: The API returns no meters for Management Groups. Do NOT query for pricing — this is a free service.
>
> **Agent instruction**: Report zero cost per month. Management Groups have no cost regardless of quantity.

## Query Pattern

### No pricing meters exist — included for validation only
### Management Groups is a free governance service
ServiceName: Management Groups
Quantity: 1
### Expected: 0 results — this service has no retail meter

## Cost Formula

```
Monthly = zero cost (free service, no meters)
```

## Notes

- Management Groups are **completely free** with no usage limits
- Used to organize subscriptions into a hierarchy for governance, policy, and access management
- Each Azure AD tenant gets a single root management group
- Supports up to six levels of depth (excluding the root and subscription level)
- Azure Policy and RBAC assignments applied at a management group scope cascade to child subscriptions
