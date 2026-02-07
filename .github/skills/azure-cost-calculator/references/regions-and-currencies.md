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

> **Note**: Some services use non-standard regions. Private Link and Private DNS pricing is listed under `armRegionName = 'Global'` or an empty string — querying any standard region (e.g., `eastus`, `australiaeast`) returns **nothing**. See [pitfalls.md](pitfalls.md) for details.

## Known API-Unavailable Services

These services have **no pricing data** in the Azure Retail Prices API and must be estimated manually:

| Service                              | Manual Estimate               | Reference                                                                                           |
| ------------------------------------ | ----------------------------- | --------------------------------------------------------------------------------------------------- |
| DDoS Protection (Network Protection) | ~$2,944 USD/month flat fee    | [Azure DDoS Protection pricing](https://azure.microsoft.com/en-au/pricing/details/ddos-protection/) |
| DDoS Protection (IP Protection)      | ~$199 USD/month per public IP | [Azure DDoS Protection pricing](https://azure.microsoft.com/en-au/pricing/details/ddos-protection/) |

When encountering these services, note the limitation to the user and provide the manual fallback values above (in USD). If the user requires a different currency, use the currency derivation method below.

## USD-Only Services & Currency Conversion

Three service categories return pricing in **USD only** — either because they are API-unavailable or because they are listed under the `Global` region:

| Service              | Reason                                       | Reference                                                    |
| -------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| DDoS Protection      | Not in API at all                            | [ddos-protection.md](services/networking/ddos-protection.md) |
| Private Link         | Global region, USD only                      | [private-link.md](services/networking/private-link.md)       |
| Private DNS          | Global region, USD only                      | [private-dns.md](services/networking/private-dns.md)         |
| Functions (sub-cent) | API returns `$0.00` in all currencies        | [functions.md](services/compute/functions.md)                |
| Load Balancer        | No API data for public regions, USD fallback | [load-balancer.md](services/networking/load-balancer.md)     |

### Deriving a USD→local currency conversion factor

To convert USD-only prices to the user's currency, derive a conversion factor from a service that IS available in both currencies:

```powershell
# Step 1: Get a known service price in USD
.\Get-AzurePricing.ps1 -ServiceName 'Virtual Machines' -ArmSkuName 'Standard_D2s_v5' -Region australiaeast -Currency USD
# → e.g., $0.1240/hr

# Step 2: Get the same service price in the target currency
.\Get-AzurePricing.ps1 -ServiceName 'Virtual Machines' -ArmSkuName 'Standard_D2s_v5' -Region australiaeast -Currency AUD
# → e.g., $0.1916/hr

# Step 3: Derive factor
# AUD/USD = 0.1916 / 0.1240 ≈ 1.545
```

Apply this factor to all USD-only prices. Always note the conversion caveat to the user — the derived factor is approximate and may differ from the actual exchange rate.
