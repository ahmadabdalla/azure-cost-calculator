# Service Catalog - Pending Documentation

This catalog tracks Azure services pending documentation. Implemented services are in [service-routing.md](../skills/azure-cost-calculator/references/service-routing.md).

For the Category Index and constants, see [shared.md](../skills/azure-cost-calculator/references/shared.md).

Filename convention: strip "Azure"/"Microsoft"/"MS" prefix - kebab-case - `.md`
Branded compound words (SignalR, DevOps, OpenAI, BizTalk, PlayFab, PubSub) are single tokens - lowercase without hyphens.
Example: "Azure Data Factory" - `data-factory.md` | "SignalR" - `signalr.md` | "Azure DevOps" - `devops.md`

## Routing Notes

- Some services share a `serviceName`; use `productName` filters to isolate.
- API `serviceFamily` may differ from category here. Always use this file's category.
- Services with no retail meter still need reference files.

## Entry Format

Each entry follows the pattern: `- {display name}: {alias1}, {alias2}, ...`

- **Display name** (before the colon): The human-readable service name. When implementing, verify the exact API `serviceName` using the exploration script.
- **Aliases** (after the colon): Comma-separated alternate names, abbreviations, and search terms for this service.

## Compute (services/compute/)

- Azure Local: Azure Stack Local, Hybrid Compute
- Azure Red Hat OpenShift: ARO, OpenShift
- Azure VM Image Builder: Image Builder, AIB, VM Image, Custom Image
- Cloud Services: Cloud Services (classic), PaaS VMs, Worker Roles, Web Roles
- Durable Task Scheduler: Durable Tasks, Workflow Scheduler
- HPC Cache: High Performance Compute Cache
- Service Fabric: Service Fabric Mesh, SF, SF Mesh, Microservices, Microservices Cluster, Reliable Services
- Specialized Compute: SAP HANA Large Instances, Azure Boost
- Virtual Machines Licenses: VM Licenses, BYOL, Windows Server License, SQL Server License

## Containers (services/containers/)

- AKS on Azure Stack HCI: AKS-HCI, AKS on HCI, Kubernetes on Azure Stack HCI
- Azure Arc-enabled AKS: Arc AKS, Arc-enabled Kubernetes, Arc K8s

## Databases (services/databases/)

- Azure Arc Enabled Databases: Arc SQL MI, Arc PostgreSQL, Arc-enabled Data Services
- Azure Cosmos DB for PostgreSQL: Cosmos DB PostgreSQL, Citus, PostgreSQL Hyperscale, Cosmos DB for Postgres
- Azure Database for MariaDB: MariaDB, Azure MariaDB
- Azure HorizonDB: Horizon DB, Distributed PostgreSQL
- Azure Managed Instance for Apache Cassandra: Cassandra MI, Apache Cassandra, Managed Cassandra
- Azure SQL Edge: Edge Database, IoT SQL
- Cosmos DB Garnet Cache: Garnet Cache, Redis-compatible Cache, Cosmos DB Cache, vCore Cache
- SQL Data Warehouse: Azure Synapse SQL Pool (dedicated), DW, Data Warehouse
- SQL DB Edge: Edge SQL (legacy name for Azure SQL Edge)
- SQL Server Stretch Database: Stretch DB, SQL Stretch

## Networking (services/networking/)

- Advanced Container Networking Services: Advanced CNI, Container Networking, Cilium, Azure CNI Overlay
- Azure Firewall Manager: Firewall Policy
- Azure Orbital: Ground Station, Satellite
- Azure Programmable Connectivity: APC, Network APIs
- Azure Route Server: BGP Routing
- Microsoft Azure Peering Service: ISP Peering, Internet Peering
- Private Mobile Network: Private 5G Core, Mobile Network, MEC

## Storage (services/storage/)

- Azure Container Storage: Container-native Storage, Kubernetes Storage
- Azure Elastic SAN: SAN, Block Storage
- Azure File Sync: Hybrid File Sync, File Server Sync, Cloud Tiering
- Azure Managed Lustre: Lustre, HPC Storage
- Data Box Gateway: Data Box Virtual Appliance, Hybrid Data Transfer Gateway
- Storage Actions: Storage Data Processing, Storage Task Automation, Serverless Storage Processing
- StorSimple: Hybrid Cloud Storage, StorSimple Array, StorSimple Virtual Array

## Security (services/security/)

- Azure Cloud HSM: Dedicated HSM, Hardware Security Module
- Azure confidential ledger: CCF, Blockchain Ledger
- Azure Defender EASM: External Attack Surface Management, EASM, Attack Surface
- Azure IoT Security: Defender for IoT, OT Security
- Microsoft Azure Payment HSM: Payment Processing HSM
- Microsoft Defender Experts: XDR Experts, Managed Detection and Response
- Microsoft Entra: Entra Suite, Microsoft Entra (exact API name), Entra ID metered
- Microsoft Entra Verified ID: Verified ID, Verifiable Credentials, Decentralized Identity, DID
- Microsoft Graph Services: Microsoft Graph, Graph API metered usage
- Microsoft Security Copilot: Copilot for Security
- Multi-Factor Authentication: MFA, Multi-Factor Auth, Azure MFA, Two-Factor Authentication
- Trusted Signing: Code Signing, Azure Code Signing

## Monitoring (services/monitoring/)

- Azure SCOM Managed Instance: SCOM MI, Operations Manager, System Center Operations Manager
- Insight and Analytics: OMS (legacy), Insight and Analytics (legacy)

## Management (services/management/)

