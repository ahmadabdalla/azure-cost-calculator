---
name: estimate-cost
description: "Estimate Azure costs for an architecture, deployment plan, or set of resource requirements. Accepts natural language descriptions or @file references."
argument-hint: "<architecture description or @file>"
disable-model-invocation: true
context: fork
agent: cost-analyst
---

Estimate the Azure costs for the following architecture:

$ARGUMENTS

Use the **cost-analyst** agent to perform this estimation. The agent follows the `skills/azure-cost-calculator/SKILL.md` workflow to produce a deterministic, API-backed cost estimate. Do not guess prices — all costs must come from live Azure Retail Prices API queries.
