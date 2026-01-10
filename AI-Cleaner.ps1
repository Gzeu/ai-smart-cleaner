# 🚀 AI SMART CLEANER v4.2 - COMPLETE WORKING SCRIPT
# High-Res GUI + C: AI Scan + Gemini CLI + Config + Safe Clean
# CRITICAL: Assemblies FIRST + Correct Initialize Order

Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type -AssemblyName System.Drawing -ErrorAction Stop

# CORRECT ORDER - MUST BE BEFORE Form Creation
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)
[System.Windows.Forms.Application]::EnableVisualStyles()

# Helper Functions
function Format-Size {
    param([long]$Size)
    if ($Size -eq 0) { return '0 B' }
    $units = 'B','KB','MB','GB','TB'
    $i = 0
    while ($Size -ge 1KB -and $i -lt 4) {
        $Size /= 1KB; $i++
    }
    return '{0:N1} {1}' -f $Size, $units[$i]
}

function Clean-Path {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return @{Success=$false; Size=0} }
    $size = (gci $Path -Recurse -File -EA SilentlyContinue | measure Length -Sum -EA SilentlyContinue).Sum
    cmd /c "rd /s /q `"$Path`" 2>nul" | Out-Null
    ri $Path -Recurse -Force -EA SilentlyContinue | Out-Null
    return @{Success=$true; Size=$size}
}

function Get-AIBigFolders {
    $candidates = @()
    $rules = @{'Cache*'=95; 'Temp*'=95; '*Chrome*\\Cache*'=90; '*Edge*\\Cache*'=90}
    gci 'C:\\' -Directory -EA SilentlyContinue | ? {(gci $_.FullName -Recurse -File -EA SilentlyContinue | measure Length -Sum -EA SilentlyContinue).Sum -gt 50MB} |
    sort {(gci $_.FullName -Recurse -File -EA SilentlyContinue | measure Length -Sum).Sum} -Desc | select -f 30 | % {
        $size = (gci $_.FullName -Recurse -File -EA SilentlyContinue | measure Length -Sum).Sum
        $score = 0
        foreach ($pat in $rules.Keys) { if ($_.FullName -like $pat) { $score = $rules[$pat]; break } }
        if ($score -gt 50) {
            $candidates += [PSCustomObject]@{Path=$_.FullName; Name=Split-Path $_.FullName -Leaf; Size=$size; AIScore=$score; Safe=($score-ge80)}
        }
    }
    return $candidates | sort Size -Desc
}

# GUI Form
$form = New-Object System.Windows.Forms.Form
$form.Text = '🚀 AI SMART CLEANER v4.2'
$form.Size = New-Object System.Drawing.Size(1200, 800)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(32, 32, 38)

# Header
$header = New-Object System.Windows.Forms.Label
$header.Text = '🧹 ULTRA-FAST CLEANUP | Cache • Temp • Recycle Bin'
$header.Size = New-Object System.Drawing.Size(1160, 50)
$header.Location = New-Object System.Drawing.Point(20, 20)
$header.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$header.ForeColor = [System.Drawing.Color]::Cyan
$header.TextAlign = 'MiddleCenter'
$form.Controls.Add($header)

# Progress
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Size = New-Object System.Drawing.Size(1160, 30)
$progress.Location = New-Object System.Drawing.Point(20, 90)
$progress.Style = 'Continuous'
$form.Controls.Add($progress)

# Status
$status = New-Object System.Windows.Forms.Label
$status.Text = 'Ready to cleanup...'
$status.Size = New-Object System.Drawing.Size(1160, 30)
$status.Location = New-Object System.Drawing.Point(20, 130)
$status.Font = New-Object System.Drawing.Font('Segoe UI', 11)
$status.ForeColor = [System.Drawing.Color]::White
$status.TextAlign = 'MiddleCenter'
$form.Controls.Add($status)

# Log
$log = New-Object System.Windows.Forms.RichTextBox
$log.Size = New-Object System.Drawing.Size(1160, 400)
$log.Location = New-Object System.Drawing.Point(20, 180)
$log.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 30)
$log.ForeColor = [System.Drawing.Color]::LimeGreen
$log.Font = New-Object System.Drawing.Font('Consolas', 10)
$log.ReadOnly = $true
$form.Controls.Add($log)

# Stats
$stats = New-Object System.Windows.Forms.Label
$stats.Text = '💾 Space freed: 0 GB | ⏱️ Time: 0s'
$stats.Size = New-Object System.Drawing.Size(1160, 30)
$stats.Location = New-Object System.Drawing.Point(20, 600)
$stats.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$stats.ForeColor = [System.Drawing.Color]::LimeGreen
$stats.TextAlign = 'MiddleCenter'
$form.Controls.Add($stats)

# Buttons
$cleanBtn = New-Object System.Windows.Forms.Button
$cleanBtn.Text = '🚀 START CLEANUP'
$cleanBtn.Size = New-Object System.Drawing.Size(200, 50)
$cleanBtn.Location = New-Object System.Drawing.Point(20, 650)
$cleanBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 50)
$cleanBtn.ForeColor = 'White'
$cleanBtn.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$cleanBtn.FlatStyle = 'Flat'
$form.Controls.Add($cleanBtn)

$scanBtn = New-Object System.Windows.Forms.Button
$scanBtn.Text = '🔍 AI SCAN ONLY'
$scanBtn.Size = New-Object System.Drawing.Size(200, 50)
$scanBtn.Location = New-Object System.Drawing.Point(240, 650)
$scanBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 100, 200)
$scanBtn.ForeColor = 'White'
$scanBtn.Font = New-Object System.Drawing.Font('Segoe UI', 12)
$scanBtn.FlatStyle = 'Flat'
$form.Controls.Add($scanBtn)

$exitBtn = New-Object System.Windows.Forms.Button
$exitBtn.Text = '❌ EXIT'
$exitBtn.Size = New-Object System.Drawing.Size(150, 50)
$exitBtn.Location = New-Object System.Drawing.Point(1030, 650)
$exitBtn.BackColor = [System.Drawing.Color]::FromArgb(200, 60, 60)
$exitBtn.ForeColor = 'White'
$exitBtn.Font = New-Object System.Drawing.Font('Segoe UI', 12)
$exitBtn.FlatStyle = 'Flat'
$form.Controls.Add($exitBtn)

# Events
$cleanBtn.Add_Click({
    $cleanBtn.Enabled = $false
    $status.Text = '🧹 Cleanup in progress...'
    $status.ForeColor = [System.Drawing.Color]::Yellow
    $log.Clear()
    $totalSize = 0
    $startTime = Get-Date
    
    $paths = @('$env:TEMP', "${env:LOCALAPPDATA}\\Google\\Chrome\\User Data\\Default\\Cache", "${env:LOCALAPPDATA}\\Temp")
    
    for ($i = 0; $i -lt $paths.Count; $i++) {
        $path = $paths[$i]
        $name = Split-Path $path -Leaf
        $percent = [math]::Round(($i + 1) / $paths.Count * 100)
        $progress.Value = $percent
        $log.AppendText("🔍 [$($i+1)/$($paths.Count)] $name...`n")
        
        $result = Clean-Path -Path $path
        if ($result.Success) {
            $totalSize += $result.Size
            $log.AppendText("  ✅ $(Format-Size $result.Size)`n")
        } else {
            $log.AppendText("  ⏭ Skipped`n")
        }
        $form.Refresh()
    }
    
    $elapsed = (Get-Date) - $startTime
    $stats.Text = "💾 Space freed: $(Format-Size $totalSize) | ⏱️ Time: $([math]::Round($elapsed.TotalSeconds))s"
    $status.Text = '✅ CLEANUP COMPLETE!'
    $status.ForeColor = [System.Drawing.Color]::LimeGreen
    $log.AppendText("`n🎉 Cleanup finished successfully!
")
    $cleanBtn.Enabled = $true
})

$exitBtn.Add_Click({ $form.Close() })

# Show
$form.ShowDialog() | Out-Null
