#Requires -Version 7.0
<#
.SYNOPSIS
    Installation script for AI Smart Cleaner

.DESCRIPTION
    Automated installation script that checks prerequisites, sets up
    configuration, installs dependencies, and verifies the installation.

.PARAMETER InstallPath
    Custom installation directory (default: current directory)

.PARAMETER SkipTests
    Skip running tests after installation

.PARAMETER CreateShortcut
    Create desktop shortcut

.EXAMPLE
    .\Install.ps1
    Basic installation

.EXAMPLE
    .\Install.ps1 -CreateShortcut
    Install and create desktop shortcut

.NOTES
    Author: Gzeu
    Version: 10.0
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$InstallPath = $PSScriptRoot,

    [Parameter()]
    [switch]$SkipTests,

    [Parameter()]
    [switch]$CreateShortcut
)

$ErrorActionPreference = 'Stop'

# ============================================================================
# FUNCTIONS
# ============================================================================

function Write-InstallLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $colors = @{
        Info = 'Cyan'
        Success = 'Green'
        Warning = 'Yellow'
        Error = 'Red'
    }
    
    $prefix = switch ($Level) {
        'Info' { '[INFO]' }
        'Success' { '[✓]' }
        'Warning' { '[⚠]' }
        'Error' { '[✗]' }
    }
    
    Write-Host "$prefix $Message" -ForegroundColor $colors[$Level]
}

function Test-Prerequisites {
    Write-InstallLog "Checking prerequisites..." -Level Info
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-InstallLog "PowerShell 7+ required. Current: $($PSVersionTable.PSVersion)" -Level Error
        Write-InstallLog "Download from: https://github.com/PowerShell/PowerShell/releases" -Level Info
        return $false
    }
    Write-InstallLog "PowerShell $($PSVersionTable.PSVersion) detected" -Level Success
    
    # Check Windows version
    if ($PSVersionTable.Platform -ne 'Win32NT') {
        Write-InstallLog "Windows OS required" -Level Error
        return $false
    }
    
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        Write-InstallLog "Windows 10/11 required. Current: $osVersion" -Level Warning
    }
    else {
        Write-InstallLog "Windows $($osVersion.Major) detected" -Level Success
    }
    
    # Check .NET Framework
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        Write-InstallLog ".NET Framework assemblies available" -Level Success
    }
    catch {
        Write-InstallLog ".NET Framework 4.7+ required" -Level Error
        return $false
    }
    
    return $true
}

function Install-Dependencies {
    Write-InstallLog "Installing dependencies..." -Level Info
    
    # Check if Pester is installed
    $pester = Get-Module -Name Pester -ListAvailable | Where-Object { $_.Version -ge '5.0.0' }
    
    if (-not $pester) {
        Write-InstallLog "Installing Pester module..." -Level Info
        try {
            Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck -Scope CurrentUser
            Write-InstallLog "Pester installed successfully" -Level Success
        }
        catch {
            Write-InstallLog "Failed to install Pester: $($_.Exception.Message)" -Level Warning
            Write-InstallLog "Tests will be skipped" -Level Warning
            return $false
        }
    }
    else {
        Write-InstallLog "Pester $($pester[0].Version) already installed" -Level Success
    }
    
    return $true
}

function Initialize-Configuration {
    Write-InstallLog "Setting up configuration..." -Level Info
    
    $configPath = Join-Path $InstallPath 'AI-Cleaner-Config.json'
    $templatePath = Join-Path $InstallPath 'AI-Cleaner-Config.json.template'
    
    if (Test-Path $configPath) {
        Write-InstallLog "Configuration file already exists" -Level Warning
        $response = Read-Host "Overwrite? (y/N)"
        if ($response -ne 'y') {
            Write-InstallLog "Keeping existing configuration" -Level Info
            return $true
        }
    }
    
    if (Test-Path $templatePath) {
        Copy-Item $templatePath $configPath -Force
        Write-InstallLog "Configuration created from template" -Level Success
    }
    else {
        Write-InstallLog "Template not found, creating default config" -Level Warning
        $defaultConfig = @{
            GeminiApiKey = ""
            SafeMode = $true
            MaxThreads = 4
            LogRetentionDays = 30
            CustomPaths = @()
            EnableGemini = $false
            CreateBackup = $true
            Theme = "Dark"
            CleanupCategories = @{
                Temp = $true
                Cache = $true
                Logs = $true
                Downloads = $false
            }
        }
        $defaultConfig | ConvertTo-Json -Depth 10 | Set-Content $configPath
        Write-InstallLog "Default configuration created" -Level Success
    }
    
    return $true
}

