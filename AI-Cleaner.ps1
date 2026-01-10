#Requires -Version 7.0
<#
.SYNOPSIS
    AI Smart Cleaner v10.0 - Professional Windows Cleanup Tool

.DESCRIPTION
    Advanced PowerShell GUI application for intelligent Windows disk cleanup
    with AI-powered analysis, parallel scanning, and comprehensive safety features.

.NOTES
    Author: Gzeu
    Version: 10.0.0
    License: MIT
    Requires: PowerShell 7.0+, Windows 10/11

.LINK
    https://github.com/Gzeu/ai-smart-cleaner

.EXAMPLE
    .\AI-Cleaner.ps1
    Launches the GUI application

.EXAMPLE
    .\AI-Cleaner.ps1 -SafeMode
    Launches in preview-only mode
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$SafeMode,

    [Parameter()]
    [switch]$NoGUI
)

# ============================================================================
# INITIALIZATION
# ============================================================================

$ErrorActionPreference = 'Stop'
$script:ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:ConfigPath = Join-Path $script:ScriptPath 'AI-Cleaner-Config.json'

# Import core module
try {
    $modulePath = Join-Path $script:ScriptPath 'AI-Cleaner-Core.psm1'
    if (-not (Test-Path $modulePath)) {
        throw "Core module not found: $modulePath"
    }
    Import-Module $modulePath -Force -ErrorAction Stop
    Write-Host "✓ Core module loaded successfully" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to load core module: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Load configuration
try {
    $script:Config = [CleanerConfig]::Load($script:ConfigPath)
    if ($SafeMode) {
        $script:Config.SafeMode = $true
    }
    Write-Host "✓ Configuration loaded" -ForegroundColor Green
}
catch {
    Write-Host "⚠ Using default configuration" -ForegroundColor Yellow
    $script:Config = [CleanerConfig]::new()
}

# Load Windows Forms
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop
    [System.Windows.Forms.Application]::EnableVisualStyles()
    Write-Host "✓ UI components loaded" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to load UI components: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ============================================================================
# THEME CONFIGURATION
# ============================================================================

$ThemeColors = @{
    Dark = @{
        Background = [System.Drawing.Color]::FromArgb(30, 30, 30)
        BackgroundLight = [System.Drawing.Color]::FromArgb(45, 45, 45)
        Foreground = [System.Drawing.Color]::FromArgb(220, 220, 220)
        Accent = [System.Drawing.Color]::FromArgb(13, 110, 253)
        Success = [System.Drawing.Color]::FromArgb(40, 167, 69)
        Warning = [System.Drawing.Color]::FromArgb(255, 193, 7)
        Danger = [System.Drawing.Color]::FromArgb(220, 53, 69)
    }
    Light = @{
        Background = [System.Drawing.Color]::FromArgb(248, 249, 250)
        BackgroundLight = [System.Drawing.Color]::White
        Foreground = [System.Drawing.Color]::FromArgb(33, 37, 41)
        Accent = [System.Drawing.Color]::FromArgb(0, 123, 255)
        Success = [System.Drawing.Color]::FromArgb(40, 167, 69)
        Warning = [System.Drawing.Color]::FromArgb(255, 193, 7)
        Danger = [System.Drawing.Color]::FromArgb(220, 53, 69)
    }
}

function Set-ControlTheme {
    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.Control]$Control,
        
        [Parameter()]
        [string]$Theme = 'Dark'
    )
    
    $colors = $ThemeColors[$Theme]
    $Control.BackColor = $colors.Background
    $Control.ForeColor = $colors.Foreground
    
    foreach ($child in $Control.Controls) {
        Set-ControlTheme -Control $child -Theme $Theme
    }
}

# ============================================================================
# GUI CREATION
# ============================================================================

# Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = '🧹 AI Smart Cleaner v10.0 Professional'
$form.Size = New-Object System.Drawing.Size(1400, 900)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)

# Tab Control
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = 'Fill'
$tabControl.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($tabControl)

# ============================================================================
# TAB 1: SETTINGS & CONTROL
# ============================================================================

