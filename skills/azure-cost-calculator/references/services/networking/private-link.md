---
serviceName: Virtual Network
category: networking
aliases: [private link, private endpoint, PL]
---

````markdown
# Private Link / Private Endpoints

**Multiple meters**: Endpoint hours (per-endpoint) + data processed (ingress/egress per-GB)

> ⚠ **Global-only pricing / USD-only** — see shared.md § Common Traps. Scripts require a Region filter and return nothing; call the API directly using query below.

## Query Pattern

# Private Endpoint hourly cost

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Virtual Network' and productName eq 'Virtual Network Private Link' and meterName eq 'Standard Private Endpoint'
Fields: meterName, unitPrice, unitOfMeasure, currencyCode, armRegionName

# Data Processed — Ingress

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Virtual Network' and productName eq 'Virtual Network Private Link' and meterName eq 'Standard Data Processed - Ingress'
Fields: meterName, unitPrice, unitOfMeasure, currencyCode, armRegionName

# Data Processed — Egress

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Virtual Network' and productName eq 'Virtual Network Private Link' and meterName eq 'Standard Data Processed - Egress'
Fields: meterName, unitPrice, unitOfMeasure, currencyCode, armRegionName

## Key Fields

| Parameter       | Value                          |
| --------------- | ------------------------------ |
| `serviceName`   | `Virtual Network`              |
| `productName`   | `Virtual Network Private Link` |
| `armRegionName` | `''` (empty) or `'Global'`     |

## Meter Names

| Meter                               | Unit Price (USD) | unitOfMeasure | Notes                  |
| ----------------------------------- | ---------------- | ------------- | ---------------------- |
| `Standard Private Endpoint`         | $0.01/hr         | `1/Hour`      | Per endpoint, per hour |
| `Standard Data Processed - Ingress` | $0.01/GB         | `1 GB`        | Inbound data           |
| `Standard Data Processed - Egress`  | $0.01/GB         | `1 GB`        | Outbound data          |

## Cost Formula

```
Monthly = endpointPrice × 730 × endpointCount + dataIngressPrice × ingressGB + dataEgressPrice × egressGB
```

## Example (3 endpoints, 100 GB total data)

```
Endpoints: $0.01/hr × 730 × 3 = ~$21.90/month
Data: $0.01/GB × 100 = ~$1.00/month
Total: ~$22.90/month (USD)
```

## Notes

- USD-only (Global region) — see shared.md § Common Traps for mandatory currency conversion
- Private endpoints are per-resource (e.g., one for SQL, one for Storage, one for Key Vault)
- Data processing charges are typically negligible compared to endpoint hours for moderate usage
- Each private endpoint consumes an IP address from the VNet subnet
````
