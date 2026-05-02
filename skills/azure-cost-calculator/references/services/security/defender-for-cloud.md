---
serviceName: Microsoft Defender for Cloud
category: security
aliases: [Azure Security Center, CSPM, CWP, MDC]
primaryCost: "Per-resource hourly or monthly rate × resource count (per sub-product)."
hasFreeGrant: true
---

# Microsoft Defender for Cloud

> **Note**: Multiple sub-products; query each separately by its own productName/skuName/meterName.

> **Trap (separate queries)**: Each sub-product needs its **own query**; unfiltered `serviceName` query mixes all products, `summary.totalMonthlyCost` is meaningless.
> **Trap (hourly ≠ scaling)**: Hourly meters are per-protected-resource, not time-based. Monthly cost = rate × 730 × resourceCount.
> **Trap (unitOfMeasure varies)**: Sub-products use `1/Hour`, `1/Month`, or `1 Hour`; always check before applying formula.
> **Trap (SQL meters)**: SQL returns multiple meters; use `Standard Instance` for PaaS. `Standard Node` = monthly flat, `Standard vCore` = per-vCore hourly (different deployment types).

## Query Pattern

All sub-products use the same pattern; substitute values from the Meter Names table:

ServiceName: Microsoft Defender for Cloud
ProductName: {productName}
SkuName: {skuName}
MeterName: {meterName}
InstanceCount: {resourceCount} # number of protected resources

## Meter Names

| Sub-product         | productName                              | skuName            | meterName                   | unitOfMeasure | Formula               |
| ------------------- | ---------------------------------------- | ------------------ | --------------------------- | ------------- | --------------------- |
| Servers P1          | `Microsoft Defender for Servers`         | `Standard P1`      | `Standard P1 Node`          | `1/Hour`      | × 730 × serverCount   |
| Servers P2          | `Microsoft Defender for Servers`         | `Standard P2`      | `Standard P2 Node`          | `1/Hour`      | × 730 × serverCount   |
| SQL (PaaS)          | `Microsoft Defender for SQL`             | `Standard`         | `Standard Instance`         | `1 Hour`      | × 730 × instanceCount |
| SQL (Node)          | `Microsoft Defender for SQL`             | `Standard`         | `Standard Node`             | `1/Month`     | × nodeCount           |
| SQL (vCore)         | `Microsoft Defender for SQL`             | `Standard`         | `Standard vCore`            | `1 Hour`      | × 730 × vCoreCount    |
| App Service         | `Microsoft Defender for App Service`     | `Standard`         | `Standard Node`             | `1/Hour`      | × 730 × planCount     |
| Key Vault           | `Microsoft Defender for Key Vault`       | `Per node Std`     | `Per node Std Node`         | `1/Hour`      | × 730 × vaultCount    |
| Storage             | `Microsoft Defender for Storage`         | `Standard`         | `Standard Node`             | `1/Hour`      | × 730 × accountCount  |
| Storage (txns)      | `Microsoft Defender for Storage`         | `Standard`         | `Standard Transactions`     | `1M`          | × transactionMillions |
| Storage (malware)   | `Microsoft Defender for Storage`         | `Malware Scanning` | `Malware Scanning Data Ingested` | `1 GB`   | × scannedGB           |
| Containers          | `Microsoft Defender for Containers`      | `Standard vCore`   | `Standard vCore vCore Pack` | `1/Hour`      | × 730 × totalVCores   |
| Containers (images) | `Microsoft Defender for Containers`      | `Standard Images`  | `Standard Images`           | `1`           | × imageScansPerMonth  |
| Cosmos DB           | `Microsoft Defender for Azure Cosmos DB` | `Standard`         | `Standard 100 RU/s`        | `1/Hour`      | × 730 × (RUs / 100)   |
| DNS                 | `Microsoft Defender for DNS`             | `Standard`         | `Standard Queries`          | `1M`          | × queryMillions       |
| Resource Manager    | `Microsoft Defender for Resource Manager`| `Per node Std`     | `Per node Std Node`         | `1/Hour`      | × 730 × subCount      |
| MySQL               | `Microsoft Defender for MySQL`           | `Standard`         | `Standard Node`             | `1/Month`     | × serverCount         |
| PostgreSQL          | `Microsoft Defender for PostgreSQL`      | `Standard`         | `Standard Node`             | `1/Month`     | × serverCount         |
| MariaDB             | `Microsoft Defender for MariaDB`         | `Standard`         | `Standard Instance`         | `1 Hour`      | × 730 × instanceCount |

## Cost Formula

- **Hourly meters**: `unitPrice × 730 × resourceCount`
- **Monthly meters**: `unitPrice × resourceCount`
- **Transaction meters**: `unitPrice × (transactions / 1,000,000)`
- **Per-GB meters**: `unitPrice × scannedGB`

## Notes

- **Servers P2 free data grant**: P2 includes **500 MB/server/day** of free Log Analytics ingestion for security data types; pooled across all protected servers. Deduct: `defenderFreeGB = serverCount × 0.5 × 30`.
- **Servers P2 MDATP Benefit**: Customers with existing Microsoft Defender for Endpoint licenses get a reduced P2 rate; query with `MeterName: Standard P2 Node - MDATP Benefit`.
- Containers has free trial tiers (Free vCore, Free Images at zero cost); always use `Standard` SKU meters for estimation.
- Containers vCore pricing = total vCores across all protected AKS nodes (e.g., 6× E4s_v5 @ 4 vCPU = 24 vCores).
- Additional plans exist (AI Services, APIs, OSS DB NonAzure); use the explore script with SearchTerm Defender to discover.

## Defender CSPM (Cloud Security Posture Management)

> **Trap (Global region only)**: Defender CSPM meters are in `Global` region; not regional endpoints.

**Query Pattern**:

ServiceName: Microsoft Defender for Cloud
ProductName: Microsoft Defender CSPM
SkuName: Standard
MeterName: Standard Node
Region: Global

| skuName    | meterName       | unitOfMeasure | Notes                       |
| ---------- | --------------- | ------------- | --------------------------- |
| `Standard` | `Standard Node` | `1/Hour`      | Query API for current price |
| `Trial`    | `Trial Node`    | `1/Hour`      | Free tier (no charge)       |

**Pricing**: Query API with Global region for current per-resource/month rate. Foundational CSPM is free (not estimated).

**Billable resource types**: VMs (excl. deallocated & Databricks), VMSS VMs, Storage accounts (with blob containers or file shares), OSS DBs (PostgreSQL/MySQL/MariaDB), SQL PaaS & Servers on Machines, Functions & Web Apps (every 8 functions and/or web apps = 1 billable resource, round up).

**NOT billable for CSPM** (do not count these): Key Vault, Cosmos DB, Container Registry, Event Hubs, Service Bus, IoT Hub, Load Balancer, Private Endpoints, DNS Zones, Virtual Networks, Application Gateway, Azure Firewall, Front Door, API Management, AKS (the service resource itself).

> **AKS counting**: AKS node pools are VMSS-based; count the individual node VMs as VMSS VMs. Do NOT count the AKS resource separately. E.g., 1 AKS cluster with 3 nodes = 3 billable resources, not 4.

**Counting example**: Architecture with 2 VMs, 1 AKS (3 nodes), 2 Storage accounts, 1 PostgreSQL, 1 Key Vault, 1 Container Registry, 1 Load Balancer → billable = 2 + 3 + 2 + 1 = **8 resources** (Key Vault, ACR, LB excluded). Cost = `unitPrice × 730 × 8`.

**Formula**: `unitPrice × 730 × billableResourceCount`; count only eligible types above; use Azure Resource Graph to enumerate.
