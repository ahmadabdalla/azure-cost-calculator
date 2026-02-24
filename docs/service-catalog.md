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

## Compute (`services/compute/`)

```yaml
- s: "Cloud Services"
  a: [Cloud Services (classic), PaaS VMs, Worker Roles, Web Roles]
- s: "Service Fabric"
  a: [Service Fabric Mesh, SF, SF Mesh, Microservices, Microservices Cluster, Reliable Services]
- s: "Azure Red Hat OpenShift"
  a: [ARO, OpenShift]
- s: "Specialized Compute"
  a: [SAP HANA Large Instances, Azure Boost]
- s: "HPC Cache"
  a: [High Performance Compute Cache]
- s: "Durable Task Scheduler"
  a: [Durable Tasks, Workflow Scheduler]
- s: "Azure VM Image Builder"
  a: [Image Builder, AIB, VM Image, Custom Image]
- s: "Virtual Machines Licenses"
  a: [VM Licenses, BYOL, Windows Server License, SQL Server License]
- s: "Azure Local"
  a: [Azure Stack Local, Hybrid Compute]
```

## Containers (`services/containers/`)

```yaml
- s: "AKS on Azure Stack HCI"
  a: [AKS-HCI, AKS on HCI, Kubernetes on Azure Stack HCI]
- s: "Azure Arc-enabled AKS"
  a: [Arc AKS, Arc-enabled Kubernetes, Arc K8s]
```

## Databases (`services/databases/`)

```yaml
- s: "Azure Database for MariaDB"
  a: [MariaDB, Azure MariaDB]
- s: "Azure Managed Instance for Apache Cassandra"
  a: [Cassandra MI, Apache Cassandra, Managed Cassandra]
- s: "SQL Data Warehouse"
  a: [Azure Synapse SQL Pool (dedicated), DW, Data Warehouse]
- s: "SQL Server Stretch Database"
  a: [Stretch DB, SQL Stretch]
- s: "Azure Arc Enabled Databases"
  a: [Arc SQL MI, Arc PostgreSQL, Arc-enabled Data Services]
- s: "Azure SQL Edge"
  a: [Edge Database, IoT SQL]
- s: "SQL DB Edge"
  a: [Edge SQL (legacy name for Azure SQL Edge)]
```

## Networking (`services/networking/`)

```yaml
- s: "Azure Firewall Manager"
  a: [Firewall Policy]
- s: "Virtual WAN"
  a: [vWAN, WAN Hub]
- s: "Bandwidth"
  a: [Data Transfer, Egress, Outbound Transfer, Inter-region Transfer]
- s: "Network Watcher"
  a: [NSG Flow Logs, Connection Monitor]
- s: "Azure Orbital"
  a: [Ground Station, Satellite]
- s: "Private Mobile Network"
  a: [Private 5G Core, Mobile Network, MEC]
- s: "Azure Route Server"
  a: [BGP Routing]
- s: "Advanced Container Networking Services"
  a: [Advanced CNI, Container Networking, Cilium, Azure CNI Overlay]
- s: "Microsoft Azure Peering Service"
  a: [ISP Peering, Internet Peering]
- s: "Azure Programmable Connectivity"
  a: [APC, Network APIs]
```

## Storage (`services/storage/`)

```yaml
- s: "Azure NetApp Files"
  a: [NetApp, ANF, Azure NetApp]
- s: "Azure Elastic SAN"
  a: [SAN, Block Storage]
- s: "Azure Managed Lustre"
  a: [Lustre, HPC Storage]
- s: "StorSimple"
  a: [Hybrid Cloud Storage, StorSimple Array, StorSimple Virtual Array]
```

## Security (`services/security/`)

```yaml
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
  a: [MFA, Multi-Factor Auth, Azure MFA, Two-Factor Authentication]
- s: "Trusted Signing"
  a: [Code Signing, Azure Code Signing]
- s: "Microsoft Entra"
  a: [Entra Suite, Microsoft Entra (exact API name), Entra ID metered]
- s: "Microsoft Entra Verified ID"
  a: [Verified ID, Verifiable Credentials, Decentralized Identity, DID]
```

