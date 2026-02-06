````markdown
# DDoS Protection

> **⚠ API UNAVAILABLE**: DDoS Protection pricing is **NOT available** in the Azure Retail Prices API. Searching by serviceName, productName, or meterName containing "DDoS" across all regions returns zero results.
> **Trap**: The manual fallback prices below are in **USD** — the only currency available for this service. Direct users to the Azure pricing calculator for local-currency equivalents.
>
> **Agent instruction**: Do NOT attempt to query this service via the scripts — it will always return zero results. Use the manual fallback table below directly and note the API limitation to the user.

**This service requires manual estimation only.**

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

## Query Pattern

**Not applicable** — no script can query this service. Return the manual estimates above and note the limitation to the user.

## Notes

- Network Protection is significantly cheaper per-IP if you have many public IPs (break-even at ~15 IPs)
- IP Protection is better for small deployments with 1-14 public IPs
- Both plans include DDoS rapid response (DRR) support
- Overage charges may apply for data processing above included limits
- Prices are in USD (only available currency for this service). If the user requires a different currency, note these are approximate USD values and direct them to the Azure pricing calculator for local-currency equivalents.
````
