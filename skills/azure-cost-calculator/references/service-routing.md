# Service Routing Map

Agent-facing routing for Azure services with implemented reference files.

For the Category Index and constants, see [shared.md](shared.md).

**Lookup:** grep this file for the service name or alias. The matching line embeds the reference file's full relative path in parentheses (e.g. `(services/compute/app-service.md)`); open that path directly. Do not read this file in full.

## Routing Notes

- Some services share a `serviceName`; use `productName` filters to isolate.
- API `serviceFamily` may differ from category here. Category names in the section headers below match the canonical Category Index in shared.md; use them exactly as written.
- Services with no retail meter still need reference files.

Entry format: `- {display name} (services/{category}/{file}.md): {alias1}, {alias2}, ...`. The parenthetical path is the reference file to open. Display name may differ from API `serviceName` (see `apiServiceName` field).

## Compute (services/compute/)

- Azure App Service (services/compute/app-service.md): Web Apps, App Service Plan, ASP
- Azure Batch (services/compute/batch.md): HPC Batch, Batch Compute
- Azure Container Apps (services/compute/container-apps.md): ACA, Container Apps
- Azure Kubernetes Service (services/compute/kubernetes-service.md): AKS, Kubernetes, K8s, AKS Automatic, Kubernetes Automatic
- Azure VMware Solution (services/compute/vmware-solution.md): AVS, VMware on Azure
- Functions (services/compute/functions.md): Serverless Functions, Function App
- Virtual Machines (services/compute/virtual-machines.md): VMs, Azure VMs, IaaS VMs, VM Scale Sets, VMSS, Dedicated Host
- Windows Virtual Desktop (services/compute/windows-virtual-desktop.md): Azure Virtual Desktop, AVD, WVD

## Containers (services/containers/)

- Container Instances (services/containers/container-instances.md): ACI, Serverless Containers
- Container Registry (services/containers/container-registry.md): ACR, Docker Registry

## Databases (services/databases/)

- Azure Cosmos DB (services/databases/cosmos-db.md): CosmosDB, DocumentDB, Multi-model DB
- Azure Cosmos DB for PostgreSQL (services/databases/cosmos-db-for-postgresql.md): Cosmos DB PostgreSQL, Citus, PostgreSQL Hyperscale, Cosmos DB for Postgres
- Azure Database for MariaDB (services/databases/database-for-mariadb.md): MariaDB, Azure MariaDB
- Azure Database for MySQL (services/databases/database-for-mysql.md): MySQL, Azure MySQL, MySQL Flexible Server
- Azure Database for PostgreSQL (services/databases/database-for-postgresql.md): PostgreSQL, Postgres, Azure Postgres, PostgreSQL Flexible Server
- Azure Database Migration Service (services/databases/database-migration-service.md): DMS, Database Migration, DB Migration Service
- Azure HorizonDB (services/databases/horizondb.md): Horizon DB, Distributed PostgreSQL
- Cosmos DB Garnet Cache (services/databases/cosmos-db-garnet-cache.md): Garnet Cache, Redis-compatible Cache, Cosmos DB Cache, vCore Cache
- Redis Cache (services/databases/redis-cache.md): Azure Cache for Redis, Redis, Azure Redis, Managed Redis
- SQL Database (services/databases/sql-database.md): Azure SQL, SQL DB
- SQL Managed Instance (services/databases/sql-managed-instance.md): SQL MI, Azure SQL MI, Managed Instance

## Networking (services/networking/)

- Application Gateway (services/networking/application-gateway.md): App Gateway, AGW, WAF, Azure WAF, WAF v2, Web Application Firewall, WAF Policy, AGIC, Application Gateway Ingress Controller
- Application Gateway for Containers (services/networking/application-gateway-for-containers.md): AGfC, AGC, App Gateway for Containers
- Azure Bastion (services/networking/bastion.md): Bastion Host, Jump Host, Jump Box
- Azure DDOS Protection (services/networking/ddos-protection.md): DDoS, DDoS Protection, DDoS Network Protection, DDoS IP Protection
- Azure DNS (services/networking/dns.md): DNS Zones, Public DNS Zones
- DNS Security Policy (services/networking/dns-security-policy.md): DNS Security, DNS Filtering, DNS Threat Intelligence
- Azure Firewall (services/networking/firewall.md): AzFW, Azure Firewall Premium/Standard/Basic
- Azure Front Door Service (services/networking/front-door.md): AFD, Front Door, Front Door Premium/Standard, Front Door WAF
- Azure Private Link (services/networking/private-link.md): Private Endpoint, PE
- Bandwidth (services/networking/bandwidth.md): Data Transfer, Egress, Outbound Transfer, Inter-region Transfer
- Content Delivery Network (services/networking/content-delivery-network.md): CDN, Azure CDN, CDN Classic, Azure CDN Classic, Content Delivery
- DNS Private Resolver (services/networking/dns-private-resolver.md): Private Resolver, DNS Resolver, Azure DNS Private Resolver
- ExpressRoute (services/networking/express-route.md): ER, Dedicated Circuit
- ExpressRoute Gateway (services/networking/expressroute-gateway.md): ER Gateway, ExpressRoute VNet Gateway, ErGw
- IP Addresses (services/networking/ip-addresses.md): Public IP, PIP, Public IP Address
- Load Balancer (services/networking/load-balancer.md): ALB, LB, Standard LB, Basic LB
- NAT Gateway (services/networking/nat-gateway.md): Azure NAT, SNAT, Outbound Connectivity
- Network Watcher (services/networking/network-watcher.md): NSG Flow Logs, Connection Monitor
- Azure Route Server (services/networking/route-server.md): BGP Routing
- Private DNS (services/networking/private-dns.md): Private DNS, Private DNS Zones
- Traffic Manager (services/networking/traffic-manager.md): DNS Load Balancer
- Virtual Network (services/networking/virtual-network.md): VNet, Peering
- Virtual Network Manager (services/networking/virtual-network-manager.md): AVNM, VNet Manager, Network Manager
- Virtual WAN (services/networking/virtual-wan.md): vWAN, WAN Hub
- VPN Gateway (services/networking/vpn-gateway.md): VPN, Site-to-Site, Point-to-Site, S2S, P2S

