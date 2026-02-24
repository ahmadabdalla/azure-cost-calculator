# Service Routing Map

Agent-facing routing for Azure services with implemented reference files.

For the Category Index and constants, see [shared.md](shared.md).

Filename convention: strip "Azure"/"Microsoft"/"MS" prefix → kebab-case → `.md`
Branded compound words (SignalR, DevOps, OpenAI, BizTalk, PlayFab, PubSub) are single tokens - lowercase without hyphens.
Example: "Azure Data Factory" → `data-factory.md` | "SignalR" → `signalr.md` | "Azure DevOps" → `devops.md`

## Routing Notes

- Some services share a `serviceName`; use `productName` filters to isolate.
- API `serviceFamily` may differ from category here. Always use this file's category.
- Services with no retail meter still need reference files.

## Compute (`services/compute/`)

```yaml
- s: "Virtual Machines"
  a: [VMs, Azure VMs, IaaS VMs, VM Scale Sets, VMSS, Dedicated Host]
- s: "Azure App Service"
  a: [Web Apps, App Service Plan, ASP]
- s: "Functions"
  a: [Serverless Functions, Function App]
- s: "Azure Container Apps"
  a: [ACA, Container Apps]
- s: "Azure Kubernetes Service"
  a: [AKS, Kubernetes, K8s, AKS Automatic, Kubernetes Automatic]
- s: "Azure Batch"
  a: [HPC Batch, Batch Compute]
- s: "Azure VMware Solution"
  a: [AVS, VMware on Azure]
- s: "Windows Virtual Desktop"
  a: [Azure Virtual Desktop, AVD, WVD]
```

## Containers (`services/containers/`)

```yaml
- s: "Container Instances"
  a: [ACI, Serverless Containers]
- s: "Container Registry"
  a: [ACR, Docker Registry]
```

## Databases (`services/databases/`)

```yaml
- s: "SQL Database"
  a: [Azure SQL, SQL DB]
- s: "SQL Managed Instance"
  a: [SQL MI, Azure SQL MI, Managed Instance]
- s: "Azure Cosmos DB"
  a: [CosmosDB, DocumentDB, Multi-model DB]
- s: "Azure Database for PostgreSQL"
  a: [PostgreSQL, Postgres, Azure Postgres, PostgreSQL Flexible Server]
- s: "Azure Database for MySQL"
  a: [MySQL, Azure MySQL, MySQL Flexible Server]
- s: "Redis Cache"
  a: [Azure Cache for Redis, Redis, Azure Redis, Managed Redis]
- s: "Azure Database Migration Service"
  a: [DMS, Database Migration, DB Migration Service]
```

## Networking (`services/networking/`)

```yaml
- s: "Application Gateway"
  a: [App Gateway, AGW, WAF, Azure WAF, WAF v2, Web Application Firewall, WAF Policy]
- s: "Azure Firewall"
  a: [AzFW, Azure Firewall Premium/Standard/Basic]
- s: "Azure Bastion"
  a: [Bastion Host, Jump Host, Jump Box]
- s: "Azure DDOS Protection"
  a: [DDoS, DDoS Protection, DDoS Network Protection, DDoS IP Protection]
- s: "ExpressRoute"
  a: [ER, Dedicated Circuit]
- s: "Virtual Network"
  a: [VNet, Peering]
- s: "VPN Gateway"
  a: [VPN, Site-to-Site, Point-to-Site, S2S, P2S]
- s: "Load Balancer"
  a: [ALB, LB, Standard LB, Basic LB]
- s: "Azure Front Door Service"
  a: [AFD, Front Door, Front Door Premium/Standard, Front Door WAF]
- s: "Azure DNS"
  a: [DNS Zones, Public DNS Zones]
- s: "Private DNS"
  a: [Private DNS, Private DNS Zones]
- s: "Traffic Manager"
  a: [DNS Load Balancer]
- s: "Azure Private Link"
  a: [Private Endpoint, PE]
- s: "Content Delivery Network"
  a: [CDN, Azure CDN, CDN Classic, Azure CDN Classic, Content Delivery]
- s: "NAT Gateway"
  a: [Azure NAT, SNAT, Outbound Connectivity]
- s: "IP Addresses"
  a: [Public IP, PIP, Public IP Address]
```

## Storage (`services/storage/`)

