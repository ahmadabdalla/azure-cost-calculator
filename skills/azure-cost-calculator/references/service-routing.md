# Full Service Routing Map

Authoritative mapping of Azure services to category folders.

For the Category Index and constants, see [shared.md](shared.md).

Filename convention: strip "Azure"/"Microsoft"/"MS" prefix → kebab-case → `.md`
Example: "Azure Data Factory" → `data-factory.md`
Only entries with explicit `f:` field deviate from this convention.

## Routing Notes

- Some services share a `serviceName`; use `productName` filters (Storage, Managed Disks, Data Lake).
- API `serviceFamily` may differ from category here (Event Hubs → IoT, APIM → Dev Tools, Sentinel → Mgmt, Spring Cloud → Other). Always use this file's category.
- Services with no retail meter (Policy, Advisor, Cost Mgmt, DevOps, Entra ID free) still need reference files.
- OpenAI/AI Services may appear as `Foundry Models`/`Foundry Tools` in newer API responses (AI Foundry rebrand).

## Compute (`services/compute/`)

```yaml
- s: "Virtual Machines"
  a: [VMs, Azure VMs, IaaS VMs, VM Scale Sets, VMSS, Dedicated Host]
- s: "Azure App Service"
  a: [Web Apps, App Service Plan, ASP]
- s: "Functions"
  a: [Serverless Functions, Function App]
- s: "Azure Container Apps"
  a: [ACA]
- s: "Azure Kubernetes Service"
  f: aks.md
  a: [AKS, Kubernetes, K8s]
- s: "Cloud Services"
  a: [Cloud Services (classic), PaaS VMs, Worker Roles, Web Roles]
- s: "Service Fabric Mesh"
  f: service-fabric.md
  a: [Service Fabric, SF Mesh, Microservices]
- s: "Azure App Service (Linux)"
  a: [App Service Linux, Linux Web Apps]
- s: "Azure Batch"
  a: [HPC Batch, Batch Compute]
- s: "Azure VMware Solution"
  a: [AVS, VMware on Azure]
- s: "Azure Red Hat OpenShift"
  f: openshift.md
  a: [ARO, OpenShift]
- s: "Specialized Compute"
  a: [SAP HANA Large Instances, Azure Boost]
- s: "HPC Cache"
  a: [High Performance Compute Cache]
- s: "Durable Task Scheduler"
  a: [Durable Tasks, Workflow Scheduler]
- s: "Windows Virtual Desktop"
  f: virtual-desktop.md
  a: [Azure Virtual Desktop, AVD, WVD]
- s: "Service Fabric"
  f: service-fabric-cluster.md
  a: [SF, Microservices Cluster, Reliable Services]
- s: "Azure VM Image Builder"
  a: [Image Builder, AIB, VM Image, Custom Image]
- s: "Virtual Machines Licenses"
  f: vm-licenses.md
  a: [VM Licenses, BYOL, Windows Server License, SQL Server License]
- s: "Azure Local"
  f: azure-local.md
  a: [Azure Stack Local, Hybrid Compute]
```

## Containers (`services/containers/`)

```yaml
- s: "Container Instances"
  a: [ACI, Serverless Containers]
- s: "Container Registry"
  a: [ACR, Docker Registry]
- s: "AKS on Azure Stack HCI"
  f: aks-on-stack-hci.md
  a: [AKS-HCI, AKS on HCI, Kubernetes on Azure Stack HCI]
- s: "Azure Arc-enabled AKS"
  a: [Arc AKS, Arc-enabled Kubernetes, Arc K8s]
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
  f: postgresql-flexible.md
  a: [PostgreSQL, Postgres, Azure Postgres, Flexible Server]
- s: "Azure Database for MySQL"
  f: mysql.md
  a: [MySQL, Azure MySQL, Flexible Server]
- s: "Azure Database for MariaDB"
  f: mariadb.md
  a: [MariaDB, Azure MariaDB]
- s: "Redis Cache"
  a: [Azure Cache for Redis, Redis, Azure Redis, Managed Redis]
- s: "Azure Managed Instance for Apache Cassandra"
  f: cassandra.md
  a: [Cassandra MI, Apache Cassandra, Managed Cassandra]
- s: "SQL Data Warehouse"
  a: [Azure Synapse SQL Pool (dedicated), DW, Data Warehouse]
- s: "SQL Server Stretch Database"
  f: sql-stretch-db.md
  a: [Stretch DB, SQL Stretch]
- s: "Azure Database Migration Service"
  f: database-migration.md
  a: [DMS, Database Migration, DB Migration Service]
- s: "Azure Arc Enabled Databases"
  f: arc-databases.md
  a: [Arc SQL MI, Arc PostgreSQL, Arc-enabled Data Services]
- s: "Azure SQL Edge"
  a: [Edge Database, IoT SQL]
- s: "SQL DB Edge"
  a: [Edge SQL (legacy name for Azure SQL Edge)]
```

