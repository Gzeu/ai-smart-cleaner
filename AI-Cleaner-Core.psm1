#Requires -Version 7.0
<#
.SYNOPSIS
    AI Smart Cleaner Core Module - Professional Windows Cleanup Engine

.DESCRIPTION
    Core functionality module providing parallel scanning, cleanup operations,
    AI integration, and utility functions for the AI Smart Cleaner application.

.NOTES
    Author: Gzeu
    Version: 10.0
    License: MIT
#>

using namespace System.Management.Automation
using namespace System.Collections.Concurrent

# ============================================================================
# CONFIGURATION CLASS
# ============================================================================

class CleanerConfig {
    [string]$GeminiApiKey = ''
    [bool]$SafeMode = $true
    [int]$MaxThreads = 4
    [int]$LogRetentionDays = 30
    [string[]]$CustomPaths = @()
    [bool]$EnableGemini = $false
    [bool]$CreateBackup = $true
    [string]$Theme = 'Dark'
    [hashtable]$CleanupCategories = @{
        Temp = $true
        Cache = $true
        Logs = $true
        Downloads = $false
    }

    [void] Save([string]$Path) {
        try {
            $this | ConvertTo-Json -Depth 10 | Set-Content -Path $Path -Encoding UTF8
        }
        catch {
            Write-Warning "Failed to save configuration: $($_.Exception.Message)"
        }
    }

    static [CleanerConfig] Load([string]$Path) {
        try {
            if (Test-Path $Path) {
                $json = Get-Content -Path $Path -Raw | ConvertFrom-Json
                $config = [CleanerConfig]::new()
                
                # Map JSON properties to config object
                $json.PSObject.Properties | ForEach-Object {
                    if ($config.PSObject.Properties.Name -contains $_.Name) {
                        $config.$($_.Name) = $_.Value
                    }
                }
                return $config
            }
        }
        catch {
            Write-Warning "Failed to load configuration: $($_.Exception.Message)"
        }
        return [CleanerConfig]::new()
    }
}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

<#
.SYNOPSIS
    Professional logging function with multiple output targets.

.DESCRIPTION
    Writes structured log messages to UI, file, and console with severity levels
    and color coding. Automatically manages log file rotation.

.PARAMETER Message
    The log message to write.

.PARAMETER Level
    Severity level: Info, Warning, Error, Success, Debug.

.PARAMETER LogBox
    Optional RichTextBox control for UI logging.

.PARAMETER LogPath
    Optional custom log file path. Defaults to %TEMP%\ai-cleaner-logs\.

.EXAMPLE
    Write-CleanerLog -Message "Cleanup started" -Level Info -LogBox $rtbLog
#>
function Write-CleanerLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('Info', 'Warning', 'Error', 'Success', 'Debug')]
        [string]$Level = 'Info',

        [Parameter()]
        [System.Windows.Forms.RichTextBox]$LogBox,

        [Parameter()]
        [string]$LogPath
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"

    # Console colors
    $consoleColors = @{
        Info = 'Cyan'
        Warning = 'Yellow'
        Error = 'Red'
        Success = 'Green'
        Debug = 'Gray'
    }

    # UI colors
    $uiColors = @{
        Info = [System.Drawing.Color]::LightBlue
        Warning = [System.Drawing.Color]::Yellow
        Error = [System.Drawing.Color]::Red
        Success = [System.Drawing.Color]::Lime
        Debug = [System.Drawing.Color]::Gray
    }

    # Write to UI
    if ($LogBox) {
        try {
            $LogBox.SelectionColor = $uiColors[$Level]
            $LogBox.AppendText("$logEntry`n")
            $LogBox.SelectionStart = $LogBox.Text.Length
            $LogBox.ScrollToCaret()
        }
        catch {
            Write-Warning "Failed to write to UI log: $($_.Exception.Message)"
        }
    }

    # Write to file
    try {
        if (-not $LogPath) {
            $logDir = Join-Path $env:TEMP 'ai-cleaner-logs'
            if (-not (Test-Path $logDir)) {
                New-Item -Path $logDir -ItemType Directory -Force | Out-Null
            }
            $LogPath = Join-Path $logDir "ai-cleaner-$(Get-Date -Format 'yyyy-MM-dd').log"
        }
        Add-Content -Path $LogPath -Value $logEntry -ErrorAction SilentlyContinue
    }
    catch {
        # Silently fail file logging to avoid disrupting main operations
    }

    # Write to console
    Write-Host $logEntry -ForegroundColor $consoleColors[$Level]
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

<#
.SYNOPSIS
    Formats byte sizes into human-readable strings.

.DESCRIPTION
    Converts raw byte values into formatted strings with appropriate units
    (B, KiB, MiB, GiB, TiB) using binary (1024) conversion.

