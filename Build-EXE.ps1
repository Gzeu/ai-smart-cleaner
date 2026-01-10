#Requires -Version 7.0
<#
.SYNOPSIS
    Build standalone EXE for AI Smart Cleaner

.DESCRIPTION
    Converts AI-Cleaner.ps1 to executable using PS2EXE module.
    Creates portable .exe that runs without PowerShell install.

.EXAMPLE
    .\Build-EXE.ps1

.EXAMPLE
    .\Build-EXE.ps1 -NoConsole
#>

[CmdletBinding()]
param(
    [switch]$NoConsole,
    [string]$OutputPath = 'dist'
)

Write-Host "🚀 Building AI Smart Cleaner EXE..." -ForegroundColor Green

# Install PS2EXE if missing
if (-not (Get-Module -Name ps2exe -ListAvailable)) {
    Install-Module ps2exe -Force -Scope CurrentUser
}

Import-Module ps2exe

# Create output dir
if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory | Out-Null
}

# Build parameters
$params = @{
    InputFile = '.\AI-Cleaner.ps1'
    OutputFile = "$OutputPath\AI-Smart-Cleaner.exe"
    NoConsole = $NoConsole
    NoOutput = $false
    NoError = $false
    Title = 'AI Smart Cleaner v10.2'
    Company = 'Gzeu'
    Version = '10.2.0.0'
    Description = 'Professional Windows Cleanup Tool'
    Icon = $null  # Add icon.ico later
    RequireAdmin = $false
}

# Build!
Invoke-ps2exe @params

Write-Host "✅ EXE built: $($params.OutputFile)" -ForegroundColor Green
Write-Host "📁 Portable - no PS7 needed!" -ForegroundColor Yellow
Write-Host "🎯 Test: & '$($params.OutputFile)'" -ForegroundColor Cyan

# Test run
& $($params.OutputFile)