## Networking (`services/networking/`)

```yaml
- s: "Application Gateway"
  f: app-gateway.md
  a: [App Gateway, AGW]
- s: "Azure Firewall"
  f: azure-firewall.md
  a: [Azure Firewall Premium/Standard/Basic]
- s: "Azure Firewall Manager"
  a: [Firewall Policy]
- s: "Azure Bastion"
  a: [Jump Host, Bastion Host]
- s: "Azure DDOS Protection"
  a: [DDoS, DDoS Network Protection]
- s: "ExpressRoute"
  a: [ER, Dedicated Circuit]
- s: "Virtual Network"
  a: [VNet, NSG, Peering, Private Link]
- s: "Virtual WAN"
  a: [vWAN, WAN Hub]
- s: "VPN Gateway"
  a: [VPN, Site-to-Site, Point-to-Site, S2S, P2S]
- s: "Bandwidth"
  a: [Data Transfer, Egress, Outbound Transfer, Inter-region Transfer]
- s: "Network Watcher"
  a: [NSG Flow Logs, Connection Monitor]
- s: "Azure Orbital"
  a: [Ground Station, Satellite]
- s: "Private Mobile Network"
  f: private-5g-core.md
  a: [Private 5G Core, Mobile Network, MEC]
- s: "Load Balancer"
  a: [ALB, Standard LB, Basic LB]
- s: "Azure Front Door"
  a: [AFD, CDN, Azure CDN, Front Door Premium/Standard]
- s: "Azure DNS"
  a: [DNS Zones, Private DNS Zones]
- s: "Traffic Manager"
  a: [DNS Load Balancer]
- s: "Azure Route Server"
  a: [BGP Routing]
- s: "Azure Private Link"
  a: [Private Endpoint, PE]
- s: "Advanced Container Networking Services"
  f: advanced-cni.md
  a: [Advanced CNI, Container Networking, Cilium, Azure CNI Overlay]
- s: "Microsoft Azure Peering Service"
  a: [ISP Peering, Internet Peering]
- s: "Azure Front Door Service"
  a: [Front Door (exact API name), AFD, CDN, Azure CDN]
- s: "Content Delivery Network"
  a: [CDN, Azure CDN, Content Delivery]
- s: "NAT Gateway"
  a: [Azure NAT, SNAT, Outbound Connectivity]
- s: "Azure Programmable Connectivity"
  a: [APC, Network APIs]
# Front Door Service is exact API serviceName; CDN is separate; some services nested under others
```

## Storage (`services/storage/`)

```yaml
- s: "Storage"
  a:
    [
      Blob Storage,
      Azure Files,
      Table Storage,
      Queue Storage,
      Data Lake Gen2,
      ADLS,
    ]
- s: "Backup"
  a: [Recovery Services Vault, MARS Agent, VM Backup]
- s: "Azure NetApp Files"
  a: [NetApp, ANF, Azure NetApp]
- s: "Data Box"
  a: [Data Box Disk, Data Box Heavy, Import/Export]
- s: "Managed Disks"
  a: [Azure Disks, Premium SSD, Standard SSD, Ultra Disk, Disk Storage]
- s: "Azure Elastic SAN"
  a: [SAN, Block Storage]
- s: "Azure Managed Lustre"
  a: [Lustre, HPC Storage]
- s: "StorSimple"
  a: [Hybrid Cloud Storage, StorSimple Array, StorSimple Virtual Array]
```

## Security (`services/security/`)

```yaml
- s: "Key Vault"
  a: [AKV, Managed HSM]
- s: "Microsoft Defender for Cloud"
  a: [Azure Security Center, CSPM, CWP]
- s: "Microsoft Purview"
  a: [Data Governance, Data Catalog]
- s: "Azure confidential ledger"
  a: [CCF, Blockchain Ledger]
- s: "Azure Cloud HSM"
  a: [Dedicated HSM, Hardware Security Module]
- s: "Microsoft Azure Payment HSM"
  a: [Payment Processing HSM]
- s: "Azure IoT Security"
  a: [Defender for IoT, OT Security]
- s: "Microsoft Security Copilot"
  a: [Copilot for Security]
- s: "Microsoft Graph Services"
  a: [Microsoft Graph, Graph API metered usage]
- s: "Microsoft Defender Experts"
  a: [XDR Experts, Managed Detection and Response]
- s: "Multi-Factor Authentication"
  f: multi-factor-auth.md
  a: [MFA, Multi-Factor Auth, Azure MFA, Two-Factor Authentication]
- s: "Trusted Signing"
  a: [Code Signing, Azure Code Signing]
- s: "Microsoft Entra"
  a: [Entra Suite, Microsoft Entra (exact API name), Entra ID metered]
- s: "Microsoft Entra Verified ID"
  a: [Verified ID, Verifiable Credentials, Decentralized Identity, DID]
- s: "Application Gateway"
  f: waf.md
  a: [WAF, Azure WAF, WAF v2, Web Application Firewall, WAF Policy, Front Door WAF]
# WAF has no dedicated API serviceName; meters split across Application Gateway and Azure Front Door Service
```