## Storage (services/storage/)

- Azure File Sync (services/storage/file-sync.md): Hybrid File Sync, File Server Sync, Cloud Tiering
- Azure Container Storage (services/storage/container-storage.md): Container-native Storage, Kubernetes Storage
- Azure NetApp Files (services/storage/netapp-files.md): NetApp, ANF, Azure NetApp
- Backup (services/storage/backup.md): Azure Backup, Recovery Services Vault, MARS Agent, VM Backup
- Data Box (services/storage/data-box.md): Data Box Disk, Data Box Heavy, Import/Export
- Data Box Gateway (services/storage/data-box-gateway.md): Data Box Virtual Appliance, Hybrid Data Transfer Gateway
- Data Lake Storage (services/storage/data-lake-storage.md): Data Lake Gen2, ADLS, ADLS Gen2, Azure Data Lake
- Managed Disks (services/storage/managed-disks.md): Managed Disks, Azure Disks, Premium SSD, Standard SSD, Ultra Disk, Disk Storage
- Storage (services/storage/storage.md): Blob Storage, Azure Files, Table Storage, Queue Storage, Azure Storage
- Storage Actions (services/storage/storage-actions.md): Storage Data Processing, Storage Task Automation, Serverless Storage Processing

## Security (services/security/)

- Azure Defender EASM (services/security/defender-easm.md): External Attack Surface Management, EASM, Attack Surface
- Key Vault (services/security/key-vault.md): AKV, KV, Managed HSM
- Microsoft Defender for Cloud (services/security/defender-for-cloud.md): Azure Security Center, CSPM, CWP, MDC
- Microsoft Purview (services/security/purview.md): Data Governance, Data Catalog, Azure Purview, Purview Data Map, Data Estate Scanning
- Sentinel (services/security/sentinel.md): SIEM, SOAR, Azure Sentinel

## Monitoring (services/monitoring/)

- Application Insights (services/monitoring/application-insights.md): App Insights, APM, Application Performance Monitoring, Application Performance, AppInsights, Azure Application Insights
- Azure Monitor (services/monitoring/monitor.md): Metrics, Alerts, Diagnostics, Platform Metrics, Basic Logs, Auxiliary Logs, Data Archive
- Azure SCOM Managed Instance (services/monitoring/scom-managed-instance.md): SCOM MI, Operations Manager, System Center Operations Manager
- Log Analytics (services/monitoring/log-analytics.md): OMS, LA, Workspace, Logs, Log Analytics Workspace, Azure Monitor Logs, Operations Management Suite

## Management (services/management/)

- Automation (services/management/automation.md): Runbooks, DSC, Update Management
- Azure Migrate (services/management/migrate.md): Server Assessment, Migration Tools
- Azure Site Recovery (services/management/site-recovery.md): ASR, Disaster Recovery, DR
- Management Groups (services/management/management-groups.md): Management Group, Azure Management Groups, Subscription Organization

## Integration (services/integration/)

- API Management (services/integration/api-management.md): APIM, API Gateway
- Logic Apps (services/integration/logic-apps.md): Workflows, Logic App Standard/Consumption
- Service Bus (services/integration/service-bus.md): ASB, Queues, Topics

## Analytics (services/analytics/)

- Azure Analysis Services (services/analytics/analysis-services.md): AAS, Tabular Model
- Azure Data Explorer (services/analytics/data-explorer.md): ADX, Kusto
- Azure Data Factory v2 (services/analytics/data-factory.md): ADF, ADF v2, ETL, Data Pipeline, Azure Data Factory
- Azure Databricks (services/analytics/databricks.md): DBX, Spark on Azure
- Azure Managed Airflow (services/analytics/managed-airflow.md): ADF Airflow, Apache Airflow, Data Factory Airflow
- Azure Synapse Analytics (services/analytics/synapse-analytics.md): Synapse, Synapse Workspace, Synapse SQL, Synapse Spark
- HDInsight (services/analytics/hdinsight.md): Hadoop, Spark, HBase, Kafka, HDI
- Microsoft Fabric (services/analytics/fabric.md): Fabric Capacity, OneLake, Lakehouse
- Power BI Embedded (services/analytics/power-bi-embedded.md): PBI Embedded, Embedded Analytics
- SignalR (services/analytics/signalr.md): Azure SignalR Service, Real-time Messaging
- Stream Analytics (services/analytics/stream-analytics.md): ASA, Real-time Analytics