.PARAMETER Size
    The size in bytes to format.

.EXAMPLE
    Format-ByteSize -Size 1048576
    # Returns: "1.0 MiB"
#>
function Format-ByteSize {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [long]$Size
    )

    if ($Size -eq 0) { return '0 B' }
    if ($Size -lt 0) { return 'Invalid Size' }

    $units = @('B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB')
    $index = 0
    $sizeDouble = [double]$Size

    while ($sizeDouble -ge 1024 -and $index -lt ($units.Count - 1)) {
        $sizeDouble /= 1024
        $index++
    }

    return "{0:N2} {1}" -f $sizeDouble, $units[$index]
}

<#
.SYNOPSIS
    Gets all cleanup target directories categorized by type.

.DESCRIPTION
    Returns a comprehensive hashtable of cleanup categories with their
    associated directory paths. Validates paths exist before including.

.PARAMETER IncludeCustomPaths
    Optional array of custom user-defined paths to include.

.EXAMPLE
    $targets = Get-CleanupTargets
    $targets['Temp'] | ForEach-Object { Scan-Directory $_ }
#>
function Get-CleanupTargets {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter()]
        [string[]]$IncludeCustomPaths = @()
    )

    $targets = @{
        Temp = @(
            $env:TEMP,
            "$env:WINDIR\Temp",
            "$env:LOCALAPPDATA\Temp",
            "$env:ProgramData\Package Cache",
            "$env:WINDIR\SoftwareDistribution\Download"
        )
        Cache = @(
            "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
            "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
            "$env:APPDATA\Mozilla\Firefox\Profiles\*\cache2",
            "$env:LOCALAPPDATA\Packages\*\AC\Temp"
        )
        Logs = @(
            "$env:WINDIR\Logs",
            "$env:ProgramData\Microsoft\Windows\WER\ReportQueue",
            "$env:LOCALAPPDATA\CrashDumps"
        )
    }

    # Add custom paths if provided
    if ($IncludeCustomPaths.Count -gt 0) {
        $targets['Custom'] = $IncludeCustomPaths
    }

    # Validate and expand wildcard paths
    foreach ($category in $targets.Keys) {
        $validPaths = @()
        foreach ($path in $targets[$category]) {
            try {
                if ($path -match '\*') {
                    # Handle wildcard paths
                    $expanded = Get-Item $path -ErrorAction SilentlyContinue
                    if ($expanded) {
                        $validPaths += $expanded.FullName
                    }
                }
                elseif (Test-Path $path) {
                    $validPaths += $path
                }
            }
            catch {
                # Skip invalid paths silently
            }
        }
        $targets[$category] = $validPaths
    }

    return $targets
}

# ============================================================================
# SCANNING FUNCTIONS
# ============================================================================

<#
.SYNOPSIS
    Performs high-performance parallel directory scanning.

.DESCRIPTION
    Uses PowerShell runspaces to scan multiple directories in parallel,
    calculating total size and file counts. Includes progress callbacks
    and comprehensive error handling.

.PARAMETER Paths
    Array of directory paths to scan.

.PARAMETER MaxThreads
    Maximum number of concurrent scanning threads (default: 4).

.PARAMETER ProgressCallback
    Optional scriptblock executed for progress updates.
    Receives parameters: $CurrentPath, $CompletedCount, $TotalCount

.OUTPUTS
    PSCustomObject[] with Path, Size, Files, Success, Errors, Duration properties.

.EXAMPLE
    $results = Invoke-ParallelScan -Paths @("C:\Temp", "C:\Windows\Temp") -MaxThreads 4
    $totalSize = ($results | Measure-Object Size -Sum).Sum
