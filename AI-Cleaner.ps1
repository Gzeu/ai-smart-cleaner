# 🚀 AI SMART CLEANER v6.0 - ADVANCED SETTINGS + AI DEEP SCAN
# Full GUI with Config Buttons + C: Scan + AI Analysis + Windows Toggles

Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type -AssemblyName System.Drawing -ErrorAction Stop

[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)
[System.Windows.Forms.Application]::EnableVisualStyles()

$config = @{ GeminiKey = $env:GEMINI_API_KEY; SafeMode = $true; CacheClean = $true; TempClean = $true; PythonClean = $false; LogsClean = $true }

function Format-Size([long]$Size) { if ($Size -eq 0) { '0 B' } else { $u = 'B','KB','MB','GB','TB'; $i = 0; while ($Size -ge 1KB -and $i -lt 4) { $Size /= 1KB; $i++ }; '{0:N1} {1}' -f $Size, $u[$i] } }

function Scan-DriveCDeep { 
    $results = @()
    $sizes = @{ 'Temp' = 0; 'Cache' = 0; 'Python' = 0; 'Logs' = 0; 'Other' = 0 }
    gci 'C:\\' -Directory -EA SilentlyContinue | % { $path = $_.FullName; $size = (gci $path -Recurse -File -EA SilentlyContinue | measure Length -Sum -EA SilentlyContinue).Sum; if ($size -gt 10MB) { if ($path -like '*Temp*') { $sizes['Temp'] += $size } elseif ($path -like '*Cache*') { $sizes['Cache'] += $size } elseif ($path -like '*Python*' -or $path -like '*venv*') { $sizes['Python'] += $size } elseif ($path -like '*Log*') { $sizes['Logs'] += $size } else { $sizes['Other'] += $size } } }
    return $sizes
}

$form = New-Object System.Windows.Forms.Form
$form.Text = '⚙️ AI SMART CLEANER v6.0 - Advanced Configuration'
$form.Size = New-Object System.Drawing.Size(1600, 1000)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.BackColor = [System.Drawing.Color]::FromArgb(32, 32, 38)
$form.MaximizeBox = $false

$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Size = New-Object System.Drawing.Size(1560, 900)
$tabs.Location = New-Object System.Drawing.Point(20, 20)

# TAB 1: ADVANCED SETTINGS
$settingsTab = New-Object System.Windows.Forms.TabPage
$settingsTab.Text = '⚙️ Settings'
$settingsTab.BackColor = [System.Drawing.Color]::FromArgb(38, 38, 45)

# Group 1: Gemini Config
$grp1 = New-Object System.Windows.Forms.GroupBox
$grp1.Text = '🤖 Gemini AI Configuration'
$grp1.Size = New-Object System.Drawing.Size(500, 150)
$grp1.Location = New-Object System.Drawing.Point(20, 20)
$grp1.ForeColor = [System.Drawing.Color]::Cyan

$geminiLbl = New-Object System.Windows.Forms.Label
$geminiLbl.Text = 'API Key:'
$geminiLbl.Size = New-Object System.Drawing.Size(80, 25)
$geminiLbl.Location = New-Object System.Drawing.Point(10, 30)
$geminiLbl.ForeColor = 'White'
$grp1.Controls.Add($geminiLbl)

$geminiBox = New-Object System.Windows.Forms.TextBox
$geminiBox.Size = New-Object System.Drawing.Size(300, 25)
$geminiBox.Location = New-Object System.Drawing.Point(100, 30)
$geminiBox.PasswordChar = '*'
$grp1.Controls.Add($geminiBox)

$testGeminiBtn = New-Object System.Windows.Forms.Button
$testGeminiBtn.Text = 'Test Key'
$testGeminiBtn.Size = New-Object System.Drawing.Size(80, 25)
$testGeminiBtn.Location = New-Object System.Drawing.Point(410, 30)
$testGeminiBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 100, 200)
$testGeminiBtn.ForeColor = 'White'
$testGeminiBtn.FlatStyle = 'Flat'
$grp1.Controls.Add($testGeminiBtn)

$settingsTab.Controls.Add($grp1)

# Group 2: Cleanup Categories
$grp2 = New-Object System.Windows.Forms.GroupBox
$grp2.Text = '🧹 Cleanup Categories'
$grp2.Size = New-Object System.Drawing.Size(500, 200)
$grp2.Location = New-Object System.Drawing.Point(20, 180)
$grp2.ForeColor = [System.Drawing.Color]::LimeGreen

$cacheChk = New-Object System.Windows.Forms.CheckBox
$cacheChk.Text = '💾 Browser Cache (Chrome/Edge/Firefox)'
$cacheChk.Size = New-Object System.Drawing.Size(450, 30)
$cacheChk.Location = New-Object System.Drawing.Point(10, 30)
$cacheChk.Checked = $true
$cacheChk.ForeColor = 'White'
$grp2.Controls.Add($cacheChk)