## Monitoring (`services/monitoring/`)

```yaml
- s: "Insight and Analytics"
  a: [OMS (legacy), Insight and Analytics (legacy)]
```

## Management (`services/management/`)

```yaml
- s: "Automation"
  a: [Runbooks, DSC, Update Management]
- s: "Azure Chaos Studio"
  a: [Chaos Engineering, Fault Injection]
- s: "Scheduler"
  a: [Azure Scheduler (legacy), Job Scheduler]
- s: "Azure Arc"
  a: [Hybrid Management, Arc-enabled Servers, Arc-enabled K8s]
- s: "Azure Lighthouse"
  a: [Delegated Resource Management, MSP Management]
- s: "Azure Policy"
  a: [Compliance, Governance]
- s: "Azure Advisor"
  a: [Best Practices]
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
  a: [Customer Insights, D365 CI, Dynamics 365 Analytics]
```

## Integration (`services/integration/`)

```yaml
- s: "Azure API Center"
  a: [API Catalog, API Inventory]
- s: "BizTalk Services"
  a: [BizTalk, BizTalk Services (legacy), B2B Integration]
```

## Analytics (`services/analytics/`)

```yaml
- s: "Azure Data Explorer"
  a: [ADX, Kusto]
- s: "HDInsight"
  a: [Hadoop, Spark, HBase, Kafka, HDI]
- s: "Azure Analysis Services"
  a: [AAS, Tabular Model]
- s: "Power BI"
  a: [Power BI Service]
- s: "Power BI Embedded"
  a: [PBI Embedded, Embedded Analytics]
- s: "Data Catalog"
  a: [Data Catalog (legacy)]
- s: "Azure Purview"
  a: [Purview Data Map, Data Estate Scanning]
- s: "Azure Data Share"
  a: [Data Sharing]
- s: "Microsoft Fabric"
  a: [Fabric Capacity, OneLake, Lakehouse]
- s: "Microsoft Planetary Computer Pro"
  a: [Planetary Computer, Geospatial Analytics]
- s: "Data Lake Store"
  a: [ADLS Gen1, Azure Data Lake (legacy)]
- s: "Web PubSub"
  a: [WebSocket Service]
- s: "Microsoft Graph data connect"
  a: [Microsoft 365 Data, M365 Data Export]
```

## AI + ML (`services/ai-ml/`)

```yaml
- s: "Foundry Models"
  a: [Azure AI Foundry Models, Model Catalog, AI Foundry]
```

## IoT (`services/iot/`)

```yaml
- s: "IoT Central"
  a: [IoT SaaS, IoT Application]
- s: "Azure Maps"
  a: [Location Services, Geospatial]
- s: "Digital Twins"
  a: [ADT, IoT Modeling]
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
  a: [Managed Grafana, Azure Managed Grafana, Grafana Dashboard]
- s: "Visual Studio Codespaces"
  a: [Codespaces (legacy), Cloud Dev Environments]
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
  a: [AAD B2C, Azure AD B2C, External Identities B2C, Entra External ID]
- s: "Azure Active Directory for External Identities"
  a: [AAD External, B2B, Guest Users, Entra External ID]
- s: "Microsoft Entra Domain Services"
  a: [AAD DS, Azure AD DS, Managed AD]
- s: "Windows 365 Agents"
  a: [Cloud PC Agents]
```

## Migration (`services/migration/`)

```yaml
- s: "Azure Database Migration Service"
  a: [DMS, Database Migration, DB Migration Service]
- s: "Azure Migrate"
  a: [Server Assessment, Migration Tools]
- s: "Azure Site Recovery"
  a: [ASR, Disaster Recovery, DR]
```

## Web (`services/web/`)

```yaml
- s: "Azure Spring Cloud"
  a: [Azure Spring Apps, Java Microservices]
- s: "Community Training"
  a: [Learning]
```

## Communication (`services/communication/`)

```yaml
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