#>
function Invoke-ParallelScan {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory)]
        [string[]]$Paths,

        [Parameter()]
        [ValidateRange(1, 16)]
        [int]$MaxThreads = 4,

        [Parameter()]
        [scriptblock]$ProgressCallback
    )

    $runspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads)
    $runspacePool.Open()
    $runspaces = [System.Collections.ArrayList]::new()
    $startTime = Get-Date

    foreach ($path in $Paths) {
        if (-not (Test-Path $path)) {
            Write-CleanerLog -Message "Path not found: $path" -Level Warning
            continue
        }

        $powershell = [powershell]::Create().AddScript({
            param($targetPath)

            $scanStart = Get-Date
            try {
                $totalSize = 0L
                $fileCount = 0
                $errors = [System.Collections.ArrayList]::new()

                Get-ChildItem -Path $targetPath -File -Recurse -Force -ErrorAction SilentlyContinue |
                    ForEach-Object {
                        try {
                            $totalSize += $_.Length
                            $fileCount++
                        }
                        catch {
                            [void]$errors.Add($_.Exception.Message)
                        }
                    }

                [PSCustomObject]@{
                    Path = $targetPath
                    Size = $totalSize
                    Files = $fileCount
                    Success = $true
                    Errors = $errors.ToArray()
                    Duration = ((Get-Date) - $scanStart).TotalSeconds
                }
            }
            catch {
                [PSCustomObject]@{
                    Path = $targetPath
                    Size = 0
                    Files = 0
                    Success = $false
                    Errors = @($_.Exception.Message)
                    Duration = ((Get-Date) - $scanStart).TotalSeconds
                }
            }
        }).AddArgument($path)

        $powershell.RunspacePool = $runspacePool
        [void]$runspaces.Add([PSCustomObject]@{
            Pipe = $powershell
            Status = $powershell.BeginInvoke()
            Path = $path
        })
    }

    # Wait for completion with progress
    $results = @()
    $completed = 0
    $total = $runspaces.Count

    while ($runspaces.Count -gt 0) {
        $finished = $runspaces | Where-Object { $_.Status.IsCompleted }

        foreach ($runspace in $finished) {
            try {
                $result = $runspace.Pipe.EndInvoke($runspace.Status)
                $results += $result
                $completed++

                # Execute progress callback
                if ($ProgressCallback) {
                    & $ProgressCallback $runspace.Path $completed $total
                }
            }
            catch {
                Write-CleanerLog -Message "Scan error for $($runspace.Path): $($_.Exception.Message)" -Level Error
            }
            finally {
                $runspace.Pipe.Dispose()
                [void]$runspaces.Remove($runspace)
            }
        }

        if ($runspaces.Count -gt 0) {
            Start-Sleep -Milliseconds 100
        }
    }

    $runspacePool.Close()
    $runspacePool.Dispose()

    $totalDuration = ((Get-Date) - $startTime).TotalSeconds
    Write-CleanerLog -Message "Parallel scan completed in $($totalDuration.ToString('F2')) seconds" -Level Success

    return $results
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

<#
.SYNOPSIS
    Executes cleanup operations for a specific category.

.DESCRIPTION
    Performs actual file deletion or preview-only scanning based on SafeMode.
    Creates backup restore points if enabled. Returns detailed statistics.

.PARAMETER Category
    Cleanup category (Temp, Cache, Logs, Custom).

.PARAMETER Paths
    Array of paths to clean for this category.

.PARAMETER SafeMode
    If true, only scans without deleting. If false, performs actual deletion.

.PARAMETER CreateBackup
    If true, creates a restore point before deletion.

.OUTPUTS
    PSCustomObject with Size, Files, Success, Errors, Duration properties.

.EXAMPLE
    $result = Invoke-CleanupOperation -Category 'Temp' -Paths @("C:\Temp") -SafeMode $false
#>
function Invoke-CleanupOperation {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [string]$Category,

        [Parameter(Mandatory)]
        [string[]]$Paths,

        [Parameter()]
        [bool]$SafeMode = $true,

        [Parameter()]
        [bool]$CreateBackup = $false,

        [Parameter()]
        [System.Windows.Forms.RichTextBox]$LogBox
    )

    $startTime = Get-Date
    Write-CleanerLog -Message "Starting cleanup: $Category (SafeMode: $SafeMode)" -Level Info -LogBox $LogBox

    # Scan directories
    $scanResults = Invoke-ParallelScan -Paths $Paths
    $totalSize = ($scanResults | Measure-Object Size -Sum).Sum
    $totalFiles = ($scanResults | Measure-Object Files -Sum).Sum

    if ($SafeMode) {
        Write-CleanerLog -Message "[PREVIEW] $Category: $(Format-ByteSize $totalSize) ($totalFiles files)" -Level Warning -LogBox $LogBox
        return [PSCustomObject]@{
            Category = $Category
            Size = $totalSize
            Files = $totalFiles
            Deleted = 0
            Success = $true
            Errors = @()
            Duration = ((Get-Date) - $startTime).TotalSeconds
            SafeMode = $true
        }
    }

    # Create backup/restore point if enabled
    if ($CreateBackup) {
        try {
            Write-CleanerLog -Message "Creating restore point..." -Level Info -LogBox $LogBox
            Checkpoint-Computer -Description "AI-Cleaner-Before-$Category-$(Get-Date -Format 'yyyyMMdd-HHmmss')" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
            Write-CleanerLog -Message "Restore point created successfully" -Level Success -LogBox $LogBox
        }
        catch {
            Write-CleanerLog -Message "Failed to create restore point: $($_.Exception.Message)" -Level Warning -LogBox $LogBox
        }
    }

    # Perform actual deletion
    $deletedFiles = 0
    $errors = @()

    foreach ($scanResult in $scanResults) {
        if (-not $scanResult.Success) { continue }

        try {
            Get-ChildItem -Path $scanResult.Path -Recurse -Force -ErrorAction SilentlyContinue |
                ForEach-Object {
                    try {
                        Remove-Item -Path $_.FullName -Force -Recurse -ErrorAction Stop
                        $deletedFiles++
                    }
                    catch {
                        $errors += "Failed to delete: $($_.FullName) - $($_.Exception.Message)"
                    }
                }
        }
        catch {
            $errors += "Failed to process: $($scanResult.Path) - $($_.Exception.Message)"
        }
    }

    $duration = ((Get-Date) - $startTime).TotalSeconds
    $level = if ($errors.Count -gt 0) { 'Warning' } else { 'Success' }
    Write-CleanerLog -Message "✓ $Category: $(Format-ByteSize $totalSize) ($deletedFiles files deleted, $($errors.Count) errors)" -Level $level -LogBox $LogBox

    return [PSCustomObject]@{
        Category = $Category
        Size = $totalSize
        Files = $totalFiles
        Deleted = $deletedFiles
        Success = ($errors.Count -eq 0)
        Errors = $errors
        Duration = $duration
        SafeMode = $false
    }
}

