# AI Smart Cleaner - Deployment Guide

Complete guide for deploying and running the AI Smart Cleaner application on Windows systems.

## Table of Contents
- [System Requirements](#system-requirements)
- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Troubleshooting](#troubleshooting)
- [Advanced Setup](#advanced-setup)

## System Requirements

### Minimum Requirements
- **Operating System**: Windows 10 (Build 19041+) or Windows 11
- **PowerShell**: PowerShell 7.0 or later
- **Memory**: 4 GB RAM minimum
- **Disk Space**: 500 MB for installation
- **.NET Framework**: .NET 6.0 or later

### Recommended Requirements
- **Operating System**: Windows 11 (Build 22621 or later)
- **PowerShell**: PowerShell 7.3 or latest
- **Memory**: 8 GB RAM or more
- **Disk Space**: 1 GB for installation and caching
- **GPU**: Dedicated GPU for enhanced glassmorphism effects

### UI Framework Requirements (for Modern 2026 GUI)
- Windows 10 Build 22621 or later recommended for full glassmorphism support
- GPU acceleration support for blur effects
- DirectX 12 compatible graphics

## Prerequisites

### 1. Install PowerShell 7
```powershell
# Download from https://github.com/PowerShell/PowerShell/releases
# Or use Windows Package Manager
winget install Microsoft.PowerShell
```

### 2. Verify .NET Installation
```powershell
dotnet --version
# Should show version 6.0 or higher
```

### 3. Clone or Download Repository
```powershell
# Using Git
git clone https://github.com/Gzeu/ai-smart-cleaner.git
cd ai-smart-cleaner

# Or download ZIP and extract
```

### 4. Set Execution Policy (if needed)
```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Installation Steps

### Step 1: Navigate to Project Directory
```powershell
cd C:\path\to\ai-smart-cleaner
```

### Step 2: Install Dependencies
```powershell
# Install required modules
Install-Module -Name Microsoft.PowerShell.Utility -Force
Install-Module -Name OxyPlot -Force  # For charts
Install-Module -Name ImportExcel -Force  # For report export (optional)
```

### Step 3: Set Up Configuration Files
```powershell
# The application creates configuration automatically on first run
# Or manually set up:
$config = @{
    'SafeMode' = $true
    'Theme' = 'Modern2026'
    'Language' = 'en-US'
}
```

### Step 4: Verify Installation
```powershell
# Run diagnostic check
.\AI-Cleaner.ps1 -Diagnostic
```

## Configuration

### Theme Configuration

Edit `UI-Theme-2026.json` to customize:
```json
{
  "ThemeName": "Modern2026",
  "Colors": {
    "Primary": "#00D9FF",
    "Secondary": "#FF006E",
    "Accent": "#8338EC"
  },
  "Glassmorphism": {
    "BlurRadius": 10,
    "Opacity": 0.8,
    "BorderOpacity": 0.15
  }
}
```

### Application Settings

Edit `AI-Cleaner-Config.json`:
```json
{
  "SafeMode": true,
  "Categories": {
    "AI Analysis": true,
    "Registry": false,
    "Duplicates": true,
    "Benchmark": true,
    "Settings": false,
    "Notifications": true
  },
  "CleanupThreshold": "Medium"
}
```

## Running the Application

### Method 1: Standard Execution
```powershell
# Run from PowerShell
.\AI-Cleaner.ps1

# Or with arguments
.\AI-Cleaner.ps1 -SafeMode
.\AI-Cleaner.ps1 -AggressiveMode
```

### Method 2: Using Enhanced Version
```powershell
# Run with Modern 2026 GUI and real deletion
.\AI-Cleaner-Enhanced.ps1 -Mode "Enhanced"
```

### Method 3: Standalone EXE (if compiled)
```cmd
AI-Cleaner.exe
Build-EXE.ps1  # Compile to EXE
```

## Running Cleanup Modes

### Safe Mode (Recommended for First Run)
1. Uncheck "Safe Mode" to enable deletion
2. Select cleanup categories to scan
3. Click "START CLEANUP" to begin analysis
4. Review results before confirming deletion
5. Click "APPLY" to proceed with deletion

### Aggressive Mode (Advanced Users)
1. Disable "Safe Mode" in Settings
2. Select cleanup categories
3. Click "START CLEANUP"
4. **Real file deletion begins immediately**
5. Monitor progress bar
6. View results showing deleted count

## Troubleshooting

### Issue: "Module not found" Error
```powershell
# Solution: Install missing module
Install-Module -Name ModuleName -Force
```

### Issue: GUI Not Rendering
```powershell
# Solution: Check graphics support
# Ensure GPU drivers are up to date
# Fall back to standard mode if needed
.\AI-Cleaner.ps1 -StandardUI
```

### Issue: Permission Denied
```powershell
# Solution: Run as Administrator
# Right-click PowerShell and select "Run as administrator"
```

### Issue: Registry Access Failed
```powershell
# Solution: Enable registry cleanup in admin mode
# The application needs admin privileges for registry operations
```

## Advanced Setup

### Task Scheduler Integration
```powershell
# Schedule automatic cleanup
$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
  -Argument '-NoProfile -WindowStyle Hidden -File "C:\path\to\AI-Cleaner.ps1"'
  
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek 'Sunday' -At '2:00 AM'

Register-ScheduledTask -TaskName 'AI Smart Cleaner' `
  -Action $action -Trigger $trigger -RunLevel 'Highest'
```

### Enable Logging
```powershell
# Set up detailed logging
$LogPath = "C:\Logs\AI-Cleaner"
New-Item -ItemType Directory -Path $LogPath -Force | Out-Null

# Configure logging in application settings
```

### Backup Before Cleanup
```powershell
# Create system restore point
Checkpoint-Computer -Description 'Before AI-Cleaner Run' -RestorePointType 'ApplicationInstall'
```

## Uninstallation

### Remove Application Files
```powershell
# Navigate to installation directory
cd C:\path\to\ai-smart-cleaner

# Remove all files
Remove-Item -Path .\* -Recurse -Force
```

### Remove Scheduled Tasks
```powershell
Unregister-ScheduledTask -TaskName 'AI Smart Cleaner' -Confirm:$false
```

### Clean Registry (Optional)
```powershell
# Remove application registry entries
Remove-Item -Path 'HKCU:\Software\AI-Smart-Cleaner' -Recurse -Force
```

## Support & Documentation

- **README**: [README.md](README.md) - General information
- **Testing Guide**: [TESTING-GUIDE-Aggressive-Mode.md](TESTING-GUIDE-Aggressive-Mode.md)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md) - Version history
- **Roadmap**: [ROADMAP-v11-Advanced-Features.md](ROADMAP-v11-Advanced-Features.md)
- **Issues**: [GitHub Issues](https://github.com/Gzeu/ai-smart-cleaner/issues)

## Security Considerations

⚠️ **Important Security Notes**:
- Always run in Safe Mode first to verify cleanup operations
- Create system restore point before running Aggressive Mode
- Run as Administrator for full functionality
- Keep PowerShell and .NET updated
- Review cleanup categories before execution
- Backup important files before cleanup

## Performance Optimization

### Tips for Better Performance
1. Close unnecessary background applications
2. Disable antivirus scanning during cleanup (temporarily)
3. Run during off-peak hours for large cleanups
4. Monitor system resources during execution
5. Use SSD for faster file deletion

---

**Last Updated**: January 15, 2026
**Version**: v10.3 ENHANCED
**Compatibility**: PowerShell 7+, Windows 10/11
