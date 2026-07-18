---
serviceName: Windows Virtual Desktop
category: compute
aliases: [Azure Virtual Desktop, AVD, WVD]
billingNeeds: [Virtual Machines, Managed Disks]
billingConsiderations: [M365 / Windows per-user licensing]
primaryCost: "Per-user access fee per month (varies by SKU) + VM compute, storage, and networking billed separately"
privateEndpoint: true
---

# Windows Virtual Desktop

> **Trap**: The per-user access fees under this service apply only to users **without** eligible Microsoft 365 or Windows per-user licenses. M365 E3/E5/A3/A5/Business Premium or Windows E3/E5 users have no separate AVD access fee; their cost is entirely VM compute, storage, and networking (priced under Virtual Machines, Managed Disks, etc.). Always confirm license entitlements before including access fees.

> **Trap (HCI meter)**: Unfiltered queries return the `AVD for Azure Stack HCI` meter (hourly per-vCPU) alongside per-user monthly meters. If estimating cloud-hosted AVD, filter by `SkuName` to exclude the HCI meter.

> **Trap (duplicate meters)**: Each per-user SKU has two meter names with different meterIds but identical prices (e.g., `App Hosting User` and `App Hosting App Users`). Querying by `SkuName` alone without `MeterName` returns both, causing double-counted totals. Always specify `MeterName` or use only one result per SKU.

## Query Pattern

### Desktop & App Hosting: 50 users (full desktop + remote apps)

ServiceName: Windows Virtual Desktop
SkuName: Desktop & App Hosting
MeterName: Desktop & App Hosting User
InstanceCount: 50

### App Hosting only: 50 users (remote apps only)

ServiceName: Windows Virtual Desktop
SkuName: App Hosting
MeterName: App Hosting User
InstanceCount: 50

### AVD for Azure Stack HCI: per vCPU/hour

ServiceName: Windows Virtual Desktop
SkuName: AVD for Azure Stack HCI
InstanceCount: 8

## Key Fields

| Parameter     | How to determine                                       | Example values                                                                              |
| ------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------- |
| `serviceName` | Always `Windows Virtual Desktop`                       | `Windows Virtual Desktop`                                                                   |
| `productName` | Always `Azure Virtual Desktop`                         | `Azure Virtual Desktop`                                                                     |
| `skuName`     | Access tier: full desktop, app-only, upgrade, or HCI   | `Desktop & App Hosting`, `App Hosting`, `App to Desktop Upgrade`, `AVD for Azure Stack HCI` |
| `meterName`   | Varies by SKU, multiple meter name variants per region | See Meter Names table                                                                       |

## Meter Names

| Meter                                         | skuName                   | unitOfMeasure | Notes                            |
| --------------------------------------------- | ------------------------- | ------------- | -------------------------------- |
| `Desktop & App Hosting User`                  | `Desktop & App Hosting`   | `1/Month`     | Full desktop + remote app access |
| `Desktop & App Hosting Desktop and App Users` | `Desktop & App Hosting`   | `1/Month`     | Alternate meter name (same SKU)  |
| `App Hosting User`                            | `App Hosting`             | `1/Month`     | Remote app streaming only        |
| `App Hosting App Users`                       | `App Hosting`             | `1/Month`     | Alternate meter name (same SKU)  |
| `App to Desktop Upgrade User`                 | `App to Desktop Upgrade`  | `1/Month`     | Upgrade from app-only to desktop |
| `App to Desktop Upgrade Upgrade Users`        | `App to Desktop Upgrade`  | `1/Month`     | Alternate meter name (same SKU)  |
| `AVD for Azure Stack HCI Service Fee/vCPU`    | `AVD for Azure Stack HCI` | `1/Hour`      | On-premises HCI per-vCPU fee     |

## Cost Formula

```
Per-user access:  Monthly = retailPrice × userCount
HCI vCPU:         Monthly = retailPrice × 730 × vCPUCount
```

## Notes

- Multi-session Windows 11/10 Enterprise is unique to AVD and allows multiple users per VM, reducing per-user compute cost
- Windows 10/11 Enterprise session hosts use Linux VM compute rates (Windows license included via AVD access fee or M365 entitlement); Windows Server session hosts use Windows VM rates
- Estimate 4–6 knowledge-worker users per D4s_v5 session host; actual density depends on application load and GPU requirements
- Session host VMs, OS disks, and networking are priced under their respective services — see `compute/virtual-machines.md` and `storage/managed-disks.md`
- FSLogix profile containers (required for multi-session) add per-user storage cost — see `storage/storage.md` (Azure Files) or `storage/netapp-files.md` (Azure NetApp Files) depending on profile backend
- Outbound data transfer from session hosts to remote users incurs egress charges — see `networking/bandwidth.md`
- OS disk storage profile (Standard SSD vs Premium SSD) for session hosts affects per-user steady-state cost; Premium reduces login storms but costs more per GiB
- The `App to Desktop Upgrade` SKU is an incremental fee to promote app-only users to full desktop access without re-provisioning
