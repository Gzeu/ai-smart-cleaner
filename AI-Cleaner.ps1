#Requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type -AssemblyName System.Drawing -ErrorAction Stop

[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)
[System.Windows.Forms.Application]::EnableVisualStyles()

$config = [ordered]@{
    GeminiKey   = $env:GEMINI_API_KEY ?? ""
    SafeMode    = $true
    CacheClean  = $true
    TempClean   = $true
    PythonClean = $false
    LogsClean   = $true
}

function Format-Size {
    param([long]$Size)
    if ($Size -eq 0) { return '0 B' }
    $units = 'B','KiB','MiB','GiB','TiB'
    $i = 0
    while ($Size -ge 1024 -and $i -lt 4) { $Size /= 1024; $i++ }
    return "{0:N1} {1}" -f $Size, $units[$i]
}

function Get-FolderSizesAsync {
    param (
        [Parameter(Mandatory)] [string] $RootPath,
        [System.Windows.Forms.ToolStripProgressBar] $ProgressBar = $null,
        [System.Windows.Forms.Label] $StatusLabel = $null
    )

    $categories = @{
        Temp    = 0L
        Cache   = 0L
        Python  = 0L
        Logs    = 0L
        Other   = 0L
    }

    $folders = Get-ChildItem -Path $RootPath -Directory -ErrorAction SilentlyContinue -Force
    $totalFolders = $folders.Count
    $processed = 0

    $folders | ForEach-Object -Parallel {
        $path = $_.FullName
        $size = 0L
        try {
            $size = (Get-ChildItem -Path $path -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            if ($null -eq $size) { $size = 0L }
        }
        catch { }
        [PSCustomObject]@{ Path = $path; Size = $size }
    } -ThrottleLimit 6 | ForEach-Object {
        $processed++
        if ($ProgressBar) {
            $percent = [math]::Min(100, [math]::Round(($processed / $totalFolders) * 100))
            $ProgressBar.Invoke(({param($p,$val) $p.Value = $val}), $ProgressBar, $percent)
        }
        if ($StatusLabel) {
            $StatusLabel.Invoke(({param($l,$t) $l.Text = $t}), $StatusLabel, "Scanning: $($_.Path -replace '^C:\\\\','')")
        }
        $p = $_.Path.ToLower()
        $s = $_.Size
        if ($s -gt 5MB) {
            switch -Wildcard ($p) {
                '*temp*'     { $categories.Temp   += $s; break }
                '*cache*'    { $categories.Cache  += $s; break }
                '*__pycache__*','*.pyc','*.pyo','*venv*' { $categories.Python += $s; break }
                '*log*'      { $categories.Logs   += $s; break }
                default      { $categories.Other  += $s }
            }
        }
    }
    if ($ProgressBar) { $ProgressBar.Value = 100 }
    if ($StatusLabel) { $StatusLabel.Text = "Scan finished." }
    return $categories
}

$form = New-Object System.Windows.Forms.Form -Property @{
    Text            = "🧹 AI SMART CLEANER v6.1 ─ Advanced + Responsive"
    Size            = New-Object System.Drawing.Size(1480,920)
    StartPosition   = "CenterScreen"
    FormBorderStyle = "FixedDialog"
    BackColor       = [System.Drawing.Color]::FromArgb(28,28,36)
    Font            = New-Object System.Drawing.Font("Segoe UI",10)
    MaximizeBox     = $false
}

$tabs = New-Object System.Windows.Forms.TabControl -Property @{
    Size     = New-Object System.Drawing.Size(1440,840)
    Location = New-Object System.Drawing.Point(20,20)
}

$tabSettings = New-Object System.Windows.Forms.TabPage -Property @{
    Text      = "  ⚙️  Settings  "
    BackColor = [System.Drawing.Color]::FromArgb(36,36,44)
}

$gbAI = New-Object System.Windows.Forms.GroupBox -Property @{
    Text      = "🤖 Gemini AI Integration"
    Size      = New-Object System.Drawing.Size(520,140)
    Location  = New-Object System.Drawing.Point(20,20)
    ForeColor = [System.Drawing.Color]::Cyan
}
$lblKey = New-Object System.Windows.Forms.Label -Property @{
    Text = "API Key:", Location = New-Object System.Drawing.Point(12,36), Size = New-Object System.Drawing.Size(70,24), ForeColor = 'White'
}
$tbKey = New-Object System.Windows.Forms.TextBox -Property @{
    Size = New-Object System.Drawing.Size(340,24), Location = New-Object System.Drawing.Point(90,34), UseSystemPasswordChar = $true, Text = $config.GeminiKey
}
$btnTest = New-Object System.Windows.Forms.Button -Property @{
    Text = "Test", Size = New-Object System.Drawing.Size(70,30), Location = New-Object System.Drawing.Point(440,33),
    BackColor = [System.Drawing.Color]::FromArgb(0,120,220), ForeColor = 'White', FlatStyle = 'Flat'
}
$gbAI.Controls.AddRange(@($lblKey,$tbKey,$btnTest))

$gbCategories = New-Object System.Windows.Forms.GroupBox -Property @{
    Text      = "🧹 What to clean"
    Size      = New-Object System.Drawing.Size(520,220)
    Location  = New-Object System.Drawing.Point(20,180)
    ForeColor = [System.Drawing.Color]::LimeGreen
}

$checks = @()
@(
    @{Text="💾 Browser Cache (Chrome/Edge/Firefox)"; Checked=$config.CacheClean;  Name="chkCache"},
    @{Text="📄 Windows Temp + Prefetch"; Checked=$config.TempClean;   Name="chkTemp"},
    @{Text="🐍 Python Cache (__pycache__, .pyc)"; Checked=$config.PythonClean; Name="chkPython"},
    @{Text="📝 Old Log Files (>30 days)"; Checked=$config.LogsClean;   Name="chkLogs"}
) | ForEach-Object {
    $chk = New-Object System.Windows.Forms.CheckBox -Property @{
        Text = $_.Text, Checked = $_.Checked, Size = New-Object System.Drawing.Size(480,28),
        Location = New-Object System.Drawing.Point(16, 30 + (32*$checks.Count)), ForeColor = 'White'
    }
    $chk.Name = $_.Name
    $gbCategories.Controls.Add($chk)
    $checks += $chk
}

$btnSave = New-Object System.Windows.Forms.Button -Property @{
    Text = "💾  SAVE CONFIG", Size = New-Object System.Drawing.Size(180,50),
    Location = New-Object System.Drawing.Point(20,430), BackColor = [System.Drawing.Color]::FromArgb(40,167,69),
    ForeColor = 'White', FlatStyle = 'Flat', Font = New-Object System.Drawing.Font("Segoe UI",11,[System.Drawing.FontStyle]::Bold)
}

$btnScan = New-Object System.Windows.Forms.Button -Property @{
    Text = "🔎  DEEP SCAN C:\\", Size = New-Object System.Drawing.Size(180,50),
    Location = New-Object System.Drawing.Point(220,430), BackColor = [System.Drawing.Color]::FromArgb(255,193,7),
    ForeColor = 'Black', FlatStyle = 'Flat', Font = New-Object System.Drawing.Font("Segoe UI",11,[System.Drawing.FontStyle]::Bold)
}

$tabSettings.Controls.AddRange(@($gbAI, $gbCategories, $btnSave, $btnScan))

$tabResults = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "  📋  Scan Results  ", BackColor = [System.Drawing.Color]::FromArgb(36,36,44)
}

