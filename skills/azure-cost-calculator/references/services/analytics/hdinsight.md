---
serviceName: HDInsight
category: analytics
aliases: [Hadoop, Spark, HBase, Kafka, HDI]
primaryCost: "Per-node hourly rate × node count × 730; price includes VM compute + HDInsight surcharge"
privateEndpoint: true
---

# HDInsight

> **Trap (inflated totals)**: An unfiltered `ServiceName 'HDInsight'` query returns 130+ meters across 20 products spanning all VM series. The `totalMonthlyCost` sums every node size and is meaningless. Always filter by `ProductName` for the specific VM series.

> **Trap (multi-node clusters)**: Each cluster has multiple node roles — topology varies by type (e.g., Hadoop: Head ×2 + Worker ×N; Spark/Kafka/HBase: Head ×2 + Worker ×N + Zookeeper ×3). Estimate each role separately.

## Query Pattern

### General-purpose node — D4a v4 (per node, hourly)

ServiceName: HDInsight
ProductName: HDInsight D Series
SkuName: D4a v4/D4as v4
MeterName: D4a v4/D4as v4

### 4-node worker tier — D4a v4 (Quantity = worker node count)

ServiceName: HDInsight
ProductName: HDInsight D Series
SkuName: D4a v4/D4as v4
MeterName: D4a v4/D4as v4
Quantity: 4

### Memory-optimized node — E8a v4

ServiceName: HDInsight
ProductName: HDInsight Eav4/Easv4 Series
SkuName: E8a v4/E8as v4
MeterName: E8a v4/E8as v4

### Kafka managed disk — Standard S30

ServiceName: HDInsight
ProductName: HDInsight Storage
SkuName: S30
MeterName: S30 Disk

## Key Fields

| Parameter     | How to determine          | Example values                                       |
| ------------- | ------------------------- | ---------------------------------------------------- |
| `serviceName` | Always `HDInsight`        | `HDInsight`                                          |
| `productName` | VM series family          | `HDInsight D Series`, `HDInsight Eav4/Easv4 Series`  |
| `skuName`     | VM size within the series | `D4a v4/D4as v4`, `E8a v4/E8as v4`                  |
| `meterName`   | Usually matches `skuName` | `D4a v4/D4as v4`, `S30 Disk`                         |

## Meter Names

| Meter              | skuName            | productName                    | unitOfMeasure | Notes                    |
| ------------------ | ------------------ | ------------------------------ | ------------- | ------------------------ |
| `D4a v4/D4as v4`  | `D4a v4/D4as v4`  | `HDInsight D Series`           | `1 Hour`      | General-purpose          |
| `E8a v4/E8as v4`  | `E8a v4/E8as v4`  | `HDInsight Eav4/Easv4 Series`  | `1 Hour`      | Memory-optimized         |
| `F8s v2`           | `F8s v2`           | `HDInsight FSv2 Series`        | `1 Hour`      | Compute-optimized        |
| `L8as v3`          | `L8as v3`          | `HDInsight Lasv3 Series`       | `1 Hour`      | Storage-optimized (NVMe) |
| `NC6`              | `NC6`              | `HDInsight NC Series`          | `1 Hour`      | GPU (Tesla K80)          |
| `S30 Disk`         | `S30`              | `HDInsight Storage`            | `1/Month`     | Standard HDD managed disk |
| `P30 Disk`         | `P30`              | `HDInsight Storage`            | `1/Month`     | Premium SSD managed disk  |
| `A2 v2`            | `A2 v2`            | `HDInsight ID Broker`          | `1 Hour`      | Auto-added for ESP       |

## Cost Formula

```
Node Monthly    = node_retailPrice × 730 × nodeCount
Cluster Monthly = Σ(Node Monthly) for each role (Head ×2, Worker ×N, ZK ×3)
Managed Disks   = disk_retailPrice × diskCount              (Kafka/HBase Accelerated Writes)
ESP Surcharge   = esp_retailPrice × totalCores × 730        (ESP-enabled only)
Total Monthly   = Cluster Monthly + Managed Disks + ESP Surcharge + Azure Storage (varies by cluster type)
```

## Notes

- **All-in pricing**: Node prices include both VM compute and HDInsight management surcharge — do not add separate Virtual Machines charges
- **Cluster types**: Hadoop, Spark, HBase, Kafka, Interactive Query, Storm — node topology varies (Hadoop: Head + Worker only; others add Zookeeper ×3)
- **Managed disks**: Kafka and HBase Accelerated Writes require managed disks (S30 Standard or P30 Premium) under `HDInsight Storage`; all clusters use external Azure Storage (Blob/ADLS) for data
- **Add-on surcharges**: ESP and ML Services add per-core/hour surcharges (empty-region meters — query the API directly, not via scripts); ESP also auto-provisions an ID Broker node
- **No stop/pause**: Clusters must be deleted to stop billing — no deallocated state
- **Capacity**: Worker node count and VM size determine cluster throughput; minimum 1 worker for Hadoop/Spark, minimum 3 workers for Kafka
- **PE sub-resources** (never-assume): `gateway`, `headnode`
