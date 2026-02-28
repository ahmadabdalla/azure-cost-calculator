---
serviceName: Azure Defender EASM
category: security
aliases: [External Attack Surface Management, EASM, Attack Surface]
apiServiceName: Microsoft Defender for Cloud
primaryCost: "Per-asset daily rate × assetCount × 30 days/month"
---

# Azure Defender EASM

> **Trap (shared serviceName)**: API `serviceName` is `Microsoft Defender for Cloud`, shared with 15+ Defender sub-products. Always filter by `ProductName` to isolate EASM meters — an unfiltered query mixes all Defender products and produces a meaningless total.

> **Trap (daily billing — MonthlyCost wrong)**: `unitOfMeasure` is `1` but billing is per-asset per-day. The script treats it as a flat per-unit charge — `MonthlyCost` shows the cost for ONE day, not one month. Always multiply by 30: `retailPrice × assetCount × 30`.

## Query Pattern

### Standard — per billable asset per day

ServiceName: Microsoft Defender for Cloud  <!-- cross-service -->
ProductName: Defender External Attack Surface Management
SkuName: Defender EASM Standard
MeterName: Defender EASM Standard Asset
Quantity: 500  # billable assets

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- |
| `Defender EASM Standard Asset` | `Defender EASM Standard` | `1` | Per billable asset per day |
| `Defender EASM 30 Day Trial Asset` | `Defender EASM 30 Day Trial` | `1` | Free trial (30 days) |

## Cost Formula

```
Monthly = retailPrice × assetCount × 30
```

## Notes

- **30-day free trial**: Automatically granted on first EASM resource creation. After 30 days, billing begins automatically at the Standard rate. Trial is not a permanent free tier.
- **Billable assets** (never-assume — ask user): Only assets in "Approved Inventory" state are billed. Types: approved host:IP combinations (deduplicated), approved domains, and approved active IP addresses.
- **Uniform pricing**: All 29 regions (28 standard + Global) have identical per-asset rates — no regional variance.
- **Asset count variability**: Billable counts fluctuate as assets are discovered, approved, or become inactive within a 30-day observation window. Estimates are approximate.
- See `defender-for-cloud.md` for other Defender sub-products (Servers, SQL, Containers, Storage, CSPM, etc.).
