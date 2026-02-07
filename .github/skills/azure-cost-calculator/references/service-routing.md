# Full Service Routing Map

Authoritative mapping of Azure services to category folders. Each entry shows the exact API `serviceName` (case-sensitive), the category folder, and common aliases. When a contributor creates a new service reference file, they MUST place it in the category listed here.

For the Category Index and constants, see [shared.md](shared.md).

## Compute (`services/compute/`)

Services billed primarily on compute hours, vCPUs, or execution time.

| API serviceName           | Suggested Filename          | Aliases / Portal Names                                        |
| ------------------------- | --------------------------- | ------------------------------------------------------------- |
| Virtual Machines          | `virtual-machines.md`       | VMs, Azure VMs, IaaS VMs, VM Scale Sets, VMSS, Dedicated Host |
| Azure App Service         | `app-service.md`            | App Service, Web Apps, App Service Plan, ASP                  |
| Functions                 | `functions.md`              | Azure Functions, Serverless Functions, Function App           |
| Azure Container Apps      | `container-apps.md`         | Container Apps, ACA                                           |
| Azure Kubernetes Service  | `aks.md`                    | AKS, Kubernetes, K8s                                          |
| Cloud Services            | `cloud-services.md`         | Cloud Services (classic), PaaS VMs, Worker Roles, Web Roles   |
| Service Fabric Mesh       | `service-fabric.md`         | Service Fabric, SF Mesh, Microservices                        |
| Azure App Service (Linux) | `app-service-linux.md`      | App Service Linux, Linux Web Apps                             |
| Azure Batch               | `batch.md`                  | Batch, HPC Batch, Batch Compute                               |
| Azure VMware Solution     | `vmware-solution.md`        | AVS, VMware on Azure                                          |
| Azure Red Hat OpenShift   | `openshift.md`              | ARO, OpenShift, Red Hat OpenShift                             |
| Specialized Compute       | `specialized-compute.md`    | SAP HANA Large Instances, Azure Boost                         |
| HPC Cache                 | `hpc-cache.md`              | HPC Cache, High Performance Compute Cache                     |
| Durable Task Scheduler    | `durable-task-scheduler.md` | Durable Tasks, Workflow Scheduler                             |
| Windows Virtual Desktop   | `virtual-desktop.md`        | Azure Virtual Desktop, AVD, WVD, Windows Virtual Desktop      |

## Containers (`services/containers/`)

Container-specific infrastructure (registries, instances). Container orchestration (AKS) is under Compute.

| API serviceName     | Suggested Filename       | Aliases / Portal Names                                |
| ------------------- | ------------------------ | ----------------------------------------------------- |
| Container Instances | `container-instances.md` | ACI, Azure Container Instances, Serverless Containers |
| Container Registry  | `container-registry.md`  | ACR, Azure Container Registry, Docker Registry        |

## Databases (`services/databases/`)

Managed database engines, caches, and database migration services.

| API serviceName                             | Suggested Filename        | Aliases / Portal Names                                   |
| ------------------------------------------- | ------------------------- | -------------------------------------------------------- |
| SQL Database                                | `sql-database.md`         | Azure SQL, SQL DB, Azure SQL Database                    |
| SQL Managed Instance                        | `sql-managed-instance.md` | SQL MI, Azure SQL MI, Managed Instance                   |
| Azure Cosmos DB                             | `cosmos-db.md`            | Cosmos DB, CosmosDB, DocumentDB, Multi-model DB          |
| Azure Database for PostgreSQL               | `postgresql-flexible.md`  | PostgreSQL, Postgres, Azure Postgres, Flexible Server    |
| Azure Database for MySQL                    | `mysql.md`                | MySQL, Azure MySQL, Flexible Server                      |
| Azure Database for MariaDB                  | `mariadb.md`              | MariaDB, Azure MariaDB                                   |
| Redis Cache                                 | `redis-cache.md`          | Azure Cache for Redis, Redis, Azure Redis, Managed Redis |
| Azure Managed Instance for Apache Cassandra | `cassandra.md`            | Cassandra MI, Apache Cassandra, Managed Cassandra        |
| SQL Data Warehouse                          | `sql-data-warehouse.md`   | Azure Synapse SQL Pool (dedicated), DW, Data Warehouse   |
| SQL Server Stretch Database                 | `sql-stretch-db.md`       | Stretch DB, SQL Stretch                                  |
| Azure Database Migration Service            | `database-migration.md`   | DMS, Database Migration, DB Migration Service            |
| Azure Arc Enabled Databases                 | `arc-databases.md`        | Arc SQL MI, Arc PostgreSQL, Arc-enabled Data Services    |