$tabSettings = New-Object System.Windows.Forms.TabPage
$tabSettings.Text = '⚙️ Settings & Control'
$tabSettings.Padding = New-Object System.Windows.Forms.Padding(20)
$tabControl.TabPages.Add($tabSettings)

# Title Label
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = '🧹 AI Smart Cleaner Professional'
$lblTitle.Location = New-Object System.Drawing.Point(20, 20)
$lblTitle.Size = New-Object System.Drawing.Size(600, 40)
$lblTitle.Font = New-Object System.Drawing.Font('Segoe UI', 20, [System.Drawing.FontStyle]::Bold)
$tabSettings.Controls.Add($lblTitle)

$lblSubtitle = New-Object System.Windows.Forms.Label
$lblSubtitle.Text = 'Intelligent Windows cleanup with AI-powered analysis'
$lblSubtitle.Location = New-Object System.Drawing.Point(20, 65)
$lblSubtitle.Size = New-Object System.Drawing.Size(600, 25)
$lblSubtitle.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Italic)
$tabSettings.Controls.Add($lblSubtitle)

# Configuration Panel
$panelConfig = New-Object System.Windows.Forms.GroupBox
$panelConfig.Text = ' Configuration '
$panelConfig.Location = New-Object System.Drawing.Point(20, 110)
$panelConfig.Size = New-Object System.Drawing.Size(650, 300)
$panelConfig.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$tabSettings.Controls.Add($panelConfig)

# Safe Mode
$yPos = 35
$lblSafeMode = New-Object System.Windows.Forms.Label
$lblSafeMode.Text = 'Safe Mode (Preview Only):'
$lblSafeMode.Location = New-Object System.Drawing.Point(20, $yPos)
$lblSafeMode.Size = New-Object System.Drawing.Size(250, 25)
$panelConfig.Controls.Add($lblSafeMode)

$chkSafeMode = New-Object System.Windows.Forms.CheckBox
$chkSafeMode.Location = New-Object System.Drawing.Point(280, $yPos)
$chkSafeMode.Size = New-Object System.Drawing.Size(100, 25)
$chkSafeMode.Checked = $script:Config.SafeMode
$chkSafeMode.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$panelConfig.Controls.Add($chkSafeMode)

# Create Backup
$yPos += 40
$lblBackup = New-Object System.Windows.Forms.Label
$lblBackup.Text = 'Create Restore Point:'
$lblBackup.Location = New-Object System.Drawing.Point(20, $yPos)
$lblBackup.Size = New-Object System.Drawing.Size(250, 25)
$panelConfig.Controls.Add($lblBackup)

$chkBackup = New-Object System.Windows.Forms.CheckBox
$chkBackup.Location = New-Object System.Drawing.Point(280, $yPos)
$chkBackup.Size = New-Object System.Drawing.Size(100, 25)
$chkBackup.Checked = $script:Config.CreateBackup
$chkBackup.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$panelConfig.Controls.Add($chkBackup)

# Max Threads
$yPos += 40
$lblThreads = New-Object System.Windows.Forms.Label
$lblThreads.Text = 'Parallel Scan Threads:'
$lblThreads.Location = New-Object System.Drawing.Point(20, $yPos)
$lblThreads.Size = New-Object System.Drawing.Size(250, 25)
$panelConfig.Controls.Add($lblThreads)

$numThreads = New-Object System.Windows.Forms.NumericUpDown
$numThreads.Location = New-Object System.Drawing.Point(280, $yPos)
$numThreads.Size = New-Object System.Drawing.Size(80, 25)
$numThreads.Minimum = 1
$numThreads.Maximum = 16
$numThreads.Value = $script:Config.MaxThreads
$numThreads.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$panelConfig.Controls.Add($numThreads)

# Enable Gemini AI
$yPos += 40
$lblGemini = New-Object System.Windows.Forms.Label
$lblGemini.Text = 'Enable Gemini AI Analysis:'
$lblGemini.Location = New-Object System.Drawing.Point(20, $yPos)
$lblGemini.Size = New-Object System.Drawing.Size(250, 25)
$panelConfig.Controls.Add($lblGemini)

