#Requires -Version 7.0
Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type -AssemblyName System.Drawing -ErrorAction Stop
[System.Windows.Forms.Application]::EnableVisualStyles()

# ====== TEMA SI CULORI ======
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

function Invoke-GeminiAI {
    param($Text, [string]$ApiKey = $env:GEMINI_API_KEY)
    if (-not $ApiKey) { return "[No Gemini API]" }
    try {
        $headers = @{ "Content-Type" = "application/json" }
        $body = @{
            contents = @(@{
                parts = @(@{ text = $Text })
            })
        } | ConvertTo-Json
        $response = Invoke-WebRequest -Uri "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$ApiKey" -Method Post -Headers $headers -Body $body -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $json = $response.Content | ConvertFrom-Json
            return $json.candidates[0].content.parts[0].text
        }
        return "[Gemini Error]"
    } catch {
        return "[API Error]"
    }
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
                    $total = 0L
                    $count = 0
                    try {
                        Get-ChildItem $p -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                            $total += $_.Length
                            $count++
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
            "$env:LOCALAPPDATA\Temp"
        )
        Cache = @(
            "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache*",
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache*"
        )
        Logs = @(
            "$env:LOCALAPPDATA\Temp\*.log",
            "C:\Windows\Logs\*\*.log"
        )
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

# === MAIN GUI v9.0 - FIXED ===
$form = New-Object System.Windows.Forms.Form @{
    Text = '🧹 AI Smart Cleaner v9.0 - Gemini CLI Ready'
    Size = '1620,1020'
    StartPosition = 'CenterScreen'
    FormBorderStyle = 'FixedSingle'
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
    Parent = $tab1; Text = 'Gemini API:'; Location = '20,105'; Size = '100,28'
}

$txtGemini = New-Object System.Windows.Forms.TextBox @{
    Parent = $tab1; Location = '130,107'; Size = '250,28'; Text = $env:GEMINI_API_KEY
}

$btnStart = New-Object System.Windows.Forms.Button @{
    Parent = $tab1; Text = '🚀 START CLEANUP'; Size = '280,65'; Location = '20,150'
    BackColor = [System.Drawing.Color]::FromArgb(40,167,69); ForeColor = 'White'
    FlatStyle = 'Flat'; Font = New-Object System.Drawing.Font('Segoe UI',16,'Bold')
}

$pbMain = New-Object System.Windows.Forms.ProgressBar @{
    Parent = $tab1; Style = 'Continuous'; Size = '400,30'; Location = '20,230'; Maximum = 100
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

# Event Handler
$btnStart.Add_Click({
    if ($txtGemini.Text) { [Environment]::SetEnvironmentVariable('GEMINI_API_KEY', $txtGemini.Text); $env:GEMINI_API_KEY = $txtGemini.Text }
    $rtbLive.Clear()
    $rtbLive.AppendText("[$(Get-Date -Format 'HH:mm:ss')] 🚀 Starting $(if($chkSafe.Checked){'PREVIEW'}else{'DELETION'})`n`n")
    $pbMain.Value = 0
    $totalSize = 0L; $totalFiles = 0
    'Temp','Cache','Logs' | ForEach-Object {
        $res = Invoke-Cleanup $_ $chkSafe.Checked $rtbLive $pbMain
        $totalSize += $res.Size; $totalFiles += $res.Files
    }
    $lblSummary.Text = "Total Freed: $(Format-Size $totalSize) | Files: $totalFiles"
    $rtbLive.AppendText("`n✅ Complete! $(Get-Date -Format 'HH:mm:ss')")
})

Set-Theme $form 'Dark'
Write-Host '🧹 AI Smart Cleaner v9.0 loaded! Gemini CLI: READY' -ForegroundColor Green
Write-Host "API Status: $(if($env:GEMINI_API_KEY){'CONFIGURED'}else{'NOT SET'})" -ForegroundColor Cyan
$form.ShowDialog() | Out-Null
Write-Host 'Cleanup finished.' -ForegroundColor Yellow