## Networking (`services/networking/`)

Network connectivity, routing, load balancing, firewalls, and DNS.

| API serviceName        | Suggested Filename    | Aliases / Portal Names                                          |
| ---------------------- | --------------------- | --------------------------------------------------------------- |
| Application Gateway    | `app-gateway.md`      | App Gateway, AGW, WAF v2, Web Application Firewall              |
| Azure Firewall         | `azure-firewall.md`   | Firewall, Azure Firewall Premium/Standard/Basic                 |
| Azure Firewall Manager | `firewall-manager.md` | Firewall Manager, Firewall Policy                               |
| Azure Bastion          | `bastion.md`          | Bastion, Jump Host, Bastion Host                                |
| Azure DDOS Protection  | `ddos-protection.md`  | DDoS, DDoS Protection, DDoS Network Protection                  |
| ExpressRoute           | `expressroute.md`     | ExpressRoute, ER, Dedicated Circuit                             |
| Virtual Network        | `virtual-network.md`  | VNet, Virtual Network, NSG, Peering, Private Link               |
| Virtual WAN            | `virtual-wan.md`      | vWAN, Virtual WAN, WAN Hub                                      |
| VPN Gateway            | `vpn-gateway.md`      | VPN, VPN Gateway, Site-to-Site, Point-to-Site, S2S, P2S         |
| Bandwidth              | `bandwidth.md`        | Data Transfer, Egress, Outbound Transfer, Inter-region Transfer |
| Network Watcher        | `network-watcher.md`  | Network Watcher, NSG Flow Logs, Connection Monitor              |
| Azure Orbital          | `orbital.md`          | Azure Orbital, Ground Station, Satellite                        |
| Private Mobile Network | `private-5g-core.md`  | Private 5G Core, Mobile Network, MEC                            |
| Load Balancer          | `load-balancer.md`    | ALB, Azure Load Balancer, Standard LB, Basic LB                 |
| Azure Front Door       | `front-door.md`       | Front Door, AFD, CDN, Azure CDN, Front Door Premium/Standard    |
| Azure DNS              | `dns.md`              | DNS, DNS Zones, Private DNS Zones                               |
| Traffic Manager        | `traffic-manager.md`  | Traffic Manager, DNS Load Balancer                              |
| Azure Route Server     | `route-server.md`     | Route Server, BGP Routing                                       |
| Azure Private Link     | `private-link.md`     | Private Link, Private Endpoint                                  |

> **Note**: Load Balancer, Front Door, DNS, Traffic Manager, Route Server, and Private Link do not always appear as distinct `serviceName` values in the API — they may be nested under `Application Gateway`, `Virtual Network`, `Bandwidth`, or queried via `productName` filters. Always verify with the Explore script.

## Storage (`services/storage/`)

Blob, File, Table, Queue, Managed Disks, Data Lake, backup, and archival storage.

| API serviceName      | Suggested Filename  | Aliases / Portal Names                                                        |
| -------------------- | ------------------- | ----------------------------------------------------------------------------- |
| Storage              | `storage.md`        | Blob Storage, Azure Files, Table Storage, Queue Storage, Data Lake Gen2, ADLS |
| Backup               | `backup.md`         | Azure Backup, Recovery Services Vault, MARS Agent, VM Backup                  |
| Azure NetApp Files   | `netapp-files.md`   | NetApp, ANF, Azure NetApp                                                     |
| Data Box             | `data-box.md`       | Data Box, Data Box Disk, Data Box Heavy, Import/Export                        |
| Managed Disks        | `managed-disks.md`  | Azure Disks, Premium SSD, Standard SSD, Ultra Disk, Disk Storage              |
| Azure Elastic SAN    | `elastic-san.md`    | Elastic SAN, SAN, Block Storage                                               |
| Azure Managed Lustre | `managed-lustre.md` | Lustre, HPC Storage, Managed Lustre                                           |

> **Note**: Managed Disks and Data Lake storage often appear under `serviceName eq 'Storage'` with different `productName` values rather than separate `serviceName` entries. Use `productName` filters.

## Security (`services/security/`)

Key management, HSMs, threat protection, compliance, and confidential computing.