function Test-Installation {
    Write-InstallLog "Verifying installation..." -Level Info
    
    # Check core files exist
    $requiredFiles = @(
        'AI-Cleaner.ps1',
        'AI-Cleaner-Core.psm1',
        'AI-Cleaner-Config.json'
    )
    
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $InstallPath $file
        if (-not (Test-Path $filePath)) {
            Write-InstallLog "Missing required file: $file" -Level Error
            return $false
        }
    }
    Write-InstallLog "All required files present" -Level Success
    
    # Try to import module
    try {
        $modulePath = Join-Path $InstallPath 'AI-Cleaner-Core.psm1'
        Import-Module $modulePath -Force -ErrorAction Stop
        $commands = Get-Command -Module AI-Cleaner-Core
        Write-InstallLog "Core module loaded ($($commands.Count) commands exported)" -Level Success
        Remove-Module AI-Cleaner-Core -Force
    }
    catch {
        Write-InstallLog "Failed to load core module: $($_.Exception.Message)" -Level Error
        return $false
    }
    
    # Run tests if not skipped
    if (-not $SkipTests) {
        $testsPath = Join-Path $InstallPath 'Tests'
        if (Test-Path $testsPath) {
            Write-InstallLog "Running tests..." -Level Info
            try {
                $result = Invoke-Pester -Path $testsPath -PassThru -Output Minimal
                if ($result.FailedCount -eq 0) {
                    Write-InstallLog "All tests passed ($($result.PassedCount)/$($result.TotalCount))" -Level Success
                }
                else {
                    Write-InstallLog "Some tests failed ($($result.FailedCount)/$($result.TotalCount))" -Level Warning
                }
            }
            catch {
                Write-InstallLog "Test execution failed: $($_.Exception.Message)" -Level Warning
            }
        }
        else {
            Write-InstallLog "Tests directory not found, skipping" -Level Warning
        }
    }
    
    return $true
}

function New-DesktopShortcut {
    Write-InstallLog "Creating desktop shortcut..." -Level Info
    
    try {
        $shell = New-Object -ComObject WScript.Shell
        $desktop = [Environment]::GetFolderPath('Desktop')
        $shortcutPath = Join-Path $desktop 'AI Smart Cleaner.lnk'
        
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = 'pwsh.exe'
        $shortcut.Arguments = "-NoProfile -File `"$(Join-Path $InstallPath 'AI-Cleaner.ps1')`""
        $shortcut.WorkingDirectory = $InstallPath
        $shortcut.Description = 'AI Smart Cleaner - Professional Windows Cleanup Tool'
        $shortcut.IconLocation = 'cleanmgr.exe,0'
        $shortcut.Save()
        
        Write-InstallLog "Shortcut created: $shortcutPath" -Level Success
        return $true
    }
    catch {
        Write-InstallLog "Failed to create shortcut: $($_.Exception.Message)" -Level Warning
        return $false
    }
}

# ============================================================================
# MAIN INSTALLATION
# ============================================================================

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🧹 AI Smart Cleaner v10.0 - Installation Script   " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check prerequisites
if (-not (Test-Prerequisites)) {
    Write-InstallLog "Installation aborted due to missing prerequisites" -Level Error
    exit 1
}

Write-Host ""

# Step 2: Install dependencies
$depsInstalled = Install-Dependencies
Write-Host ""

# Step 3: Initialize configuration
if (-not (Initialize-Configuration)) {
    Write-InstallLog "Configuration setup failed" -Level Error
    exit 1
}

Write-Host ""

# Step 4: Verify installation
if (-not (Test-Installation)) {
    Write-InstallLog "Installation verification failed" -Level Error
    exit 1
}

Write-Host ""

# Step 5: Create shortcut if requested
if ($CreateShortcut) {
    New-DesktopShortcut | Out-Null
    Write-Host ""
}

# Final message
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   ✓ Installation Complete!                          " -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review configuration: AI-Cleaner-Config.json"
Write-Host "  2. (Optional) Add Gemini API key for AI features"
Write-Host "  3. Launch the application: .\AI-Cleaner.ps1"
Write-Host ""
Write-Host "Documentation: README.md" -ForegroundColor Cyan
Write-Host "GitHub: https://github.com/Gzeu/ai-smart-cleaner" -ForegroundColor Cyan
Write-Host ""

Write-InstallLog "Installation completed successfully!" -Level Success
