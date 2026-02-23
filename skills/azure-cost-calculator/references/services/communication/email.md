---
serviceName: Email
category: communication
aliases: [ACS Email, Email Communication]
primaryCost: "Per-email sent + per-MB data transferred"
hasKnownRates: true
---

# Azure Communication Services — Email

> **Trap (sub-cent pricing)**: Email meters are priced at sub-cent levels — the script may display zero cost. Use `Quantity` with expected monthly volume for accurate estimates.

## Query Pattern

### Sent email (per-message, Quantity = monthly emails)

ServiceName: Email
ProductName: Email
SkuName: Basic
MeterName: Basic Sent Email
Quantity: 50000

### Data transferred (per-MB, Quantity = monthly MB of attachments)

ServiceName: Email
ProductName: Email
SkuName: Basic
MeterName: Basic Data Transferred
Quantity: 1000

## Key Fields

| Parameter     | How to determine        | Example values            |
| ------------- | ----------------------- | ------------------------- |
| `serviceName` | Always `Email`          | `Email`                   |
| `productName` | Always `Email`          | `Email`                   |
| `skuName`     | Always `Basic`          | `Basic`                   |
| `meterName`   | Billing dimension       | `Basic Sent Email`, `Basic Data Transferred` |

## Meter Names

| Meter                    | unitOfMeasure | Notes                    |
| ------------------------ | ------------- | ------------------------ |
| `Basic Sent Email`       | `1`           | Per email sent           |
| `Basic Data Transferred` | `1 MB`        | Email attachment data    |

## Cost Formula

```
Monthly = email_retailPrice × emails + dataTransfer_retailPrice × dataMB
```

## Notes

- **Part of ACS family**: Related services use separate API serviceNames — `Voice`, `SMS`, `Messaging`, `Phone Numbers`, `Network Traversal`, `Routing`
- Only 2 meters — simple per-email + per-MB model
- Single product and SKU: all queries use `productName: Email`, `skuName: Basic`

## Known Rates

| Meter                    | Unit      | Published Rate (USD) |
| ------------------------ | --------- | -------------------- |
| `Basic Sent Email`       | Per email | $0.00025             |
| `Basic Data Transferred` | Per MB    | $0.00012             |
