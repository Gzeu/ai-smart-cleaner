
@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'AI-Cleaner.psm1'

    # Version number of this module.
    ModuleVersion = '10.2.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Core', 'Desktop')

    # ID used to uniquely identify this module
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'

    # Author of this module
    Author = 'Gzeu'

    # Company or vendor of this module
    CompanyName = 'Gzeu'

    # Copyright statement for this module
    Copyright = '(c) 2026 Gzeu. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'AI Smart Cleaner - Professional Windows disk cleanup with AI analysis, charts, and scheduler'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '7.0'

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @('System.Windows.Forms.DataVisualization')

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Write-CleanerLog',
        'Format-ByteSize',
        'Get-CleanupTargets',
        'Invoke-ParallelScan',
        'Invoke-CleanupOperation',
        'Invoke-GeminiAnalysis',
        'Test-IsWhitelisted',
        'Test-IsBlacklisted',
        'Export-CleanupReport'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # DSC resources to export from this module
    DscResourcesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('cleanup', 'disk', 'ai', 'gemini', 'windows', 'performance')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/Gzeu/ai-smart-cleaner/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/Gzeu/ai-smart-cleaner'

            # A URL to an icon representing this module.
            IconUri = 'https://raw.githubusercontent.com/Gzeu/ai-smart-cleaner/main/icon.png'

            # ReleaseNotes of this module
            ReleaseNotes = 'v10.2 Ultimate with Charts, Scheduler, History'

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}