```yaml
- s: "Storage"
  a: [Blob Storage, Azure Files, Table Storage, Queue Storage, Azure Storage]
- s: "Data Lake Storage"
  a: [Data Lake Gen2, ADLS, ADLS Gen2, Azure Data Lake]
- s: "Backup"
  a: [Azure Backup, Recovery Services Vault, MARS Agent, VM Backup]
- s: "Data Box"
  a: [Data Box Disk, Data Box Heavy, Import/Export]
- s: "Managed Disks"
  a: [Managed Disks, Azure Disks, Premium SSD, Standard SSD, Ultra Disk, Disk Storage]
```

## Security (`services/security/`)

```yaml
- s: "Key Vault"
  a: [AKV, KV, Managed HSM]
- s: "Microsoft Defender for Cloud"
  a: [Azure Security Center, CSPM, CWP, MDC]
- s: "Sentinel"
  a: [SIEM, SOAR, Azure Sentinel]
```

## Monitoring (`services/monitoring/`)

```yaml
- s: "Azure Monitor"
  a: [Metrics, Alerts, Diagnostics, Platform Metrics, Basic Logs, Auxiliary Logs, Data Archive]
- s: "Application Insights"
  a: [App Insights, APM, Application Performance Monitoring, Application Performance, AppInsights, Azure Application Insights]
- s: "Log Analytics"
  a: [OMS, LA, Workspace, Logs, Log Analytics Workspace, Azure Monitor Logs, Operations Management Suite]
```

## Management (`services/management/`)

```yaml
- s: "Azure Site Recovery"
  a: [ASR, Disaster Recovery, DR]
- s: "Azure Migrate"
  a: [Server Assessment, Migration Tools]
- s: "Management Groups"
  a: [Management Group, Azure Management Groups, Subscription Organization]
```

## Integration (`services/integration/`)

```yaml
- s: "Service Bus"
  a: [ASB, Queues, Topics]
- s: "Logic Apps"
  a: [Workflows, Logic App Standard/Consumption]
- s: "API Management"
  a: [APIM, API Gateway]
```

## Analytics (`services/analytics/`)

```yaml
- s: "Azure Synapse Analytics"
  a: [Synapse, Synapse Workspace, Synapse SQL, Synapse Spark]
- s: "Azure Data Factory v2"
  a: [ADF, ADF v2, ETL, Data Pipeline, Azure Data Factory]
- s: "Azure Databricks"
  a: [DBX, Spark on Azure]
- s: "Stream Analytics"
  a: [ASA, Real-time Analytics]
- s: "SignalR"
  a: [Azure SignalR Service, Real-time Messaging]
```

## AI + ML (`services/ai-ml/`)

```yaml
- s: "Azure Machine Learning"
  a: [Azure ML, AML, ML Workspace]
- s: "Foundry Tools"
  a: [Azure AI Foundry Tools, AI Studio, AI Foundry Workspace, Azure AI Services, Cognitive Services, Vision, Speech, Language, Decision]
- s: "Azure Bot Service"
  a: [Bot Framework, Chatbot]
- s: "Intelligent Recommendations"
  a: [Recommendations, Personalization]
- s: "Microsoft Genomics"
  a: [Genomics Workspace]
- s: "Azure OpenAI Service"
  a: [OpenAI, GPT, Azure OpenAI, AOAI, ChatGPT, GPT-4]
- s: "Machine Learning Studio"
  a: [ML Studio (classic), Classic ML]
```

## IoT (`services/iot/`)

```yaml
- s: "IoT Hub"
  a: [Device Messaging]
- s: "Event Hubs"
  a: [Kafka on Azure, Event Streaming]
- s: "Event Grid"
  a: [Event Routing, Event-driven]
- s: "Notification Hubs"
  a: [Push Notifications, ANH]
```

## Developer Tools (`services/developer-tools/`)

```yaml
- s: "Azure DevOps"
  a: [ADO, VSTS, Repos, Pipelines, Boards, Artifacts]
```

## Identity (`services/identity/`)

```yaml
- s: "Microsoft Entra ID"
  a: [Azure AD, Azure Active Directory, AAD, Directory]
```

## Web (`services/web/`)

```yaml
- s: "Azure Cognitive Search"
  a: [Azure AI Search, Search Service, Full-text Search]
- s: "Azure Static Web Apps"
  a: [SWA, JAMstack]
```

## Communication (`services/communication/`)

```yaml
- s: "Phone Numbers"
  a: [ACS Phone Numbers, PSTN, Telephony]
- s: "Voice"
  a: [ACS Voice, Voice Calling, VOIP]
- s: "Email"
  a: [ACS Email, Email Communication]
- s: "Messaging"
  a: [ACS Chat, Chat Messaging]
- s: "SMS"
  a: [ACS SMS, Text Messaging]
- s: "Network Traversal"
  a: [ACS TURN, TURN Relay]
```

