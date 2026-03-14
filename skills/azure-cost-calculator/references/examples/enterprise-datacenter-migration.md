# Enterprise Manufacturing — On-Premises Data Center Migration to Azure, North Europe

A European industrial manufacturing group is migrating its primary on-premises data center to Azure via lift-and-shift. The estate comprises 100 servers spanning SAP ERP, engineering CAD/PLM workflows, a manufacturing execution system (MES), corporate web applications, middleware, and shared infrastructure services. The company holds Windows Server 2022 Datacenter and SQL Server Enterprise licenses qualifying for Azure Hybrid Benefit across all Windows and SQL workloads. Databases are migrated via backup and restore over existing ExpressRoute connectivity. Production workloads are distributed across availability zones in North Europe. Disaster recovery replication to West Europe is handled by Azure Site Recovery. Microsoft Defender for Cloud Servers Plan 2 is enabled on all Windows Server instances. Existing ExpressRoute circuits, Azure virtual networks, VNet peering, and DNS infrastructure are already provisioned and excluded from this estimate.

**VM Summary**: 100 VMs total — 70 Windows Server 2022, 30 Linux (Ubuntu 22.04). Disk mix: 10 Ultra Disk, 40 Premium SSD v2, 50 Standard SSD. Commitment mix: 10 three-year RI, 62 one-year RI, 28 Pay-As-You-Go.

**OS Disks**: Each VM includes 1× E10 LRS Standard SSD (128 GB) OS disk — 100 OS disks total, not listed per VM below.

**Standard SSD Disk Operations**: Disk operations (per 10K transactions) for all Standard SSD disks (50 data disks + 100 OS disks) are estimated at zero (negligible transactional I/O).

## ERP & Core Business Applications

- 4× Azure Virtual Machines, Standard_E32s_v5 (Windows), 3-Year Reserved, AHUB enabled — SAP application servers
  - 1× Ultra Disk, 512 GB, 5,000 provisioned IOPS, 200 MBps provisioned throughput, 32 vCPU reservation per VM
- 2× Azure Virtual Machines, Standard_E64s_v5 (Windows), 3-Year Reserved, AHUB enabled — SAP database servers
  - 1× Ultra Disk, 1,024 GB, 10,000 provisioned IOPS, 300 MBps provisioned throughput, 64 vCPU reservation per VM
- 6× Azure Virtual Machines, Standard_D8s_v5 (Windows), 1-Year Reserved, AHUB enabled — SAP central services and web dispatchers
  - 1× Premium SSD v2, 256 GB, 3,000 provisioned IOPS, 125 MBps provisioned throughput per VM
- 4× Azure Virtual Machines, Standard_D4s_v5 (Windows), 1-Year Reserved, AHUB enabled — manufacturing execution system (MES) servers
  - 1× Premium SSD v2, 256 GB, 3,000 provisioned IOPS, 125 MBps provisioned throughput per VM
- 4× Azure Virtual Machines, Standard_D4s_v5 (Windows), 1-Year Reserved, AHUB enabled — quality management system
  - 1× E15 LRS Standard SSD Managed Disk (256 GB) per VM
- 4× Azure Virtual Machines, Standard_D2s_v5 (Windows), Pay-As-You-Go, AHUB enabled — job scheduling and utility servers
  - 1× E10 LRS Standard SSD Managed Disk (128 GB) per VM

## Web & Application Layer

- 6× Azure Virtual Machines, Standard_D4s_v5 (Linux), 1-Year Reserved — customer self-service portal
  - 1× Premium SSD v2, 128 GB, 3,000 provisioned IOPS, 125 MBps provisioned throughput per VM
- 4× Azure Virtual Machines, Standard_D4s_v5 (Windows), 1-Year Reserved, AHUB enabled — corporate intranet
  - 1× E15 LRS Standard SSD Managed Disk (256 GB) per VM
- 4× Azure Virtual Machines, Standard_D2s_v5 (Linux), Pay-As-You-Go — internal API services
  - 1× E10 LRS Standard SSD Managed Disk (128 GB) per VM
- 2× Azure Virtual Machines, Standard_D2s_v5 (Windows), Pay-As-You-Go, AHUB enabled — legacy web applications
  - 1× E10 LRS Standard SSD Managed Disk (128 GB) per VM

## Middleware & Integration