| API serviceName              | Suggested Filename       | Aliases / Portal Names                                    |
| ---------------------------- | ------------------------ | --------------------------------------------------------- |
| Key Vault                    | `key-vault.md`           | Key Vault, AKV, Azure Key Vault, Managed HSM              |
| Microsoft Defender for Cloud | `defender-for-cloud.md`  | Defender for Cloud, Azure Security Center, CSPM, CWP      |
| Microsoft Purview            | `purview.md`             | Purview, Microsoft Purview, Data Governance, Data Catalog |
| Azure confidential ledger    | `confidential-ledger.md` | Confidential Ledger, CCF, Blockchain Ledger               |
| Azure Cloud HSM              | `cloud-hsm.md`           | Cloud HSM, Dedicated HSM, Hardware Security Module        |
| Microsoft Azure Payment HSM  | `payment-hsm.md`         | Payment HSM, Payment Processing HSM                       |
| Azure IoT Security           | `iot-security.md`        | Defender for IoT, IoT Security, OT Security               |
| Microsoft Security Copilot   | `security-copilot.md`    | Security Copilot, Copilot for Security                    |
| Microsoft Graph Services     | `graph-services.md`      | Microsoft Graph, Graph API metered usage                  |

## Monitoring (`services/monitoring/`)

Observability, alerting, log collection, and application performance.

| API serviceName       | Suggested Filename         | Aliases / Portal Names                       |
| --------------------- | -------------------------- | -------------------------------------------- |
| Azure Monitor         | `monitor.md`               | Azure Monitor, Metrics, Alerts, Diagnostics  |
| Application Insights  | `app-insights.md`          | App Insights, APM, Application Performance   |
| Log Analytics         | `log-analytics.md`         | Log Analytics, OMS, Workspace, Logs          |
| Insight and Analytics | `insight-and-analytics.md` | OMS (legacy), Insight and Analytics (legacy) |

## Management (`services/management/`)

Governance, automation, cost management, compliance, disaster recovery, and operations.

| API serviceName       | Suggested Filename   | Aliases / Portal Names                                             |
| --------------------- | -------------------- | ------------------------------------------------------------------ |
| Automation            | `automation.md`      | Azure Automation, Runbooks, DSC, Update Management                 |
| Azure Site Recovery   | `site-recovery.md`   | ASR, Site Recovery, Disaster Recovery, DR                          |
| Sentinel              | `sentinel.md`        | Microsoft Sentinel, Azure Sentinel, SIEM, SOAR                     |
| Azure Chaos Studio    | `chaos-studio.md`    | Chaos Studio, Chaos Engineering, Fault Injection                   |
| Scheduler             | `scheduler.md`       | Azure Scheduler (legacy), Job Scheduler                            |
| Azure Migrate         | `migrate.md`         | Azure Migrate, Server Assessment, Migration Tools                  |
| Azure Arc             | `arc.md`             | Azure Arc, Hybrid Management, Arc-enabled Servers, Arc-enabled K8s |
| Azure Lighthouse      | `lighthouse.md`      | Lighthouse, Delegated Resource Management, MSP Management          |
| Azure Policy          | `policy.md`          | Policy, Azure Policy, Compliance, Governance                       |
| Azure Advisor         | `advisor.md`         | Advisor, Recommendations, Best Practices                           |
| Azure Cost Management | `cost-management.md` | Cost Management, Billing, Budgets, Cost Analysis                   |
| Azure Blueprints      | `blueprints.md`      | Blueprints, Governance Templates (deprecated)                      |

> **Note**: Sentinel is under Management (not Security) because its API `serviceFamily` is `Management and Governance` and its billing uses Log Analytics meters. Some management services (Policy, Advisor, Cost Management, Lighthouse) are free or have no direct retail meters — they still need reference files to document that fact and prevent unnecessary API queries.

## Integration (`services/integration/`)

Messaging, eventing, API gateways, and workflow orchestration.

| API serviceName  | Suggested Filename  | Aliases / Portal Names                                |
| ---------------- | ------------------- | ----------------------------------------------------- |
| Service Bus      | `service-bus.md`    | Service Bus, ASB, Queues, Topics                      |
| Logic Apps       | `logic-apps.md`     | Logic Apps, Workflows, Logic App Standard/Consumption |
| Azure API Center | `api-center.md`     | API Center, API Catalog, API Inventory                |
| BizTalk Services | `biztalk.md`        | BizTalk, BizTalk Services (legacy), B2B Integration   |
| API Management   | `api-management.md` | APIM, API Management, API Gateway                     |