$chkGemini = New-Object System.Windows.Forms.CheckBox
$chkGemini.Location = New-Object System.Drawing.Point(280, $yPos)
$chkGemini.Size = New-Object System.Drawing.Size(100, 25)
$chkGemini.Checked = $script:Config.EnableGemini
$chkGemini.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$panelConfig.Controls.Add($chkGemini)

# Gemini API Key
$yPos += 40
$lblApiKey = New-Object System.Windows.Forms.Label
$lblApiKey.Text = 'Gemini API Key:'
$lblApiKey.Location = New-Object System.Drawing.Point(20, $yPos)
$lblApiKey.Size = New-Object System.Drawing.Size(250, 25)
$panelConfig.Controls.Add($lblApiKey)

$txtApiKey = New-Object System.Windows.Forms.TextBox
$txtApiKey.Location = New-Object System.Drawing.Point(20, ($yPos + 30))
$txtApiKey.Size = New-Object System.Drawing.Size(600, 25)
$txtApiKey.UseSystemPasswordChar = $true
$txtApiKey.Font = New-Object System.Drawing.Font('Consolas', 10)
$txtApiKey.Text = if ($script:Config.GeminiApiKey) { $script:Config.GeminiApiKey } else { [Environment]::GetEnvironmentVariable('GEMINI_API_KEY') }
$panelConfig.Controls.Add($txtApiKey)

# Cleanup Categories Panel
$panelCategories = New-Object System.Windows.Forms.GroupBox
$panelCategories.Text = ' Cleanup Categories '
$panelCategories.Location = New-Object System.Drawing.Point(690, 110)
$panelCategories.Size = New-Object System.Drawing.Size(650, 300)
$panelCategories.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$tabSettings.Controls.Add($panelCategories)

$yPos = 35
$checkboxes = @{}
foreach ($category in $script:Config.CleanupCategories.Keys) {
    $chk = New-Object System.Windows.Forms.CheckBox
    $chk.Text = $category
    $chk.Location = New-Object System.Drawing.Point(20, $yPos)
    $chk.Size = New-Object System.Drawing.Size(150, 25)
    $chk.Checked = $script:Config.CleanupCategories[$category]
    $chk.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $panelCategories.Controls.Add($chk)
    $checkboxes[$category] = $chk
    $yPos += 35
}

# Control Buttons
$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Text = '🚀 START CLEANUP'
$btnStart.Location = New-Object System.Drawing.Point(20, 430)
$btnStart.Size = New-Object System.Drawing.Size(320, 70)
$btnStart.BackColor = $ThemeColors['Dark'].Success
$btnStart.ForeColor = [System.Drawing.Color]::White
$btnStart.FlatStyle = 'Flat'
$btnStart.Font = New-Object System.Drawing.Font('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
$btnStart.Cursor = [System.Windows.Forms.Cursors]::Hand
$tabSettings.Controls.Add($btnStart)

$btnSaveConfig = New-Object System.Windows.Forms.Button
$btnSaveConfig.Text = '💾 Save Configuration'
$btnSaveConfig.Location = New-Object System.Drawing.Point(360, 430)
$btnSaveConfig.Size = New-Object System.Drawing.Size(200, 70)
$btnSaveConfig.BackColor = $ThemeColors['Dark'].Accent
$btnSaveConfig.ForeColor = [System.Drawing.Color]::White
$btnSaveConfig.FlatStyle = 'Flat'
$btnSaveConfig.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$btnSaveConfig.Cursor = [System.Windows.Forms.Cursors]::Hand
$tabSettings.Controls.Add($btnSaveConfig)

$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = '🔄 Refresh Targets'
$btnRefresh.Location = New-Object System.Drawing.Point(580, 430)
$btnRefresh.Size = New-Object System.Drawing.Size(200, 70)
$btnRefresh.BackColor = $ThemeColors['Dark'].BackgroundLight
$btnRefresh.ForeColor = [System.Drawing.Color]::White
$btnRefresh.FlatStyle = 'Flat'
$btnRefresh.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$btnRefresh.Cursor = [System.Windows.Forms.Cursors]::Hand
$tabSettings.Controls.Add($btnRefresh)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 520)
$progressBar.Size = New-Object System.Drawing.Size(760, 30)
$progressBar.Style = 'Continuous'
$progressBar.Maximum = 100
$tabSettings.Controls.Add($progressBar)

