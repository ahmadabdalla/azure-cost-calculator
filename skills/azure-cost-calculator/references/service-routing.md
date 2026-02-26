# Service Routing Map

Agent-facing routing for Azure services with implemented reference files.

For the Category Index and constants, see [shared.md](shared.md).

Filename convention: strip "Azure"/"Microsoft"/"MS" prefix → kebab-case → .md
Branded compound words (SignalR, DevOps, OpenAI, BizTalk, PlayFab, PubSub) are single tokens - lowercase without hyphens.
Example: "Azure Data Factory" → data-factory.md | "SignalR" → signalr.md | "Azure DevOps" → devops.md

## Routing Notes

- Some services share a `serviceName`; use `productName` filters to isolate.
- API `serviceFamily` may differ from category here. Always use this file's category.
- Services with no retail meter still need reference files.

Entry format: `- {display name}: {alias1}, {alias2}, ...` — display name may differ from API `serviceName` (see `apiServiceName` field).

## Compute (services/compute/)

- Virtual Machines: VMs, Azure VMs, IaaS VMs, VM Scale Sets, VMSS, Dedicated Host
- Azure App Service: Web Apps, App Service Plan, ASP
- Functions: Serverless Functions, Function App
- Azure Container Apps: ACA, Container Apps
- Azure Kubernetes Service: AKS, Kubernetes, K8s, AKS Automatic, Kubernetes Automatic
- Azure Batch: HPC Batch, Batch Compute
- Azure VMware Solution: AVS, VMware on Azure
- Windows Virtual Desktop: Azure Virtual Desktop, AVD, WVD

## Containers (services/containers/)

- Container Instances: ACI, Serverless Containers
- Container Registry: ACR, Docker Registry

## Databases (services/databases/)

- SQL Database: Azure SQL, SQL DB
- SQL Managed Instance: SQL MI, Azure SQL MI, Managed Instance
- Azure Cosmos DB: CosmosDB, DocumentDB, Multi-model DB
- Azure Database for PostgreSQL: PostgreSQL, Postgres, Azure Postgres, PostgreSQL Flexible Server
- Azure Database for MySQL: MySQL, Azure MySQL, MySQL Flexible Server
- Redis Cache: Azure Cache for Redis, Redis, Azure Redis, Managed Redis
- Azure Database Migration Service: DMS, Database Migration, DB Migration Service

## Networking (services/networking/)

- Application Gateway: App Gateway, AGW, WAF, Azure WAF, WAF v2, Web Application Firewall, WAF Policy
- Azure Firewall: AzFW, Azure Firewall Premium/Standard/Basic
- Azure Bastion: Bastion Host, Jump Host, Jump Box
- Azure DDOS Protection: DDoS, DDoS Protection, DDoS Network Protection, DDoS IP Protection
- ExpressRoute: ER, Dedicated Circuit
- ExpressRoute Gateway: ER Gateway, ExpressRoute VNet Gateway, ErGw
- Virtual Network: VNet, Peering
- VPN Gateway: VPN, Site-to-Site, Point-to-Site, S2S, P2S
- Load Balancer: ALB, LB, Standard LB, Basic LB
- Azure Front Door Service: AFD, Front Door, Front Door Premium/Standard, Front Door WAF
- Azure DNS: DNS Zones, Public DNS Zones
- Private DNS: Private DNS, Private DNS Zones
- Traffic Manager: DNS Load Balancer
- Azure Private Link: Private Endpoint, PE
- Content Delivery Network: CDN, Azure CDN, CDN Classic, Azure CDN Classic, Content Delivery
- NAT Gateway: Azure NAT, SNAT, Outbound Connectivity
- IP Addresses: Public IP, PIP, Public IP Address
- Bandwidth: Data Transfer, Egress, Outbound Transfer, Inter-region Transfer

## Storage (services/storage/)