> **Note**: API Management appears under `serviceFamily eq 'Developer Tools'` in the Retail Prices API, but functionally it's an integration/gateway service. Place it here.

## Analytics (`services/analytics/`)

Data warehousing, ETL, streaming, BI, big data, and data governance.

| API serviceName                  | Suggested Filename      | Aliases / Portal Names                                 |
| -------------------------------- | ----------------------- | ------------------------------------------------------ |
| Azure Synapse Analytics          | `synapse.md`            | Synapse, Synapse Workspace, Synapse SQL, Synapse Spark |
| Azure Data Factory               | `data-factory.md`       | ADF, Data Factory, ETL, Data Pipeline                  |
| Azure Data Factory v2            | `data-factory-v2.md`    | ADF v2, Data Factory v2                                |
| Azure Databricks                 | `databricks.md`         | Databricks, DBX, Spark on Azure                        |
| Azure Data Explorer              | `data-explorer.md`      | ADX, Kusto, Data Explorer                              |
| HDInsight                        | `hdinsight.md`          | HDInsight, Hadoop, Spark, HBase, Kafka, HDI            |
| Azure Analysis Services          | `analysis-services.md`  | Analysis Services, AAS, Tabular Model                  |
| Stream Analytics                 | `stream-analytics.md`   | Stream Analytics, ASA, Real-time Analytics             |
| Power BI                         | `power-bi.md`           | Power BI, Power BI Service                             |
| Power BI Embedded                | `power-bi-embedded.md`  | PBI Embedded, Embedded Analytics                       |
| Data Catalog                     | `data-catalog.md`       | Data Catalog (legacy)                                  |
| Azure Purview                    | `purview-analytics.md`  | Purview Data Map, Data Estate Scanning                 |
| Azure Data Share                 | `data-share.md`         | Data Share, Data Sharing                               |
| Microsoft Fabric                 | `fabric.md`             | Microsoft Fabric, Fabric Capacity, OneLake, Lakehouse  |
| Microsoft Planetary Computer Pro | `planetary-computer.md` | Planetary Computer, Geospatial Analytics               |
| SignalR                          | `signalr.md`            | Azure SignalR Service, SignalR, Real-time Messaging    |
| Web PubSub                       | `web-pubsub.md`         | Azure Web PubSub, WebSocket Service                    |

> **Note**: SignalR and Web PubSub are under `serviceFamily eq 'Analytics'` in the API (not Integration as expected). Data Factory has both v1 and v2 as separate `serviceName` values — v2 is the current version. Azure Purview appears in both Security (`serviceFamily eq 'Security'` as `Microsoft Purview`) and Analytics (`serviceFamily eq 'Analytics'` as `Azure Purview`). Create files in both categories referencing each other.

## AI + ML (`services/ai-ml/`)

Machine learning, cognitive services, OpenAI, bots, and AI platforms.

| API serviceName             | Suggested Filename               | Aliases / Portal Names                                              |
| --------------------------- | -------------------------------- | ------------------------------------------------------------------- |
| Azure Machine Learning      | `machine-learning.md`            | Azure ML, AML, ML Workspace, Machine Learning Studio                |
| Foundry Models              | `foundry-models.md`              | Azure AI Foundry Models, Model Catalog, AI Foundry                  |
| Foundry Tools               | `foundry-tools.md`               | Azure AI Foundry Tools, AI Studio, AI Foundry Workspace             |
| Azure Bot Service           | `bot-service.md`                 | Bot Service, Bot Framework, Chatbot                                 |
| Intelligent Recommendations | `intelligent-recommendations.md` | Recommendations, Personalization                                    |
| Microsoft Genomics          | `genomics.md`                    | Genomics, Microsoft Genomics, Genomics Workspace                    |
| Azure OpenAI Service        | `openai.md`                      | OpenAI, GPT, Azure OpenAI, AOAI, ChatGPT, GPT-4                     |
| Azure AI Services           | `ai-services.md`                 | Cognitive Services, AI Services, Vision, Speech, Language, Decision |

> **Note**: Azure OpenAI Service and Azure AI Services may appear under `Foundry Models` or `Foundry Tools` as `serviceName` in newer API responses, as Microsoft rebranded under AI Foundry. Check both legacy and new names. If the API returns 0 results for `Azure OpenAI Service`, try `Foundry Models`.