$lblStatus = New-Object System.Windows.Forms.Label -Property @{
    Text = "Ready...", AutoSize = $true, Location = New-Object System.Drawing.Point(20,12),
    ForeColor = [System.Drawing.Color]::LightGray, Font = New-Object System.Drawing.Font("Segoe UI",10)
}

$pbScan = New-Object System.Windows.Forms.ProgressBar -Property @{
    Style = 'Continuous', Size = New-Object System.Drawing.Size(1380,24),
    Location = New-Object System.Drawing.Point(20,40), Visible = $false
}

$rtbLog = New-Object System.Windows.Forms.RichTextBox -Property @{
    Size = New-Object System.Drawing.Size(1380,680), Location = New-Object System.Drawing.Point(20,74),
    BackColor = [System.Drawing.Color]::FromArgb(20,20,26), ForeColor = [System.Drawing.Color]::FromArgb(180,255,180),
    Font = New-Object System.Drawing.Font("Consolas",10.2), ReadOnly = $true, WordWrap = $false
}

$tabResults.Controls.AddRange(@($lblStatus, $pbScan, $rtbLog))
$tabs.TabPages.AddRange(@($tabSettings, $tabResults))
$form.Controls.Add($tabs)

$worker = New-Object System.ComponentModel.BackgroundWorker -Property @{
    WorkerReportsProgress = $true
    WorkerSupportsCancellation = $true
}

$worker.add_DoWork({
    param($sender, $e)
    $result = Get-FolderSizesAsync -RootPath "C:\\" -ProgressBar $pbScan -StatusLabel $lblStatus
    $e.Result = $result
})

$worker.add_RunWorkerCompleted({
    param($sender, $e)
    $pbScan.Visible = $false
    $btnScan.Enabled = $true
    if ($e.Error) {
        $rtbLog.SelectionColor = [System.Drawing.Color]::OrangeRed
        $rtbLog.AppendText("ERROR: $($e.Error.Message)\n\n")
        return
    }
    $sizes = $e.Result
    $rtbLog.Clear()
    $rtbLog.SelectionColor = [System.Drawing.Color]::Cyan
    $rtbLog.AppendText("══════════ C:\\ SCAN RESULTS ══════════\n\n")
    $total = 0L
    foreach ($k in $sizes.Keys) {
        $sizeStr = Format-Size $sizes[$k]
        $total += $sizes[$k]
        $rtbLog.AppendText("  $k`t`t $sizeStr\n")
    }
    $rtbLog.AppendText("\n")
    $rtbLog.SelectionColor = [System.Drawing.Color]::Gold
    $rtbLog.AppendText("TOTAL CLEANABLE: $(Format-Size $total)\n\n")
    $rtbLog.SelectionColor = [System.Drawing.Color]::FromArgb(180,255,180)
    $rtbLog.AppendText("Finished: $(Get-Date -Format 'HH:mm:ss')")
})

$btnScan.Add_Click({
    if ($worker.IsBusy) { return }
    $btnScan.Enabled = $false
    $pbScan.Value = 0
    $pbScan.Visible = $true
    $rtbLog.Clear()
    $rtbLog.AppendText("Starting deep C:\\ scan (may take minutes)...\n\n")
    $tabs.SelectedTab = $tabResults
    $worker.RunWorkerAsync()
})

$btnSave.Add_Click({
    $config.GeminiKey   = $tbKey.Text
    $config.CacheClean  = $checks[0].Checked
    $config.TempClean   = $checks[1].Checked
    $config.PythonClean = $checks[2].Checked
    $config.LogsClean   = $checks[3].Checked
    [System.Windows.Forms.MessageBox]::Show("Config saved!", "Success", 0, 64)
})

$btnTest.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("API test - coming soon!", "Info", 0, 64)
})

$form.ShowDialog() | Out-Null
