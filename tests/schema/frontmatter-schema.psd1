@{
    # ── Schema metadata ───────────────────────────────────────────────────
    SchemaVersion      = '1.0.0'

    # ── Field definitions ─────────────────────────────────────────────────
    # Each field specifies Type, Required, and optionally Default,
    # AllowedValues, MinItems, and MaxLength.  The validation pipeline
    # imports this file as the single source of truth for front matter
    # checks — keep it in sync with docs/TEMPLATE.md and CONTRIBUTING.md.

    Fields             = @{

        # ── Identity (existing) ──────────────────────────────────────────
        serviceName           = @{
            Type        = 'string'
            Required    = $true
            Description = 'Exact case-sensitive serviceName from the Azure Retail Prices API'
        }
        category              = @{
            Type          = 'string'
            Required      = $true
            AllowedValues = @(
                'compute'; 'containers'; 'databases'; 'networking'; 'storage'
                'security'; 'monitoring'; 'management'; 'integration'; 'analytics'
                'ai-ml'; 'iot'; 'developer-tools'; 'identity'; 'migration'
                'web'; 'communication'; 'specialist'
            )
            Description   = 'Category folder name — must match a folder under references/services/'
        }
        aliases               = @{
            Type        = 'array'
            Required    = $true
            MinItems    = 1
            Description = 'Search index — common names, abbreviations, and synonyms'
        }

        # ── Billing Graph (existing) ─────────────────────────────────────
        billingNeeds          = @{
            Type        = 'array'
            Required    = $false
            Description = 'Services billed under a different serviceName when deploying this service'
        }
        billingConsiderations = @{
            Type          = 'array'
            Required      = $false
            AllowedValues = @(
                'Reserved Instances'
                'Spot Pricing'
                'Azure Hybrid Benefit'
                'M365 / Windows per-user licensing'
            )
            Description   = 'Pricing factors the agent should ask the user about before calculating'
        }

        # ── API Identity (new) ───────────────────────────────────────────
        apiServiceName        = @{
            Type        = 'string'
            Required    = $false
            Description = 'API serviceName when it differs from display serviceName (e.g., VMware Solution uses Specialized Compute)'
        }

        # ── Pricing Profile (new) ────────────────────────────────────────
        primaryCost           = @{
            Type        = 'string'
            Required    = $true
            MaxLength   = 120
            Description = 'One-line billing summary — replaces bold **Primary cost** line in body'
        }
        hasMeters             = @{
            Type        = 'boolean'
            Required    = $false
            Default     = $true
            Description = 'Whether the service has meters in the Retail Prices API'
        }
        pricingRegion         = @{
            Type          = 'string'
            Required      = $false
            Default       = 'regional'
            AllowedValues = @('regional'; 'global'; 'empty-region'; 'api-unavailable')
            Description   = 'How region affects API queries for this service'
        }
        hasKnownRates         = @{
            Type        = 'boolean'
            Required    = $false
            Default     = $false
            Description = 'Whether the file contains a Known Rates table with manual pricing'
        }

        # ── Service Capabilities (new) ───────────────────────────────────
        hasFreeGrant          = @{
            Type        = 'boolean'
            Required    = $false
            Default     = $false
            Description = 'Whether the service has a free tier or included units requiring grant deduction'
        }
        privateEndpoint       = @{
            Type        = 'boolean'
            Required    = $false
            Default     = $false
            Description = 'Whether the service supports private endpoints — tier restrictions stay in Notes'
        }
    }

    # ── Field groups (display and documentation order) ────────────────────
    FieldGroups        = @(
        @{ Name = 'Identity'; Fields = @('serviceName'; 'category'; 'aliases') }
        @{ Name = 'Billing Graph'; Fields = @('billingNeeds'; 'billingConsiderations') }
        @{ Name = 'API Identity'; Fields = @('apiServiceName') }
        @{ Name = 'Pricing Profile'; Fields = @('primaryCost'; 'hasMeters'; 'pricingRegion'; 'hasKnownRates') }
        @{ Name = 'Service Capabilities'; Fields = @('hasFreeGrant'; 'privateEndpoint') }
    )

    # ── Elision rule ──────────────────────────────────────────────────────
    # Optional fields whose value matches the default SHOULD be omitted.
    # Only exceptions (non-default values) appear in the YAML block.
    DefaultElisionRule = 'Omit optional fields when value matches the default'
}
