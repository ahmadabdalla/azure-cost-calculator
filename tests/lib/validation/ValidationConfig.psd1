@{
    ValidCategories = @(
        'compute', 'containers', 'databases', 'networking', 'storage',
        'security', 'monitoring', 'management', 'integration', 'analytics',
        'ai-ml', 'iot', 'developer-tools', 'identity', 'migration',
        'web', 'communication', 'specialist'
    )
    RequiredFrontMatterFields = @('serviceName', 'category', 'aliases')
    RequiredSections = @('Query Pattern', 'Cost Formula', 'Notes')
    RequiredSectionOrder = @('Query Pattern', 'Key Fields', 'Meter Names', 'Cost Formula', 'Notes')
    OptionalSections = @(
        'Reserved Instance Pricing', 'Manual Calculation Example',
        'Known Rates', 'Common SKUs', 'Product Names', 'SKU Selection Guide'
    )
    MaxLineCount = 100
    QueryPatternDeadline = 45
    ServicesFolderPattern = 'references/services/([^/]+)/'
}