## IoT (`services/iot/`)

Internet of Things hubs, device management, edge computing, and spatial intelligence.

| API serviceName      | Suggested Filename        | Aliases / Portal Names                                 |
| -------------------- | ------------------------- | ------------------------------------------------------ |
| IoT Hub              | `iot-hub.md`              | IoT Hub, Azure IoT Hub, Device Messaging               |
| IoT Central          | `iot-central.md`          | IoT Central, IoT SaaS, IoT Application                 |
| Event Hubs           | `event-hubs.md`           | Event Hubs, Kafka on Azure, Event Streaming            |
| Event Grid           | `event-grid.md`           | Event Grid, Event Routing, Event-driven                |
| Azure Maps           | `maps.md`                 | Azure Maps, Location Services, Geospatial              |
| Digital Twins        | `digital-twins.md`        | Azure Digital Twins, ADT, IoT Modeling                 |
| Notification Hubs    | `notification-hubs.md`    | Notification Hubs, Push Notifications, ANH             |
| Time Series Insights | `time-series-insights.md` | TSI, Time Series, IoT Analytics (deprecated/migrating) |

> **Note**: Event Hubs and Event Grid are placed under IoT (matching the API `serviceFamily eq 'Internet of Things'`) even though they're often used outside IoT scenarios. Service reference files should note this dual nature.

## Developer Tools (`services/developer-tools/`)

Development environments, testing, configuration, and DevOps tooling.

| API serviceName               | Suggested Filename           | Aliases / Portal Names                                    |
| ----------------------------- | ---------------------------- | --------------------------------------------------------- |
| App Configuration             | `app-configuration.md`       | App Configuration, Feature Flags, Configuration Store     |
| Azure Lab Services            | `lab-services.md`            | Lab Services, Classroom Labs, DevTest Labs                |
| Microsoft Playwright Testing  | `playwright-testing.md`      | Playwright, Browser Testing, E2E Testing                  |
| Azure App Testing             | `app-testing.md`             | App Testing, Mobile App Testing                           |
| Azure Fluid Relay             | `fluid-relay.md`             | Fluid Framework, Real-time Collaboration                  |
| Azure Grafana Service         | `grafana.md`                 | Managed Grafana, Azure Managed Grafana, Grafana Dashboard |
| Visual Studio Codespaces      | `codespaces.md`              | Codespaces (legacy), Cloud Dev Environments               |
| Azure DevOps                  | `devops.md`                  | Azure DevOps, ADO, Repos, Pipelines, Boards, Artifacts    |
| Azure DevTest Labs            | `devtest-labs.md`            | DevTest Labs, Lab VMs, Dev Environments                   |
| Microsoft Dev Box             | `dev-box.md`                 | Dev Box, Cloud Dev Workstation, Developer VM              |
| Azure Deployment Environments | `deployment-environments.md` | ADE, Deployment Environments, IaC Templates               |
| Azure Load Testing            | `load-testing.md`            | Load Testing, JMeter, Performance Testing                 |

> **Note**: Azure DevOps and some DevTest Labs pricing may not appear in the Retail Prices API (they have separate licensing). Reference files should document this and link to the Azure DevOps pricing page.

## Identity (`services/identity/`)

Identity management, directory services, and external identity providers.

| API serviceName                                | Suggested Filename         | Aliases / Portal Names                                            |
| ---------------------------------------------- | -------------------------- | ----------------------------------------------------------------- |
| Azure Active Directory B2C                     | `aad-b2c.md`               | AAD B2C, Azure AD B2C, External Identities B2C, Entra External ID |
| Azure Active Directory for External Identities | `aad-external.md`          | AAD External, B2B, Guest Users, Entra External ID                 |
| Microsoft Entra Domain Services                | `entra-domain-services.md` | AAD DS, Azure AD DS, Managed AD, Entra Domain Services            |
| Microsoft Entra ID                             | `entra-id.md`              | Azure AD, Azure Active Directory, Entra ID, AAD, Directory        |
| Windows 365 Agents                             | `windows-365-agents.md`    | Windows 365 Agents, Cloud PC Agents                               |

> **Note**: Microsoft Entra ID (formerly Azure AD) free tier has no retail meter. Premium P1/P2 tiers are licensed per-user, often not in the Retail Prices API. Reference files should document this licensing model.

