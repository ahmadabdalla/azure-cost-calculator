# Data Analytics Platform — Azure Architecture

## Ingestion Layer

- 1× Azure Event Hubs, Standard tier, 4 Throughput Units
- 20 million ingress events per month

## Orchestration Layer

- 1× Azure Data Factory v2, Cloud runtime
- 50,000 orchestration activity runs per month
- 200 data movement hours per month

## Processing Layer

- 1× Azure Databricks, Premium Jobs Compute, 10 DBU
- 4× Azure Virtual Machines, Standard_E8s_v5 (Linux) — Databricks worker nodes

## Storage Layer

- 1× Azure Data Lake Storage Gen2 (HNS), Hot LRS, 5,000 GB
- 1× Azure Data Lake Storage Gen2 (HNS), Cool LRS, 20,000 GB

## Serving Layer

- 1× Azure Synapse Analytics, Dedicated SQL Pool, DW500c
- 500 GB managed storage (Standard LRS)

## Network Security

- 1× Azure Firewall, Standard tier, 500 GB data processed per month
- 4× Private Endpoints (Data Lake, Synapse, Databricks, Event Hubs)

## Security Monitoring

- 1× Microsoft Sentinel (SIEM), Pay-as-you-go, 20 GB/month ingestion
- 1× Azure Key Vault, Standard tier, 30K operations/month

## Parameters

- Region: eastus
- Currency: USD
- Commitment: Pay-As-You-Go
- Hybrid Benefit: Not applied
- Zone Redundancy: Disabled
