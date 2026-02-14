---
serviceName: Logic Apps
category: integration
aliases: [Workflows, Logic App Standard/Consumption]
---

# Logic Apps

**Primary cost**: Per-action (Consumption) or vCPU + memory hours (Standard)

> **Trap (executions vs actions)**: Azure bills per **action**, not per workflow execution. One workflow execution may contain 5–50+ actions (each trigger, HTTP call, condition, loop iteration, etc. is one action). If user says "25,000 executions/month," clarify whether they mean 25,000 workflow runs — if so, multiply by estimated actions per run (e.g., 10 actions/run = 250,000 billable actions).

> **Trap (inflated totals)**: Unfiltered queries return ISE, Integration Account, and workflow meters combined — `totalMonthlyCost` is wildly inflated. Always filter by `ProductName` and `SkuName`.

> **Trap (sub-cent actions)**: Consumption connector actions are priced at sub-cent levels per action — the script shows minimal cost for low volumes. Use `Quantity` with expected monthly volume.

> **Trap (Built-in tiered)**: `Consumption Built-in Actions` returns two rows — a free monthly allocation then a low per-action rate. Sum both tiers.

## Query Pattern

All patterns below use `ServiceName: Logic Apps` and `ProductName: Logic Apps` unless noted otherwise.

### Consumption — standard connector actions (use Quantity for monthly volume)

SkuName: Consumption
MeterName: Consumption Standard Connector Actions
Quantity: 10000

### Consumption — enterprise connector actions

SkuName: Consumption
MeterName: Consumption Enterprise Connector Actions
Quantity: 5000

### Standard — vCPU hours (per-vCPU, use InstanceCount for multiple vCPUs)

SkuName: Standard
MeterName: Standard vCPU Duration
InstanceCount: 2

### Standard — memory (per GiB-hour)

SkuName: Standard
MeterName: Standard Memory Duration

### Hybrid — on-premises vCPU hours

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

> Integration Account meters (`Basic Unit`, `Standard Unit`, `Premium Unit`) are flat monthly — query with ProductName `Logic Apps Integration Account`.

## Cost Formula

```
Consumption: Monthly = (stdActions × $stdPrice) + (entActions × $entPrice) + max(0, builtInActions − 4000) × $builtInPrice + retentionGB × $retentionPrice
Standard:    Monthly = vCPU_retailPrice × 730 × vCPUs + memory_retailPrice × 730 × memoryGiB
Hybrid:      Monthly = vCPU_retailPrice × 730 × vCPUs
Integration Account (add-on): Monthly = retailPrice (flat monthly per tier)
```

## Notes

- **Billing unit is actions, not workflow executions** — each step (trigger, HTTP, condition, loop iteration, etc.) counts as one action
- Consumption: per-action pricing, first 4,000 built-in actions/month free, auto-scales to zero
- Standard: runs on App Service Plan (WS1–WS3) or as container; vCPU+memory billed per-second
- Integration Account is a separate add-on for B2B/EDI scenarios — not required for basic workflows
- ISE (Integration Service Environment) is deprecated — use Standard tier with VNet integration instead
- Standard tier supports VNet integration, private endpoints, and stateful/stateless workflows
