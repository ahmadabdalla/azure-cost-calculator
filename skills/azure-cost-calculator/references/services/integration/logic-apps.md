---
serviceName: Logic Apps
category: integration
aliases: [Workflows, Logic App Standard/Consumption]
primaryCost: "Per-action (Consumption) or vCPU + memory hours (Standard)"
hasFreeGrant: true
privateEndpoint: true
---

# Logic Apps

> **Trap (executions vs actions)**: Azure bills per **action**, not per workflow execution. One run may contain 5–50+ actions. If user says "25,000 executions/month," clarify: multiply workflow runs × estimated actions/run.
>
> **Trap (inflated totals)**: Unfiltered queries return ISE, Integration Account, and workflow meters combined — always filter by `ProductName` and `SkuName`.
>
> **Trap (sub-cent actions)**: Consumption actions are sub-cent — use `Quantity` with expected monthly volume.
>
> **Trap (Built-in tiered)**: `Consumption Built-in Actions` returns two rows — a free allocation then a per-action rate. Sum both tiers.

## Query Pattern

### Consumption — connector actions (use Quantity; substitute Standard/Enterprise connector type)

ServiceName: Logic Apps
ProductName: Logic Apps
SkuName: Consumption
MeterName: Consumption {ConnectorType} Connector Actions
Quantity: 10000

### Standard — vCPU + memory (use InstanceCount for plan count)

ServiceName: Logic Apps
ProductName: Logic Apps
SkuName: Standard
InstanceCount: 2

### Hybrid — on-premises vCPU hours

ServiceName: Logic Apps
ProductName: Logic Apps
SkuName: Hybrid
MeterName: Hybrid vCPU Duration

### Integration Account (add-on for B2B) — substitute tier: Basic, Standard, Premium

ServiceName: Logic Apps
ProductName: Logic Apps Integration Account
MeterName: {Tier} Unit

## Meter Names

| Meter                                      | skuName       | unitOfMeasure | Notes                     |
| ------------------------------------------ | ------------- | ------------- | ------------------------- |
| `Consumption Standard Connector Actions`   | `Consumption` | `1`           | Per-action                |
| `Consumption Enterprise Connector Actions` | `Consumption` | `1`           | Per-action                |
| `Consumption Built-in Actions`             | `Consumption` | `1`           | Tiered — first 4,000 free |
| `Consumption Data Retention`               | `Consumption` | `1 GB/Month`  | Run history storage       |
| `Standard vCPU Duration`                   | `Standard`    | `1 Hour`      | Per vCPU                  |
| `Standard Memory Duration`                 | `Standard`    | `1 GiB Hour`  | Per GiB                   |
| `Hybrid vCPU Duration`                     | `Hybrid`      | `1 Hour`      | On-premises vCPU          |
| `Consumption Agent Loop Input Token`       | `Consumption` | `1M`          | AI agent input tokens     |
| `Consumption Agent Loop Output Token`      | `Consumption` | `1M`          | AI agent output tokens    |

> Integration Account meters (`Basic Unit`, `Standard Unit`, `Premium Unit`) are flat monthly — query with ProductName `Logic Apps Integration Account`.

## Cost Formula

```text
Consumption: Monthly = (stdActions × stdPrice) + (entActions × entPrice) + max(0, builtInActions − 4000) × builtInPrice + retentionGB × retentionPrice
Standard:    Monthly = (vCPU_price × vCPUs × 730) + (memory_price × memoryGiB × 730)
Hybrid:      Monthly = vCPU_price × vCPUs × 730
Integration Account (add-on): Monthly = retailPrice (flat monthly per tier)
```

## Notes

- **Billing unit is actions, not workflow executions** — each step counts as one action
- Consumption: per-action, first 4,000 built-in actions/month free, auto-scales to zero
- Standard: runs on App Service Plan (WS1–WS3) or container; billed per-second
- Integration Account is a separate B2B/EDI add-on; ISE is deprecated — use Standard with VNet instead
- **Private Endpoints**: Require Standard tier with VNet integration

## Standard Plan Sizes (WS)

The API returns generic `Standard vCPU Duration` and `Standard Memory Duration` — NO WS1/WS2/WS3-specific meter. Multiply by plan specs below.

| Plan | vCPUs | Memory (GiB) | Monthly Formula                                     |
| ---- | ----- | ------------ | --------------------------------------------------- |
| WS1  | 1     | 3.5          | (vCPU_price × 1 × 730) + (memory_price × 3.5 × 730) |
| WS2  | 2     | 7            | (vCPU_price × 2 × 730) + (memory_price × 7 × 730)   |
| WS3  | 4     | 14           | (vCPU_price × 4 × 730) + (memory_price × 14 × 730)  |

> **Agent instruction**: When the user says "Logic Apps Standard WS2", query `Logic Apps` SkuName `Standard` for generic per-vCPU and per-GiB hourly rates, then multiply by WS2 specs (2 vCPU, 7 GiB).
