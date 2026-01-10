#Requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type -AssemblyName System.Drawing -ErrorAction Stop

[System.Windows.Forms.Application]::EnableVisualStyles()

# Modern Theme Manager
enum Theme { Light; Dark; Auto }
$ThemeManager = @{
    Current = [Theme]::Auto
    Colors = @{
        Light = @{ Back = '#F8F9FA'; Fore = '#212529'; Accent = '#007BFF' }
        Dark = @{ Back = '#1E1E1E'; Fore = '#D4D4D4'; Accent = '#0D6EFD' }
    }
    LoadTheme = {
        param($Control)
        $colors = $this.Colors[$this.Current]
        $Control.BackColor = [System.Drawing.Color]::FromName($colors.Back)
        $Control.ForeColor = [System.Drawing.Color]::FromName($colors.Fore)
        foreach ($child in $Control.Controls) { & $this.LoadTheme($child) }
    }
}

$config = [ordered]@{
    GeminiKey = $env:GEMINI_API_KEY ?? ""
    SafeMode = $true
    Theme = [Theme]::Auto
}

function Format-Size {
    param([long]$Size)
    if ($Size -eq 0) { return '0 B' }
    $units = 'B','KiB','MiB','GiB','TiB'
    $i = 0
    while ($Size -ge 1024 -and $i -lt 4) { $Size /= 1024; $i++ }
    return "{0:N1} {1}" -f $Size, $units[$i]
}

function Scan-Directories {
    param($Paths)
    $Jobs = @()
    foreach ($Path in $Paths) {
        $Jobs += Start-Job -ScriptBlock { 
            param($P) 
            $total = 0L
            Get-ChildItem $P -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $total += $_.Length }
            [PSCustomObject]@{ Path=$P; Size=$total }
        } -ArgumentList $Path
    }
    $Results = $Jobs | Wait-Job | Receive-Job
    $Jobs | Remove-Job
    return $Results
}

function Get-TempFolders { @(
    "$env:TEMP",
    "$env:WINDIR\Temp",
    "$env:SystemDrive\Windows\Temp",
    "$env:USERPROFILE\AppData\Local\Temp"
) | Where-Object { Test-Path $_ } }

function Get-CacheFolders { @(
    "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Cache",
    "$env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
) | Where-Object { Test-Path $_ } }

function Remove-CleanupItems {
    param([string]$Category, [bool]$SafeMode, [System.Windows.Forms.RichTextBox]$Logger)
    $items = 0; $size = 0L
    switch ($Category) {
        'Temp' { $folders = Get-TempFolders }
        'Cache' { $folders = Get-CacheFolders }
    }
    $scanResults = Scan-Directories $folders
    foreach ($res in $scanResults) {
        $size += $res.Size
        if (-not $SafeMode) {
            Get-ChildItem $res.Path -Recurse -Force | Remove-Item -Force -ErrorAction SilentlyContinue
        }
        $items++
        $Logger.AppendText("Processed $($res.Path): $(Format-Size $res.Size)`n")
    }
    return @{ Items=$items; Size=$size }
}

# Main Form
$form = New-Object System.Windows.Forms.Form -Property @{
    Text = "🧹 AI Smart Cleaner v7.0 - Enhanced Edition"
    Size = New-Object System.Drawing.Size(1600,1000)
    StartPosition = "CenterScreen"
    FormBorderStyle = "FixedSingle"
    MaximizeBox = $false
    Icon = (New-Object System.Drawing.Icon([System.Drawing.SystemIcons]::Shield, 32,32))
}

$tabs = New-Object System.Windows.Forms.TabControl -Property @{
    Dock = 'Fill'
    ItemSize = New-Object System.Drawing.Size(150,35)
}