# ============================================================================
# AI INTEGRATION
# ============================================================================

<#
.SYNOPSIS
    Performs AI-powered safety analysis using Google Gemini.

.DESCRIPTION
    Sends scan results to Gemini API for intelligent safety scoring and
    recommendations. Returns analysis with safety scores (0-100) for each path.

.PARAMETER ApiKey
    Google Gemini API key.

.PARAMETER ScanResults
    Array of scan result objects to analyze.

.OUTPUTS
    PSCustomObject with analysis results including safety scores and recommendations.

.EXAMPLE
    $analysis = Invoke-GeminiAnalysis -ApiKey $apiKey -ScanResults $scanData
#>
function Invoke-GeminiAnalysis {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,

        [Parameter(Mandatory)]
        [PSCustomObject[]]$ScanResults,

        [Parameter()]
        [System.Windows.Forms.RichTextBox]$LogBox
    )

    Write-CleanerLog -Message "Initiating Gemini AI analysis..." -Level Info -LogBox $LogBox

    try {
        # Prepare data for AI
        $dataForAI = $ScanResults | ForEach-Object {
            @{
                path = $_.Path
                size = $_.Size
                files = $_.Files
                sizeFormatted = Format-ByteSize $_.Size
            }
        }

        $prompt = @"
You are a Windows system cleanup expert. Analyze these cleanup targets and provide safety recommendations.

Cleanup Targets:
$($dataForAI | ConvertTo-Json -Compress)

For each path, provide:
1. safetyScore (0-100, where 100 is completely safe to delete)
2. reasoning (brief explanation)
3. recommendation (DELETE, REVIEW, or SKIP)

Respond ONLY with valid JSON in this exact format:
{
  "analysis": [
    {"path": "path1", "safetyScore": 95, "reasoning": "...", "recommendation": "DELETE"},
    {"path": "path2", "safetyScore": 60, "reasoning": "...", "recommendation": "REVIEW"}
  ],
  "summary": "Overall analysis summary"
}
"@

        $headers = @{
            'Content-Type' = 'application/json'
        }

        $body = @{
            contents = @(
                @{
                    parts = @(
                        @{ text = $prompt }
                    )
                }
            )
            generationConfig = @{
                temperature = 0.2
                topK = 40
                topP = 0.95
                maxOutputTokens = 2048
            }
        } | ConvertTo-Json -Depth 10

        $uri = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$ApiKey"

        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 30

        # Extract and parse response
        $aiText = $response.candidates[0].content.parts[0].text
        
        # Clean up response (remove markdown code blocks if present)
        $aiText = $aiText -replace '```json\s*', '' -replace '```\s*$', ''
        
        $analysis = $aiText | ConvertFrom-Json

        Write-CleanerLog -Message "AI analysis completed: $($analysis.summary)" -Level Success -LogBox $LogBox

        return $analysis
    }
    catch {
        Write-CleanerLog -Message "Gemini API Error: $($_.Exception.Message)" -Level Error -LogBox $LogBox
        return $null
    }
}

# ============================================================================
# EXPORT MODULE MEMBERS
# ============================================================================

Export-ModuleMember -Function @(
    'Write-CleanerLog',
    'Format-ByteSize',
    'Get-CleanupTargets',
    'Invoke-ParallelScan',
    'Invoke-CleanupOperation',
    'Invoke-GeminiAnalysis'
) -Variable @() -Alias @()

Export-ModuleMember -Class @('CleanerConfig')
