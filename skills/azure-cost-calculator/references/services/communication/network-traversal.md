---
serviceName: Network Traversal
category: communication
aliases: [ACS TURN, TURN Relay]
primaryCost: "Per-GB media relayed through TURN servers"
---

# Azure Communication Services — Network Traversal

> **Trap (productName encoding)**: The API returns the productName with a broken Unicode character (`TURN \ufffd Regional`). Omit `ProductName` from queries — `ServiceName` alone is sufficient for this single-meter service.

## Query Pattern

### TURN relay — media relayed (Quantity = monthly GB)

ServiceName: Network Traversal
SkuName: Standard
MeterName: Standard Media Relayed
Quantity: 100

## Key Fields

| Parameter     | How to determine                  | Example values         |
| ------------- | --------------------------------- | ---------------------- |
| `serviceName` | Always `Network Traversal`        | `Network Traversal`    |
| `productName` | Single product (encoding issue)   | `TURN * Regional`      |
| `skuName`     | Always `Standard`                 | `Standard`             |
| `meterName`   | Always `Standard Media Relayed`   | `Standard Media Relayed` |

## Meter Names

| Meter                    | unitOfMeasure | Notes                  |
| ------------------------ | ------------- | ---------------------- |
| `Standard Media Relayed` | `1 GB`        | Per-GB TURN relay data |

## Cost Formula

```
Monthly = retailPrice × dataGB
```

## Notes

- **Part of ACS family**: Related services use separate API serviceNames — `Voice`, `SMS`, `Email`, `Messaging`, `Phone Numbers`, `Routing`
- Single meter service — only `Standard Media Relayed` per-GB
- Regional pricing varies (e.g., lower in US/EU, higher in Asia-Pacific/Brazil)