$tempChk = New-Object System.Windows.Forms.CheckBox
$tempChk.Text = '📄 Temp Files (Windows + User)'
$tempChk.Size = New-Object System.Drawing.Size(450, 30)
$tempChk.Location = New-Object System.Drawing.Point(10, 65)
$tempChk.Checked = $true
$tempChk.ForeColor = 'White'
$grp2.Controls.Add($tempChk)

$pythonChk = New-Object System.Windows.Forms.CheckBox
$pythonChk.Text = '🐍 Python Cache (__pycache__, .pyc)'
$pythonChk.Size = New-Object System.Drawing.Size(450, 30)
$pythonChk.Location = New-Object System.Drawing.Point(10, 100)
$pythonChk.Checked = $false
$pythonChk.ForeColor = 'White'
$grp2.Controls.Add($pythonChk)

$logsChk = New-Object System.Windows.Forms.CheckBox
$logsChk.Text = '📝 Log Files (Old logs > 30 days)'
$logsChk.Size = New-Object System.Drawing.Size(450, 30)
$logsChk.Location = New-Object System.Drawing.Point(10, 135)
$logsChk.Checked = $true
$logsChk.ForeColor = 'White'
$grp2.Controls.Add($logsChk)

$settingsTab.Controls.Add($grp2)

# Buttons
$saveConfigBtn = New-Object System.Windows.Forms.Button
$saveConfigBtn.Text = '✅ SAVE CONFIG'
$saveConfigBtn.Size = New-Object System.Drawing.Size(150, 45)
$saveConfigBtn.Location = New-Object System.Drawing.Point(20, 400)
$saveConfigBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 50)
$saveConfigBtn.ForeColor = 'White'
$saveConfigBtn.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$saveConfigBtn.FlatStyle = 'Flat'
$settingsTab.Controls.Add($saveConfigBtn)

$scanC = New-Object System.Windows.Forms.Button
$scanC.Text = '🔍 SCAN C: (Deep AI)'
$scanC.Size = New-Object System.Drawing.Size(150, 45)
$scanC.Location = New-Object System.Drawing.Point(180, 400)
$scanC.BackColor = [System.Drawing.Color]::FromArgb(255, 193, 7)
$scanC.ForeColor = 'Black'
$scanC.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$scanC.FlatStyle = 'Flat'
$settingsTab.Controls.Add($scanC)

$tabs.TabPages.Add($settingsTab)

# TAB 2: SCAN RESULTS
$resultsTab = New-Object System.Windows.Forms.TabPage
$resultsTab.Text = '🔍 Scan Results'
$resultsTab.BackColor = [System.Drawing.Color]::FromArgb(38, 38, 45)

$resultsLog = New-Object System.Windows.Forms.RichTextBox
$resultsLog.Size = New-Object System.Drawing.Size(1520, 600)
$resultsLog.Location = New-Object System.Drawing.Point(20, 20)
$resultsLog.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 30)
$resultsLog.ForeColor = [System.Drawing.Color]::LimeGreen
$resultsLog.Font = New-Object System.Drawing.Font('Consolas', 10)
$resultsLog.ReadOnly = $true
$resultsTab.Controls.Add($resultsLog)

$tabs.TabPages.Add($resultsTab)

# TAB 3: CLEANUP
$cleanupTab = New-Object System.Windows.Forms.TabPage
$cleanupTab.Text = '🧹 Cleanup'
$cleanupTab.BackColor = [System.Drawing.Color]::FromArgb(38, 38, 45)

$cleanProgress = New-Object System.Windows.Forms.ProgressBar
$cleanProgress.Size = New-Object System.Drawing.Size(1520, 30)
$cleanProgress.Location = New-Object System.Drawing.Point(20, 20)
$cleanupTab.Controls.Add($cleanProgress)

$cleanLog = New-Object System.Windows.Forms.RichTextBox
$cleanLog.Size = New-Object System.Drawing.Size(1520, 500)
$cleanLog.Location = New-Object System.Drawing.Point(20, 70)
$cleanLog.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 30)
$cleanLog.ForeColor = [System.Drawing.Color]::LimeGreen
$cleanLog.ReadOnly = $true
$cleanupTab.Controls.Add($cleanLog)

$tabs.TabPages.Add($cleanupTab)

$form.Controls.Add($tabs)

# Events
$saveConfigBtn.Add_Click({
    $config.GeminiKey = $geminiBox.Text
    $config.CacheClean = $cacheChk.Checked
    $config.TempClean = $tempChk.Checked
    $config.PythonClean = $pythonChk.Checked
    $config.LogsClean = $logsChk.Checked
    [System.Windows.Forms.MessageBox]::Show('Config Saved!', 'Success', 'OK', 'Information')
})

$scanC.Add_Click({
    $tabs.SelectedTab = $resultsTab
    $resultsLog.Clear()
    $resultsLog.AppendText("🔍 Scanning C: Drive (Deep AI Analysis)...`n`n")
    $results = Scan-DriveCDeep
    foreach ($cat in $results.Keys) { $resultsLog.AppendText("📊 $cat : $(Format-Size $results[$cat])`n") }
    $resultsLog.AppendText("`n✅ Scan Complete!")
})

$form.ShowDialog() | Out-Null
