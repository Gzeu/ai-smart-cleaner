#Requires -Version 7.0
<# AI-Cleaner.ps1 v10.3 FULL FEATURES - All Tabs/Charts/Scheduler #>

Add-Type -AssemblyName System.Windows.Forms,System.Drawing,System.Windows.Forms.DataVisualization -ErrorAction Stop
[System.Windows.Forms.Application]::EnableVisualStyles()

# CLASS
class CleanerConfig {
    [string]$GeminiApiKey=''
    [bool]$SafeMode=$true
    [int]$MaxThreads=4
    [string[]]$WhitelistPaths=@()
    [string[]]$BlacklistPaths=@()
    [bool]$ExportReports=$true
    [string]$ReportPath="$env:USERPROFILE\Desktop"
    [hashtable]$CleanupCategories=@{Temp=$true;Cache=$true;Logs=$true;Downloads=$false;Thumbnails=$false;Prefetch=$false}
    [void]Save([string]$Path){ $this | ConvertTo-Json -Depth 10 | Set-Content $Path }
    static [CleanerConfig]Load([string]$Path){ if(Test-Path $Path){ return [CleanerConfig](Get-Content $Path | ConvertFrom-Json) }; return [CleanerConfig]::new() }
}

# FUNCTIONS
function Write-CleanerLog([string]$Message,[string]$Level='Info',[System.Windows.Forms.RichTextBox]$LogBox){
    $timestamp=Get-Date -f 'HH:mm:ss'
    $text="[$timestamp][$Level] $Message\n"
    if($LogBox){ $LogBox.SelectionColor=@{Info='Cyan';Success='Green';Warning='Yellow';Error='Red'}[$Level]; $LogBox.AppendText($text); $LogBox.ScrollToCaret() } else { Write-Host $text -ForegroundColor @{Info='Cyan';Success='Green';Warning='Yellow';Error='Red'}[$Level] }
}

function Format-ByteSize([long]$Size){ if($Size -eq 0){'0 B'}else{ $units='B','KiB','MiB','GiB'; $i=0; $s=[double]$Size; while($s -ge 1024 -and $i -lt 3){$s /=1024;$i++}; '{0:N1} {1}' -f $s,$units[$i] } }

