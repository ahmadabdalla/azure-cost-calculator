---
serviceName: Foundry Agents
category: ai-ml
aliases: [AI Agents, Agent Orchestration, HOBO Agents, SRE Agent]
billingNeeds: [Azure OpenAI Service]
apiServiceName: Foundry Tools
primaryCost: "Hosted compute (vCPU + memory × 730 hrs/mo) + per-unit SRE agent charges; model inference billed separately."
---

# Foundry Agents

> **Trap (serviceName)**: API `serviceName` is `Foundry Tools`, NOT `Foundry Agents`. Always filter by `ProductName` to isolate agent meters from the 300+ Foundry Tools meters.

> **Trap (multiple products)**: Two `productName` values — `Foundry Agents` (compute vCPU/memory) and `Azure Agent Unit` (SRE orchestration). Queries without `ProductName` filter will mix compute and SRE meters.

> **Trap (mixed units)**: Compute meters use `1 Hour` (multiply by 730), but SRE Agent Unit uses `unitOfMeasure: 1` (per-unit, not hourly). Do NOT multiply SRE cost by 730.

## Query Pattern

### Hosted agent compute — vCPU

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Foundry Agents
SkuName: Hosted HOBO
MeterName: Hosted HOBO vCPU Usage
InstanceCount: 4 # vCPUs allocated

### Hosted agent compute — memory

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Foundry Agents
SkuName: Hosted HOBO
MeterName: Hosted HOBO Memory Usage
Quantity: 8 # GBs of memory

### SRE Agent Unit

ServiceName: Foundry Tools <!-- cross-service -->
ProductName: Azure Agent Unit
SkuName: SRE
MeterName: SRE Agent Unit
Quantity: 500 # agent units consumed

## Key Fields

| Parameter     | How to determine               | Example values                             |
| ------------- | ------------------------------ | ------------------------------------------ |
| `serviceName` | Always `Foundry Tools`         | `Foundry Tools`                            |
| `productName` | Billing dimension              | `Foundry Agents`, `Azure Agent Unit`       |
| `skuName`     | Compute SKU or agent type      | `Hosted HOBO`, `SRE`                       |
| `meterName`   | Specific resource being billed | `Hosted HOBO vCPU Usage`, `SRE Agent Unit` |

## Meter Names

| Meter                      | productName        | unitOfMeasure | Notes                         |
| -------------------------- | ------------------ | ------------- | ----------------------------- |
| `Hosted HOBO vCPU Usage`   | `Foundry Agents`   | `1 Hour`      | Per vCPU-hour of compute      |
| `Hosted HOBO Memory Usage` | `Foundry Agents`   | `1 Hour`      | Per GB-hour of memory         |
| `SRE Agent Unit`           | `Azure Agent Unit` | `1`           | Per-unit orchestration charge |

## Cost Formula

```
vCPU:    Monthly = vCPU_retailPrice × vCPUs × 730
Memory:  Monthly = memory_retailPrice × GBs × 730
SRE:     Monthly = sre_retailPrice × agentUnits
Total:   Monthly = vCPU + Memory + SRE
```

## Notes

- **Billing dependency**: Agent compute only — model inference (LLM tokens) billed separately via Azure OpenAI; see `openai-service.md`
- **Regional availability**: Compute meters in 24 regions; SRE Agent Unit in 6 regions only (eastus, eastus2, centralus, westus3, swedencentral, australiaeast)
- **Capacity planning**: 1 unit = 1 vCPU-hour or 1 GB-hour (compute), 1 agent unit (SRE); scale `InstanceCount`/`Quantity` to match allocation
- **Scope**: Part of Foundry Tools umbrella — see `ai-services.md` for other sub-services (Language, Vision, Speech, Translator)
