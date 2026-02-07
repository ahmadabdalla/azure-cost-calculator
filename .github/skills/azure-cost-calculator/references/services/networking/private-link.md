````markdown
# Private Link / Private Endpoints

- **serviceName**: `Virtual Network`
- **category**: networking
- **aliases**: [private link, private endpoint, PL]

**Multiple meters**: Endpoint hours (per-endpoint) + data processed (ingress/egress per-GB)

> **Critical trap**: Private Link pricing is **NOT available under any standard region** (e.g., `eastus`, `australiaeast`). The data is listed under `armRegionName = 'Global'` or an empty string. The `Get-AzurePricing.ps1` script requires a `-Region` parameter and will silently return no results. **You must call the API directly** to get these prices.
> **Trap**: Prices returned from the Global region are in **USD only**, regardless of any currency parameter. Always note this caveat to the user.
>
> **Agent instruction**: Do NOT use `Get-AzurePricing.ps1` or `Explore-AzurePricing.ps1` — they will silently return nothing. Copy the direct API query below into PowerShell. Prices are always USD regardless of currency parameter.

## Query Pattern

```powershell
# Private Endpoint hourly cost
$uri = "https://prices.azure.com/api/retail/prices?`$filter=serviceName eq 'Virtual Network' and productName eq 'Virtual Network Private Link' and meterName eq 'Standard Private Endpoint'"
(Invoke-RestMethod -Uri $uri).Items | Select-Object meterName, unitPrice, unitOfMeasure, currencyCode, armRegionName

# Data Processed — Ingress
$uri = "https://prices.azure.com/api/retail/prices?`$filter=serviceName eq 'Virtual Network' and productName eq 'Virtual Network Private Link' and meterName eq 'Standard Data Processed - Ingress'"
(Invoke-RestMethod -Uri $uri).Items | Select-Object meterName, unitPrice, unitOfMeasure, currencyCode, armRegionName

# Data Processed — Egress
$uri = "https://prices.azure.com/api/retail/prices?`$filter=serviceName eq 'Virtual Network' and productName eq 'Virtual Network Private Link' and meterName eq 'Standard Data Processed - Egress'"
(Invoke-RestMethod -Uri $uri).Items | Select-Object meterName, unitPrice, unitOfMeasure, currencyCode, armRegionName
```

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

- Prices returned from the Global region are in **USD** regardless of the `currencyCode` parameter
- Private endpoints are per-resource (e.g., one for SQL, one for Storage, one for Key Vault)
- Data processing charges are typically negligible compared to endpoint hours for moderate usage
- Each private endpoint consumes an IP address from the VNet subnet
````