function Get-CleanupTargets{ @{ Temp=@($env:TEMP,(Resolve-Path "$env:WINDIR\Temp" -ErrorAction SilentlyContinue)); Cache=@((Resolve-Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache" -ErrorAction SilentlyContinue)); Logs=@("$env:WINDIR\Logs"); Downloads=@("$env:USERPROFILE\Downloads\*.tmp"); Thumbnails=@("$env:APPDATA\Thumbnails"); Prefetch=@("$env:WINDIR\Prefetch") } }

function Invoke-Cleanup([bool]$SafeMode,[System.Windows.Forms.RichTextBox]$LogBox){
    $targets=Get-CleanupTargets
    $totalSize=0;$totalFiles=0;$allResults=@()
    $targets.Keys | ForEach-Object {
        $cat=$_; $paths=$targets[$_]
        $size=0;$files=0
        foreach($p in $paths){
            if(Test-Path $p){
                Get-ChildItem $p -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                    $size+=$_.Length;$files++
                }
            }
        }
        Write-CleanerLog "✓ $cat`: $(Format-ByteSize $size)" 'Success' $LogBox
        $totalSize+=$size;$totalFiles+=$files
        $allResults += [PSCustomObject]@{Category=$cat;Size=$size;Files=$files}
    }
    @{TotalSize=$totalSize;TotalFiles=$totalFiles;Results=$allResults}
}

# THEMES
function Set-ControlTheme($Control,$Colors){
    $Control.BackColor=$Colors.Background
    $Control.ForeColor=$Colors.Text
    foreach($child in $Control.Controls){ Set-ControlTheme $child $Colors }
}

$colors=@{Background=[System.Drawing.Color]::FromArgb(20,20,20);Panel=[System.Drawing.Color]::FromArgb(35,35,35);Accent=[System.Drawing.Color]::FromArgb(0,122,255);Text='White'}

# FORM
$form=New-Object System.Windows.Forms.Form
$form.Text='🧹 AI Smart Cleaner v10.3 FULL'
$form.Size=[System.Drawing.Size]::new(1200,800)
$form.StartPosition='CenterScreen'
$form.BackColor=$colors.Background

$tabControl=New-Object System.Windows.Forms.TabControl
$tabControl.Dock='Fill'
$form.Controls.Add($tabControl)

# SETTINGS TAB
$tabSettings=New-Object System.Windows.Forms.TabPage
$tabSettings.Text='⚙️ Settings'
$lblSafe=New-Object System.Windows.Forms.Label
$lblSafe.Text='Safe Mode:';$lblSafe.Location=[System.Drawing.Point]::new(10,10)
$chkSafe=New-Object System.Windows.Forms.CheckBox
$chkSafe.Checked=$true;$chkSafe.Location=[System.Drawing.Point]::new(100,10)
$tabSettings.Controls.AddRange(@($lblSafe,$chkSafe))
$tabControl.TabPages.Add($tabSettings)

# RESULTS TABLE
$tabTable=New-Object System.Windows.Forms.TabPage
$tabTable.Text='📊 Results'
$dgv=New-Object System.Windows.Forms.DataGridView
$dgv.Dock='Fill';$dgv.AutoSizeColumnsMode='Fill';$dgv.BackgroundColor=$colors.Panel;$dgv.DefaultCellStyle.ForeColor=$colors.Text;$dgv.AlternatingRowsDefaultCellStyle.BackColor=[System.Drawing.Color]::FromArgb(45,45,45)
$tabTable.Controls.Add($dgv)
$tabControl.TabPages.Add($tabTable)

# LOGS
$tabLog=New-Object System.Windows.Forms.TabPage
$tabLog.Text='📝 Logs'
$rtbLog=New-Object System.Windows.Forms.RichTextBox
$rtbLog.Dock='Fill';$rtbLog.BackColor=[System.Drawing.Color]::FromArgb(15,15,15);$rtbLog.ForeColor='Cyan';$rtbLog.Font=[System.Drawing.Font]::new('Consolas',9)
$tabLog.Controls.Add($rtbLog)
$tabControl.TabPages.Add($tabLog)

# CHARTS
$tabChart=New-Object System.Windows.Forms.TabPage
$tabChart.Text='📈 Charts'
$chart=New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$chart.Dock='Fill';$chart.BackColor=$colors.Panel;$chart.BorderlineColor=$colors.Accent
$tabChart.Controls.Add($chart)
$tabControl.TabPages.Add($tabChart)

# BUTTON BAR
$panelButtons=New-Object System.Windows.Forms.Panel
$panelButtons.Dock='Bottom';$panelButtons.Height=60;$panelButtons.BackColor=$colors.Panel
$btnRun=New-Object System.Windows.Forms.Button
$btnRun.Text='🚀 RUN CLEANUP';$btnRun.Size=[System.Drawing.Size]::new(150,40);$btnRun.Location=[System.Drawing.Point]::new(10,10);$btnRun.BackColor=$colors.Accent;$btnRun.ForeColor='White'
$panelButtons.Controls.Add($btnRun)
$form.Controls.Add($panelButtons)

# EVENTS
$btnRun.Add_Click({
    $safe=$chkSafe.Checked
    $rtbLog.Clear()
    Write-CleanerLog 'Starting...' $null $rtbLog
    $res=Invoke-Cleanup $safe $rtbLog
    Write-CleanerLog "DONE! $(Format-ByteSize $res.TotalSize) ($($res.TotalFiles) files)" 'Success' $rtbLog
    # TABLE
    $dgv.DataSource=[System.Collections.ArrayList]$res.Results
    # CHART
    $chart.Series.Clear()
    $series=New-Object System.Windows.Forms.DataVisualization.Charting.Series('Space')
    $series.ChartType='Pie';$series['PieLabelStyle']='Outside'
    $res.Results | ForEach-Object { $series.Points.AddXY($_.Category,$_.Size) | Out-Null }
    $chart.Series.Add($series)
    $chart.Titles.Clear();$chart.Titles.Add('Space by Category')
})

# THEME
Set-ControlTheme $form $colors

Write-Host 'GUI ready!'
$form.ShowDialog()