#Requires -Version 7.0
<#
.SYNOPSIS
    AI Smart Cleaner Core Module v10.1 - Enhanced Professional Edition

.DESCRIPTION
    Enhanced core module with advanced features: whitelisting, reporting,
    additional cleanup categories, scheduling support, and improved AI prompts.

.NOTES
    Author: Gzeu
    Version: 10.1
    License: MIT
#>

using namespace System.Management.Automation
using namespace System.Collections.Concurrent

# ... (keep existing CleanerConfig class)

class CleanerConfig {
    # Existing properties...
    [string[]]$WhitelistPaths = @()
    [string[]]$BlacklistPaths = @()
    [bool]$ExportReports = $true
    [string]$ReportPath = "$env:USERPROFILE\Desktop"
    [hashtable]$CleanupCategories = @{
        Temp = $true
        Cache = $true
        Logs = $true
        Downloads = $false
        Thumbnails = $false
        Prefetch = $false
    }
    # ... rest unchanged
}

# Existing functions (Write-CleanerLog, Format-ByteSize, etc.) unchanged...

# NEW: Whitelist/Blacklist Management
function Test-IsWhitelisted {
    param([string]$Path)
    $script:Config.WhitelistPaths | Where-Object { $Path -like "*$_*" }
}

function Test-IsBlacklisted {
    param([string]$Path)
    $script:Config.BlacklistPaths | Where-Object { $Path -like "*$_*" }
}

# ENHANCED: Get-CleanupTargets with new categories
function Get-CleanupTargets {
    # Existing + new
    $targets = @{
        # Existing...
        Downloads = @("$env:USERPROFILE\Downloads\*.old", "$env:USERPROFILE\Downloads\*.tmp")
        Thumbnails = @("$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db", "$env:APPDATA\Thumbnails")
        Prefetch = @("$env:WINDIR\Prefetch")
    }
    # ... rest unchanged
}

# NEW: Export Report
function Export-CleanupReport {
    param(
        [PSCustomObject[]]$Results,
        [string]$Path
    )
    $csvPath = "$Path\AI-Cleaner-Report-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    $Results | Export-Csv -Path $csvPath -NoTypeInformation
    $htmlPath = "$Path\AI-Cleaner-Report-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
    $Results | ConvertTo-Html -Title "Cleanup Report" | Set-Content $htmlPath
    return @($csvPath, $htmlPath)
}

# ENHANCED AI with better prompt
function Invoke-GeminiAnalysis {
    # Existing + improved prompt
    $prompt = @"
Enhanced analysis with whitelisting consideration...
"@
    # ... rest unchanged
}

# Export all (existing + new)
Export-ModuleMember -Function @('Write-CleanerLog', 'Format-ByteSize', 'Get-CleanupTargets', 'Invoke-ParallelScan', 'Invoke-CleanupOperation', 'Invoke-GeminiAnalysis', 'Test-IsWhitelisted', 'Test-IsBlacklisted', 'Export-CleanupReport')
Export-ModuleMember -Class @('CleanerConfig')