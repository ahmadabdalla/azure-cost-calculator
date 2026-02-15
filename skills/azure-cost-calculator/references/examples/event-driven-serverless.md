# Trade Settlement & AML Event Processing — Financial Services, Australia

A boutique Australian financial services firm processes ~80,000 equity and fixed-income trades per day across ASX and Chi-X venues. Each trade triggers settlement matching, real-time AML screening against AUSTRAC watchlists, confirmation dispatch to counterparties, and immutable regulatory archival. The platform must guarantee ordered processing per instrument and maintain a complete audit trail for ASIC compliance.

## Ingestion Layer

- 1× Azure Event Grid, Standard Operations, 25M events/month (trade executions, settlement status changes, compliance alerts, position updates)
- 1× Azure Service Bus, Premium tier, 1 namespace, 1 messaging unit, 80M operations/month, message sessions enabled for ordered per-instrument trade processing

## Processing Layer

- 1× Azure Functions, Consumption plan, 18M executions/month at 256 MB memory, 400 ms average duration (trade matching — correlates execution reports with expected fills)
- 1× Azure Functions, Consumption plan, 12M executions/month at 512 MB memory, 1200 ms average duration (AML screening — enriches trade events against AUSTRAC PEP/sanctions lists)
- 1× Azure Functions, Consumption plan, 8M executions/month at 256 MB memory, 300 ms average duration (settlement confirmation — generates T+2 SWIFT MT548/MT544 messages)
- 1× Azure Functions, Consumption plan, 6M executions/month at 128 MB memory, 200 ms average duration (notification dispatch — pushes status updates to counterparties and internal dashboards)

## Data Layer

- 1× Azure Cosmos DB, Provisioned throughput, 1-Year Reserved Capacity, 4000 RU/s, 200 GB storage, 2 containers (trade ledger: 3000 RU/s, audit log: 1000 RU/s), Session consistency
- 1× Azure SQL Database, General Purpose tier, Standard-series (Gen5), 4 vCores, 1-Year Reserved Instance, 100 GB max storage, zone redundancy disabled (settlement reconciliation — structured T+2 netting and cash projection data)
- 1× Azure Cache for Redis, Standard tier, C2 (6 GB), 1 instance (real-time position caching — maintains intraday net exposure per instrument per counterparty)

## Storage Layer

- 1× Azure Blob Storage, Hot LRS, 500 GB data stored (active trade documents, confirmation PDFs, intraday position snapshots)
- 1× Azure Blob Storage, Cool LRS, 2 TB data stored (compliance archival — 7-year ASIC regulatory retention of trade records and AML screening results)

## Backup & Recovery

- 1× Azure Backup for Azure Cosmos DB, continuous backup tier, 200 GB protected data (point-in-time restore for trade ledger and audit log)

## Security & Compliance

- 1× Azure Key Vault, Standard tier, 250K operations/month (certificate-based mTLS between all services, trade signing keys, SWIFT credential rotation)
- 7× Private Endpoints (Cosmos DB, Service Bus, SQL Database, Redis Cache, Blob Storage ×2, Key Vault)
- 1× Microsoft Sentinel (SIEM), Pay-as-you-go, 35 GB/month ingestion (financial compliance monitoring — suspicious transaction pattern detection, access anomaly alerting)

## Observability

- 1× Application Insights (workspace-based), 25 GB/month ingestion, 90-day retention (distributed trade tracing — end-to-end latency tracking from execution to settlement confirmation)

## Parameters

- Region: australiaeast
- Currency: AUD
- Commitment: 1-Year Reserved Instances (where applicable)
- Hybrid Benefit: Not applied
- Zone Redundancy: Disabled