## Monitoring (`services/monitoring/`)

```yaml
- s: "Azure Monitor"
  a: [Metrics, Alerts, Diagnostics]
- s: "Application Insights"
  f: app-insights.md
  a: [App Insights, APM, Application Performance]
- s: "Log Analytics"
  a: [OMS, Workspace, Logs]
- s: "Insight and Analytics"
  a: [OMS (legacy), Insight and Analytics (legacy)]
```

## Management (`services/management/`)

```yaml
- s: "Automation"
  a: [Runbooks, DSC, Update Management]
- s: "Azure Site Recovery"
  a: [ASR, Disaster Recovery, DR]
- s: "Sentinel"
  a: [SIEM, SOAR]
- s: "Azure Chaos Studio"
  a: [Chaos Engineering, Fault Injection]
- s: "Scheduler"
  a: [Azure Scheduler (legacy), Job Scheduler]
- s: "Azure Migrate"
  a: [Server Assessment, Migration Tools]
- s: "Azure Arc"
  a: [Hybrid Management, Arc-enabled Servers, Arc-enabled K8s]
- s: "Azure Lighthouse"
  a: [Delegated Resource Management, MSP Management]
- s: "Azure Policy"
  a: [Compliance, Governance]
- s: "Azure Advisor"
  a: [Recommendations, Best Practices]
- s: "Azure Cost Management"
  a: [Billing, Budgets, Cost Analysis]
- s: "Azure Blueprints"
  a: [Governance Templates (deprecated)]
- s: "Azure Resource Mover"
  a: [Move Resources, Subscription Mover]
- s: "Azure Update Manager"
  a: [Patch Management, OS Updates]
- s: "Azure Virtual Enclaves"
  a: [Isolated Environments, Secure Enclaves]
- s: "Change Tracking and Inventory"
  a: [Change Tracking, Inventory Tracking, Configuration Tracking]
- s: "Dynamics 365 for Customer Insights"
  f: dynamics-365-customer-insights.md
  a: [Customer Insights, D365 CI, Dynamics 365 Analytics]
- s: "Management Groups"
  a: [Management Group, Azure Management Groups, Subscription Organization]
```

## Integration (`services/integration/`)

```yaml
- s: "Service Bus"
  a: [ASB, Queues, Topics]
- s: "Logic Apps"
  a: [Workflows, Logic App Standard/Consumption]
- s: "Azure API Center"
  a: [API Catalog, API Inventory]
- s: "BizTalk Services"
  f: biztalk.md
  a: [BizTalk, BizTalk Services (legacy), B2B Integration]
- s: "API Management"
  a: [APIM, API Gateway]
```

## Analytics (`services/analytics/`)

```yaml
- s: "Azure Synapse Analytics"
  f: synapse.md
  a: [Synapse, Synapse Workspace, Synapse SQL, Synapse Spark]
- s: "Azure Data Factory"
  a: [ADF, ETL, Data Pipeline]
- s: "Azure Data Factory v2"
  a: [ADF v2]
- s: "Azure Databricks"
  a: [DBX, Spark on Azure]
- s: "Azure Data Explorer"
  a: [ADX, Kusto]
- s: "HDInsight"
  a: [Hadoop, Spark, HBase, Kafka, HDI]
- s: "Azure Analysis Services"
  a: [AAS, Tabular Model]
- s: "Stream Analytics"
  a: [ASA, Real-time Analytics]
- s: "Power BI"
  a: [Power BI Service]
- s: "Power BI Embedded"
  a: [PBI Embedded, Embedded Analytics]
- s: "Data Catalog"
  a: [Data Catalog (legacy)]
- s: "Azure Purview"
  f: purview-analytics.md
  a: [Purview Data Map, Data Estate Scanning]
- s: "Azure Data Share"
  a: [Data Sharing]
- s: "Microsoft Fabric"
  a: [Fabric Capacity, OneLake, Lakehouse]
- s: "Microsoft Planetary Computer Pro"
  f: planetary-computer.md
  a: [Planetary Computer, Geospatial Analytics]
- s: "Data Lake Store"
  a: [ADLS Gen1, Azure Data Lake (legacy)]
- s: "SignalR"
  a: [Azure SignalR Service, Real-time Messaging]
- s: "Web PubSub"
  a: [WebSocket Service]
- s: "Microsoft Graph data connect"
  a: [Microsoft 365 Data, M365 Data Export]
# Data Factory v1+v2 are separate serviceNames; Data Lake Store=Gen1 legacy; Purview in Security+Analytics
```

