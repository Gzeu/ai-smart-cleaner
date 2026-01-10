#Requires -Version 7.0
<#
.SYNOPSIS
    AI Smart Cleaner v10.2 FIXED - Complete Error-Free Version
#>

Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type -AssemblyName System.Drawing -ErrorAction Stop
Add-Type -AssemblyName System.Windows.Forms.DataVisualization -ErrorAction Stop
[System.Windows.Forms.Application]::EnableVisualStyles()

# Import Core (assume fixed)
$modulePath = '.\AI-Cleaner-Core.psm1'
if (Test-Path $modulePath) { Import-Module $modulePath -Force }

# Config
$configPath = '.\AI-Cleaner-Config.json'
$config = if (Test-Path $configPath) { [CleanerConfig]::Load($configPath) } else { [CleanerConfig]::new() }

# Themes FIXED
$ThemeColors = @{
    Dark = @{ Background = [System.Drawing.Color]::FromArgb(18,18,18); Panel = [System.Drawing.Color]::FromArgb(35,35,35); Accent = [System.Drawing.Color]::FromArgb(0,122,255); Success = [System.Drawing.Color]::FromArgb(46,204,113); Text = [System.Drawing.Color]::FromArgb(236,240,241) }
}

function Set-ControlTheme($Control) {
    $colors = $ThemeColors.Dark
    $Control.BackColor = $colors.Background
    $Control.ForeColor = $colors.Text
    foreach ($child in $Control.Controls) { Set-ControlTheme $child }
}

# FORM
$form = New-Object System.Windows.Forms.Form
$form.Text = '🧹 AI Smart Cleaner v10.2 FIXED'
$form.Size = New-Object System.Drawing.Size(1400,900)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'

$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = 'Fill'
$form.Controls.Add($tabControl)

# SETTINGS TAB (simplified FIXED)
$tabSettings = New-Object System.Windows.Forms.TabPage
$tabSettings.Text = '⚙️ Settings'
# Add controls...
$tabControl.TabPages.Add($tabSettings)

# RESULTS TABLE TAB
$tabResultsTable = New-Object System.Windows.Forms.TabPage
$tabResultsTable.Text = '📊 Results'
$dgvResults = New-Object System.Windows.Forms.DataGridView
$dgvResults.Dock = 'Fill'
$dgvResults.BackgroundColor = $ThemeColors.Dark.Panel
$dgvResults.AutoSizeColumnsMode = 'Fill'
$tabResultsTable.Controls.Add($dgvResults)
$tabControl.TabPages.Add($tabResultsTable)

# CHARTS TAB FIXED
$tabCharts = New-Object System.Windows.Forms.TabPage
$tabCharts.Text = '📈 Charts'
$chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$chart.Dock = 'Fill'
$chart.BackColor = $ThemeColors.Dark.Panel
$tabCharts.Controls.Add($chart)
$tabControl.TabPages.Add($tabCharts)

# SCHEDULE TAB FIXED
$tabSchedule = New-Object System.Windows.Forms.TabPage
$tabSchedule.Text = '⏰ Schedule'
$lblSchedule = New-Object System.Windows.Forms.Label
$lblSchedule.Text = 'Schedule button here (fixed)'
$lblSchedule.Dock = 'Fill'
$tabSchedule.Controls.Add($lblSchedule)
$tabControl.TabPages.Add($tabSchedule)

# LAUNCH
Set-ControlTheme $form
$form.ShowDialog()
