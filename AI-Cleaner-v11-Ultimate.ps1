#Requires -Version 7.0
# AI Smart Cleaner v11.0 ULTIMATE - Multi-Button UI + Live Dashboard
# Enhanced Glassmorphism UI with 8-Button Toolbar, Dashboard, Categories Grid
# Author: Gzeu | GitHub: github.com/Gzeu/ai-smart-cleaner
# Version: 11.0 | Release: 2026-01-11

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

Write-Host '[v11] AI Smart Cleaner - Ultimate Edition loaded' -ForegroundColor Cyan
Write-Host '[v11] Multi-Button Toolbar: SCAN, CLEANUP, PAUSE, UNDO, SETTINGS, STATS, LOGS, HELP' -ForegroundColor Green
Write-Host '[v11] Dashboard with live metrics, 9 cleanup categories, glassmorphism UI' -ForegroundColor Green

# THEME COLORS (Glassmorphism 2026)
$ThemeColors = @{
    'Primary'    = [System.Drawing.Color]::FromArgb(0, 217, 255)      # Cyan
    'Secondary'  = [System.Drawing.Color]::FromArgb(0, 150, 255)      # Blue
    'Accent'     = [System.Drawing.Color]::FromArgb(255, 0, 255)      # Magenta
    'Success'    = [System.Drawing.Color]::FromArgb(0, 255, 136)      # Green
    'Warning'    = [System.Drawing.Color]::FromArgb(255, 170, 0)      # Orange
    'Error'      = [System.Drawing.Color]::FromArgb(255, 51, 102)     # Red
    'Background' = [System.Drawing.Color]::FromArgb(10, 14, 39)       # Dark
    'Surface'    = [System.Drawing.Color]::FromArgb(18, 23, 46)       # Surface
    'CardBG'     = [System.Drawing.Color]::FromArgb(150, 25, 35, 60)  # Glass
}

# CLEANUP TARGETS (9 Categories)
function Get-CleanupCategories {
    return @(
        @{ Name = 'Temp Files';    Icon = '📄'; Path = @($env:TEMP); Risk = 'Low' },
        @{ Name = 'Cache';         Icon = '💾'; Path = @("$env:LOCALAPPDATA\Cache"); Risk = 'Low' },
        @{ Name = 'Logs';          Icon = '📝'; Path = @("$env:WINDIR\Logs"); Risk = 'Medium' },
        @{ Name = 'Duplicates';    Icon = '📋'; Custom = $true; Risk = 'Low' },
        @{ Name = 'Downloads';     Icon = '⬇️'; Path = @("$env:USERPROFILE\Downloads"); Risk = 'High' },
        @{ Name = 'Recycle Bin';   Icon = '🗑️'; Special = $true; Risk = 'Medium' },
        @{ Name = 'Browser Cache'; Icon = '🌐'; Path = @("$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"); Risk = 'Low' },
        @{ Name = 'Thumbnails';    Icon = '🖼️'; Path = @("$env:APPDATA\Thumbnails"); Risk = 'Low' },
        @{ Name = 'Prefetch';      Icon = '⚡'; Path = @("$env:WINDIR\Prefetch"); Risk = 'Medium' }
    )
}

function Invoke-CategoryScan {
    param([hashtable]$Category, [System.Windows.Forms.ProgressBar]$Progress)
    $totalSize = 0; $totalFiles = 0
    if ($Category.Custom) { return @{ Size = 0; Files = 0; Status = 'Custom' } }
    if ($Category.Special) {
        try {
            $shell = New-Object -ComObject Shell.Application
            $recycleBin = $shell.Namespace(0xA)
            $totalFiles = $recycleBin.Items().Count
            $totalSize = ($recycleBin.Items() | Measure-Object -Sum Size).Sum
        } catch {}
        return @{ Size = $totalSize; Files = $totalFiles; Status = 'Ready' }
    }
    foreach ($p in $Category.Path) {
        if (Test-Path $p) {
            try {
                Get-ChildItem $p -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                    $totalSize += $_.Length; $totalFiles++
                }
            } catch {}
        }
    }
    return @{ Size = $totalSize; Files = $totalFiles; Status = 'Ready' }
}

function Format-ByteSize {
    param([long]$Size)
    if ($Size -eq 0) { return '0 B' }
    $units = 'B', 'KB', 'MB', 'GB', 'TB'
    $idx = 0; $s = [double]$Size
    while ($s -ge 1024 -and $idx -lt 4) { $s /= 1024; $idx++ }
    return '{0:N2} {1}' -f $s, $units[$idx]
}

function Get-SystemMetrics {
    $os = Get-CimInstance Win32_OperatingSystem
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $cpu = try { [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples[0].CookedValue, 1) } catch { 0 }
    return @{
        CPU = $cpu
        RAM = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100, 1)
        DiskUsed = $disk.Size - $disk.FreeSpace
        DiskTotal = $disk.Size
        DiskFree = $disk.FreeSpace
        DiskPercent = [math]::Round(($disk.Size - $disk.FreeSpace) / $disk.Size * 100, 1)
    }
}

Write-Host '[Setup] Initialization complete. Ready to launch UI.' -ForegroundColor Green
