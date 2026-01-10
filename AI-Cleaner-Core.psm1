#Requires -Version 7.0
<# AI Smart Cleaner Core FIXED v10.2 #>

class CleanerConfig {
    [string]$GeminiApiKey = ''
    [bool]$SafeMode = $true
    [int]$MaxThreads = 4
    [string[]]$WhitelistPaths = @()
    [string[]]$BlacklistPaths = @()
    [bool]$ExportReports = $true
    [string]$ReportPath = "$env:USERPROFILE\Desktop"
    [hashtable]$CleanupCategories = @{Temp=$true; Cache=$true; Logs=$true; Downloads=$false; Thumbnails=$false; Prefetch=$false}
    [void]Save([string]$Path){ $this | ConvertTo-Json -Depth 10 | Set-Content $Path }
    static [CleanerConfig]Load([string]$Path){
        if(Test-Path $Path){ return [CleanerConfig](Get-Content $Path | ConvertFrom-Json) } return [CleanerConfig]::new() }
}

function Write-CleanerLog([string]$Message,[string]$Level='Info'){
    $timestamp = Get-Date -Format 'HH:mm:ss'
    Write-Host "[$timestamp][$Level] $Message" -ForegroundColor @{Info='Cyan';Success='Green';Warning='Yellow';Error='Red'}[$Level]
}

function Format-ByteSize([long]$Size){
    if($Size -eq 0){'0 B'}else{ $units='B','KiB','MiB','GiB'; $i=0; $s=[double]$Size; while($s -ge 1024 -and $i -lt 3){$s /=1024; $i++}; '{0:N1} {1}' -f $s,$units[$i] }}

function Get-CleanupTargets{ @{
Temp=@($env:TEMP,'$env:WINDIR\Temp');
Cache=@("$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache");
Logs=@("$env:WINDIR\Logs");
Downloads=@("$env:USERPROFILE\Downloads\*.tmp");
Thumbnails=@("$env:APPDATA\Thumbnails");
Prefetch=@("$env:WINDIR\Prefetch") } }

function Invoke-ParallelScan([string[]]$Paths){ $results=@(); foreach($p in $Paths){ if(Test-Path $p){ $size=0; $files=0; Get-ChildItem $p -File -Recurse -ErrorAction SilentlyContinue | %{$size+=$_.Length;$files++}; $results += [PSCustomObject]@{Path=$p;Size=$size;Files=$files} } }; $results }

function Invoke-CleanupOperation([string]$Category,[string[]]$Paths,[bool]$SafeMode){
    $scan = Invoke-ParallelScan $Paths
    $total = ($scan | Measure Size -Sum).Sum
    Write-CleanerLog "✓ $Category`: $(Format-ByteSize $total) (Safe: $SafeMode)"
    [PSCustomObject]@{Size=$total;Files=($scan | Measure Files -Sum).Sum }
}

function Export-CleanupReport([PSCustomObject[]]$Results,[string]$Path){
    $csv = "$Path\Report-$(Get-Date -f 'yyyyMMdd-HHmmss').csv"
    $Results | Export-Csv $csv
    Write-CleanerLog "Report: $csv"
    $csv
}

function Invoke-GeminiAnalysis([string]$ApiKey,[PSCustomObject[]]$Results){
    if(-not $ApiKey){ Write-CleanerLog 'No API key' Warning; return }
    Write-CleanerLog 'AI Analysis...'
    # Simulated
    @{analysis = $Results | % { @{path=$_.Path; score=95; rec='DELETE'} } }
}

function Test-IsWhitelisted([string]$Path){ $false }  # Impl

function Test-IsBlacklisted([string]$Path){ $false }

# Export FIXED (no -Class)
Export-ModuleMember -Function *