## AI + ML (services/ai-ml/)

- Azure AI Content Understanding (services/ai-ml/ai-content-understanding.md): Content Extraction, Multi-modal AI, Document Understanding
- Azure Bot Service (services/ai-ml/bot-service.md): Bot Framework, Chatbot
- Azure Document Intelligence (services/ai-ml/document-intelligence.md): Form Recognizer, Document AI, OCR, Invoice Processing
- Azure Language (services/ai-ml/language.md): Language Understanding, LUIS, Text Analytics, NER, Sentiment Analysis, CLU
- Azure Machine Learning (services/ai-ml/machine-learning.md): Azure ML, AML, ML Workspace
- Azure OpenAI Service (services/ai-ml/openai-service.md): OpenAI, GPT, Azure OpenAI, AOAI, ChatGPT, GPT-4
- Azure Speech (services/ai-ml/speech.md): Speech to Text, STT, TTS, Text to Speech, Neural TTS, Speech Services
- Azure Translator (services/ai-ml/translator.md): Translator Text, Text Translation, Document Translation
- Azure Video Indexer (services/ai-ml/video-indexer.md): Video AI, Media Indexer, Video Analysis
- Azure Vision (services/ai-ml/vision.md): Computer Vision, Face API, Spatial Analysis, Image Analysis
- Content Safety (services/ai-ml/content-safety.md): Content Moderation, Image Moderation, Text Moderation, AI Content Safety
- Foundry Agents (services/ai-ml/foundry-agents.md): AI Agents, Agent Orchestration, HOBO Agents, SRE Agent
- Foundry Tools (services/ai-ml/ai-services.md): Azure AI Foundry Tools, AI Studio, AI Foundry Workspace, Azure AI Services, Cognitive Services, Language, Decision
- Machine Learning Studio (services/ai-ml/machine-learning-studio.md): ML Studio (classic), Classic ML
- Microsoft Discovery (services/ai-ml/discovery.md): Discovery Platform, Scientific Discovery
- Microsoft Genomics (services/ai-ml/genomics.md): Genomics Workspace

## IoT (services/iot/)

- Azure Maps (services/iot/maps.md): Location Services, Geospatial
- Digital Twins (services/iot/digital-twins.md): ADT, IoT Modeling
- Event Grid (services/iot/event-grid.md): Event Routing, Event-driven
- Event Hubs (services/iot/event-hubs.md): Kafka on Azure, Event Streaming
- IoT Central (services/iot/iot-central.md): IoT SaaS, IoT Application
- IoT Hub (services/iot/iot-hub.md): Device Messaging
- Notification Hubs (services/iot/notification-hubs.md): Push Notifications, ANH

## Developer Tools (services/developer-tools/)

- App Configuration (services/developer-tools/app-configuration.md): Feature Flags, Configuration Store
- Azure DevOps (services/developer-tools/devops.md): ADO, VSTS, Repos, Pipelines, Boards, Artifacts
- Azure Managed Grafana (services/developer-tools/managed-grafana.md): Managed Grafana, Azure Grafana Service, Grafana Dashboard

## Identity (services/identity/)

- Microsoft Entra Domain Services (services/identity/entra-domain-services.md): AAD DS, Azure AD DS, Managed AD
- Microsoft Entra External ID (services/identity/entra-external-id.md): Entra External ID, CIAM, Microsoft Entra CIAM, AAD B2C, Azure AD B2C, External Identities B2C
- Microsoft Entra ID (services/identity/entra-id.md): Azure AD, Azure Active Directory, AAD, Directory

## Web (services/web/)

- Azure Cognitive Search (services/web/cognitive-search.md): Azure AI Search, Search Service, Full-text Search
- Azure Spring Cloud (services/web/spring-apps.md): Azure Spring Apps, Java Microservices
- Azure Static Web Apps (services/web/static-web-apps.md): SWA, JAMstack

## Communication (services/communication/)

- Email (services/communication/email.md): ACS Email, Email Communication
- Messaging (services/communication/messaging.md): ACS Chat, Chat Messaging
- Network Traversal (services/communication/network-traversal.md): ACS TURN, TURN Relay
- Phone Numbers (services/communication/phone-numbers.md): ACS Phone Numbers, PSTN, Telephony
- SMS (services/communication/sms.md): ACS SMS, Text Messaging
- Voice (services/communication/voice.md): ACS Voice, Voice Calling, VOIP

## Specialist (services/specialist/)

- Azure Health Bot (services/specialist/health-bot.md): Healthcare Bot, Health Virtual Assistant, Medical Bot
