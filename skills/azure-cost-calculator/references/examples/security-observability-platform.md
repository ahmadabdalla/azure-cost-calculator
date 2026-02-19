# Security & Observability Platform — Regulated Financial Services, Singapore

A Singapore-based digital bank regulated under MAS Technology Risk Management (TRM) Guidelines is building a centralized security operations center (SOC) and full-stack observability platform across its Azure landing zone. The platform monitors 120 production servers, 25 PaaS services, and processes security telemetry from Azure Firewall, NSG Flow Logs, Entra ID, and endpoint detection. MAS TRM mandates 1-year online retention and 5-year archival for all security audit logs.

## Security Information & Event Management (SIEM)

- 1× Microsoft Sentinel, Pay-as-you-go, Sentinel-enabled Log Analytics workspace
  - Analytics Logs ingestion: 80 GB/day (SecurityEvent, Syslog, SigninLogs, AuditLogs, threat intelligence)
  - Basic Logs ingestion: 40 GB/day (Azure Firewall logs, NSG Flow Logs — high-volume, search-only)
  - Auxiliary Logs ingestion: 10 GB/day (custom security telemetry via Logs Ingestion API — honeypot data, OSINT feeds)
  - Analytics Logs retention: 365 days (MAS TRM 1-year online mandate)
  - Data Archive: 500 GB steady-state archived data (5-year MAS regulatory archival)
  - Search queries against Basic Logs: 100 GB/month (threat hunting, investigations)
  - Continuous data export to Azure Storage: 300 GB/month (compliance evidence)

## Application Performance Monitoring

- 1× Application Insights (workspace-based), 15 GB/month ingestion, 90-day retention — digital banking app tracing
- 1× Application Insights (workspace-based), 8 GB/month ingestion, 90-day retention — internal ops portal

## Network Security

- 1× Azure Firewall, Premium tier, 1,500 GB data processed per month
- 1× Azure DDoS Protection Plan — protecting 15 public IPs
- 2× Public IP addresses, Standard SKU, static

## Web Application Firewall

- 1× Azure Front Door, Standard tier, 2 routing rules
- 1× WAF Policy (Front Door), managed ruleset, 5 million requests/month

## Secrets & Certificate Management

- 1× Azure Key Vault, Premium tier (HSM-backed), 500,000 operations/month

## Private Endpoints & DNS

- 4× Private Endpoints (AMPLS, Key Vault, Storage blob, Storage table)
- 7× Private DNS Zones (~500,000 DNS queries/month total)

## Parameters

- Region: southeastasia
- Currency: USD
- Commitment: Pay-As-You-Go
- Hybrid Benefit: Not applied
- Zone Redundancy: Disabled