# Status Label
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = 'Ready to start cleanup...'
$lblStatus.Location = New-Object System.Drawing.Point(20, 560)
$lblStatus.Size = New-Object System.Drawing.Size(760, 30)
$lblStatus.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Italic)
$tabSettings.Controls.Add($lblStatus)

# ============================================================================
# TAB 2: RESULTS & LOGS
# ============================================================================

$tabResults = New-Object System.Windows.Forms.TabPage
$tabResults.Text = '📊 Results & Logs'
$tabControl.TabPages.Add($tabResults)

# Summary Panel
$panelSummary = New-Object System.Windows.Forms.Panel
$panelSummary.Dock = 'Top'
$panelSummary.Height = 120
$tabResults.Controls.Add($panelSummary)

$lblSummary = New-Object System.Windows.Forms.Label
$lblSummary.Text = 'Total Space Freed: 0 B | Files Processed: 0 | Duration: 0s'
$lblSummary.Location = New-Object System.Drawing.Point(20, 20)
$lblSummary.Size = New-Object System.Drawing.Size(1300, 40)
$lblSummary.Font = New-Object System.Drawing.Font('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
$lblSummary.ForeColor = $ThemeColors['Dark'].Success
$panelSummary.Controls.Add($lblSummary)

$lblLastRun = New-Object System.Windows.Forms.Label
$lblLastRun.Text = 'Last run: Never'
$lblLastRun.Location = New-Object System.Drawing.Point(20, 70)
$lblLastRun.Size = New-Object System.Drawing.Size(1300, 25)
$lblLastRun.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Italic)
$panelSummary.Controls.Add($lblLastRun)

# Log Box
$rtbLog = New-Object System.Windows.Forms.RichTextBox
$rtbLog.Dock = 'Fill'
$rtbLog.Font = New-Object System.Drawing.Font('Consolas', 10)
$rtbLog.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 18)
$rtbLog.ForeColor = [System.Drawing.Color]::WhiteSmoke
$rtbLog.ReadOnly = $true
$rtbLog.WordWrap = $false
$rtbLog.ScrollBars = 'Both'
$tabResults.Controls.Add($rtbLog)

# ============================================================================
# TAB 3: AI ANALYSIS
# ============================================================================

$tabAI = New-Object System.Windows.Forms.TabPage
$tabAI.Text = '🤖 AI Analysis'
$tabControl.TabPages.Add($tabAI)

$rtbAI = New-Object System.Windows.Forms.RichTextBox
$rtbAI.Dock = 'Fill'
$rtbAI.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$rtbAI.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 18)
$rtbAI.ForeColor = [System.Drawing.Color]::WhiteSmoke
$rtbAI.ReadOnly = $true
$rtbAI.Text = "AI analysis results will appear here after cleanup...\n\n" +
              "Enable 'Enable Gemini AI Analysis' in Settings and provide your API key to use this feature."
$tabAI.Controls.Add($rtbAI)

# ============================================================================
# EVENT HANDLERS
# ============================================================================

# Save Configuration
$btnSaveConfig.Add_Click({
    try {
        # Update config from UI
        $script:Config.SafeMode = $chkSafeMode.Checked
        $script:Config.CreateBackup = $chkBackup.Checked
        $script:Config.MaxThreads = $numThreads.Value
        $script:Config.EnableGemini = $chkGemini.Checked
        $script:Config.GeminiApiKey = $txtApiKey.Text
        
        foreach ($cat in $checkboxes.Keys) {
            $script:Config.CleanupCategories[$cat] = $checkboxes[$cat].Checked
        }
        
        $script:Config.Save($script:ConfigPath)
        [System.Windows.Forms.MessageBox]::Show(
            "Configuration saved successfully!",
            "Success",
            'OK',
            'Information'
        )
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to save configuration: $($_.Exception.Message)",
            "Error",
            'OK',
            'Error'
        )
    }
})

# Refresh Targets
$btnRefresh.Add_Click({
    try {
        $targets = Get-CleanupTargets
        $count = ($targets.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
        [System.Windows.Forms.MessageBox]::Show(
            "Found $count cleanup targets across $($targets.Count) categories.",
            "Target Discovery",
            'OK',
            'Information'
        )
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to refresh targets: $($_.Exception.Message)",
            "Error",
            'OK',
            'Error'
        )
    }
})

