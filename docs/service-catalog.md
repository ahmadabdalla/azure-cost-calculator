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

- Cloud Services: Cloud Services (classic), PaaS VMs, Worker Roles, Web Roles
- Service Fabric: Service Fabric Mesh, SF, SF Mesh, Microservices, Microservices Cluster, Reliable Services
- Azure Red Hat OpenShift: ARO, OpenShift
- Specialized Compute: SAP HANA Large Instances, Azure Boost
- HPC Cache: High Performance Compute Cache
- Durable Task Scheduler: Durable Tasks, Workflow Scheduler
- Azure VM Image Builder: Image Builder, AIB, VM Image, Custom Image
- Virtual Machines Licenses: VM Licenses, BYOL, Windows Server License, SQL Server License
- Azure Local: Azure Stack Local, Hybrid Compute

## Containers (services/containers/)

- AKS on Azure Stack HCI: AKS-HCI, AKS on HCI, Kubernetes on Azure Stack HCI
- Azure Arc-enabled AKS: Arc AKS, Arc-enabled Kubernetes, Arc K8s

## Databases (services/databases/)

- Azure Database for MariaDB: MariaDB, Azure MariaDB
- Azure Managed Instance for Apache Cassandra: Cassandra MI, Apache Cassandra, Managed Cassandra
- SQL Data Warehouse: Azure Synapse SQL Pool (dedicated), DW, Data Warehouse
- SQL Server Stretch Database: Stretch DB, SQL Stretch
- Azure Arc Enabled Databases: Arc SQL MI, Arc PostgreSQL, Arc-enabled Data Services
- Azure SQL Edge: Edge Database, IoT SQL
- SQL DB Edge: Edge SQL (legacy name for Azure SQL Edge)

## Networking (services/networking/)

- Azure Firewall Manager: Firewall Policy
- Network Watcher: NSG Flow Logs, Connection Monitor
- Azure Orbital: Ground Station, Satellite
- Private Mobile Network: Private 5G Core, Mobile Network, MEC
- Azure Route Server: BGP Routing
- Advanced Container Networking Services: Advanced CNI, Container Networking, Cilium, Azure CNI Overlay
- Microsoft Azure Peering Service: ISP Peering, Internet Peering
- Azure Programmable Connectivity: APC, Network APIs

## Storage (services/storage/)

- Azure Elastic SAN: SAN, Block Storage
- Azure Managed Lustre: Lustre, HPC Storage
- StorSimple: Hybrid Cloud Storage, StorSimple Array, StorSimple Virtual Array

## Security (services/security/)

- Microsoft Purview: Data Governance, Data Catalog
- Azure confidential ledger: CCF, Blockchain Ledger
- Azure Cloud HSM: Dedicated HSM, Hardware Security Module
- Microsoft Azure Payment HSM: Payment Processing HSM
- Azure IoT Security: Defender for IoT, OT Security
- Microsoft Security Copilot: Copilot for Security
- Microsoft Graph Services: Microsoft Graph, Graph API metered usage
- Microsoft Defender Experts: XDR Experts, Managed Detection and Response
- Multi-Factor Authentication: MFA, Multi-Factor Auth, Azure MFA, Two-Factor Authentication
- Trusted Signing: Code Signing, Azure Code Signing
- Microsoft Entra: Entra Suite, Microsoft Entra (exact API name), Entra ID metered
- Microsoft Entra Verified ID: Verified ID, Verifiable Credentials, Decentralized Identity, DID

## Monitoring (services/monitoring/)

- Insight and Analytics: OMS (legacy), Insight and Analytics (legacy)

## Management (services/management/)

- Automation: Runbooks, DSC, Update Management
- Azure Chaos Studio: Chaos Engineering, Fault Injection
- Scheduler: Azure Scheduler (legacy), Job Scheduler
- Azure Arc: Hybrid Management, Arc-enabled Servers, Arc-enabled K8s
- Azure Lighthouse: Delegated Resource Management, MSP Management
- Azure Policy: Compliance, Governance
- Azure Advisor: Best Practices
- Azure Cost Management: Billing, Budgets, Cost Analysis
- Azure Blueprints: Governance Templates (deprecated)
- Azure Resource Mover: Move Resources, Subscription Mover
- Azure Update Manager: Patch Management, OS Updates
- Azure Virtual Enclaves: Isolated Environments, Secure Enclaves
- Change Tracking and Inventory: Change Tracking, Inventory Tracking, Configuration Tracking
- Dynamics 365 for Customer Insights: Customer Insights, D365 CI, Dynamics 365 Analytics

## Integration (services/integration/)

- Azure API Center: API Catalog, API Inventory
- BizTalk Services: BizTalk, BizTalk Services (legacy), B2B Integration

## Analytics (services/analytics/)

