# Event-Driven Serverless Order Processing — Azure Architecture

## Ingestion Layer

- 1× Azure Event Grid, Standard Operations, 5M events/month
- 1× Azure Service Bus, Standard tier, 1 namespace, 20M operations/month

## Processing Layer

- 1× Azure Functions, Consumption plan, 10M executions/month at 256 MB memory, 500 ms average duration
- 1× Azure Functions, Consumption plan, 4M executions/month at 512 MB memory, 800 ms average duration

## Data Layer

- 1× Azure Cosmos DB, Provisioned throughput, 1000 RU/s, 50 GB storage

## Storage Layer

- 1× Azure Blob Storage, Hot LRS, 200 GB data stored

## Security & Compliance

- 1× Azure Key Vault, Standard tier, 50K operations/month
- 3× Private Endpoints (Cosmos DB, Service Bus, Blob Storage)
- 1× Microsoft Sentinel (SIEM), Pay-as-you-go, 10 GB/month ingestion

## Observability

- 1× Application Insights (workspace-based), 10 GB/month ingestion, 90-day retention

## Parameters

- Region: eastus
- Currency: USD
- Commitment: Pay-As-You-Go
- Hybrid Benefit: Not applied
- Zone Redundancy: Disabled
