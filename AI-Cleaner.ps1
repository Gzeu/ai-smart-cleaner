#Requires -Version 7.0
Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type -AssemblyName System.Drawing -ErrorAction Stop

[System.Windows.Forms.Application]::EnableVisualStyles()

# Fixed ThemeManager with proper scriptblock invocation
$ThemeColors = @{
    Light = @{ Back = [System.Drawing.Color]::FromArgb(248,249,250); Fore = [System.Drawing.Color]::FromArgb(33,37,41); Accent = [System.Drawing.Color]::FromArgb(0,123,255) }
    Dark = @{ Back = [System.Drawing.Color]::FromArgb(30,30,30); Fore = [System.Drawing.Color]::FromArgb(212,212,212); Accent = [System.Drawing.Color]::FromArgb(13,110,253) }
}

function Set-Theme {
    param($Control, $Theme = 'Dark')
    $colors = $ThemeColors[$Theme]
    $Control.BackColor = $colors.Back
    $Control.ForeColor = $colors.Fore
    foreach ($child in $Control.Controls) { Set-Theme $child $Theme }
}

function Format-Size {
    param([long]$Size)
    if ($Size -eq 0) { return '0 B' }
    $units = 'B','KiB','MiB','GiB','TiB'
    $i = 0
    $s = [double]$Size
    while ($s -ge 1024 -and $i -lt 4) { $s /= 1024; $i++ }
    return "{0:N1} {1}" -f $s, $units[$i]
}

function Scan-Directories {
    param($Paths, $MaxJobs = 4)
    $jobs = @(); $queue = New-Object System.Collections.Queue
    $queue.EnqueueRange($Paths)
    
    while ($queue.Count -gt 0 -or $jobs.Count -gt 0) {
        while ($jobs.Count -lt $MaxJobs -and $queue.Count -gt 0) {
            $path = $queue.Dequeue()
            if (Test-Path $path) {
                $jobs += Start-Job -ScriptBlock {
                    param($p)
                    $total = 0L; $count = 0
                    try {
                        Get-ChildItem $p -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                            $total += $_.Length; $count++
                        }
                    } catch { }
                    [PSCustomObject]@{Path=$p; Size=$total; Files=$count}
                } -ArgumentList $path
            }
        }
        $done = $jobs | Where-Object { $_.State -eq 'Completed' }
        $results += $done | Receive-Job
        $done | Remove-Job
        $jobs = $jobs | Where-Object { $_.State -ne 'Completed' }
        Start-Sleep -Milliseconds 100
    }
    return $results
}

function Get-CleanupTargets {
    return @{
        Temp = @(
            "$env:TEMP",
            "$env:WINDIR\Temp",
            "$env:LOCALAPPDATA\Temp",
            "$env:USERPROFILE\AppData\Local\Temp"
        )
        Cache = @(
            "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache*",
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache*",
            "$env:LOCALAPPDATA\Packages\*\AC\*\TempState"
        )
        Logs = @(
            "$env:LOCALAPPDATA\Temp\*.log",
            "C:\Windows\Logs\*\*.log"
        )
        Python = @("${env:USERPROFILE}\AppData\Local\Programs\Python\Python*\Lib\site-packages\*__pycache__")
    }
}

function Invoke-Cleanup {
    param($Category, $SafeMode, $Logger, $Progress)
    $targets = (Get-CleanupTargets)[$Category]
    $scan = Scan-Directories $targets
    $totalSize = ($scan | Measure-Object Size -Sum).Sum
    $fileCount = ($scan | Measure-Object Files -Sum).Sum
    
    if (-not $SafeMode) {
        foreach ($item in $scan) {
            Get-ChildItem $item.Path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
        }
    }
    
    $msg = "${Category}: $(Format-Size $totalSize) ($fileCount files)"
    $Logger.SelectionColor = if ($SafeMode) { [System.Drawing.Color]::Yellow } else { [System.Drawing.Color]::Lime }
    $Logger.AppendText("$msg`n")
    $Progress.Value = $Progress.Value + 25
    return @{Size=$totalSize; Files=$fileCount}
}

