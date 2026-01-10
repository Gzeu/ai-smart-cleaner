# Installation Guide

## 3 Methods to Install AI Smart Cleaner

### Method 1: EXE Standalone (Recommended for Beginners)

No PowerShell 7 required - fully portable!

```powershell
.\Build-EXE.ps1
.\dist\AI-Smart-Cleaner.exe
```

**Benefits:**
- One-click installation
- No dependencies
- Portable (USB-ready)
- Works on Windows 10/11

### Method 2: PowerShell Gallery (Pro Users)

```powershell
Install-Module AI-Smart-Cleaner -Scope CurrentUser
AI-Smart-Cleaner
```

**Benefits:**
- Auto-updates via `Update-Module`
- Windows PowerShell compatible
- Easy uninstall: `Remove-Module`

### Method 3: Source Code (Developers)

```powershell
git clone https://github.com/Gzeu/ai-smart-cleaner.git
cd ai-smart-cleaner
.\AI-Cleaner.ps1
```

## System Requirements

- Windows 10/11
- PowerShell 7.0+ (for source)
- Admin privileges (for cleanup)
- 50 MB disk space

## Troubleshooting

**Q: Script blocked by execution policy?**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Q: Module not found?**
```powershell
Update-Module AI-Smart-Cleaner
```

For more help, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