## Migration (`services/migration/`)

Tools for migrating workloads, data, and databases to Azure.

| API serviceName                  | Suggested Filename      | Aliases / Portal Names                             |
| -------------------------------- | ----------------------- | -------------------------------------------------- |
| Azure Database Migration Service | `database-migration.md` | DMS, Database Migration Service, DB Migration      |
| Azure Migrate                    | `migrate.md`            | Azure Migrate, Server Assessment, Server Migration |
| Azure Site Recovery              | `site-recovery.md`      | ASR (also in Management for DR use case)           |

> **Note**: Migration has significant overlap with Management (Site Recovery) and Databases (DMS). Place the primary reference in the category matching the API `serviceFamily`. Add cross-references in the other category.

## Web (`services/web/`)

Web-hosted search, content delivery, and web application platforms.

| API serviceName        | Suggested Filename    | Aliases / Portal Names                                              |
| ---------------------- | --------------------- | ------------------------------------------------------------------- |
| Azure Cognitive Search | `cognitive-search.md` | Azure AI Search, Cognitive Search, Search Service, Full-text Search |
| Azure Static Web Apps  | `static-web-apps.md`  | Static Web Apps, SWA, JAMstack                                      |
| Azure Spring Cloud     | `spring-apps.md`      | Azure Spring Apps, Spring Cloud, Java Microservices                 |

> **Note**: Azure Spring Cloud/Apps appears under `serviceFamily eq 'Other'` in the API. We route it to Web because it's a web app hosting service. Static Web Apps may not have retail pricing meters (free tier is common).

## Communication (`services/communication/`)

Communication platforms, telephony, messaging, and telecom services.

| API serviceName   | Suggested Filename     | Aliases / Portal Names                                 |
| ----------------- | ---------------------- | ------------------------------------------------------ |
| Phone Numbers     | `phone-numbers.md`     | ACS Phone Numbers, PSTN, Telephony                     |
| Voice             | `voice.md`             | ACS Voice, Voice Calling, VOIP                         |
| Email             | `email.md`             | ACS Email, Email Communication                         |
| Messaging         | `messaging.md`         | ACS Chat, Chat Messaging                               |
| SMS               | `sms.md`               | ACS SMS, Text Messaging                                |
| Network Traversal | `network-traversal.md` | ACS TURN, TURN Relay, Network Traversal                |
| AI Ops            | `ai-ops.md`            | Telecom AI Ops, Azure Operator Insights                |
| Packet Core       | `packet-core.md`       | Azure Private 5G Core, Packet Core, Mobile Packet Core |

> **Note**: All Azure Communication Services appear as separate `serviceName` values per feature (Voice, SMS, Email, etc.) rather then one unified entry. Telecom services (AI Ops, Packet Core) are from `serviceFamily eq 'Telecommunications'`.

## Specialist (`services/specialist/`)

Niche, emerging, or cross-cutting services that don't fit other categories.

| API serviceName          | Suggested Filename       | Aliases / Portal Names                                       |
| ------------------------ | ------------------------ | ------------------------------------------------------------ |
| Azure Blockchain         | `blockchain.md`          | Blockchain Service, Blockchain Workbench (deprecated)        |
| Azure Remote Rendering   | `remote-rendering.md`    | Remote Rendering, 3D Rendering, Mixed Reality                |
| Quantum Computing        | `quantum-computing.md`   | Azure Quantum, Quantum Computing, Q#                         |
| Azure API for FHIR       | `fhir.md`                | FHIR API, Healthcare API, Health Data Services               |
| Energy Data Manager      | `energy-data-manager.md` | Energy Data Manager, OSDU, Oil & Gas Data                    |
| Microsoft Dragon Copilot | `dragon-copilot.md`      | Dragon Copilot, Healthcare Copilot, Clinical Documentation   |
| Microsoft Copilot Studio | `copilot-studio.md`      | Copilot Studio, Power Virtual Agents, Chatbot Builder        |
| Syntex                   | `syntex.md`              | Microsoft Syntex, SharePoint Syntex, Document Processing     |
| Azure Spatial Anchors    | `spatial-anchors.md`     | Spatial Anchors, AR Anchors, Mixed Reality Anchors           |
| Azure Stack Edge         | `stack-edge.md`          | Stack Edge, Azure Stack Edge, Edge Computing, Edge Appliance |
