#Requires -Version 7.0
<#
.SYNOPSIS
    Publish AI Smart Cleaner to PowerShell Gallery

.DESCRIPTION
    Builds module, tests, and publishes to PSGallery.

.PARAMETER WhatIf
    Show what would be published

.EXAMPLE
    .\Publish-Gallery.ps1
#>

[CmdletBinding(SupportsShouldProcess)]
param([switch]$WhatIf)

# API Token needed
$token = Read-Host 'PSGallery API Token (secure)'
$secureToken = ConvertTo-SecureString $token -AsPlainText -Force

# Build module
Import-Module ./AI-Cleaner-Core.psm1

# Test
Invoke-Pester ./Tests -PassThru | Export-Clixml test.xml

# Publish
Publish-Module -Path . -NuGetApiKey $secureToken -WhatIf:$WhatIf

Write-Host '✅ Published to PowerShell Gallery!'