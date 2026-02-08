## Description

<!-- Brief description of the service reference being added or changed -->

## Pre-submission Checklist

- [ ] YAML front matter has `serviceName`, `category`, and `aliases`
- [ ] `serviceName` matches the exact case-sensitive API value
- [ ] `category` matches the folder this file is in
- [ ] First query pattern appears within lines 1-45
- [ ] All API filter values verified against live API using `skills/azure-cost-calculator/scripts/Explore-AzurePricing.ps1`
- [ ] Cost formula uses `retailPrice` from API (no hardcoded prices)
- [ ] Validation script passes locally: `.\skills\azure-cost-calculator\scripts\Validate-ServiceReference.ps1 -Path skills\azure-cost-calculator\references\services\{category}\{file} -CheckAliasUniqueness`
- [ ] File placed in correct `skills/azure-cost-calculator/references/services/{category}/` folder
