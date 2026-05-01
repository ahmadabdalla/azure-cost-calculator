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

> **Trap (Tiered data processing)**: Data processing meters return multiple rows with `tierMinimumUnits` (0, 1 000 000 GB, 5 000 000 GB). Use the tier matching the workload volume. Do not sum all tiers. Most workloads stay in the first tier.

> **Trap (Service endpoint meter)**: A `Service endpoint Standard Virtual Network` meter (skuName `Service endpoint Standard`) exists at a higher hourly rate than Private Endpoints. Always include `SkuName: Standard` or a specific `MeterName` to avoid mixing PE and Service endpoint meters in query results.

## Query Pattern

### Endpoint hourly cost

ServiceName: Virtual Network <!-- cross-service -->
ProductName: Virtual Network Private Link
SkuName: Standard
MeterName: Standard Private Endpoint
Region: Global

### Multi-endpoint deployment (InstanceCount = number of private endpoints)

ServiceName: Virtual Network <!-- cross-service -->
ProductName: Virtual Network Private Link
SkuName: Standard
MeterName: Standard Private Endpoint
Region: Global
InstanceCount: 5

### Data processed: substitute {direction} with Ingress or Egress

ServiceName: Virtual Network <!-- cross-service -->
ProductName: Virtual Network Private Link
SkuName: Standard
MeterName: Standard Data Processed - {direction}
Region: Global

### Private Link Service (provider-side hourly cost)

ServiceName: Virtual Network <!-- cross-service -->
ProductName: Virtual Network Private Link
SkuName: Service endpoint Standard
MeterName: Service endpoint Standard Virtual Network
Region: Global

## Key Fields

| Parameter       | How to determine                                                             | Example values                              |
| --------------- | ---------------------------------------------------------------------------- | ------------------------------------------- |
| `serviceName`   | Always `Virtual Network`                                                     | `Virtual Network`                           |
| `productName`   | Single product for all PE meters                                             | `Virtual Network Private Link`              |
| `skuName`       | `Standard` for PE meters; `Service endpoint Standard` for PL Service meters  | `Standard`, `Service endpoint Standard`     |
| `meterName`     | Substitute from Meter Names table                                            | `Standard Private Endpoint`                 |
| `armRegionName` | `Global` for public cloud; US Gov and edge zones have region-specific meters | `Global`, `US Gov`                          |

## Meter Names

| Meter                                          | unitOfMeasure | Notes                                    |
| ---------------------------------------------- | ------------- | ---------------------------------------- |
| `Standard Private Endpoint`                    | `1 Hour`      | Per endpoint, per hour                   |
| `Standard Data Processed - Ingress`            | `1 GB`        | Inbound data (3 volume tiers via API)    |
| `Standard Data Processed - Egress`             | `1 GB`        | Outbound data (3 volume tiers via API)   |
| `Service endpoint Standard Virtual Network`    | `1 Hour`      | Private Link Service (provider-side fee) |

## Cost Formula

```
Monthly = endpoint_retailPrice × 730 × endpointCount
        + ingress_retailPrice × ingressGB
        + egress_retailPrice × egressGB
        + plService_retailPrice × 730 × plServiceCount  (if exposing a PL Service)
```

## Notes

- **Companion cost**: PEs typically require a Private DNS Zone per service type. See `networking/private-dns.md` for zone hosting and query costs. Multiple PEs of the same type share one zone
- **Service availability**: Do not maintain an internal PE support list. Refer to [Azure Private Link availability](https://learn.microsoft.com/en-us/azure/private-link/availability)
- **AMPLS**: Azure Monitor Private Link Scope is a free grouping resource with no unique meters. Uses standard PE billing. 1 PE per AMPLS-to-VNet connection. Requires 5 Private DNS zones (monitor, oms, ods, agentsvc, blob)
- **Multi-PE services**: Some services support multiple PE sub-resources (e.g., blob, file, queue for Storage). The service's own reference file should document which sub-resources are available. This file only prices the generic private endpoint.
- **Service-specific PE meters**: Some services (e.g., Notification Hubs) have their own Private Link meters under their `serviceName`. Those are documented in the service file, not here. This file covers generic PEs billed under `serviceName: Virtual Network`
- **Private Link Service**: Provider-side PL Service resources now have an hourly meter (`Service endpoint Standard Virtual Network`). Add this when the user is exposing a service via Private Link, not just consuming one
- Each PE consumes an IP address from the VNet subnet
- Data processing is typically negligible compared to endpoint hours for moderate usage
- **US Gov / edge zones**: PE meters also exist under `US Gov` (flat-rate, no volume tiers) and edge zone regions (e.g., `attatlanta1`, `sgxsingapore1`) at different rates. Omit `Region: Global` and use the target region when estimating for sovereign or edge deployments