- Storage: Blob Storage, Azure Files, Table Storage, Queue Storage, Azure Storage
- Data Lake Storage: Data Lake Gen2, ADLS, ADLS Gen2, Azure Data Lake
- Backup: Azure Backup, Recovery Services Vault, MARS Agent, VM Backup
- Data Box: Data Box Disk, Data Box Heavy, Import/Export
- Azure NetApp Files: NetApp, ANF, Azure NetApp
- Managed Disks: Managed Disks, Azure Disks, Premium SSD, Standard SSD, Ultra Disk, Disk Storage

## Security (services/security/)

- Key Vault: AKV, KV, Managed HSM
- Microsoft Defender for Cloud: Azure Security Center, CSPM, CWP, MDC
- Sentinel: SIEM, SOAR, Azure Sentinel

## Monitoring (services/monitoring/)

- Azure Monitor: Metrics, Alerts, Diagnostics, Platform Metrics, Basic Logs, Auxiliary Logs, Data Archive
- Application Insights: App Insights, APM, Application Performance Monitoring, Application Performance, AppInsights, Azure Application Insights
- Log Analytics: OMS, LA, Workspace, Logs, Log Analytics Workspace, Azure Monitor Logs, Operations Management Suite

## Management (services/management/)

- Azure Site Recovery: ASR, Disaster Recovery, DR
- Azure Migrate: Server Assessment, Migration Tools
- Management Groups: Management Group, Azure Management Groups, Subscription Organization

## Integration (services/integration/)

- Service Bus: ASB, Queues, Topics
- Logic Apps: Workflows, Logic App Standard/Consumption
- API Management: APIM, API Gateway

## Analytics (services/analytics/)

- Azure Synapse Analytics: Synapse, Synapse Workspace, Synapse SQL, Synapse Spark
- Azure Data Factory v2: ADF, ADF v2, ETL, Data Pipeline, Azure Data Factory
- Azure Databricks: DBX, Spark on Azure
- Stream Analytics: ASA, Real-time Analytics
- Microsoft Fabric: Fabric Capacity, OneLake, Lakehouse
- Power BI Embedded: PBI Embedded, Embedded Analytics
- SignalR: Azure SignalR Service, Real-time Messaging
- Azure Data Explorer: ADX, Kusto
- HDInsight: Hadoop, Spark, HBase, Kafka, HDI

## AI + ML (services/ai-ml/)

- Azure Machine Learning: Azure ML, AML, ML Workspace
- Foundry Tools: Azure AI Foundry Tools, AI Studio, AI Foundry Workspace, Azure AI Services, Cognitive Services, Vision, Speech, Language, Decision
- Azure Bot Service: Bot Framework, Chatbot
- Intelligent Recommendations: Recommendations, Personalization
- Microsoft Genomics: Genomics Workspace
- Azure OpenAI Service: OpenAI, GPT, Azure OpenAI, AOAI, ChatGPT, GPT-4
- Machine Learning Studio: ML Studio (classic), Classic ML

## IoT (services/iot/)

- IoT Hub: Device Messaging
- Event Hubs: Kafka on Azure, Event Streaming
- Event Grid: Event Routing, Event-driven
- Notification Hubs: Push Notifications, ANH

## Developer Tools (services/developer-tools/)

- Azure DevOps: ADO, VSTS, Repos, Pipelines, Boards, Artifacts

## Identity (services/identity/)

- Microsoft Entra ID: Azure AD, Azure Active Directory, AAD, Directory

## Web (services/web/)

- Azure Cognitive Search: Azure AI Search, Search Service, Full-text Search
- Azure Static Web Apps: SWA, JAMstack

## Communication (services/communication/)

- Phone Numbers: ACS Phone Numbers, PSTN, Telephony
- Voice: ACS Voice, Voice Calling, VOIP
- Email: ACS Email, Email Communication
- Messaging: ACS Chat, Chat Messaging
- SMS: ACS SMS, Text Messaging
- Network Traversal: ACS TURN, TURN Relay