## AI + ML (`services/ai-ml/`)

```yaml
- s: "Azure Machine Learning"
  a: [Azure ML, AML, ML Workspace, Machine Learning Studio]
- s: "Foundry Models"
  a: [Azure AI Foundry Models, Model Catalog, AI Foundry]
- s: "Foundry Tools"
  a: [Azure AI Foundry Tools, AI Studio, AI Foundry Workspace]
- s: "Azure Bot Service"
  a: [Bot Framework, Chatbot]
- s: "Intelligent Recommendations"
  a: [Recommendations, Personalization]
- s: "Microsoft Genomics"
  a: [Genomics Workspace]
- s: "Azure OpenAI Service"
  f: openai.md
  a: [OpenAI, GPT, Azure OpenAI, AOAI, ChatGPT, GPT-4]
- s: "Azure AI Services"
  a: [Cognitive Services, Vision, Speech, Language, Decision]
- s: "Machine Learning Studio"
  f: ml-studio-classic.md
  a: [ML Studio (classic), Classic ML]
# ML Studio (classic) is separate serviceName from Azure ML (current workspace service)
```

## IoT (`services/iot/`)

```yaml
- s: "IoT Hub"
  a: [Device Messaging]
- s: "IoT Central"
  a: [IoT SaaS, IoT Application]
- s: "Event Hubs"
  a: [Kafka on Azure, Event Streaming]
- s: "Event Grid"
  a: [Event Routing, Event-driven]
- s: "Azure Maps"
  a: [Location Services, Geospatial]
- s: "Digital Twins"
  a: [ADT, IoT Modeling]
- s: "Notification Hubs"
  a: [Push Notifications, ANH]
- s: "Time Series Insights"
  a: [TSI, Time Series, IoT Analytics (deprecated/migrating)]
- s: "AKS Edge Essentials"
  a: [AKS Edge, K8s Edge, Kubernetes Edge Essentials]
- s: "Azure Device Registry"
  a: [IoT Device Registry, Asset Registry]
- s: "Azure IoT Operations"
  a: [IoT Ops, Edge IoT, Azure IoT OPC UA]
- s: "Windows 10 IoT Core Services"
  a: [IoT Core, Windows IoT, IoT Core Services, Windows CE]
```

## Developer Tools (`services/developer-tools/`)

```yaml
- s: "App Configuration"
  a: [Feature Flags, Configuration Store]
- s: "Azure Lab Services"
  a: [Classroom Labs, DevTest Labs]
- s: "Microsoft Playwright Testing"
  a: [Playwright, Browser Testing, E2E Testing]
- s: "Azure App Testing"
  a: [Mobile App Testing]
- s: "Azure Fluid Relay"
  a: [Fluid Framework, Real-time Collaboration]
- s: "Azure Grafana Service"
  f: grafana.md
  a: [Managed Grafana, Azure Managed Grafana, Grafana Dashboard]
- s: "Visual Studio Codespaces"
  f: codespaces.md
  a: [Codespaces (legacy), Cloud Dev Environments]
- s: "Azure DevOps"
  a: [ADO, Repos, Pipelines, Boards, Artifacts]
- s: "Azure DevTest Labs"
  a: [Lab VMs, Dev Environments]
- s: "Microsoft Dev Box"
  a: [Cloud Dev Workstation, Developer VM]
- s: "Azure Deployment Environments"
  a: [ADE, IaC Templates]
- s: "Azure Load Testing"
  a: [JMeter, Performance Testing]
- s: "GitHub"
  a: [GitHub Enterprise, GitHub Actions, GitHub Copilot]
- s: "GitHub AE"
  a: [GitHub Enterprise (Azure-hosted, legacy)]
- s: "Test Base"
  a: [Test Base for Microsoft 365, Compatibility Testing]
- s: "Visual Studio Subscription"
  a: [VS Subscription, MSDN, Visual Studio Enterprise/Professional]
```

## Identity (`services/identity/`)

