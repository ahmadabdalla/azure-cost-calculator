---
serviceName: Foundry Agents
category: ai-ml
aliases: [AI Agents, Agent Orchestration, HOBO Agents, SRE Agent]
billingNeeds: [Azure OpenAI Service]
apiServiceName: Foundry Tools
primaryCost: "Hosted compute (vCPU + memory × 730 hrs/mo) + skills execution + per-unit SRE agent charges."
---

# Foundry Agents

> **Trap (serviceName)**: API `serviceName` is `Foundry Tools`, NOT `Foundry Agents`. Always filter by `ProductName` to isolate agent meters from the 300+ Foundry Tools meters.

> **Trap (multiple products)**: Two `productName` values: `Foundry Agents` (compute and skills execution) and `Azure Agent Unit` (SRE orchestration). Queries without `ProductName` filter will mix unrelated meters.

> **Trap (mixed units)**: Compute meters use `1 Hour` (multiply by 730), but SRE Agent Unit uses `unitOfMeasure: 1` (per-unit, not hourly). Do NOT multiply SRE cost by 730.

> **Trap (memory regions)**: `Long Term Memory`, `Short Term Memory`, and `Memory Retrieval` meters return zero in `eastus`; use `eastus2` or another supported region.

## Query Pattern

### Hosted agent compute: vCPU

ServiceName: Foundry Tools
ProductName: Foundry Agents
SkuName: Hosted
MeterName: Hosted vCPU Usage
Quantity: 4 # vCPUs allocated

### Hosted agent compute: memory

ServiceName: Foundry Tools
ProductName: Foundry Agents
SkuName: Hosted
MeterName: Hosted Memory Usage
Quantity: 8 # GBs of memory

### Long-term memory
ServiceName: Foundry Tools
ProductName: Foundry Agents
SkuName: Long Term Memory
MeterName: Long Term Memory Memories
Region: eastus2
Quantity: 100 # thousands of memories

### Short-term memory
ServiceName: Foundry Tools
ProductName: Foundry Agents
SkuName: Short Term Memory
MeterName: Short Term Memory Events Stored
Region: eastus2
Quantity: 100 # thousands of stored events

### Memory retrieval
ServiceName: Foundry Tools
ProductName: Foundry Agents
SkuName: Memory Retrieval
MeterName: Memory Retrievals
Region: eastus2
Quantity: 100 # thousands of retrievals

### Skills execution container

ServiceName: Foundry Tools
ProductName: Foundry Agents
SkuName: Skills Execution
MeterName: Skills Execution Container
Quantity: 2 # container-hours consumed

### SRE Agent Unit

ServiceName: Foundry Tools
ProductName: Azure Agent Unit
SkuName: SRE
MeterName: SRE Agent Unit
Quantity: 500 # agent units consumed

## Key Fields

| Parameter     | How to determine                                                      | Example values                                                      |
| ------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------- |
| `serviceName` | Always `Foundry Tools` (API value; see apiServiceName in frontmatter) | `Foundry Tools`                                                     |
| `productName` | Billing dimension                                                     | `Foundry Agents`, `Azure Agent Unit`                                |
| `skuName`     | Compute SKU or agent type                                             | `Hosted`, `Skills Execution`, `Long Term Memory`, `SRE`             |
| `meterName`   | Specific resource being billed                                        | `Hosted vCPU Usage`, `Skills Execution Container`, `SRE Agent Unit` |

## Meter Names

| Meter                             | skuName             | productName        | unitOfMeasure | Notes                         |
| --------------------------------- | ------------------- | ------------------ | ------------- | ----------------------------- |
| `Hosted vCPU Usage`               | `Hosted`            | `Foundry Agents`   | `1 Hour`      | Per vCPU-hour of compute      |
| `Hosted Memory Usage`             | `Hosted`            | `Foundry Agents`   | `1 Hour`      | Per GB-hour of memory         |
| `Skills Execution Container`      | `Skills Execution`  | `Foundry Agents`   | `1 Hour`      | Per hour of skills container  |
| `Long Term Memory Memories`       | `Long Term Memory`  | `Foundry Agents`   | `1K/Month`    | Persistent memory storage     |
| `Short Term Memory Events Stored` | `Short Term Memory` | `Foundry Agents`   | `1K`          | Ephemeral event storage       |
| `Memory Retrievals`               | `Memory Retrieval`  | `Foundry Agents`   | `1K`          | Per-1K memory read operations |
| `SRE Agent Unit`                  | `SRE`               | `Azure Agent Unit` | `1`           | Per-unit orchestration charge |

## Cost Formula

```
vCPU:      Monthly = vCPU_retailPrice × vCPUs × 730
Memory:    Monthly = memory_retailPrice × GBs × 730
Skills:    Monthly = skills_retailPrice × containerHours
LTM:       Monthly = ltm_retailPrice × (memories / 1000)
STM:       Monthly = stm_retailPrice × (events / 1000)
Retrieval: Monthly = retrieval_retailPrice × (retrievals / 1000)
SRE:       Monthly = sre_retailPrice × agentUnits
Total:     Monthly = vCPU + Memory + Skills + LTM + STM + Retrieval + SRE
```

## Notes

- **Billing dependency**: Agent compute only; model inference (LLM tokens) billed separately via Azure OpenAI; see `openai-service.md`
- **Optional commit pricing**: Agent Commit Unit bundles are separate `Foundry Models` reservation items under `Microsoft Agent Pre-Purchase Plan`
- **Regional availability**: Hosted compute is multi-region, memory meters require `eastus2` or another supported region, and SRE coverage differs by region
- **Capacity planning**: 1 unit = 1 vCPU-hour or 1 GB-hour (compute), 1 container-hour (skills), 1 agent unit (SRE); scale `Quantity` to match allocation
- **Scope**: Part of Foundry Tools umbrella (see `ai-services.md` for other sub-services)