# === MAIN GUI ===
$form = New-Object System.Windows.Forms.Form @{
    Text = '🧹 AI Smart Cleaner v8.0 - Production Ready'
    Size = '1620,1020'
    StartPosition = 'CenterScreen'
    FormBorderStyle = 'FixedSingle'
    Icon = (New-Object System.Drawing.Icon 'shield.ico' 2>&1 | Out-Null; $null) # Fallback
}

$tabs = New-Object System.Windows.Forms.TabControl @{
    Dock = 'Fill'
    Font = New-Object System.Drawing.Font('Segoe UI Semibold', 11)
}

# Settings Tab
$tab1 = New-Object System.Windows.Forms.TabPage '⚙️ Settings'
New-Object System.Windows.Forms.Label @{
    Parent = $tab1; Text = 'Safe Mode:'; Location = '20,25'; Size = '100,28'; Font = New-Object System.Drawing.Font('Segoe UI',12,'Bold')
}
$chkSafe = New-Object System.Windows.Forms.CheckBox @{
    Parent = $tab1; Checked = $true; Location = '130,27'; Size = '120,24'; ForeColor = 'White'
}
New-Object System.Windows.Forms.Label @{
    Parent = $tab1; Text = 'Theme:'; Location = '20,65'; Size = '60,28'
}
$cmbTheme = New-Object System.Windows.Forms.ComboBox @{
    Parent = $tab1; Location = '85,67'; Size = '100,28'; DropDownStyle = 'DropDownList'
    Items = 'Light','Dark'; SelectedIndex = 1
}
$btnStart = New-Object System.Windows.Forms.Button @{
    Parent = $tab1; Text = '🚀 START FULL CLEANUP'; Size = '280,65'; Location = '20,130'
    BackColor = [System.Drawing.Color]::FromArgb(40,167,69); ForeColor = 'White'
    FlatStyle = 'Flat'; Font = New-Object System.Drawing.Font('Segoe UI',16,'Bold')
}
$pbMain = New-Object System.Windows.Forms.ProgressBar @{
    Parent = $tab1; Style = 'Continuous'; Size = '400,30'; Location = '20,220'; Maximum = 100
}

# Results Tab
$tab2 = New-Object System.Windows.Forms.TabPage '📊 Live Results'
$lblSummary = New-Object System.Windows.Forms.Label @{
    Parent = $tab2; Text = 'Total Freed: 0 B | Files: 0'; Location = '20,20'; Size = '500,40'
    Font = New-Object System.Drawing.Font('Segoe UI',18,'Bold'); ForeColor = [System.Drawing.Color]::Lime
}
$rtbLive = New-Object System.Windows.Forms.RichTextBox @{
    Parent = $tab2; Dock = 'Fill'; Font = New-Object System.Drawing.Font('Consolas',11)
    BackColor = [System.Drawing.Color]::FromArgb(15,15,18); ForeColor = [System.Drawing.Color]::WhiteSmoke
    ReadOnly = $true; WordWrap = $false
}

$tabs.TabPages.AddRange(@($tab1,$tab2))
$form.Controls.Add($tabs)

# Events
$cmbTheme.Add_SelectedIndexChanged({ Set-Theme $form ($cmbTheme.SelectedItem) })
$btnStart.Add_Click({
    $rtbLive.Clear()
    $rtbLive.AppendText("[$(Get-Date)] 🚀 Starting $(if($chkSafe.Checked){'PREVIEW SCAN'}else{'DELETION'})`n`n")
    $pbMain.Value = 0
    
    $totalSize = 0L; $totalFiles = 0
    'Temp','Cache','Logs','Python' | ForEach-Object {
        $res = Invoke-Cleanup $_ $chkSafe.Checked $rtbLive $pbMain
        $totalSize += $res.Size; $totalFiles += $res.Files
    }
    
    $lblSummary.Text = "Total Freed: $(Format-Size $totalSize) | Files: $totalFiles"
    $rtbLive.AppendText("\n✅ Complete! $(Get-Date)")
})

# Initialize Dark Theme
Set-Theme $form 'Dark'

# Show with console integration
Write-Host "🧹 AI Smart Cleaner v8.0 loaded! Press Ctrl+C to exit GUI." -ForegroundColor Green
Write-Host "Gemini CLI: Set \"$env:GEMINI_API_KEY\" for AI scoring (future)" -ForegroundColor Cyan
$form.ShowDialog() | Out-Null
Write-Host "GUI closed." -ForegroundColor Yellow