- 4× Azure Virtual Machines, Standard_D8s_v5 (Windows), 1-Year Reserved, AHUB enabled — BizTalk integration servers
  - 1× Premium SSD v2, 256 GB, 3,000 provisioned IOPS, 125 MBps provisioned throughput per VM
- 4× Azure Virtual Machines, Standard_D4s_v5 (Linux), 1-Year Reserved — RabbitMQ message broker cluster
  - 1× E15 LRS Standard SSD Managed Disk (256 GB) per VM
- 4× Azure Virtual Machines, Standard_D4s_v5 (Windows), 1-Year Reserved, AHUB enabled — ETL/SSIS data integration servers
  - 1× E15 LRS Standard SSD Managed Disk (256 GB) per VM

## Engineering & PLM Systems

- 6× Azure Virtual Machines, Standard_F16s_v2 (Windows), 1-Year Reserved, AHUB enabled — CAD batch rendering servers
  - 1× Premium SSD v2, 512 GB, 3,000 provisioned IOPS, 125 MBps provisioned throughput per VM
- 6× Azure Virtual Machines, Standard_D8s_v5 (Windows), 1-Year Reserved, AHUB enabled — PLM/PDM application servers
  - 1× Premium SSD v2, 256 GB, 3,000 provisioned IOPS, 125 MBps provisioned throughput per VM

## Data Processing & Reporting

- 4× Azure Virtual Machines, Standard_E16s_v5 (Linux), 1-Year Reserved — batch data processing nodes
  - 1× Premium SSD v2, 512 GB, 3,000 provisioned IOPS, 125 MBps provisioned throughput per VM
- 4× Azure Virtual Machines, Standard_E8s_v5 (Windows), 1-Year Reserved, AHUB enabled — SSRS reporting servers
  - 1× E15 LRS Standard SSD Managed Disk (256 GB) per VM
- 4× Azure Virtual Machines, Standard_E8s_v5 (Linux), 1-Year Reserved — data warehouse staging and ETL workers
  - 1× Ultra Disk, 512 GB, 5,000 provisioned IOPS, 200 MBps provisioned throughput, 8 vCPU reservation per VM

## Infrastructure & Management

- 4× Azure Virtual Machines, Standard_D2s_v5 (Windows), 3-Year Reserved, AHUB enabled — Active Directory domain controllers
  - 1× Premium SSD v2, 128 GB, 3,000 provisioned IOPS, 125 MBps provisioned throughput per VM
- 4× Azure Virtual Machines, Standard_D2s_v5 (Windows), Pay-As-You-Go, AHUB enabled — jump/management servers
  - 1× E10 LRS Standard SSD Managed Disk (128 GB) per VM
- 2× Azure Virtual Machines, Standard_D4s_v5 (Windows), 1-Year Reserved, AHUB enabled — SCOM management servers
  - 1× E15 LRS Standard SSD Managed Disk (256 GB) per VM
- 2× Azure Virtual Machines, Standard_D2s_v5 (Linux), Pay-As-You-Go — Ansible automation controllers
  - 1× E10 LRS Standard SSD Managed Disk (128 GB) per VM
- 2× Azure Virtual Machines, Standard_D4s_v5 (Windows), Pay-As-You-Go, AHUB enabled — PKI and certificate authority servers
  - 1× E10 LRS Standard SSD Managed Disk (128 GB) per VM
- 2× Azure Virtual Machines, Standard_D2s_v5 (Linux), Pay-As-You-Go — monitoring collectors and log forwarders
  - 1× E6 LRS Standard SSD Managed Disk (64 GB) per VM

## Development & Test

- 4× Azure Virtual Machines, Standard_D4s_v5 (Linux), Pay-As-You-Go — development servers
  - 1× E10 LRS Standard SSD Managed Disk (128 GB) per VM
- 4× Azure Virtual Machines, Standard_D4s_v5 (Windows), Pay-As-You-Go, AHUB enabled — test and QA servers
  - 1× E15 LRS Standard SSD Managed Disk (256 GB) per VM

## Database Layer

- 1× Azure SQL Managed Instance, Business Critical tier, Gen5, 16 vCores, Zone Redundant, 1-Year Reserved, SQL AHUB enabled — SAP and ERP transactional databases
  - 1 TB storage (ZRS, included with zone-redundant deployment)
- 1× Azure SQL Managed Instance, General Purpose tier, Gen5, 8 vCores, Zone Redundant, 1-Year Reserved, SQL AHUB enabled — LOB application databases (CRM, HR, procurement)
  - 512 GB storage (ZRS, included with zone-redundant deployment)
