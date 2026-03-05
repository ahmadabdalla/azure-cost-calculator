# Service Routing Map

Agent-facing routing for Azure services with implemented reference files.

For the Category Index and constants, see [shared.md](shared.md).

Filename convention: strip "Azure"/"Microsoft"/"MS" prefix → kebab-case → .md
Branded compound words (SignalR, DevOps, OpenAI, BizTalk, PlayFab, PubSub) are single tokens - lowercase without hyphens.
Example: "Azure Data Factory" → data-factory.md | "SignalR" → signalr.md | "Azure DevOps" → devops.md

## Routing Notes

- Some services share a `serviceName`; use `productName` filters to isolate.
- API `serviceFamily` may differ from category here. Category names in the section headers below match the canonical Category Index in shared.md — use them exactly as written.
- Services with no retail meter still need reference files.

Entry format: `- {display name}: {alias1}, {alias2}, ...` — display name may differ from API `serviceName` (see `apiServiceName` field).

## Compute (services/compute/)

- Azure App Service: Web Apps, App Service Plan, ASP
- Azure Batch: HPC Batch, Batch Compute
- Azure Container Apps: ACA, Container Apps
- Azure Kubernetes Service: AKS, Kubernetes, K8s, AKS Automatic, Kubernetes Automatic
- Azure VMware Solution: AVS, VMware on Azure
- Functions: Serverless Functions, Function App
- Virtual Machines: VMs, Azure VMs, IaaS VMs, VM Scale Sets, VMSS, Dedicated Host
- Windows Virtual Desktop: Azure Virtual Desktop, AVD, WVD

## Containers (services/containers/)

- Container Instances: ACI, Serverless Containers
- Container Registry: ACR, Docker Registry

## Databases (services/databases/)

- Azure Cosmos DB: CosmosDB, DocumentDB, Multi-model DB
- Azure Cosmos DB for PostgreSQL: Cosmos DB PostgreSQL, Citus, PostgreSQL Hyperscale, Cosmos DB for Postgres
- Azure Database for MySQL: MySQL, Azure MySQL, MySQL Flexible Server
- Azure Database for PostgreSQL: PostgreSQL, Postgres, Azure Postgres, PostgreSQL Flexible Server
- Azure Database Migration Service: DMS, Database Migration, DB Migration Service
- Azure HorizonDB: Horizon DB, Distributed PostgreSQL
- Cosmos DB Garnet Cache: Garnet Cache, Redis-compatible Cache, Cosmos DB Cache, vCore Cache
- Redis Cache: Azure Cache for Redis, Redis, Azure Redis, Managed Redis
- SQL Database: Azure SQL, SQL DB
- SQL Managed Instance: SQL MI, Azure SQL MI, Managed Instance

## Networking (services/networking/)

- Application Gateway: App Gateway, AGW, WAF, Azure WAF, WAF v2, Web Application Firewall, WAF Policy
- Azure Bastion: Bastion Host, Jump Host, Jump Box
- Azure DDOS Protection: DDoS, DDoS Protection, DDoS Network Protection, DDoS IP Protection
- Azure DNS: DNS Zones, Public DNS Zones
- Azure Firewall: AzFW, Azure Firewall Premium/Standard/Basic
- Azure Front Door Service: AFD, Front Door, Front Door Premium/Standard, Front Door WAF
- Azure Private Link: Private Endpoint, PE
- Bandwidth: Data Transfer, Egress, Outbound Transfer, Inter-region Transfer
- Content Delivery Network: CDN, Azure CDN, CDN Classic, Azure CDN Classic, Content Delivery
- ExpressRoute: ER, Dedicated Circuit
- ExpressRoute Gateway: ER Gateway, ExpressRoute VNet Gateway, ErGw
- IP Addresses: Public IP, PIP, Public IP Address
- Load Balancer: ALB, LB, Standard LB, Basic LB
- NAT Gateway: Azure NAT, SNAT, Outbound Connectivity
- Network Watcher: NSG Flow Logs, Connection Monitor
- Private DNS: Private DNS, Private DNS Zones
- Traffic Manager: DNS Load Balancer
- Virtual Network: VNet, Peering
- Virtual Network Manager: AVNM, VNet Manager, Network Manager
- Virtual WAN: vWAN, WAN Hub
- VPN Gateway: VPN, Site-to-Site, Point-to-Site, S2S, P2S

## Storage (services/storage/)

- Azure File Sync: Hybrid File Sync, File Server Sync, Cloud Tiering
- Azure Container Storage: Container-native Storage, Kubernetes Storage
- Azure NetApp Files: NetApp, ANF, Azure NetApp
- Backup: Azure Backup, Recovery Services Vault, MARS Agent, VM Backup
- Data Box: Data Box Disk, Data Box Heavy, Import/Export
- Data Box Gateway: Data Box Virtual Appliance, Hybrid Data Transfer Gateway
- Data Lake Storage: Data Lake Gen2, ADLS, ADLS Gen2, Azure Data Lake
- Managed Disks: Managed Disks, Azure Disks, Premium SSD, Standard SSD, Ultra Disk, Disk Storage
- Storage: Blob Storage, Azure Files, Table Storage, Queue Storage, Azure Storage
- Storage Actions: Storage Data Processing, Storage Task Automation, Serverless Storage Processing

## Security (services/security/)

