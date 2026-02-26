---
serviceName: Container Instances
category: containers
aliases: [ACI, Serverless Containers]
primaryCost: "vCPU per-hour + memory per-GB-hour (Linux); add Windows software surcharge for Windows containers"
---

# Azure Container Instances

> **Trap (unfiltered query)**: An unfiltered query returns 16 meters across 6 SKUs (Standard, Standard Spot, Confidential, K80/P100/V100 GPU) — always filter with `ProductName: Container Instances`, `SkuName: Standard` for standard Linux pricing.
>
> **Trap (memory & per-second MonthlyCost)**: The script cannot calculate monthly cost for `Standard Memory Duration` (unit `1 GB Hour`) and `Standard Windows Software Duration` (unit `1 Second`) without quantity. Memory: `retailPrice × GiB × 730`. Windows: `retailPrice × vCPUs × 730 × 3600`.
>
> **Trap (Windows surcharge)**: The `Standard` SKU includes a `Standard Windows Software Duration` meter priced per-second. This only applies to Windows containers. Exclude it for Linux workloads.

## Query Pattern

### Standard Linux — vCPU and memory (most common)

ServiceName: Container Instances
ProductName: Container Instances
SkuName: Standard
MeterName: Standard vCPU Duration
Quantity: 4 # number of vCPUs

ServiceName: Container Instances
ProductName: Container Instances
SkuName: Standard
MeterName: Standard Memory Duration

### Windows surcharge — add to Linux cost above

ServiceName: Container Instances
ProductName: Container Instances
SkuName: Standard
MeterName: Standard Windows Software Duration

### Spot containers (up to 70% discount, may be evicted)

ServiceName: Container Instances
ProductName: Container Instances
SkuName: Standard Spot

### GPU containers — substitute {gpu}: K80, P100, V100

ServiceName: Container Instances
ProductName: Container Instances with GPU
SkuName: {gpu}

## Meter Names

| Meter                                         | skuName                       | unitOfMeasure    | Notes                  |
| --------------------------------------------- | ----------------------------- | ---------------- | ---------------------- |
| `Standard vCPU Duration`                      | `Standard`                    | `1 Hour`         | Per vCPU               |
| `Standard Memory Duration`                    | `Standard`                    | `1 GB Hour`      | Per GiB                |
| `Standard Windows Software Duration`          | `Standard`                    | `1 Second`       | Windows only surcharge |
| `Standard Spot vCPU Duration`                 | `Standard Spot`               | `1 Hour`         | Spot — evictable       |
| `Standard Spot Memory Duration`               | `Standard Spot`               | `1 GB Hour`      | Spot — evictable       |
| `Confidential containers ACI vCPU Duration`   | `Confidential containers ACI` | `1 Hour`         | Confidential computing |
| `Confidential containers ACI Memory Duration` | `Confidential containers ACI` | `1 GB Hour`      | Confidential computing |
| `K80 vGPU Duration`                           | `K80`                         | `100 Seconds`    | GPU meter              |
| `P100 vGPU Duration`                          | `P100`                        | `100 Seconds`    | GPU meter              |
| `V100 vGPU Duration`                          | `V100`                        | `100 Seconds`    | GPU meter              |
| `vCPU Duration`                               | `{gpu}`                       | `100 Seconds`    | GPU compute (per vCPU) |
| `Memory Duration`                             | `{gpu}`                       | `100 GB Seconds` | GPU memory (per GiB)   |

## Cost Formula

```
Linux Standard:
  Monthly = (vCPU_price × vCPUs × 730) + (memory_price × GiB × 730)

Windows Standard:
  Monthly = Linux cost + (windows_per_second × vCPUs × 730 × 3600)

GPU (all prices per 100 sec):
  Monthly = ((vGPU_price × gpuCount) + (vCPU_price × vCPUs) + (mem_price × GiB)) / 100 × 3600 × 730
```

## Notes

- No free tier — billing starts when the container group is running
- Stopped container groups incur no compute charges (only storage for mounted volumes)
- Spot containers offer up to ~70% discount but can be evicted at any time
- GPU containers require `productName eq 'Container Instances with GPU'` — separate from standard pricing
- For long-running workloads, consider Azure Container Apps (Dedicated plan) or AKS for better cost efficiency
