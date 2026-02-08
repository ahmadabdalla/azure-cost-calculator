---
serviceName: not in API
category: networking
aliases: [DDoS, DDoS protection]
---

# DDoS Protection

> ⚠ **API unavailable / USD-only** — see shared.md § Common Traps. Do not query via scripts. Use manual fallback table below.

**This service requires manual estimation only.**

## Query Pattern

**Not applicable** — no script can query this service. Return the manual estimates above and note the limitation to the user.

## Pricing (manual fallback)

| Plan               | Monthly Cost (USD) | Scope                            |
| ------------------ | ------------------ | -------------------------------- |
| Network Protection | ~$2,944/month      | Covers all resources in a VNet   |
| IP Protection      | ~$199/month/IP     | Per individual public IP address |

> Source: [Azure DDoS Protection pricing](https://azure.microsoft.com/en-au/pricing/details/ddos-protection/)

## Cost Formula

```
Network Protection:
  Monthly = ~$2,944 USD (flat fee, covers entire VNet)

IP Protection:
  Monthly = ~$199 USD × publicIPCount
```

## Notes

- Network Protection is significantly cheaper per-IP if you have many public IPs (break-even at ~15 IPs)
- IP Protection is better for small deployments with 1-14 public IPs
- Both plans include DDoS rapid response (DRR) support
- Overage charges may apply for data processing above included limits
- USD-only — see shared.md § Common Traps for mandatory currency conversion