- Azure Defender EASM: External Attack Surface Management, EASM, Attack Surface
- Key Vault: AKV, KV, Managed HSM
- Microsoft Defender for Cloud: Azure Security Center, CSPM, CWP, MDC
- Microsoft Purview: Data Governance, Data Catalog, Azure Purview, Purview Data Map, Data Estate Scanning
- Sentinel: SIEM, SOAR, Azure Sentinel

## Monitoring (services/monitoring/)

- Application Insights: App Insights, APM, Application Performance Monitoring, Application Performance, AppInsights, Azure Application Insights
- Azure Monitor: Metrics, Alerts, Diagnostics, Platform Metrics, Basic Logs, Auxiliary Logs, Data Archive
- Azure SCOM Managed Instance: SCOM MI, Operations Manager, System Center Operations Manager
- Log Analytics: OMS, LA, Workspace, Logs, Log Analytics Workspace, Azure Monitor Logs, Operations Management Suite

## Management (services/management/)

- Automation: Runbooks, DSC, Update Management
- Azure Migrate: Server Assessment, Migration Tools
- Azure Site Recovery: ASR, Disaster Recovery, DR
- Management Groups: Management Group, Azure Management Groups, Subscription Organization

## Integration (services/integration/)

- API Management: APIM, API Gateway
- Logic Apps: Workflows, Logic App Standard/Consumption
- Service Bus: ASB, Queues, Topics

## Analytics (services/analytics/)

- Azure Analysis Services: AAS, Tabular Model
- Azure Data Explorer: ADX, Kusto
- Azure Data Factory v2: ADF, ADF v2, ETL, Data Pipeline, Azure Data Factory
- Azure Databricks: DBX, Spark on Azure
- Azure Managed Airflow: ADF Airflow, Apache Airflow, Data Factory Airflow
- Azure Synapse Analytics: Synapse, Synapse Workspace, Synapse SQL, Synapse Spark
- HDInsight: Hadoop, Spark, HBase, Kafka, HDI
- Microsoft Fabric: Fabric Capacity, OneLake, Lakehouse
- Power BI Embedded: PBI Embedded, Embedded Analytics
- SignalR: Azure SignalR Service, Real-time Messaging
- Stream Analytics: ASA, Real-time Analytics

## AI + ML (services/ai-ml/)

- Azure AI Content Understanding: Content Extraction, Multi-modal AI, Document Understanding
- Azure Bot Service: Bot Framework, Chatbot
- Azure Document Intelligence: Form Recognizer, Document AI, OCR, Invoice Processing
- Azure Language: Language Understanding, LUIS, Text Analytics, NER, Sentiment Analysis, CLU
- Azure Machine Learning: Azure ML, AML, ML Workspace
- Azure OpenAI Service: OpenAI, GPT, Azure OpenAI, AOAI, ChatGPT, GPT-4
- Azure Speech: Speech to Text, STT, TTS, Text to Speech, Neural TTS, Speech Services
- Azure Translator: Translator Text, Text Translation, Document Translation
- Azure Video Indexer: Video AI, Media Indexer, Video Analysis
- Azure Vision: Computer Vision, Face API, Spatial Analysis, Image Analysis
- Content Safety: Content Moderation, Image Moderation, Text Moderation, AI Content Safety
- Foundry Agents: AI Agents, Agent Orchestration, HOBO Agents, SRE Agent
- Foundry Tools: Azure AI Foundry Tools, AI Studio, AI Foundry Workspace, Azure AI Services, Cognitive Services, Language, Decision
- Intelligent Recommendations: Recommendations, Personalization
- Machine Learning Studio: ML Studio (classic), Classic ML
- Microsoft Genomics: Genomics Workspace

## IoT (services/iot/)

- Azure Maps: Location Services, Geospatial
- Digital Twins: ADT, IoT Modeling
- Event Grid: Event Routing, Event-driven
- Event Hubs: Kafka on Azure, Event Streaming
- IoT Central: IoT SaaS, IoT Application
- IoT Hub: Device Messaging
- Notification Hubs: Push Notifications, ANH

## Developer Tools (services/developer-tools/)

- App Configuration: Feature Flags, Configuration Store
- Azure DevOps: ADO, VSTS, Repos, Pipelines, Boards, Artifacts
- Azure Managed Grafana: Managed Grafana, Azure Grafana Service, Grafana Dashboard

## Identity (services/identity/)

- Azure Active Directory B2C: AAD B2C, Azure AD B2C, External Identities B2C, Entra External ID
- Microsoft Entra Domain Services: AAD DS, Azure AD DS, Managed AD
- Microsoft Entra ID: Azure AD, Azure Active Directory, AAD, Directory

## Web (services/web/)

- Azure Cognitive Search: Azure AI Search, Search Service, Full-text Search
- Azure Spring Cloud: Azure Spring Apps, Java Microservices
- Azure Static Web Apps: SWA, JAMstack

## Communication (services/communication/)

- Email: ACS Email, Email Communication
- Messaging: ACS Chat, Chat Messaging
- Network Traversal: ACS TURN, TURN Relay
- Phone Numbers: ACS Phone Numbers, PSTN, Telephony
- SMS: ACS SMS, Text Messaging
- Voice: ACS Voice, Voice Calling, VOIP

## Specialist (services/specialist/)

- Azure Health Bot: Healthcare Bot, Health Virtual Assistant, Medical Bot