# Settings Tab
$tabSettings = New-Object System.Windows.Forms.TabPage -Property @{ Text = "⚙️ Settings"; UseVisualStyleBackColor = $true }
$lblSafe = New-Object System.Windows.Forms.Label -Property @{ Text = "Safe Mode"; Location = New-Object System.Drawing.Point(20,20); Size = New-Object System.Drawing.Size(120,25); Font = New-Object System.Drawing.Font('Segoe UI',11,[System.Drawing.FontStyle]::Bold) }
$chkSafe = New-Object System.Windows.Forms.CheckBox -Property @{ Checked = $true; Location = New-Object System.Drawing.Point(150,22); Size = New-Object System.Drawing.Size(120,20) }
$lblTheme = New-Object System.Windows.Forms.Label -Property @{ Text = "Theme:"; Location = New-Object System.Drawing.Point(20,60); Size = New-Object System.Drawing.Size(50,25) }
$cmbTheme = New-Object System.Windows.Forms.ComboBox -Property @{ Location = New-Object System.Drawing.Point(80,62); DropDownStyle = 'DropDownList'; Items = @('Light','Dark','Auto'); SelectedIndex = 2 }
$btnScan = New-Object System.Windows.Forms.Button -Property @{ Text = "🚀 START CLEANUP"; Size = New-Object System.Drawing.Size(220,60); Location = New-Object System.Drawing.Point(20,120); BackColor = [System.Drawing.Color]::FromArgb(40,167,69); ForeColor = 'White'; FlatStyle = 'Flat'; Font = New-Object System.Drawing.Font('Segoe UI',14,[System.Drawing.FontStyle]::Bold) }
$pbProgress = New-Object System.Windows.Forms.ProgressBar -Property @{ Style = 'Marquee'; Size = New-Object System.Drawing.Size(300,25); Location = New-Object System.Drawing.Point(20,200); Visible = $false }

$tabSettings.Controls.AddRange(@($lblSafe,$chkSafe,$lblTheme,$cmbTheme,$btnScan,$pbProgress))

# Results Tab
$tabResults = New-Object System.Windows.Forms.TabPage -Property @{ Text = "📊 Results"; UseVisualStyleBackColor = $true }
$lblTotal = New-Object System.Windows.Forms.Label -Property @{ Text = "Space Freed: 0 B"; Location = New-Object System.Drawing.Point(20,20); Size = New-Object System.Drawing.Size(300,30); Font = New-Object System.Drawing.Font('Segoe UI',16,[System.Drawing.FontStyle]::Bold); ForeColor = [System.Drawing.Color]::LimeGreen }
$rtbLog = New-Object System.Windows.Forms.RichTextBox -Property @{ Dock = 'Bottom'; Height = 600; Font = New-Object System.Drawing.Font('Consolas',10); BackColor = [System.Drawing.Color]::FromArgb(30,30,30); ForeColor = [System.Drawing.Color]::LightGreen; ReadOnly = $true }
$tabResults.Controls.AddRange(@($lblTotal,$rtbLog))

$tabs.TabPages.AddRange(@($tabSettings,$tabResults))
$form.Controls.Add($tabs)

# Event Handlers
$cmbTheme.Add_SelectedIndexChanged({ $ThemeManager.Current = [Theme]::($cmbTheme.SelectedItem); $ThemeManager.LoadTheme($form) })
$btnScan.Add_Click({
    if ([System.Windows.Forms.MessageBox]::Show('Start cleanup?',[string]::Empty,'YesNo','Question') -ne 'Yes') { return }
    $pbProgress.Visible = $true
    $rtbLog.Clear()
    $rtbLog.AppendText("[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] 🚀 Cleanup initiated in $(if($chkSafe.Checked){'PREVIEW'}else{'DELETE'}) mode`n")
    $totalSize = 0L
    $resultTemp = Remove-CleanupItems 'Temp' $chkSafe.Checked $rtbLog
    $totalSize += $resultTemp.Size
    $rtbLog.AppendText("\n✓ Temp cleanup: $(Format-Size $resultTemp.Size)`n")
    $resultCache = Remove-CleanupItems 'Cache' $chkSafe.Checked $rtbLog
    $totalSize += $resultCache.Size
    $rtbLog.AppendText("✓ Cache cleanup: $(Format-Size $resultCache.Size)`n")
    $lblTotal.Text = "Space Freed: $(Format-Size $totalSize)" 
    $rtbLog.AppendText("\n✅ Operation complete at $(Get-Date -Format 'HH:mm:ss')!")
    $pbProgress.Visible = $false
})

$ThemeManager.LoadTheme($form)
$form.ShowDialog() | Out-Null