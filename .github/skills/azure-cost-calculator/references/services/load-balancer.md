# Virtual Network / Load Balancer

## Virtual Network

VNets themselves are free. Costs come from:

- **Peering**: per-GB data transfer (intra-region ~$0.01/GB, inter-region ~$0.035/GB)
- **Public IPs**: per-hour for static IPs
- **NAT Gateway**: per-hour + per-GB processed

## Load Balancer

> **Trap (verified 2026-02-06)**: The Retail Prices API returns **no data for any standard public Azure region** (e.g., `eastus`, `australiaeast`, `westeurope`). Data only exists for edge/operator regions (`attdetroit1`, `sgxsingapore1`, etc.), `Global`, and `US Gov`. Both `Get-AzurePricing.ps1` and `Explore-AzurePricing.ps1` will return zero results for any public region. This is an API data gap, not a filter issue.
>
> **Agent instruction**: Do NOT attempt to query this service via the scripts — it will always fail. Use the manual fallback below and note the limitation to the user.

### Query Pattern

```powershell
.\Get-AzurePricing.ps1 `
    -ServiceName 'Load Balancer' `
    -SkuName 'Standard'
```

### Manual Fallback (API unavailable for public regions)

The API has no data for any standard Azure public region. Use the known rates below (USD, verified 2026-02-06):

| Component       | Rate (USD) | Unit              | Notes                                      |
| --------------- | ---------- | ----------------- | ------------------------------------------ |
| Base fixed cost | ~$0.025    | per hour          | First 5 LB rules + outbound rules included |
| Overage rules   | ~$0.01     | per hour per rule | Each rule beyond the first 5               |
| Data processed  | ~$0.005    | per GB            | Inbound + outbound                         |

> Source: [Azure Load Balancer pricing](https://azure.microsoft.com/pricing/details/load-balancer/). These are approximate USD values — direct users to the pricing page for current rates. For non-USD currencies, use the currency derivation method in [shared.md](../shared.md).

### Manual Cost Formula

```
Base      = $0.025 × 730                          = ~$18.25/month
Overage   = max(0, totalRules - 5) × $0.01 × 730 = per extra rule
Data      = processedGB × $0.005
Monthly   = Base + Overage + Data
```

### Example (8 rules, 200 GB)

```
Base:    $0.025 × 730         = $18.25
Overage: 3 × $0.01 × 730     = $21.90
Data:    200 × $0.005         = $1.00
Total:   ~$41.15 USD/month
```

### Meter Names

| Meter                                           | unitOfMeasure | Notes                            |
| ----------------------------------------------- | ------------- | -------------------------------- |
| `Standard Data Processed`                       | 1 GB          | Per-GB processed                 |
| `Standard Included LB Rules and Outbound Rules` | 1 Hour        | First 5 rules included           |
| `Standard Overage LB Rules and Outbound Rules`  | 1/Hour        | Per additional rule beyond 5     |
| `Standard Data Processed - Free`                | 1 GB          | Free tier (Basic SKU equivalent) |
