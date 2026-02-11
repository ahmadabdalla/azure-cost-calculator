# Regions, Currencies & API-Unavailable Services

Reference for region names, currency handling, and services not available in the Retail Prices API. Only loaded when needed for region lookup or currency conversion.

## Common Region Names

| Display Name        | armRegionName        |
| ------------------- | -------------------- |
| Australia East      | `australiaeast`      |
| Australia Southeast | `australiasoutheast` |
| East US             | `eastus`             |
| East US 2           | `eastus2`            |
| West US 2           | `westus2`            |
| West Europe         | `westeurope`         |
| North Europe        | `northeurope`        |
| UK South            | `uksouth`            |
| Southeast Asia      | `southeastasia`      |
| Japan East          | `japaneast`          |
| Central US          | `centralus`          |
| Canada Central      | `canadacentral`      |

> **Note**: Some services use non-standard regions. Private DNS pricing is listed under empty `armRegionName` or zone-based regions — querying any standard region returns **nothing** and the scripts cannot query it. Private Link and Load Balancer use `armRegionName = 'Global'` and can be queried with `Region: Global`. See [pitfalls.md](pitfalls.md) for details.

## Known API-Unavailable Services

These services have **no pricing data** in the Azure Retail Prices API and must be estimated manually:

| Service                              | Manual Estimate               | Reference                                                                                           |
| ------------------------------------ | ----------------------------- | --------------------------------------------------------------------------------------------------- |
| DDoS Protection (Network Protection) | ~$2,944 USD/month flat fee    | [Azure DDoS Protection pricing](https://azure.microsoft.com/en-au/pricing/details/ddos-protection/) |
| DDoS Protection (IP Protection)      | ~$199 USD/month per public IP | [Azure DDoS Protection pricing](https://azure.microsoft.com/en-au/pricing/details/ddos-protection/) |
| Defender CSPM                        | $5.11 USD/month per resource  | [Azure Defender pricing](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/)     |

When encountering these services, note the limitation to the user and provide the manual fallback values above (in USD). If the user's requested currency is NOT USD, you **MUST** derive a conversion factor using the method below and convert all USD-only prices to the target currency. Do NOT leave prices in USD when the user requested a different currency. Do NOT direct them to the Azure pricing calculator — perform the conversion yourself.

## USD-Only Services & Currency Conversion

Three service categories return pricing in **USD only** — either because they are API-unavailable or because they are listed under the `Global` region:

| Service              | Reason                                        | Reference                                                        |
| -------------------- | --------------------------------------------- | ---------------------------------------------------------------- |
| DDoS Protection      | Not in API at all                             | [ddos-protection.md](services/networking/ddos-protection.md)     |
| Private Link         | Global region, USD only; use `Region: Global` | [private-link.md](services/networking/private-link.md)           |
| Private DNS          | Global region, USD only                       | [private-dns.md](services/networking/private-dns.md)             |
| Defender CSPM        | Not in API at all                             | [defender-for-cloud.md](services/security/defender-for-cloud.md) |
| Functions (sub-cent) | API returns `$0.00` in all currencies         | [functions.md](services/compute/functions.md)                    |
| Load Balancer        | Global region, USD only; use `Region: Global` | [load-balancer.md](services/networking/load-balancer.md)         |

### Deriving a USD→local currency conversion factor (MANDATORY for non-USD requests)

When ANY service in the estimate returns USD-only prices and the user requested a non-USD currency, you **MUST** perform this conversion. Do NOT skip it. Do NOT leave individual services in USD while others are in the target currency.

> **IMPORTANT**: Reuse a regional service already in the estimate (e.g., the user's VM SKU) to derive the conversion factor. Query it once in USD and once in the target currency, then divide. This avoids extra API calls for a separate reference SKU. Use the same SKU consistently within a single estimate.

```
# Step 1: Query a regional service already in the estimate (USD)

ServiceName: Virtual Machines
ArmSkuName: Standard_D2s_v5
Region: australiaeast
Currency: USD

→ e.g., $0.1200/hr

# Step 2: Query the SAME service in the target currency

ServiceName: Virtual Machines
ArmSkuName: Standard_D2s_v5
Region: australiaeast
Currency: AUD

→ e.g., $0.1715/hr

# Step 3: Derive factor

AUD/USD = 0.1715 / 0.1200 ≈ 1.4292
```

Apply this factor to all USD-only prices. Always note the conversion caveat to the user — the derived factor is approximate and may differ from the actual exchange rate.
