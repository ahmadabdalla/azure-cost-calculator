---
serviceName: Virtual Network
category: networking
aliases: [private link, private endpoint, PL]
---

# Private Link / Private Endpoints

**Primary cost**: Per-endpoint hourly fee + per-GB data processed (ingress/egress)

> **Note**: **Global-region / USD-only** — see shared.md & Common Traps for mandatory currency conversion.

## Query Pattern

### Substitute {meterName} from Meter Names table

ServiceName: Virtual Network
ProductName: Virtual Network Private Link
MeterName: {meterName}
Region: Global

Meter names: `Standard Private Endpoint` (hourly), `Standard Data Processed - Ingress` (per-GB), `Standard Data Processed - Egress` (per-GB)

## Key Fields

| Parameter       | Value                                                                                                                 |
| --------------- | --------------------------------------------------------------------------------------------------------------------- |
| `serviceName`   | `Virtual Network`                                                                                                     |
| `productName`   | `Virtual Network Private Link`                                                                                        |
| `armRegionName` | `Global` (not a real ARM region — omit region filter or use `'Global'` explicitly; empty string returns zero results) |

## Meter Names

| Meter                               | unitOfMeasure | Notes                  |
| ----------------------------------- | ------------- | ---------------------- |
| `Standard Private Endpoint`         | `1 Hour`      | Per endpoint, per hour |
| `Standard Data Processed - Ingress` | `1 GB`        | Inbound data (tiered)  |
| `Standard Data Processed - Egress`  | `1 GB`        | Outbound data (tiered) |

## Cost Formula

```
Monthly = endpointPrice × 730 × endpointCount + dataIngressPrice × ingressGB + dataEgressPrice × egressGB
```

## Example (3 endpoints, 100 GB total data)

Query each meter via the script, then calculate:

```
Endpoints: endpointPrice × 730 × 3
Data: dataIngressPrice × ingressGB + dataEgressPrice × egressGB
Total: Endpoints + Data (USD)
```

## Notes

- USD-only (Global region) — see shared.md & Common Traps for mandatory currency conversion
- Private endpoints are per-resource (e.g., one for SQL, one for Storage, one for Key Vault)
- Data processing charges are typically negligible compared to endpoint hours for moderate usage
- Each private endpoint consumes an IP address from the VNet subnet
