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

> **Note**: Some services use non-standard regions. Private DNS pricing is listed under empty `armRegionName` or zone-based regions; querying any standard region returns **nothing** and the scripts cannot query it. Private Link, Load Balancer, and Defender CSPM use `armRegionName = 'Global'` and can be queried with `Region: Global`. See [pitfalls.md](pitfalls.md) for details.

## Known API-Unavailable Services

These services have **no pricing data** in the Azure Retail Prices API and must be estimated manually:

| Service            | Manual Estimate | Reference |
| ------------------ | --------------- | --------- |
| _(none currently)_ |                 |           |

If a service is added to this table, note the limitation to the user and provide the manual fallback values above. Manual fallback values are stated in USD, so convert them to the user's requested currency yourself. Do NOT direct them to the Azure pricing calculator.

## Currency Handling

`currencyCode` is a top-level query parameter, independent of `pricingRegion`. Region scoping controls which `armRegionName` values return rows; it does not constrain currency. Request the user's target currency and use the returned value directly, including for `global` and `empty-region` services.

Derive a conversion factor only for manual USD rates that the API does not publish.

## Sub-Cent Services

Consumption-based meters with per-unit prices below $0.01. See the Sub-Cent Pricing rule in [shared.md](shared.md#sub-cent-pricing-000-display) for the query-and-fallback procedure.

| Service        | Reference                                               |
| -------------- | ------------------------------------------------------- |
| Functions      | [functions.md](services/compute/functions.md)           |
| Container Apps | [container-apps.md](services/compute/container-apps.md) |

## Deriving a USD→local currency conversion factor

Use this only for manual USD rates that the API does not publish. Otherwise query the target currency directly.

> **MANDATORY**: You MUST use this exact anchor SKU; do NOT substitute any other service, even one already in the estimate. A fixed anchor keeps the derived factor deterministic across estimates.

**Fixed anchor: use these exact parameters (no substitutions):**

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

Note the caveat that the derived factor is approximate. Do NOT attach it to values the API returned in the target currency.
