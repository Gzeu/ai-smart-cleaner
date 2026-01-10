#Requires -Version 7.0
Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type -AssemblyName System.Drawing -ErrorAction Stop
[System.Windows.Forms.Application]::EnableVisualStyles()

# Theme Colors
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
    $jobs = @()
    $results = @()
    $queue = New-Object System.Collections.Queue
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
        Temp = @("$env:TEMP", "$env:WINDIR\Temp", "$env:LOCALAPPDATA\Temp")
        Cache = @("$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache", "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache")
        Logs = @("$env:LOCALAPPDATA\Temp\*.log", "C:\Windows\Logs\*\*.log")
    }
}

function Invoke-Cleanup {
    param($Category, $SafeMode, $Logger, $Progress)
    $targets = (Get-CleanupTargets)[$Category]
    $scan = Scan-Directories $targets
    $totalSize = if ($scan) { ($scan | Measure-Object Size -Sum).Sum } else { 0L }
    $fileCount = if ($scan) { ($scan | Measure-Object Files -Sum).Sum } else { 0 }
    
    if (-not $SafeMode) {
        foreach ($item in $scan) {
            Get-ChildItem $item.Path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    $msg = "✓ ${Category}: $(Format-Size $totalSize) ($fileCount files)"
    $Logger.SelectionColor = if ($SafeMode) { [System.Drawing.Color]::Yellow } else { [System.Drawing.Color]::Lime }
    $Logger.AppendText("$msg`n")
    $Progress.Value = [Math]::Min($Progress.Value + 25, 100)
    return @{Size=$totalSize; Files=$fileCount}
}

# === CREATE FORM - PROPER SYNTAX ===
$form = New-Object System.Windows.Forms.Form
$form.Text = '🧹 AI Smart Cleaner v9.0 - Gemini Ready'
$form.Size = New-Object System.Drawing.Size(1620, 1020)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedSingle'

$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Dock = 'Fill'
$tabs.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)

# Tab 1 - Settings
$tab1 = New-Object System.Windows.Forms.TabPage
$tab1.Text = '⚙️ Settings'
$tab1.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
$tab1.ForeColor = [System.Drawing.Color]::White

$lblSafe = New-Object System.Windows.Forms.Label
$lblSafe.Text = 'Safe Mode:'
$lblSafe.Location = New-Object System.Drawing.Point(20, 25)
$lblSafe.Size = New-Object System.Drawing.Size(100, 28)
$lblSafe.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$tab1.Controls.Add($lblSafe)

$chkSafe = New-Object System.Windows.Forms.CheckBox
$chkSafe.Checked = $true
$chkSafe.Location = New-Object System.Drawing.Point(130, 27)
$chkSafe.Size = New-Object System.Drawing.Size(120, 24)
$chkSafe.ForeColor = 'White'
$tab1.Controls.Add($chkSafe)

$lblGemini = New-Object System.Windows.Forms.Label
$lblGemini.Text = 'Gemini API:'
$lblGemini.Location = New-Object System.Drawing.Point(20, 105)
$lblGemini.Size = New-Object System.Drawing.Size(100, 28)
$tab1.Controls.Add($lblGemini)

$txtGemini = New-Object System.Windows.Forms.TextBox
$txtGemini.Location = New-Object System.Drawing.Point(130, 107)
$txtGemini.Size = New-Object System.Drawing.Size(250, 28)
$txtGemini.Text = [Environment]::GetEnvironmentVariable('GEMINI_API_KEY') ?? ''
$tab1.Controls.Add($txtGemini)

$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Text = '🚀 START CLEANUP'
$btnStart.Size = New-Object System.Drawing.Size(280, 65)
$btnStart.Location = New-Object System.Drawing.Point(20, 150)
$btnStart.BackColor = [System.Drawing.Color]::FromArgb(40,167,69)
$btnStart.ForeColor = 'White'
$btnStart.FlatStyle = 'Flat'
$btnStart.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$tab1.Controls.Add($btnStart)

$pbMain = New-Object System.Windows.Forms.ProgressBar
$pbMain.Size = New-Object System.Drawing.Size(400, 30)
$pbMain.Location = New-Object System.Drawing.Point(20, 230)
$pbMain.Maximum = 100
$tab1.Controls.Add($pbMain)

# Tab 2 - Results
$tab2 = New-Object System.Windows.Forms.TabPage
$tab2.Text = '📊 Results'
$tab2.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)

$lblSummary = New-Object System.Windows.Forms.Label
$lblSummary.Text = 'Total Freed: 0 B | Files: 0'
$lblSummary.Location = New-Object System.Drawing.Point(20, 20)
$lblSummary.Size = New-Object System.Drawing.Size(500, 40)
$lblSummary.Font = New-Object System.Drawing.Font('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
$lblSummary.ForeColor = [System.Drawing.Color]::Lime
$tab2.Controls.Add($lblSummary)

$rtbLive = New-Object System.Windows.Forms.RichTextBox
$rtbLive.Dock = 'Fill'
$rtbLive.Font = New-Object System.Drawing.Font('Consolas', 11)
$rtbLive.BackColor = [System.Drawing.Color]::FromArgb(15,15,18)
$rtbLive.ForeColor = [System.Drawing.Color]::WhiteSmoke
$rtbLive.ReadOnly = $true
$rtbLive.WordWrap = $false
$tab2.Controls.Add($rtbLive)

$tabs.TabPages.Add($tab1)
$tabs.TabPages.Add($tab2)
$form.Controls.Add($tabs)

# Event Handler
$btnStart.Add_Click({
    if ($txtGemini.Text) {
        [Environment]::SetEnvironmentVariable('GEMINI_API_KEY', $txtGemini.Text)
        $env:GEMINI_API_KEY = $txtGemini.Text
    }
    $rtbLive.Clear()
    $rtbLive.AppendText("[$(Get-Date -Format 'HH:mm:ss')] 🚀 Starting $(if($chkSafe.Checked){'PREVIEW'}else{'DELETION'})`n`n")
    $pbMain.Value = 0
    $totalSize = 0L
    $totalFiles = 0
    'Temp','Cache','Logs' | ForEach-Object {
        $res = Invoke-Cleanup $_ $chkSafe.Checked $rtbLive $pbMain
        $totalSize += $res.Size
        $totalFiles += $res.Files
    }
    $lblSummary.Text = "Total Freed: $(Format-Size $totalSize) | Files: $totalFiles"
    $rtbLive.AppendText("`n✅ Complete! $(Get-Date -Format 'HH:mm:ss')")
})

Set-Theme $form 'Dark'
Write-Host '🧹 AI Smart Cleaner v9.0 - FIXED & OPERATIONAL' -ForegroundColor Green
Write-Host "Gemini API: $(if([Environment]::GetEnvironmentVariable('GEMINI_API_KEY')){'CONFIGURED'}else{'NOT SET'})" -ForegroundColor Cyan
$form.ShowDialog() | Out-Null
Write-Host 'Application closed.' -ForegroundColor Yellow
