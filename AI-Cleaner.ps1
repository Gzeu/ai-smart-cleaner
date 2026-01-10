#Requires -Version 7.0
# AI-Cleaner.ps1 v10.2 ULTIMATE - Charts + Scheduler + History

# Import + Init unchanged...

# NEW: Add Charting Assembly
Add-Type -AssemblyName System.Windows.Forms.DataVisualization -ErrorAction SilentlyContinue

# CHARTS TAB
$tabCharts = New-Object System.Windows.Forms.TabPage
$tabCharts.Text = '📈 Charts'

$chartSpace = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$chartSpace.Dock = 'Fill'
$chartSpace.BackColor = $ThemeColors['Dark'].Panel
$chartSpace.BorderlineColor = $ThemeColors['Dark'].Accent

$tabCharts.Controls.Add($chartSpace)
$tabControl.TabPages.Add($tabCharts)

# SCHEDULE TAB - REAL SCHEDULER
$tabSchedule.Controls.Clear()

$lblScheduleStatus = New-Object System.Windows.Forms.Label
$lblScheduleStatus.Text = 'Scheduler Status: Not Scheduled'
$lblScheduleStatus.Dock = 'Top'
$lblScheduleStatus.Height = 40
$tabSchedule.Controls.Add($lblScheduleStatus)

$chkDaily = New-Object System.Windows.Forms.CheckBox
$chkDaily.Text = 'Daily Cleanup at'
$chkDaily.Location = New-Object System.Drawing.Point(20,50)

$timePicker = New-Object System.Windows.Forms.DateTimePicker
$timePicker.Format = 'Time'
$timePicker.ShowUpDown = $true
$timePicker.Location = New-Object System.Drawing.Point(150,50)

$btnSchedule = New-Object System.Windows.Forms.Button
$btnSchedule.Text = '⏰ Schedule'
$btnSchedule.Location = New-Object System.Drawing.Point(20,90)
$btnSchedule.Size = New-Object System.Drawing.Size(120,40)

$btnUnschedule = New-Object System.Windows.Forms.Button
$btnUnschedule.Text = '🛑 Unschedule'
$btnUnschedule.Location = New-Object System.Drawing.Point(150,90)
$btnUnschedule.Size = New-Object System.Drawing.Size(120,40)

$tabSchedule.Controls.AddRange(@($chkDaily, $timePicker, $btnSchedule, $btnUnschedule))

# HISTORY TAB
$tabHistory = New-Object System.Windows.Forms.TabPage
$tabHistory.Text = '📚 History'

$lvHistory = New-Object System.Windows.Forms.ListView
$lvHistory.Dock = 'Fill'
$lvHistory.View = 'Details'
$lvHistory.FullRowSelect = $true
$lvHistory.Columns.Add('Date',200)
$lvHistory.Columns.Add('Size Freed',150)
$lvHistory.Columns.Add('Files',80)
$lvHistory.Columns.Add('Duration',100)
$lvHistory.Columns.Add('Mode',100)

$tabHistory.Controls.Add($lvHistory)
$tabControl.TabPages.Add($tabHistory)

# ENHANCED START CLEANUP
$btnStart.Add_Click({
    # Existing...
    
    # POPULATE CHART
    $chartSpace.Series.Clear()
    $pieSeries = New-Object System.Windows.Forms.DataVisualization.Charting.Series('Space by Category')
    $pieSeries.ChartType = 'Pie'
    $pieSeries['PieLabelStyle'] = 'Outside'
    
    foreach ($result in $allResults) {
        $pieSeries.Points.AddXY($result.Category, $result.Size) | Out-Null
    }
    $chartSpace.Series.Add($pieSeries)
    $chartSpace.Titles.Add('Space Freed by Category')
    
    # HISTORY
    $historyItem = New-Object System.Windows.Forms.ListViewItem((Get-Date -Format 'yyyy-MM-dd HH:mm'))
    $historyItem.SubItems.Add((Format-ByteSize $totalSize))
    $historyItem.SubItems.Add($totalFiles.ToString())
    $historyItem.SubItems.Add("$($duration.ToString('F1'))s")
    $historyItem.SubItems.Add(($chkSafeMode.Checked ? 'Safe' : 'Delete'))
    $lvHistory.Items.Insert(0, $historyItem)
})

# SCHEDULER EVENTS
$btnSchedule.Add_Click({
    $taskName = 'AI-Smart-Cleaner-Daily'
    $time = $timePicker.Value.TimeOfDay
    
    $action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument "-NoProfile -File '$PSScriptRoot\AI-Cleaner.ps1' -SafeMode"
    $trigger = New-ScheduledTaskTrigger -Daily -At $time
    $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
    
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Force
    $lblScheduleStatus.Text = "Scheduled Daily at $time"
})

$btnUnschedule.Add_Click({
    Unregister-ScheduledTask -TaskName 'AI-Smart-Cleaner-Daily' -Confirm:$false
    $lblScheduleStatus.Text = 'Not Scheduled'
})

# LOAD HISTORY FROM LOGS (simple)
$historyLogs = Get-ChildItem "$env:TEMP\ai-cleaner-logs" -Filter '*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 10
foreach ($log in $historyLogs) {
    # Parse simple history...
}

# PERFECT THEME & LAUNCH