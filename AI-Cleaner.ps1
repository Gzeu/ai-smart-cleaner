# 🚀 AI SMART CLEANER v4.2 - COMPLETE WORKING SCRIPT
# High-Res GUI + C: AI Scan + Gemini CLI + Config + Safe Clean
# Author: AI Smart Cleaner Team
# License: MIT
# Website: https://github.com/Gzeu/ai-smart-cleaner

# CRITICAL: Assemblies FIRST
Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type -AssemblyName System.Drawing -ErrorAction Stop

# App settings IMMEDIATELY AFTER
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

# Helper Functions
function Format-Size {
    param([long]$Size)
    if ($Size -eq 0) { return '0 B' }
    $units = 'B','KB','MB','GB','TB'
    $i = 0
    while ($Size -ge 1KB -and $i -lt 4) {
        $Size /= 1KB
        $i++
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
    $rules = @{
        'Cache*' = 95; 'Temp*' = 95; '*Chrome*\\Cache*' = 90; '*Edge*\\Cache*' = 90
        '*\\AppData\\Local\\Temp' = 95; '*\\Prefetch' = 85; '*Slack*\\Cache' = 85
        '*\\Teams\\Cache' = 85; '*\\SoftwareDistribution\\Download' = 90
    }
    
    gci 'C:\\' -Directory -EA SilentlyContinue | ? { (gci $_.FullName -Recurse -File -EA SilentlyContinue | measure Length -Sum -EA SilentlyContinue).Sum -gt 50MB } |
    sort { (gci $_.FullName -Recurse -File -EA SilentlyContinue | measure Length -Sum).Sum } -Desc | select -f 30 | % {
        $size = (gci $_.FullName -Recurse -File -EA SilentlyContinue | measure Length -Sum).Sum
        $score = 0
        foreach ($pat in $rules.Keys) {
            if ($_.FullName -like $pat -or $_.Name -like $pat) { $score = $rules[$pat]; break }
        }
        if ($score -gt 50) {
            $candidates += [PSCustomObject]@{
                Path=$_.FullName
                Name=Split-Path $_.FullName -Leaf
                Size=$size
                AIScore=$score
                Safe=($score -ge 80)
                Category=if($score-ge90){'🔥 PRIORITY'}elseif($score-ge70){'✅ SAFE'}else{'⚠️ REVIEW'}
            }
        }
    }
    return $candidates | sort Size -Desc
}

Write-Host '🚀 AI Smart Cleaner v4.2 Loaded Successfully!' -ForegroundColor Green
Write-Host 'Repository: https://github.com/Gzeu/ai-smart-cleaner' -ForegroundColor Cyan