- 1× Azure Database for PostgreSQL, Flexible Server, General Purpose, Standard_D4ds_v5 (4 vCores, 16 GB RAM), Zone Redundant HA, Pay-As-You-Go — Linux application databases
  - 512 GB storage, 1,536 included IOPS (3 IOPS/GiB × 512 GiB, no additional IOPS provisioned)

## File & Object Storage

- 1× Azure NetApp Files, Premium tier, 20 TB capacity pool — CAD/engineering file shares (SMB protocol)
- 1× Azure Storage Account, Premium FileStorage, LRS, 5 TB provisioned — corporate file shares
- 1× Azure Storage Account, General Purpose v2, Hot access tier, ZRS, 2 TB stored — application data, VM diagnostics, NSG flow logs
- 1× Azure Storage Account, General Purpose v2, Cool access tier, ZRS, 10 TB stored — backup staging, archival documents, compliance exports

## Network Security & Connectivity

ExpressRoute circuits, virtual networks, VNet peering, and DNS zones are already provisioned and excluded from this estimate.

- 1× Azure Application Gateway, WAF_v2 SKU, zone redundant, autoscaling (minimum 2, maximum 10 capacity units), 500 GB data processed per month — external web tier ingress
- 1× Azure Firewall, Standard tier, zone redundant, 2,000 GB data processed per month — centralized hub network traffic inspection
- 2× Azure Standard Load Balancer, internal — SAP tier (5 load balancing rules, 500 GB data processed/month) and web tier (5 load balancing rules, 300 GB data processed/month)
- 1× Azure Bastion, Standard SKU, 2 scale units — secure RDP/SSH management access
- 1× Azure NAT Gateway, 2 associated public IPs, 1,000 GB data processed per month — outbound internet connectivity for private subnets
- 5× Public IP addresses, Standard SKU, static, zone redundant — Application Gateway (1), Azure Firewall (1), NAT Gateway (2), Azure Bastion (1)

## Migration & Disaster Recovery

Database migration is performed via backup and restore over ExpressRoute. Server migration uses Azure Migrate with Azure Site Recovery for replication. Post-migration, Site Recovery continues for ongoing DR to West Europe.

- Azure Migrate — assessment and server migration tooling (free service, no direct compute cost)
- 1× Azure Site Recovery, 100 protected VMs replicating from North Europe to West Europe — ongoing disaster recovery
- 1× Azure Storage Account, Standard LRS, Hot, 500 GB — Site Recovery cache storage in North Europe
- Replica managed disks provisioned automatically by Site Recovery in West Europe — 200 Standard HDD managed disks (100 data disks + 100 OS disks, matching source capacities), billed in the DR region

## Backup & Retention

- Azure Backup, 100 Azure VMs protected, LRS redundancy
  - 90 instances with 50–500 GB protected data each
  - 10 instances with 500 GB–2 TB protected data each
  - 15 TB total backup storage (LRS)
  - Retention: 30 daily, 12 monthly, 1 yearly restore points
- Azure SQL Managed Instance automated backups (PITR backup storage included up to allocated instance data size; overage billed separately)
  - Long-term retention enabled: 52 weekly, 12 monthly, 1 yearly
  - 500 GB estimated LTR backup storage (LRS)

## Monitoring & Management

- 1× SCOM Managed Instance — monitoring infrastructure for 100 servers
- 1× Log Analytics workspace, Pay-as-you-go, 50 GB/day total ingestion (includes all sources below), 90-day interactive retention (59 days beyond 31-day free tier) — centralized log aggregation for all VMs, PaaS diagnostics, and security logs
- 1× Application Insights (workspace-based), 10 GB/month ingestion, 90-day retention — customer portal and external web applications (data ingested into Log Analytics workspace, included in 50 GB/day total)
- 1× Application Insights (workspace-based), 5 GB/month ingestion, 90-day retention — corporate intranet and internal applications (data ingested into Log Analytics workspace, included in 50 GB/day total)

## Security

- Microsoft Defender for Cloud, Servers Plan 2 — 70 Windows Server VMs
- 1× Microsoft Sentinel (SIEM), Pay-as-you-go, 30 GB/day analysis — security event monitoring, threat detection across all infrastructure, compliance audit logging (Sentinel analyzes a 30 GB/day subset of the 50 GB/day ingested into Log Analytics; Sentinel analysis fee is billed in addition to Log Analytics ingestion)
- 1× Azure Key Vault, Premium tier (HSM-backed), 200,000 operations/month — TLS certificates, disk encryption keys, service principal secrets, SAP credential rotation

