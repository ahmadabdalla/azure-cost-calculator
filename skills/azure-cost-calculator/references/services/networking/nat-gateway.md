---
serviceName: NAT Gateway
category: networking
aliases: [Azure NAT, SNAT, Outbound Connectivity]
billingNeeds: [IP Addresses]
primaryCost: "Hourly gateway charge × 730 + data processed per-GB"
pricingRegion: global
---

# NAT Gateway

> **Trap**: Unfiltered queries return gateway (hourly), data processing (per-GB), and StandardV2 logging (monthly) meters summed — `totalMonthlyCost` is meaningless. Query each meter separately using `MeterName`.

> **Trap (always-on)**: NAT Gateway bills per-hour from resource creation, not per-use. Even with zero outbound traffic, the gateway meter charges continuously (730 hours/month).

## Query Pattern

### Gateway hourly cost (always-on)

ServiceName: NAT Gateway
SkuName: Standard
MeterName: Standard Gateway
Region: Global

### Data processed (Quantity = estimated monthly GB through the gateway)

ServiceName: NAT Gateway
SkuName: Standard
MeterName: Standard Data Processed
Region: Global
Quantity: 500

### Multiple gateways (InstanceCount = number of NAT Gateway resources)

ServiceName: NAT Gateway
SkuName: Standard
MeterName: Standard Gateway
Region: Global
InstanceCount: 3

## Key Fields

| Parameter     | How to determine                          | Example values           |
| ------------- | ----------------------------------------- | ------------------------ |
| `serviceName` | Always `NAT Gateway`                      | `NAT Gateway`            |
| `productName` | Single product for all meters             | `NAT Gateway`            |
| `skuName`     | Standard for both Standard and StandardV2 | `Standard`, `StandardV2` |
| `meterName`   | Substitute from Meter Names table         | `Standard Gateway`       |

## Meter Names

| Meter                     | skuName      | unitOfMeasure | Notes                                    |
| ------------------------- | ------------ | ------------- | ---------------------------------------- |
| `Standard Gateway`        | `Standard`   | `1 Hour`      | Per-gateway hourly charge (always-on)    |
| `Standard Data Processed` | `Standard`   | `1 GB`        | Per-GB outbound + return traffic         |
| `StandardV2 Log Enabled`  | `StandardV2` | `1/Month`     | Optional flow logs fee (prorated hourly) |

## Cost Formula

```
Gateway monthly  = gateway_retailPrice × 730 × gatewayCount
Data monthly     = data_retailPrice × processedGB
Total monthly    = Gateway + Data
```

## Notes

- **Always-on cost**: Gateway hourly charge runs continuously from deployment — minimum monthly cost is gateway_retailPrice × 730 per gateway, even with zero traffic
- **Data processing scope**: Charges apply to both outbound and return traffic through the gateway
- **StandardV2**: Same pricing as Standard for gateway and data meters — only difference is an optional flow logs meter. StandardV2 adds zone redundancy, IPv6 support, and 100 Gbps throughput (vs 50 Gbps for Standard)
- **Public IPs billed separately**: NAT Gateway requires Standard SKU Public IP addresses (up to 16) — billed separately under Virtual Network
- **Bandwidth egress**: Standard Azure bandwidth charges for internet-bound traffic apply separately from the NAT Gateway data processing fee
- **Multi-gateway scaling**: Each NAT Gateway resource is billed independently — multiply total cost by gateway count
