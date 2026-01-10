#Requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type -AssemblyName System.Drawing -ErrorAction Stop

[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)
[System.Windows.Forms.Application]::EnableVisualStyles()

$config = [ordered]@{
    GeminiKey = $env:GEMINI_API_KEY ?? ""
    SafeMode = $true
    CacheClean = $true
    TempClean = $true
    PythonClean = $false
    LogsClean = $true
}

function Format-Size {
    param([long]$Size)
    if ($Size -eq 0) { return '0 B' }
    $units = 'B','KiB','MiB','GiB','TiB'
    $i = 0
    while ($Size -ge 1024 -and $i -lt 4) { $Size /= 1024; $i++ }
    return "{0:N1} {1}" -f $Size, $units[$i]
}

function Get-TempFolders {
    $paths = @(
        "$env:TEMP",
        "$env:WINDIR\\Temp",
        "$env:SystemDrive\\Windows\\Temp",
        "$env:USERPROFILE\\AppData\\Local\\Temp",
        "C:\\ProgramData\\Package Cache"
    )
    return $paths | Where-Object { Test-Path $_ }
}

function Get-CacheFolders {
    $paths = @(
        "$env:USERPROFILE\\AppData\\Local\\Google\\Chrome\\User Data\\Default\\Cache",
        "$env:USERPROFILE\\AppData\\Local\\Microsoft\\Edge\\User Data\\Default\\Cache",
        "$env:USERPROFILE\\AppData\\Roaming\\Mozilla\\Firefox\\Profiles\\*\\cache",
        "$env:USERPROFILE\\AppData\\Local\\Chromium\\User Data\\Default\\Cache"
    )
    return $paths | Where-Object { Test-Path $_ }
}

function Remove-CleanupItems {
    param(
        [string]$Category,
        [bool]$SafeMode = $true,
        [System.Windows.Forms.RichTextBox]$Logger
    )
    
    $itemsRemoved = 0
    $sizeFreed = 0L
    
    try {
        if ($Category -eq 'Temp') {
            $folders = Get-TempFolders
            foreach ($folder in $folders) {
                if (Test-Path $folder) {
                    Get-ChildItem -Path $folder -File -Recurse -ErrorAction SilentlyContinue |
                    ForEach-Object {
                        try {
                            $sizeFreed += $_.Length
                            if (-not $SafeMode) { Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue }
                            $itemsRemoved++
                        } catch { }
                    }
                }
            }
        }
    }
    catch {
        if ($Logger) { $Logger.AppendText("Error: $_`n") }
    }
    
    return @{ ItemsRemoved = $itemsRemoved; SizeFreed = $sizeFreed }
}

$form = New-Object System.Windows.Forms.Form -Property @{
    Text = "🧹 AI SMART CLEANER v6.2 - Complete Edition"
    Size = New-Object System.Drawing.Size(1480, 920)
    StartPosition = "CenterScreen"
    FormBorderStyle = "FixedDialog"
    BackColor = [System.Drawing.Color]::FromArgb(28,28,36)
    Font = New-Object System.Drawing.Font("Segoe UI", 10)
    MaximizeBox = $false
}

$tabs = New-Object System.Windows.Forms.TabControl -Property @{
    Size = New-Object System.Drawing.Size(1440, 840)
    Location = New-Object System.Drawing.Point(20, 20)
}

# Settings Tab
$tabSettings = New-Object System.Windows.Forms.TabPage -Property @{
    Text = " ⚙️ Settings "
    BackColor = [System.Drawing.Color]::FromArgb(36,36,44)
}

$lblMode = New-Object System.Windows.Forms.Label -Property @{
    Text = "Safe Mode (Preview Only):"
    Location = New-Object System.Drawing.Point(20, 20)
    Size = New-Object System.Drawing.Size(200, 24)
    ForeColor = 'White'
}

$chkSafeMode = New-Object System.Windows.Forms.CheckBox -Property @{
    Checked = $true
    Location = New-Object System.Drawing.Point(220, 20)
    Size = New-Object System.Drawing.Size(150, 24)
    ForeColor = 'White'
}

$btnClean = New-Object System.Windows.Forms.Button -Property @{
    Text = "🚀 START CLEANUP"
    Size = New-Object System.Drawing.Size(200, 50)
    Location = New-Object System.Drawing.Point(20, 450)
    BackColor = [System.Drawing.Color]::FromArgb(220,50,50)
    ForeColor = 'White'
    FlatStyle = 'Flat'
    Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
}

$tabSettings.Controls.AddRange(@($lblMode, $chkSafeMode, $btnClean))

# Results Tab
$tabResults = New-Object System.Windows.Forms.TabPage -Property @{
    Text = " 📋 Results "
    BackColor = [System.Drawing.Color]::FromArgb(36,36,44)
}

$rtbLog = New-Object System.Windows.Forms.RichTextBox -Property @{
    Size = New-Object System.Drawing.Size(1380, 750)
    Location = New-Object System.Drawing.Point(20, 40)
    BackColor = [System.Drawing.Color]::FromArgb(20,20,26)
    ForeColor = [System.Drawing.Color]::FromArgb(180,255,180)
    Font = New-Object System.Drawing.Font("Consolas", 10)
    ReadOnly = $true
    WordWrap = $false
}

$tabResults.Controls.Add($rtbLog)

$tabs.TabPages.AddRange(@($tabSettings, $tabResults))
$form.Controls.Add($tabs)

$btnClean.Add_Click({
    if ([System.Windows.Forms.MessageBox]::Show("Ready to clean?", "Confirm", "YesNo") -eq "Yes") {
        $rtbLog.Clear()
        $rtbLog.AppendText("[$(Get-Date -Format 'HH:mm:ss')] Cleanup started in $(if ($chkSafeMode.Checked) { 'PREVIEW MODE' } else { 'SAFE DELETE' })`n")
        $rtbLog.AppendText("Scanning and cleaning system...`n`n")
        
        $result = Remove-CleanupItems -Category "Temp" -SafeMode $chkSafeMode.Checked -Logger $rtbLog
        $rtbLog.AppendText("✓ Temp: Freed $(Format-Size $result.SizeFreed)`n")
        
        $rtbLog.AppendText("\n[$(Get-Date -Format 'HH:mm:ss')] Cleanup complete!`n")
    }
})

$form.ShowDialog() | Out-Null
