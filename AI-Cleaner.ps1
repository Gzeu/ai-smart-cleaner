#Requires -Version 7.0
# ENHANCED AI-Cleaner.ps1 v10.1 - Improved GUI & Functions

# ... (keep existing imports/init)

# NEW THEME WITH BETTER COLORS
$ThemeColors = @{
    Dark = @{
        Background = [System.Drawing.Color]::FromArgb(18, 18, 18)
        Panel = [System.Drawing.Color]::FromArgb(35, 35, 35)
        Accent = [System.Drawing.Color]::FromArgb(0, 122, 255)
        Success = [System.Drawing.Color]::FromArgb(46, 204, 113)
        Warning = [System.Drawing.Color]::FromArgb(241, 196, 15)
        Danger = [System.Drawing.Color]::FromArgb(231, 76, 60)
        Text = [System.Drawing.Color]::FromArgb(236, 240, 241)
        Mute = [System.Drawing.Color]::FromArgb(127, 140, 141)
    }
}

# ENHANCED GUI: Add DataGridView for results
function New-ResultsTable {
    $dataGrid = New-Object System.Windows.Forms.DataGridView
    $dataGrid.Dock = 'Fill'
    $dataGrid.AllowUserToAddRows = $false
    $dataGrid.ReadOnly = $true
    $dataGrid.SelectionMode = 'FullRowSelect'
    $dataGrid.AutoSizeColumnsMode = 'Fill'
    $dataGrid.BackgroundColor = $ThemeColors['Dark'].Panel
    $dataGrid.GridColor = $ThemeColors['Dark'].Mute
    $dataGrid.DefaultCellStyle.ForeColor = $ThemeColors['Dark'].Text
    $dataGrid.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(25,25,25)
    $dataGrid.ColumnHeadersDefaultCellStyle.BackColor = $ThemeColors['Dark'].Accent
    $dataGrid.ColumnHeadersDefaultCellStyle.ForeColor = 'White'
    return $dataGrid
}

# SPLIT TABS: Results now has Table + Logs
$tabResultsTable = New-Object System.Windows.Forms.TabPage
$tabResultsTable.Text = '📊 Results Table'
$dgvResults = New-ResultsTable
$tabResultsTable.Controls.Add($dgvResults)

$tabResultsLog = New-Object System.Windows.Forms.TabPage
$tabResultsLog.Text = '📝 Live Logs'
$rtbLog.Dock = 'Fill'
$tabResultsLog.Controls.Add($rtbLog)

# NEW TAB: Schedule
$tabSchedule = New-Object System.Windows.Forms.TabPage
$tabSchedule.Text = '⏰ Schedule'
# Placeholder for future scheduler
$lblSchedule = New-Object System.Windows.Forms.Label
$lblSchedule.Text = 'Scheduler coming in v10.2'
$lblSchedule.Dock = 'Fill'
$lblSchedule.TextAlign = 'MiddleCenter'
$tabSchedule.Controls.Add($lblSchedule)

# ADD TO TABCONTROL
$tabControl.TabPages.Add($tabResultsTable)
$tabControl.TabPages.Add($tabResultsLog)
$tabControl.TabPages.Add($tabSchedule)

# NEW: Whitelist/Blacklist in Config Panel
$yPos += 60
$lblWhitelist = New-Object System.Windows.Forms.Label
$lblWhitelist.Text = 'Whitelist Paths (comma sep):'
$lblWhitelist.Location = New-Object System.Drawing.Point(20, $yPos)
$txtWhitelist = New-Object System.Windows.Forms.TextBox
$txtWhitelist.Location = New-Object System.Drawing.Point(20, ($yPos+25))
$txtWhitelist.Size = New-Object System.Drawing.Size(600,25)

# NEW BUTTONS: Export, Whitelist Add
$btnExport = New-Object System.Windows.Forms.Button
$btnExport.Text = '📤 Export Report'
$btnExport.Location = New-Object System.Drawing.Point(800, 430)
$btnExport.Size = New-Object System.Drawing.Size(200,70)

# ENHANCED START CLEANUP - Populate Table
$btnStart.Add_Click({
    # Existing logic...
    # After cleanup:
    $dgvResults.DataSource = [System.Collections.ArrayList]$allResults
    $dgvResults.Refresh()
    
    # Export if enabled
    if ($script:Config.ExportReports) {
        $reports = Export-CleanupReport -Results $allResults -Path $script:Config.ReportPath
        Write-CleanerLog "Reports exported: $($reports -join ', ')" -Level Success -LogBox $rtbLog
    }
})

# IMPROVED THEME APPLICATION
foreach ($tab in $tabControl.TabPages) {
    Set-ControlTheme -Control $tab -Theme 'Dark'
}

# LAUNCH WITH ANIMATED PROGRESS (fake)
$progressBar.Style = 'Marquee'

Write-Host '🧹 AI Smart Cleaner v10.1 - ENHANCED GUI & FUNCTIONS!'