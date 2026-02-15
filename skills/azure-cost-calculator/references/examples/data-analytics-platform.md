# Regulatory & Portfolio Analytics Platform — Financial Services, Australia

A mid-size Australian wealth management firm processing daily ASX/global market feeds, client portfolio valuations across 12,000 managed accounts, and APRA/ASIC regulatory reporting. The platform ingests real-time price ticks during market hours, runs overnight batch valuations, and produces compliance datasets for quarterly lodgement. Reserved instances are used across production compute to optimise costs on predictable workloads.

## Ingestion Layer

- 1× Azure Event Hubs, Standard tier, 8 Throughput Units — real-time ASX and global market price feeds
- 60 million ingress events per month
- 1× Azure Event Hubs, Standard tier, 4 Throughput Units — client transaction and order flow events
- 15 million ingress events per month

## Orchestration Layer

- 1× Azure Data Factory v2, Cloud runtime
- 120,000 orchestration activity runs per month
- 500 data movement hours per month
- 80 data flow execution hours per month (General Purpose, 16 cores)

## Processing Layer

- 1× Azure Databricks, Premium Jobs Compute, 24 DBU
- 8× Azure Virtual Machines, Standard_E16s_v5 (Linux), 1-Year Reserved — Databricks worker nodes for overnight batch valuations
- 2× Azure Virtual Machines, Standard_E8s_v5 (Linux), 1-Year Reserved — Databricks driver nodes

## Storage Layer

- 1× Azure Data Lake Storage Gen2 (HNS), Hot LRS, 10,000 GB — current portfolio and position data
- 1× Azure Data Lake Storage Gen2 (HNS), Cool LRS, 40,000 GB — recent market history and staging
- 1× Azure Data Lake Storage Gen2 (HNS), Archive LRS, 120,000 GB — 7-year historical market data for regulatory retention

## Structured Data Layer

- 1× Azure SQL Database, Business Critical tier, 8 vCores, 1-Year Reserved — regulatory reporting warehouse
- 500 GB included storage
- Long-term retention enabled, 52 weekly backups

## Caching Layer

- 1× Azure Cache for Redis, Premium P2 (6 GB), 1 instance — low-latency portfolio position lookups and session state
- Redis persistence enabled (AOF)

## Serving Layer

- 1× Azure Synapse Analytics, Dedicated SQL Pool, DW1000c, 1-Year Reserved
- 1,000 GB managed storage (Standard LRS)

## Disaster Recovery

- 1× Azure Backup, backing up Azure SQL Database (500 GB, LRS redundancy)
- 1× Azure Backup, backing up 50,000 GB Azure Data Lake Storage Gen2 (LRS redundancy)
- 30-day retention policy for daily backups

## Network Security

- 1× Azure Firewall, Standard tier, 800 GB data processed per month
- 8× Private Endpoints (Data Lake Hot, Data Lake Cool, Data Lake Archive, Synapse, Databricks, Event Hubs Market, Event Hubs Orders, Azure SQL)

## Security & Compliance Monitoring

- 1× Microsoft Sentinel (SIEM), Pay-as-you-go, 50 GB/month ingestion — APRA compliance audit logging
- 1× Azure Key Vault, Standard tier, 150K operations/month — certificate rotation, TDE keys, secrets management for 40+ service principals

## Parameters

- Region: australiaeast
- Currency: AUD
- Commitment: 1-Year Reserved Instances (where applicable)
- Hybrid Benefit: Not applied
- Zone Redundancy: Disabled
