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

| Service       | Manual Estimate              | Reference                                                                                       |
| ------------- | ---------------------------- | ----------------------------------------------------------------------------------------------- |
| Defender CSPM | $5.11 USD/month per resource | [Azure Defender pricing](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/) |

When encountering these services, note the limitation to the user and provide the manual fallback values above (in USD). If the user's requested currency is NOT USD, you **MUST** derive a conversion factor using the method below and convert all USD-only prices to the target currency. Do NOT leave prices in USD when the user requested a different currency. Do NOT direct them to the Azure pricing calculator — perform the conversion yourself.

## USD-Only Services

These services return pricing in **USD only** — either because they are API-unavailable or because they are listed under the `Global` region:

| Service       | Reason                                                                 | Reference                                                        |
| ------------- | ---------------------------------------------------------------------- | ---------------------------------------------------------------- |
| Private Link  | Global region, USD only; use `Region: Global`                          | [private-link.md](services/networking/private-link.md)           |
| Private DNS   | Empty-region pricing (`armRegionName == ''`); USD only; use workaround | [private-dns.md](services/networking/private-dns.md)             |
| Defender CSPM | Not in API at all                                                      | [defender-for-cloud.md](services/security/defender-for-cloud.md) |
| Load Balancer | Global region, USD only; use `Region: Global`                          | [load-balancer.md](services/networking/load-balancer.md)         |

## Sub-Cent Services

Consumption-based meters with per-unit prices below $0.01. See the Sub-Cent Pricing rule in [shared.md](shared.md#sub-cent-pricing-000-display) for the query-and-fallback procedure.

| Service        | Reference                                               |
| -------------- | ------------------------------------------------------- |
| Functions      | [functions.md](services/compute/functions.md)           |
| Container Apps | [container-apps.md](services/compute/container-apps.md) |

## Deriving a USD→local currency conversion factor

When ANY service in the estimate returns USD-only prices and the user requested a non-USD currency, you **MUST** perform this conversion. Do NOT skip it. Do NOT leave individual services in USD while others are in the target currency.

> **MANDATORY**: You MUST use this exact anchor SKU — do NOT substitute any other service, even one already in the estimate. Azure sets local-currency prices independently per service, so different anchors yield different factors and non-deterministic results.

**Fixed anchor — use these exact parameters (no substitutions):**

```
# Step 1: Query anchor in USD

ServiceName: Virtual Machines
ArmSkuName: Standard_B2s
ProductName: Virtual Machines BS Series
Region: <user's region>
Currency: USD

# Step 2: Query anchor in target currency (same parameters, different currency)

ServiceName: Virtual Machines
ArmSkuName: Standard_B2s
ProductName: Virtual Machines BS Series
Region: <user's region>
Currency: <target currency>

# Step 3: Derive factor

factor = target_price / usd_price
```

Apply this factor to all USD-only prices. Always note the conversion caveat to the user — the derived factor is approximate and may differ from the actual exchange rate.