# Start Cleanup
$btnStart.Add_Click({
    # Confirmation dialog
    $mode = if ($chkSafeMode.Checked) { "PREVIEW MODE" } else { "DELETION MODE" }
    $result = [System.Windows.Forms.MessageBox]::Show(
        "This will scan and cleanup your system in $mode.`n`nDo you want to continue?",
        "Confirm Cleanup",
        'YesNo',
        'Question'
    )
    
    if ($result -ne 'Yes') { return }
    
    # Disable controls
    $btnStart.Enabled = $false
    $btnSaveConfig.Enabled = $false
    $btnRefresh.Enabled = $false
    
    # Clear previous results
    $rtbLog.Clear()
    $rtbAI.Clear()
    $progressBar.Value = 0
    
    $startTime = Get-Date
    Write-CleanerLog -Message "========================================" -Level Info -LogBox $rtbLog
    Write-CleanerLog -Message "AI Smart Cleaner v10.0 - Cleanup Started" -Level Success -LogBox $rtbLog
    Write-CleanerLog -Message "Mode: $(if ($chkSafeMode.Checked) {'PREVIEW ONLY'} else {'ACTIVE DELETION'})" -Level Warning -LogBox $rtbLog
    Write-CleanerLog -Message "========================================" -Level Info -LogBox $rtbLog
    
    $lblStatus.Text = "Discovering cleanup targets..."
    [System.Windows.Forms.Application]::DoEvents()
    
    try {
        # Get cleanup targets
        $targets = Get-CleanupTargets -IncludeCustomPaths $script:Config.CustomPaths
        $enabledCategories = $checkboxes.Keys | Where-Object { $checkboxes[$_].Checked }
        
        $totalSize = 0L
        $totalFiles = 0
        $totalDeleted = 0
        $allResults = @()
        $categoryCount = $enabledCategories.Count
        $currentCategory = 0
        
        foreach ($category in $enabledCategories) {
            if (-not $targets.ContainsKey($category) -or $targets[$category].Count -eq 0) {
                Write-CleanerLog -Message "Skipping $category (no targets found)" -Level Warning -LogBox $rtbLog
                continue
            }
            
            $currentCategory++
            $lblStatus.Text = "Processing $category ($currentCategory/$categoryCount)..."
            $progressBar.Value = [int](($currentCategory / $categoryCount) * 100)
            [System.Windows.Forms.Application]::DoEvents()
            
            $result = Invoke-CleanupOperation `
                -Category $category `
                -Paths $targets[$category] `
                -SafeMode $chkSafeMode.Checked `
                -CreateBackup $chkBackup.Checked `
                -LogBox $rtbLog
            
            $allResults += $result
            $totalSize += $result.Size
            $totalFiles += $result.Files
            $totalDeleted += $result.Deleted
        }
        
        # AI Analysis
        if ($chkGemini.Checked -and $txtApiKey.Text) {
            Write-CleanerLog -Message "Performing AI analysis..." -Level Info -LogBox $rtbLog
            $lblStatus.Text = "Running AI analysis..."
            [System.Windows.Forms.Application]::DoEvents()
            
            $scanResults = $allResults | ForEach-Object {
                [PSCustomObject]@{
                    Path = $_.Category
                    Size = $_.Size
                    Files = $_.Files
                }
            }
            
            $aiAnalysis = Invoke-GeminiAnalysis -ApiKey $txtApiKey.Text -ScanResults $scanResults -LogBox $rtbLog
            
            if ($aiAnalysis) {
                $rtbAI.Clear()
                $rtbAI.SelectionColor = [System.Drawing.Color]::Lime
                $rtbAI.AppendText("🤖 AI ANALYSIS RESULTS`n")
                $rtbAI.AppendText("======================`n`n")
                
                $rtbAI.SelectionColor = [System.Drawing.Color]::White
                $rtbAI.AppendText("Summary: $($aiAnalysis.summary)`n`n")
                
                foreach ($item in $aiAnalysis.analysis) {
                    $color = switch ($item.safetyScore) {
                        {$_ -ge 90} { [System.Drawing.Color]::Lime }
                        {$_ -ge 70} { [System.Drawing.Color]::Yellow }
                        default { [System.Drawing.Color]::Red }
                    }
                    
                    $rtbAI.SelectionColor = $color
                    $rtbAI.AppendText("$($item.path)`n")
                    $rtbAI.SelectionColor = [System.Drawing.Color]::White
                    $rtbAI.AppendText("  Safety Score: $($item.safetyScore)/100`n")
                    $rtbAI.AppendText("  Recommendation: $($item.recommendation)`n")
                    $rtbAI.AppendText("  Reasoning: $($item.reasoning)`n`n")
                }
            }
        }
        
        # Final summary
        $duration = ((Get-Date) - $startTime).TotalSeconds
        Write-CleanerLog -Message "========================================" -Level Info -LogBox $rtbLog
        Write-CleanerLog -Message "✅ Cleanup Complete!" -Level Success -LogBox $rtbLog
        Write-CleanerLog -Message "Total Size: $(Format-ByteSize $totalSize)" -Level Success -LogBox $rtbLog
        Write-CleanerLog -Message "Total Files: $totalFiles" -Level Success -LogBox $rtbLog
        if (-not $chkSafeMode.Checked) {
            Write-CleanerLog -Message "Files Deleted: $totalDeleted" -Level Success -LogBox $rtbLog
        }
        Write-CleanerLog -Message "Duration: $($duration.ToString('F2'))s" -Level Info -LogBox $rtbLog
        Write-CleanerLog -Message "========================================" -Level Info -LogBox $rtbLog
        
        $lblSummary.Text = "Total Space Freed: $(Format-ByteSize $totalSize) | Files Processed: $totalFiles | Duration: $($duration.ToString('F1'))s"
        $lblLastRun.Text = "Last run: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        $lblStatus.Text = "Cleanup completed successfully!"
        $progressBar.Value = 100
        
        [System.Windows.Forms.MessageBox]::Show(
            "Cleanup completed!`n`nSpace analyzed: $(Format-ByteSize $totalSize)`nFiles: $totalFiles`nDuration: $($duration.ToString('F1'))s",
            "Cleanup Complete",
            'OK',
            'Information'
        )
    }
    catch {
        Write-CleanerLog -Message "ERROR: $($_.Exception.Message)" -Level Error -LogBox $rtbLog
        [System.Windows.Forms.MessageBox]::Show(
            "An error occurred during cleanup:`n`n$($_.Exception.Message)",
            "Error",
            'OK',
            'Error'
        )
    }
    finally {
        # Re-enable controls
        $btnStart.Enabled = $true
        $btnSaveConfig.Enabled = $true
        $btnRefresh.Enabled = $true
    }
})