## Private Endpoints

All PaaS services with private endpoint support are accessed exclusively via private endpoints — public network access is disabled.

SQL Managed Instances and Azure Database for PostgreSQL Flexible Server use VNet-integrated (delegated subnet) deployment — no private endpoints required. Azure NetApp Files uses delegated subnets.

| Target Service                | Sub-resource      | PE Count | Ingress GB/month | Egress GB/month | Notes                                           |
| ----------------------------- | ----------------- | -------: | ---------------: | --------------: | ----------------------------------------------- |
| Storage Account (Hot ZRS)     | blob              |        1 |              200 |             300 | App data, diagnostics, NSG flow logs            |
| Storage Account (Hot ZRS)     | table             |        1 |               50 |              80 | VM diagnostics tables                           |
| Storage Account (Cool ZRS)    | blob              |        1 |              100 |              20 | Backup staging, archival writes, rare reads     |
| Storage Account (FileStorage) | file              |        1 |              500 |             800 | SMB corporate file share traffic (5 TB share)   |
| Storage Account (ASR Cache)   | blob              |        1 |              300 |              50 | Site Recovery replication cache                 |
| Azure Key Vault               | vault             |        1 |              0.5 |               1 | Certificate and secret operations               |
| Recovery Services Vault       | AzureBackup       |        1 |              500 |             100 | VM backup data transfer                         |
| Recovery Services Vault       | AzureSiteRecovery |        1 |              300 |              50 | DR replication data transfer to West Europe     |
| Azure Monitor (AMPLS)         | —                 |        1 |               55 |              20 | Log Analytics + Application Insights + Sentinel |

**PE Totals**: 9 private endpoints, ~2,006 GB ingress, ~1,421 GB egress (~3,427 GB total data processed)

### Private DNS Zones

| Zone FQDN                                   | Service(s)                            | Notes                                    |
| ------------------------------------------- | ------------------------------------- | ---------------------------------------- |
| `privatelink.blob.core.windows.net`         | Storage (Hot, Cool, ASR Cache), AMPLS | Shared zone — 3 storage accounts + AMPLS |
| `privatelink.table.core.windows.net`        | Storage (Hot ZRS)                     | VM diagnostics table storage             |
| `privatelink.file.core.windows.net`         | Storage (FileStorage Premium)         | Corporate SMB file shares                |
| `privatelink.vaultcore.azure.net`           | Key Vault                             | HSM-backed secrets and certificates      |
| `privatelink.ne.backup.windowsazure.com`    | Recovery Services Vault (Backup)      | North Europe geo-specific backup zone    |
| `privatelink.siterecovery.windowsazure.com` | Recovery Services Vault (ASR)         | Site Recovery replication endpoint       |
| `privatelink.monitor.azure.com`             | AMPLS (Azure Monitor)                 | AMPLS required zone                      |
| `privatelink.oms.opinsights.azure.com`      | AMPLS (Log Analytics)                 | AMPLS required zone                      |
| `privatelink.ods.opinsights.azure.com`      | AMPLS (Log Analytics data)            | AMPLS required zone                      |
| `privatelink.agentsvc.azure-automation.net` | AMPLS (Agent Service)                 | AMPLS required zone                      |

**Total**: 10 Private DNS Zones, estimated 1,500,000 DNS queries/month

## Parameters

- Region: northeurope
- DR Region: westeurope (Site Recovery replication target)
- Currency: EUR
- Commitment: Mixed — 3-Year Reserved (10 VMs), 1-Year Reserved (62 VMs), Pay-As-You-Go (28 VMs); 1-Year Reserved for SQL MI; Pay-As-You-Go for PostgreSQL Flexible Server
- Hybrid Benefit: Windows Server AHUB on all 70 Windows VMs, SQL AHUB on both SQL Managed Instances (Linux VMs excluded)
- Zone Redundancy: Enabled — VMs across availability zones, SQL MI (BC and GP) zone redundant, PostgreSQL Flexible zone redundant HA, Application Gateway zone redundant, Azure Firewall zone redundant, Standard Load Balancer zone redundant, Public IPs zone redundant, Storage ZRS
- Excluded from estimate: ExpressRoute circuits, Azure virtual networks, VNet peering, DNS zones (already provisioned)