- Azure Advisor: Best Practices
- Azure Arc: Hybrid Management, Arc-enabled Servers, Arc-enabled K8s
- Azure Blueprints: Governance Templates (deprecated)
- Azure Chaos Studio: Chaos Engineering, Fault Injection
- Azure Cost Management: Billing, Budgets, Cost Analysis
- Azure Lighthouse: Delegated Resource Management, MSP Management
- Azure Policy: Compliance, Governance
- Azure Resource Mover: Move Resources, Subscription Mover
- Azure Update Manager: Patch Management, OS Updates
- Azure Virtual Enclaves: Isolated Environments, Secure Enclaves
- Change Tracking and Inventory: Change Tracking, Inventory Tracking, Configuration Tracking
- Dynamics 365 for Customer Insights: Customer Insights, D365 CI, Dynamics 365 Analytics
- Scheduler: Azure Scheduler (legacy), Job Scheduler

## Integration (services/integration/)

- Azure API Center: API Catalog, API Inventory
- BizTalk Services: BizTalk, BizTalk Services (legacy), B2B Integration

## Analytics (services/analytics/)

- Azure Data Share: Data Sharing
- Azure Managed Airflow: ADF Airflow, Apache Airflow, Data Factory Airflow
- Data Catalog: Data Catalog (legacy)
- Data Lake Store: ADLS Gen1, Azure Data Lake (legacy)
- Microsoft Graph data connect: Microsoft 365 Data, M365 Data Export
- Microsoft Planetary Computer Pro: Planetary Computer, Geospatial Analytics
- Power BI: Power BI Service
- Web PubSub: WebSocket Service

## AI + ML (services/ai-ml/)

- Azure AI Content Understanding: Content Extraction, Multi-modal AI, Document Understanding
- Azure Speech: Speech to Text, STT, TTS, Text to Speech, Neural TTS, Speech Services
- Azure Video Indexer: Video AI, Media Indexer, Video Analysis
- Content Safety: Content Moderation, Image Moderation, Text Moderation, AI Content Safety
- Foundry Agents: AI Agents, Agent Orchestration, HOBO Agents, SRE Agent
- Foundry Models: Azure AI Foundry Models, Model Catalog, AI Foundry

## IoT (services/iot/)

- AKS Edge Essentials: AKS Edge, K8s Edge, Kubernetes Edge Essentials
- Azure Device Registry: IoT Device Registry, Asset Registry
- Azure IoT Operations: IoT Ops, Edge IoT, Azure IoT OPC UA
- Time Series Insights: TSI, Time Series, IoT Analytics (deprecated/migrating)
- Windows 10 IoT Core Services: IoT Core, Windows IoT, IoT Core Services, Windows CE

## Developer Tools (services/developer-tools/)

- Azure App Testing: Mobile App Testing
- Azure Deployment Environments: ADE, IaC Templates
- Azure DevTest Labs: Lab VMs, Dev Environments
- Azure Fluid Relay: Fluid Framework, Real-time Collaboration
- Azure Lab Services: Classroom Labs, DevTest Labs
- Azure Load Testing: JMeter, Performance Testing
- GitHub: GitHub Enterprise, GitHub Actions, GitHub Copilot
- GitHub AE: GitHub Enterprise (Azure-hosted, legacy)
- Microsoft Dev Box: Cloud Dev Workstation, Developer VM
- Microsoft Playwright Testing: Playwright, Browser Testing, E2E Testing
- Test Base: Test Base for Microsoft 365, Compatibility Testing
- Visual Studio Codespaces: Codespaces (legacy), Cloud Dev Environments
- Visual Studio Subscription: VS Subscription, MSDN, Visual Studio Enterprise/Professional

## Identity (services/identity/)

- Azure Active Directory for External Identities: AAD External, B2B, Guest Users, Entra External ID
- Windows 365 Agents: Cloud PC Agents

## Web (services/web/)

- Community Training: Learning

## Communication (services/communication/)

- AI Ops: Telecom AI Ops, Azure Operator Insights
- Azure Operator Nexus: Telecom Nexus, Carrier Network
- Packet Core: Azure Private 5G Core, Mobile Packet Core
- Routing: ACS Routing, Communication Routing, Call Routing
- Voice Core: Telecom Voice, Core Voice Infrastructure

## Specialist (services/specialist/)

- Azure API for FHIR: FHIR API, Healthcare API, Health Data Services
- Azure Blockchain: Blockchain Service, Blockchain Workbench (deprecated)
- Azure Health Bot: Healthcare Bot, Health Virtual Assistant, Medical Bot
- Azure Orbital Edge: Edge Satellite, Space Edge Computing
- Azure Remote Rendering: 3D Rendering, Mixed Reality
- Azure Spatial Anchors: AR Anchors, Mixed Reality Anchors
- Azure Stack Edge: Edge Computing, Edge Appliance
- Azure Stack HCI: HCI, Hyper-Converged Infrastructure
- Azure Stack Hub: Azure Stack (original)
- Dataverse: Common Data Service, CDS, Power Platform Data
- Energy Data Manager: OSDU, Oil & Gas Data
- Firmware Analysis: Defender for IoT Firmware, IoT Firmware
- Microsoft Copilot Studio: Power Virtual Agents, Chatbot Builder
- Microsoft Dragon Copilot: Healthcare Copilot, Clinical Documentation
- MS Bing Services: Bing Search, Bing API, Bing Search API
- PlayFab: Game Backend, Game Services
- Power Apps: PowerApps, Low-code Apps, Canvas Apps, Model-driven
- Power Automate: Flow, Microsoft Flow, Workflow Automation
- Power Pages: Portal, Power Apps Portals, Low-code Websites
- Quantum Computing: Azure Quantum, Q#
- SAP Embrace: SAP on Azure, SAP Integration
- Syntex: SharePoint Syntex, Document Processing