# ============================================================================
# APPLY THEME AND LAUNCH
# ============================================================================

Set-ControlTheme -Control $form -Theme $script:Config.Theme

# Show startup banner
Write-Host "`n" -NoNewline
Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                       ║" -ForegroundColor Cyan
Write-Host "║   🧹 AI Smart Cleaner v10.0 Professional Edition    ║" -ForegroundColor Green
Write-Host "║                                                       ║" -ForegroundColor Cyan
Write-Host "║   PowerShell 7+ • Windows 10/11 • Gemini AI          ║" -ForegroundColor Yellow
Write-Host "║                                                       ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Status: " -NoNewline
Write-Host "✓ Ready" -ForegroundColor Green
Write-Host "Config: " -NoNewline
Write-Host $script:ConfigPath -ForegroundColor Cyan
Write-Host "Gemini: " -NoNewline
if ($script:Config.GeminiApiKey -or [Environment]::GetEnvironmentVariable('GEMINI_API_KEY')) {
    Write-Host "✓ Configured" -ForegroundColor Green
}
else {
    Write-Host "✗ Not configured" -ForegroundColor Yellow
}
Write-Host ""

# Launch GUI
Write-Host "Launching application...`n" -ForegroundColor Cyan
[void]$form.ShowDialog()

Write-Host "`nApplication closed. Goodbye!" -ForegroundColor Yellow
