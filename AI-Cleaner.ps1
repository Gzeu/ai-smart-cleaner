#Requires -Version 7.0
<# AI-Cleaner.ps1 v10.2 PARSER-FIXED SELF-CONTAINED #>

Add-Type -AssemblyName System.Windows.Forms,System.Drawing,System.Windows.Forms.DataVisualization -ErrorAction Stop
[System.Windows.Forms.Application]::EnableVisualStyles()

# CLASS PARSER-FIXED
class CleanerConfig {
    [string]$GeminiApiKey=''
    [bool]$SafeMode=$true
    [int]$MaxThreads=4
    [string[]]$WhitelistPaths=@()
    [string[]]$BlacklistPaths=@()
    [bool]$ExportReports=$true
    [string]$ReportPath="$env:USERPROFILE\Desktop"
    [hashtable]$CleanupCategories=@{Temp=$true;Cache=$true;Logs=$true;Downloads=$false;Thumbnails=$false;Prefetch=$false}
    [void]Save([string]$Path){
        $this | ConvertTo-Json -Depth 10 | Set-Content $Path
    }
    static [CleanerConfig]Load([string]$Path){
        if(Test-Path $Path){
            return [CleanerConfig](Get-Content $Path | ConvertFrom-Json)
        }
        return [CleanerConfig]::new()
    }
}

# FUNCTIONS (unchanged)
function Write-CleanerLog([string]$Message,[string]$Level='Info'){
    $timestamp=Get-Date -f 'HH:mm:ss'
    $colors=@{Info='Cyan';Success='Green';Warning='Yellow';Error='Red'}
    Write-Host "[$timestamp][$Level] $Message" -ForegroundColor $colors[$Level]
}

function Format-ByteSize([long]$Size){
    if($Size -eq 0){return '0 B'}
    $units=@('B','KiB','MiB','GiB')
    $i=0;$s=[double]$Size
    while($s -ge 1024 -and $i -lt 3){$s/=1024;$i++}
    return "{0:N1} {1}" -f $s,$units[$i]
}

function Get-CleanupTargets{@{Temp=@($env:TEMP,'$env:WINDIR\Temp');Cache=@("$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache");Logs=@("$env:WINDIR\Logs");Downloads=@("$env:USERPROFILE\Downloads\*.tmp");Thumbnails=@("$env:APPDATA\Thumbnails");Prefetch=@("$env:WINDIR\Prefetch")}}

function Invoke-Cleanup($SafeMode){
    $targets=Get-CleanupTargets
    $total=0;$files=0;$results=@()
    $targets.Keys | ForEach-Object {
        $paths=$targets[$_]
        $scan=@()
        foreach($p in $paths){
            if(Test-Path $p){
                $size=0;$f=0
                Get-ChildItem $p -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {$size+=$_.Length;$f++}
                $scan+=[PSCustomObject]@{Path=$p;Size=$size;Files=$f}
            }
        }
        $ts=($scan | Measure-Object Size -Sum).Sum
        Write-CleanerLog "✓ $_`: $(Format-ByteSize $ts) (Safe: $SafeMode)"
        $total+=$ts;$files+=($scan | Measure-Object Files -Sum).Sum
        $results += $scan
    }
    @{TotalSize=$total;TotalFiles=$files;Results=$results}
}

# GUI (unchanged)
$form=New-Object System.Windows.Forms.Form
$form.Text='🧹 AI Smart Cleaner v10.2 PARSER-FIXED'
$form.Size=[System.Drawing.Size]::new(900,700)
$form.StartPosition='CenterScreen'
$form.BackColor=[System.Drawing.Color]::FromArgb(20,20,20)
$form.ForeColor='White'

$btnClean=New-Object System.Windows.Forms.Button
$btnClean.Text='🚀 RUN CLEANUP (Safe Mode)'
$btnClean.Dock='Top'
$btnClean.Height=60
$btnClean.BackColor=[System.Drawing.Color]::FromArgb(0,122,255)
$btnClean.ForeColor='White'
$form.Controls.Add($btnClean)

$rtbLog=New-Object System.Windows.Forms.RichTextBox
$rtbLog.Dock='Fill'
$rtbLog.BackColor=[System.Drawing.Color]::FromArgb(15,15,15)
$rtbLog.ForeColor='Cyan'
$rtbLog.Font=[System.Drawing.Font]::new('Consolas',10)
$form.Controls.Add($rtbLog)

$btnClean.Add_Click({
    $rtbLog.Clear()
    $rtbLog.SelectionColor='Yellow'
    $rtbLog.AppendText("Starting cleanup...\n")
    $res=Invoke-Cleanup $true
    $rtbLog.SelectionColor='Green'
    $rtbLog.AppendText("SUCCESS! Total: $(Format-ByteSize $res.TotalSize) ($($res.TotalFiles) files)\n")
})

Write-Host 'GUI launching...'
$form.ShowDialog()
Write-Host 'Done.'