- Azure Analysis Services: AAS, Tabular Model
- Power BI: Power BI Service
- Data Catalog: Data Catalog (legacy)
- Azure Purview: Purview Data Map, Data Estate Scanning
- Azure Data Share: Data Sharing
- Microsoft Planetary Computer Pro: Planetary Computer, Geospatial Analytics
- Data Lake Store: ADLS Gen1, Azure Data Lake (legacy)
- Web PubSub: WebSocket Service
- Microsoft Graph data connect: Microsoft 365 Data, M365 Data Export

## AI + ML (services/ai-ml/)

- Foundry Models: Azure AI Foundry Models, Model Catalog, AI Foundry

## IoT (services/iot/)

- IoT Central: IoT SaaS, IoT Application
- Azure Maps: Location Services, Geospatial
- Digital Twins: ADT, IoT Modeling
- Time Series Insights: TSI, Time Series, IoT Analytics (deprecated/migrating)
- AKS Edge Essentials: AKS Edge, K8s Edge, Kubernetes Edge Essentials
- Azure Device Registry: IoT Device Registry, Asset Registry
- Azure IoT Operations: IoT Ops, Edge IoT, Azure IoT OPC UA
- Windows 10 IoT Core Services: IoT Core, Windows IoT, IoT Core Services, Windows CE

## Developer Tools (services/developer-tools/)

- App Configuration: Feature Flags, Configuration Store
- Azure Lab Services: Classroom Labs, DevTest Labs
- Microsoft Playwright Testing: Playwright, Browser Testing, E2E Testing
- Azure App Testing: Mobile App Testing
- Azure Fluid Relay: Fluid Framework, Real-time Collaboration
- Azure Grafana Service: Managed Grafana, Azure Managed Grafana, Grafana Dashboard
- Visual Studio Codespaces: Codespaces (legacy), Cloud Dev Environments
- Azure DevTest Labs: Lab VMs, Dev Environments
- Microsoft Dev Box: Cloud Dev Workstation, Developer VM
- Azure Deployment Environments: ADE, IaC Templates
- Azure Load Testing: JMeter, Performance Testing
- GitHub: GitHub Enterprise, GitHub Actions, GitHub Copilot
- GitHub AE: GitHub Enterprise (Azure-hosted, legacy)
- Test Base: Test Base for Microsoft 365, Compatibility Testing
- Visual Studio Subscription: VS Subscription, MSDN, Visual Studio Enterprise/Professional

## Identity (services/identity/)

- Azure Active Directory B2C: AAD B2C, Azure AD B2C, External Identities B2C, Entra External ID
- Azure Active Directory for External Identities: AAD External, B2B, Guest Users, Entra External ID
- Microsoft Entra Domain Services: AAD DS, Azure AD DS, Managed AD
- Windows 365 Agents: Cloud PC Agents

## Web (services/web/)

- Azure Spring Cloud: Azure Spring Apps, Java Microservices
- Community Training: Learning

## Communication (services/communication/)

- AI Ops: Telecom AI Ops, Azure Operator Insights
- Packet Core: Azure Private 5G Core, Mobile Packet Core
- Azure Operator Nexus: Telecom Nexus, Carrier Network
- Voice Core: Telecom Voice, Core Voice Infrastructure
- Routing: ACS Routing, Communication Routing, Call Routing

## Specialist (services/specialist/)

- Azure Blockchain: Blockchain Service, Blockchain Workbench (deprecated)
- Azure Remote Rendering: 3D Rendering, Mixed Reality
- Quantum Computing: Azure Quantum, Q#
- Azure API for FHIR: FHIR API, Healthcare API, Health Data Services
- Energy Data Manager: OSDU, Oil & Gas Data
- Microsoft Dragon Copilot: Healthcare Copilot, Clinical Documentation
- Microsoft Copilot Studio: Power Virtual Agents, Chatbot Builder
- Syntex: SharePoint Syntex, Document Processing
- Azure Spatial Anchors: AR Anchors, Mixed Reality Anchors
- Azure Stack Edge: Edge Computing, Edge Appliance
- Azure Stack HCI: HCI, Hyper-Converged Infrastructure
- Azure Stack Hub: Azure Stack (original)
- Azure Orbital Edge: Edge Satellite, Space Edge Computing
- Firmware Analysis: Defender for IoT Firmware, IoT Firmware
- Dataverse: Common Data Service, CDS, Power Platform Data
- Power Apps: PowerApps, Low-code Apps, Canvas Apps, Model-driven
- Power Automate: Flow, Microsoft Flow, Workflow Automation
- Power Pages: Portal, Power Apps Portals, Low-code Websites
- PlayFab: Game Backend, Game Services
- MS Bing Services: Bing Search, Bing API, Bing Search API
- SAP Embrace: SAP on Azure, SAP Integration
