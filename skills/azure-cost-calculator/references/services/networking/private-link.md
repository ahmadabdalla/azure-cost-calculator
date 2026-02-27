---
serviceName: Azure Private Link
category: networking
aliases: [Private Endpoint, PE]
apiServiceName: Virtual Network
primaryCost: "Per-endpoint hourly rate × 730 × endpointCount + data processed per-GB (tiered)"
pricingRegion: global
---

# Azure Private Link

> **Warning**: Use `Region: Global` explicitly; empty string returns zero results.

> **Trap (Cross-region)**: When the PE and the target PaaS service are in different regions, both PE data processing charges AND standard Azure bandwidth egress charges apply. Deploy PEs in the same region as the target service to avoid double charges.

> **Trap (Tiered data processing)**: Data processing meters return multiple rows with `tierMinimumUnits` (0, 1 000 000 GB, 5 000 000 GB). Use the tier matching the workload volume — do not sum all tiers. Most workloads stay in the first tier.

## Query Pattern

### Endpoint hourly cost

ServiceName: Virtual Network <!-- cross-service -->
ProductName: Virtual Network Private Link
MeterName: Standard Private Endpoint
Region: Global

### Multi-endpoint deployment (InstanceCount = number of private endpoints)

ServiceName: Virtual Network <!-- cross-service -->
ProductName: Virtual Network Private Link
MeterName: Standard Private Endpoint
Region: Global
InstanceCount: 5

### Data processed — substitute {direction} with Ingress or Egress

ServiceName: Virtual Network <!-- cross-service -->
ProductName: Virtual Network Private Link
MeterName: Standard Data Processed - {direction}
Region: Global

## Key Fields

| Parameter       | How to determine                                                             | Example values                 |
| --------------- | ---------------------------------------------------------------------------- | ------------------------------ |
| `serviceName`   | Always `Virtual Network`                                                     | `Virtual Network`              |
| `productName`   | Single product for all PE meters                                             | `Virtual Network Private Link` |
| `meterName`     | Substitute from Meter Names table                                            | `Standard Private Endpoint`    |
| `armRegionName` | `Global` for public cloud; US Gov and edge zones have region-specific meters | `Global`, `US Gov`             |

## Meter Names

| Meter                               | unitOfMeasure | Notes                                  |
| ----------------------------------- | ------------- | -------------------------------------- |
| `Standard Private Endpoint`         | `1 Hour`      | Per endpoint, per hour                 |
| `Standard Data Processed - Ingress` | `1 GB`        | Inbound data (3 volume tiers via API)  |
| `Standard Data Processed - Egress`  | `1 GB`        | Outbound data (3 volume tiers via API) |

## Cost Formula

```
Monthly = endpoint_retailPrice × 730 × endpointCount
        + ingress_retailPrice × ingressGB
        + egress_retailPrice × egressGB
```

## Notes

- **Companion cost**: PEs typically require a Private DNS Zone per service type — see `networking/private-dns.md` for zone hosting and query costs. Multiple PEs of the same type share one zone
- **Service availability**: Do not maintain an internal PE support list — refer to [Azure Private Link availability](https://learn.microsoft.com/en-us/azure/private-link/availability)
- **AMPLS**: Azure Monitor Private Link Scope is a free grouping resource with no unique meters — uses standard PE billing. 1 PE per AMPLS-to-VNet connection. Requires 5 Private DNS zones (monitor, oms, ods, agentsvc, blob)
- **Multi-PE services**: Some services support multiple PE sub-resources (e.g., blob, file, queue for Storage). The service's own reference file should document which sub-resources are available — this file only prices the generic private endpoint.
- **Service-specific PE meters**: Some services (e.g., Notification Hubs) have their own Private Link meters under their `serviceName` — those are documented in the service file, not here. This file covers generic PEs billed under `serviceName: Virtual Network`
- Each PE consumes an IP address from the VNet subnet
- Data processing is typically negligible compared to endpoint hours for moderate usage
- **US Gov / edge zones**: PE meters also exist under `US Gov` and edge zone regions (e.g., `attatlanta1`, `sgxsingapore1`) at different rates — omit `Region: Global` and use the target region when estimating for sovereign or edge deployments