```yaml
- s: "Azure Active Directory B2C"
  f: aad-b2c.md
  a: [AAD B2C, Azure AD B2C, External Identities B2C, Entra External ID]
- s: "Azure Active Directory for External Identities"
  f: aad-external.md
  a: [AAD External, B2B, Guest Users, Entra External ID]
- s: "Microsoft Entra Domain Services"
  a: [AAD DS, Azure AD DS, Managed AD]
- s: "Microsoft Entra ID"
  a: [Azure AD, Azure Active Directory, AAD, Directory]
- s: "Windows 365 Agents"
  a: [Cloud PC Agents]
# Microsoft Entra (Security) and Microsoft Entra ID (Identity) are separate API entries
```

## Migration (`services/migration/`)

```yaml
- s: "Azure Database Migration Service"
  f: database-migration.md
  a: [DMS, DB Migration]
- s: "Azure Migrate"
  a: [Server Assessment, Server Migration]
- s: "Azure Site Recovery"
  a: [ASR (also in Management for DR use case)]
# Overlaps Management (Site Recovery) and Databases (DMS); cross-reference both
```

## Web (`services/web/`)

```yaml
- s: "Azure Cognitive Search"
  a: [Azure AI Search, Search Service, Full-text Search]
- s: "Azure Static Web Apps"
  a: [SWA, JAMstack]
- s: "Azure Spring Cloud"
  f: spring-apps.md
  a: [Azure Spring Apps, Java Microservices]
- s: "Community Training"
  a: [Learning]
```

## Communication (`services/communication/`)

```yaml
- s: "Phone Numbers"
  f: communication-services.md
  a: [ACS Phone Numbers, PSTN, Telephony]
- s: "Voice"
  f: communication-services.md
  a: [ACS Voice, Voice Calling, VOIP]
- s: "Email"
  f: communication-services.md
  a: [ACS Email, Email Communication]
- s: "Messaging"
  f: communication-services.md
  a: [ACS Chat, Chat Messaging]
- s: "SMS"
  f: communication-services.md
  a: [ACS SMS, Text Messaging]
- s: "Network Traversal"
  f: communication-services.md
  a: [ACS TURN, TURN Relay]
- s: "AI Ops"
  a: [Telecom AI Ops, Azure Operator Insights]
- s: "Packet Core"
  a: [Azure Private 5G Core, Mobile Packet Core]
- s: "Azure Operator Nexus"
  a: [Telecom Nexus, Carrier Network]
- s: "Voice Core"
  a: [Telecom Voice, Core Voice Infrastructure]
- s: "Routing"
  a: [ACS Routing, Communication Routing, Call Routing]
```

## Specialist (`services/specialist/`)

```yaml
- s: "Azure Blockchain"
  a: [Blockchain Service, Blockchain Workbench (deprecated)]
- s: "Azure Remote Rendering"
  a: [3D Rendering, Mixed Reality]
- s: "Quantum Computing"
  a: [Azure Quantum, Q#]
- s: "Azure API for FHIR"
  f: fhir.md
  a: [FHIR API, Healthcare API, Health Data Services]
- s: "Energy Data Manager"
  a: [OSDU, Oil & Gas Data]
- s: "Microsoft Dragon Copilot"
  a: [Healthcare Copilot, Clinical Documentation]
- s: "Microsoft Copilot Studio"
  a: [Power Virtual Agents, Chatbot Builder]
- s: "Syntex"
  a: [SharePoint Syntex, Document Processing]
- s: "Azure Spatial Anchors"
  a: [AR Anchors, Mixed Reality Anchors]
- s: "Azure Stack Edge"
  a: [Edge Computing, Edge Appliance]
- s: "Azure Stack HCI"
  a: [HCI, Hyper-Converged Infrastructure]
- s: "Azure Stack Hub"
  a: [Azure Stack (original)]
- s: "Azure Orbital Edge"
  a: [Edge Satellite, Space Edge Computing]
- s: "Firmware Analysis"
  a: [Defender for IoT Firmware, IoT Firmware]
- s: "Dataverse"
  a: [Common Data Service, CDS, Power Platform Data]
- s: "Power Apps"
  a: [PowerApps, Low-code Apps, Canvas Apps, Model-driven]
- s: "Power Automate"
  a: [Flow, Microsoft Flow, Workflow Automation]
- s: "Power Pages"
  a: [Portal, Power Apps Portals, Low-code Websites]
- s: "PlayFab"
  a: [Game Backend, Game Services]
- s: "MS Bing Services"
  a: [Bing Search, Bing API, Bing Search API]
- s: "SAP Embrace"
  a: [SAP on Azure, SAP Integration]
```
