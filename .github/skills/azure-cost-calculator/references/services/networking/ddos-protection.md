---
serviceName: not in API
category: networking
aliases: [DDoS, DDoS protection]
---

# DDoS Protection

> **⚠ API UNAVAILABLE**: DDoS Protection pricing is **NOT available** in the Azure Retail Prices API. Searching by serviceName, productName, or meterName containing "DDoS" across all regions returns zero results.
> **Trap**: The manual fallback prices below are in **USD only**.
>
> **Agent instruction**: Do NOT attempt to query this service via the scripts — it will always return zero results. Use the manual fallback table below directly and note the API limitation to the user.
>
> **Currency instruction (MANDATORY)**: If the user's requested currency is NOT USD, you **MUST** convert the USD fallback prices using the currency derivation method in [regions-and-currencies.md](../../regions-and-currencies.md#deriving-a-usdlocal-currency-conversion-factor). Do NOT leave prices in USD when the user requested a different currency. Do NOT direct the user to the Azure pricing calculator — derive the factor yourself and apply it.

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
- Prices are in USD (only available currency for this service). If the user requested a non-USD currency, you **MUST** convert using the derivation method in [regions-and-currencies.md](../../regions-and-currencies.md#deriving-a-usdlocal-currency-conversion-factor). Always note the conversion is approximate.
