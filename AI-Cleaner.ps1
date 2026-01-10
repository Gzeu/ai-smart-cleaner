#Requires -Version 7.0
<# AI-Cleaner.ps1 v10.2 SELF-CONTAINED FIXED - No Module Deps #>

Add-Type -AssemblyName System.Windows.Forms,System.Drawing,System.Windows.Forms.DataVisualization -ErrorAction Stop
[System.Windows.Forms.Application]::EnableVisualStyles()

# CLASS SELF-CONTAINED
class CleanerConfig {
    [string]$GeminiApiKey=''
    [bool]$SafeMode=$true
    [int]$MaxThreads=4
    [string[]]$WhitelistPaths=@()
    [string[]]$BlacklistPaths=@()
    [bool]$ExportReports=$true
    [string]$ReportPath="$env:USERPROFILE\Desktop"
    [hashtable]$CleanupCategories=@{Temp=$true;Cache=$true;Logs=$true;Downloads=$false;Thumbnails=$false;Prefetch=$false}
    [void]Save([string]$Path){this | ConvertTo-Json -Depth 10 | Set-Content $Path}
    static [CleanerConfig]Load([string]$Path){if(Test-Path $Path){[CleanerConfig](Get-Content $Path|ConvertFrom-Json)}else{[CleanerConfig]::new()}}
}

# FUNCTIONS SELF-CONTAINED (no module)
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
    "{0:N1} {1}" -f $s,$units[$i]
}

function Get-CleanupTargets{@{Temp=@($env:TEMP,'$env:WINDIR\Temp');Cache=@("$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache");Logs=@("$env:WINDIR\Logs");Downloads=@("$env:USERPROFILE\Downloads\*.tmp");Thumbnails=@("$env:APPDATA\Thumbnails");Prefetch=@("$env:WINDIR\Prefetch")}}

function Invoke-Cleanup($SafeMode){
    $targets=Get-CleanupTargets
    $total=0;$files=0
    $targets.Keys | % {
        $paths=$targets[$_]
        $scan=@();foreach($p in $paths){if(Test-Path $p){$size=0;$f=0;Get-ChildItem $p -File -ErrorAction SilentlyContinue | %{$size+=$_.Length;$f++};$scan+=[PSCustomObject]@{Path=$p;Size=$size;Files=$f}}}
        $ts=($scan|Measure Size -Sum).Sum
        Write-CleanerLog "✓ $_`: $(Format-ByteSize $ts)"
        $total+=$ts;$files+=($scan|Measure Files -Sum).Sum
    }
    @{TotalSize=$total;TotalFiles=$files}
}

# GUI MINIMAL FIXED (expand later)
$form=New-Object System.Windows.Forms.Form
$form.Text='🧹 AI Smart Cleaner FIXED v10.2'
$form.Size=[System.Drawing.Size]::new(800,600)
$form.StartPosition='CenterScreen'

$btnClean=New-Object System.Windows.Forms.Button
$btnClean.Text='🚀 CLEANUP'
$btnClean.Dock='Top'
$btnClean.Height=50
$form.Controls.Add($btnClean)

$rtb=New-Object System.Windows.Forms.RichTextBox
$rtb.Dock='Fill'
$rtb.BackColor=[System.Drawing.Color]::FromArgb(20,20,20)
$rtb.ForeColor='White'
$form.Controls.Add($rtb)

$btnClean.Add_Click({
    $rtb.Clear()
    $res=Invoke-Cleanup $true  # Safe
    $rtb.AppendText("Total: $(Format-ByteSize $res.TotalSize) ($($res.TotalFiles) files)\n")
})

$form.ShowDialog()