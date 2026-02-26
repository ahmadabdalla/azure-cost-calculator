---
serviceName: Network Watcher
category: networking
aliases: [NSG Flow Logs, Connection Monitor]
billingNeeds: [Storage, Log Analytics]
primaryCost: "Per-GB flow log collection + per-GB traffic analytics + per-test connection monitor + per-check diagnostics"
hasFreeGrant: true
---

# Network Watcher

> **Trap (multi-meter)**: Unfiltered queries return 8 distinct billing meters across 19 tiered rows — `totalMonthlyCost` is meaningless. Query each meter separately using `MeterName`.

> **Trap (sub-cent diagnostics)**: `Standard Diagnostic Tool API` costs sub-cent per check after 1,000 free checks/month. The script may display near-zero — use `retailPrice` directly.

## Query Pattern

### NSG Flow Logs (Quantity = estimated monthly GB of log data)

ServiceName: Network Watcher
MeterName: Standard Network Logs Collected
Quantity: 50

### Traffic Analytics — 60-minute processing interval

ServiceName: Network Watcher
MeterName: Standard Traffic Analytics Processing
Quantity: 50

### Connection Monitor tests (Quantity = number of tests/month)

ServiceName: Network Watcher
MeterName: Standard Connection Monitor Test
Quantity: 100

### Diagnostic tools — IP Flow Verify, Next Hop, Packet Capture

ServiceName: Network Watcher
MeterName: Standard Diagnostic Tool API
Quantity: 5000

## Key Fields

| Parameter     | How to determine              | Example values                    |
| ------------- | ----------------------------- | --------------------------------- |
| `serviceName` | Always `Network Watcher`      | `Network Watcher`                 |
| `productName` | Single product for all meters | `Network Watcher`                 |
| `skuName`     | Always `Standard`             | `Standard`                        |
| `meterName`   | Feature-specific — see table  | `Standard Network Logs Collected` |

## Meter Names

| Meter                                                        | unitOfMeasure | Notes                                            |
| ------------------------------------------------------------ | ------------- | ------------------------------------------------ |
| `Standard Network Logs Collected`                            | `1 GB`        | NSG flow logs — 5 GB/month free                  |
| `Standard VNet Flow Logs Collected`                          | `1 GB`        | VNet flow logs — 5 GB/month free                 |
| `Standard Traffic Analytics Processing`                      | `1 GB`        | 60-min processing interval                       |
| `Standard Traffic Analytics Processing at 10-Minute Interval` | `1 GB`        | 10-min interval (premium rate)                   |
| `Standard Connection Monitor Test`                           | `1`           | Per test — 10 tests/month free; 5 price tiers    |
| `Standard Connection Monitoring`                             | `1`           | Legacy NPM — per connection/month, flat rate     |
| `Standard Diagnostic Tool API`                               | `1`           | Per check — 1,000 checks/month free; sub-cent    |
| `Standard Perf Monitor Connection Metric`                    | `1`           | Legacy NPM — 10 metrics/month free; 5 price tiers |

## Cost Formula

```
NSGFlowLogs      = max(0, nsgLogGB - 5) × flowlog_retailPrice
VNetFlowLogs     = max(0, vnetLogGB - 5) × flowlog_retailPrice
TrafficAnalytics = processedGB × analytics_retailPrice
ConnMonitor      = tiered pricing on test count (10 free, then progressive tiers)
Diagnostics      = max(0, checks - 1000) × diag_retailPrice
NPMConnMon       = connections × npm_retailPrice                          # legacy NPM only
NPMPerfMon       = tiered pricing on metric count (10 free, then tiers)   # legacy NPM only
Monthly          = NSGFlowLogs + VNetFlowLogs + TrafficAnalytics + ConnMonitor + Diagnostics [+ NPM]
```

## Notes

- **Free grants**: NSG/VNet flow logs: 5 GB/month each; Diagnostic tools: 1,000 checks/month; Connection Monitor: 10 tests/month; NPM Perf Monitor: 10 metrics/month
- **Auto-enabled**: Network Watcher is automatically enabled per-region when a virtual network is created — billing begins when features (flow logs, connection monitors) are configured
- **Storage billed separately**: Flow log data is stored in Azure Storage accounts — storage charges are not included in Network Watcher meters
- **Log Analytics billed separately**: Traffic Analytics and Network Analytics results are stored in Log Analytics — data ingestion charges apply separately
- **Packet Capture**: Counts as a diagnostic check under `Standard Diagnostic Tool API`; captured data stored in Storage at additional cost
- **Two flow log types**: NSG flow logs (older, retiring Sep 2027) and VNet flow logs (newer) have identical pricing — migrate to VNet flow logs for new deployments
- **Traffic Analytics intervals**: 10-minute processing costs more per-GB than 60-minute — choose interval based on latency requirements
