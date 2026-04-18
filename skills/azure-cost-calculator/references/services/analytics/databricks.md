---
serviceName: Azure Databricks
category: analytics
aliases: [DBX, Spark on Azure]
billingNeeds: [Virtual Machines]
billingConsiderations: [Reserved Instances]
primaryCost: "DBU rate × tier; classic adds VM compute (Virtual Machines); serverless includes compute in DBU rate"
privateEndpoint: true
---

# Azure Databricks

> **Trap (inflated totals)**: An unfiltered `ServiceName 'Azure Databricks'` query returns ~41 meters across classic and serverless workloads, POC, and free-trial SKUs. The `totalMonthlyCost` sums all of them which is meaningless. Always filter by `SkuName` for a specific workload type.

> **Trap (VM compute split)**: Classic workloads (`productName: Azure Databricks`) charge DBU platform fees only — estimate VM cost separately via Virtual Machines. Serverless workloads (`productName: Azure Databricks Regional`) include compute in the DBU rate.

## Query Pattern

### Premium Jobs Compute: e.g., 10 DBUs running full month

ServiceName: Azure Databricks
ProductName: Azure Databricks
SkuName: Premium Jobs Compute
Quantity: 10

### Premium All-purpose Compute: interactive clusters

ServiceName: Azure Databricks
ProductName: Azure Databricks
SkuName: Premium All-purpose Compute

### Premium Serverless SQL: serverless SQL warehouse

ServiceName: Azure Databricks
ProductName: Azure Databricks Regional
SkuName: Premium Serverless SQL

## Key Fields

| Parameter     | How to determine                | Example values                                                 |
| ------------- | ------------------------------- | -------------------------------------------------------------- |
| `serviceName` | Always `Azure Databricks`       | `Azure Databricks`                                             |
| `productName` | Classic vs serverless workloads | `Azure Databricks`, `Azure Databricks Regional`                |
| `skuName`     | Tier + workload type            | `Premium Jobs Compute`, `Standard All-purpose Compute`         |
| `meterName`   | Matches skuName + `DBU` suffix  | `Premium Jobs Compute DBU`, `Standard All-purpose Compute DBU` |

## Meter Names

| Meter                                        | skuName                                  | unitOfMeasure | Notes                             |
| -------------------------------------------- | ---------------------------------------- | ------------- | --------------------------------- |
| `Premium All-purpose Compute DBU`            | `Premium All-purpose Compute`            | `1 Hour`      | Interactive clusters (Premium)    |
| `Premium Jobs Compute DBU`                   | `Premium Jobs Compute`                   | `1 Hour`      | Automated job clusters (Premium)  |
| `Premium Jobs Light Compute DBU`             | `Premium Jobs Light Compute`             | `1 Hour`      | Light jobs (Premium)              |
| `Standard All-purpose Compute DBU`           | `Standard All-purpose Compute`           | `1 Hour`      | Interactive clusters (Standard)   |
| `Standard Jobs Compute DBU`                  | `Standard Jobs Compute`                  | `1 Hour`      | Automated job clusters (Standard) |
| `Premium Serverless SQL DBU`                 | `Premium Serverless SQL`                 | `1 Hour`      | Serverless SQL warehouse          |
| `Premium SQL Compute Pro DBU`                | `Premium SQL Compute Pro`                | `1 Hour`      | Pro SQL warehouse                 |
| `Premium Interactive Serverless Compute DBU` | `Premium Interactive Serverless Compute` | `1 Hour`      | Serverless notebooks              |
| `Premium Automated Serverless Compute DBU`   | `Premium Automated Serverless Compute`   | `1 Hour`      | Serverless jobs                   |
| `Premium Model Training DBU`                 | `Premium Model Training`                 | `1 Hour`      | Serverless ML model training      |
| `Premium Database Serverless Compute DBU`    | `Premium Database Serverless Compute`    | `1 Hour`      | Serverless online tables / vector search |
| `Premium Serverless Realtime Inferencing DBU`| `Premium Serverless Realtime Inferencing`| `1 Hour`      | Model serving endpoints (+ per-launch fee) |
| `Premium Enhanced Security and Compliance DBU`| `Premium Enhanced Security and Compliance`| `1 Hour`     | Add-on surcharge per DBU-hour     |
| `Premium Databricks Storage Unit DSU`        | `Premium Databricks Storage Unit`        | `1`           | Per-unit storage (DSU, not DBU)   |

## Cost Formula

```
Classic Monthly    = (dbu_retailPrice × 730 × dbuCount) + (vm_retailPrice × 730 × nodeCount)
Serverless Monthly = serverless_dbu_retailPrice × 730 × dbuCount   (VM included in DBU rate)
DSU Monthly        = dsu_retailPrice × dsuCount                    (billed per unit, not time-based)
```

## Notes

- **Two tiers**: Standard (data engineering, retiring Oct 2026) and Premium (adds RBAC, audit logs, Unity Catalog). Premium DBU rates are higher; all new workloads should use Premium
- **Photon variants**: Photon-accelerated SKUs (e.g., `Premium All-Purpose Photon`) have the same DBU rate but process data faster, reducing total DBU-hours consumed
- **Delta Live Tables**: Separate DLT meters at Core, Pro, and Advanced levels (e.g., `Premium Pro Compute Delta Live Tables`)
- **Enhanced Security and Compliance**: Optional add-on surcharge billed per DBU-hour on top of base workload rate; query separately with `SkuName: Premium Enhanced Security and Compliance`
- **14-day free trial**: Free Trial SKUs (`Premium - Free Trial *`) return zero cost; ignore these for cost estimation
- **SQL warehouses**: `Premium SQL Analytics` / `Standard SQL Analytics` (classic, `Azure Databricks`); `Premium SQL Compute Pro` (Pro) and `Premium Serverless SQL` (serverless) both under `Azure Databricks Regional` — compute included in DBU rate
- **DBCU pre-purchase**: Reserved Instance queries return Databricks Commit Unit blocks (e.g., `SkuName: 100,000 DBCUs`); Global region, 1-Year and 3-Year terms; monthly cost = `unitPrice ÷ 12` or `unitPrice ÷ 36`
- **Clean Rooms**: `Premium Clean Rooms Collaborator` billed per collaborator per day (`1/Day`), not per DBU-hour
- **Model serving**: Realtime inferencing incurs both an hourly DBU rate and a per-launch charge (`Launch Charge Serverless Realtime Inferencing`, `unitOfMeasure: 1`)
- **Capacity per DBU**: 1 DBU maps to a fractional VM; actual throughput depends on node VM size, workload type, and Photon enablement; Databricks auto-scales clusters within configured min/max node bounds
- **PE sub-resources** (never-assume): `databricks_ui_api`, `browser_authentication`, Premium required
