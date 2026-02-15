# 3-Tier Web App — Azure Architecture

## Web Tier

- 2× Azure Virtual Machines, Standard_D2s_v5 (Linux)
- 1× P30 LRS Premium SSD Managed Disk per VM

## App Tier

- 2× Azure Virtual Machines, Standard_D4s_v5 (Linux)
- 1× P30 LRS Premium SSD Managed Disk per VM

## Data Tier

- 1× Azure SQL Managed Instance, General Purpose, Gen5, 8 vCore
- 256 GB storage

## Parameters

- Region: eastus
- Currency: USD
- Commitment: Pay-As-You-Go
- Hybrid Benefit: Not applied
- Zone Redundancy: Disabled
