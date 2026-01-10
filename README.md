# 🧹 AI Smart Cleaner v6.2

**Advanced PowerShell GUI Application for Intelligent Windows Disk Cleanup with AI-Powered Decision Making**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub Gzeu/ai-smart-cleaner](https://img.shields.io/badge/GitHub-Gzeu%2Fai--smart--cleaner-green)](https://github.com/Gzeu/ai-smart-cleaner)
[![Language: PowerShell 7](https://img.shields.io/badge/Language-PowerShell%207-cyan)]()
[![Platform: Windows 10/11](https://img.shields.io/badge/Platform-Windows%2010%2F11-orange)]()

## 📋 Overview

AI Smart Cleaner is a powerful Windows disk cleanup utility that combines:

- 🤖 **AI-Powered Analysis**: Intelligent C: drive scanning with machine learning-based safe-to-delete scoring
- 🎨 **High-Resolution GUI**: Modern Windows Forms interface with dark theme and real-time progress tracking
- ⚡ **Lightning-Fast Cleanup**: Ultra-rapid deletion of cache, temp files, and junk data
- 🛡️ **Safety First**: AI scoring system (0-100) ensures only truly safe items are cleaned
- 🧠 **Gemini CLI Integration**: Optional advanced analysis via Google Gemini AI API
- 📊 **Live Statistics**: Real-time size calculations and cleanup metrics
- ✅ **Safe Mode**: Preview-only scanning without actual deletion

## ✨ Key Features

### 🤖 AI-Powered Decision Making
- Automatic C: drive scanning with 30+ folder analysis
- AI scoring algorithm (safety threshold 80%+)
- Multi-tab configuration system
- Safe-to-delete pattern matching

### 🎨 Premium UI/UX
- High-DPI support (1920x1080 minimum)
- Dark theme with modern styling
- Emoji-enhanced controls and labels
- Two-tab interface (Settings + Results)
- Real-time progress bar visualization

### 🚀 v6.2 Complete Edition Features
- **START CLEANUP Button**: Fully functional cleanup with confirmation dialog
- **Safe Mode Toggle**: Preview-only scanning without actual deletion
- **Helper Functions**: Get-TempFolders & Get-CacheFolders for comprehensive discovery
- **Complete Cleanup Logic**: Remove-CleanupItems with size tracking
- **Results Tab**: Detailed logging with timestamps and statistics
- **Error Handling**: Graceful fallbacks and comprehensive error logging

### 📁 Cleanup Categories
1. **Temp Folders**
   - %TEMP% directory
   - Windows\\Temp
   - AppData\\Local\\Temp
   - ProgramData\\Package Cache

2. **Browser Cache**
   - Chrome
   - Microsoft Edge
   - Mozilla Firefox
   - Chromium

3. **Python Cache** (Optional)
   - __pycache__ directories
   - .pyc files
   - Virtual environments

4. **Old Log Files** (Optional)
   - Files older than 30 days
   - System and application logs

## 🚀 Quick Start

### Requirements
- **Windows 10/11** (fully tested)
- **PowerShell 7+** (or Windows PowerShell 5.1)
- Administrator privileges for deletion (optional for preview mode)

### Installation

```powershell
# Clone the repository
git clone https://github.com/Gzeu/ai-smart-cleaner.git
cd ai-smart-cleaner

# Run the script
.\AI-Cleaner.ps1
```

### Usage

1. **Launch the Application**
   ```powershell
   .\AI-Cleaner.ps1
   ```

2. **Configure Settings**
   - Set Safe Mode toggle (ON = preview only, OFF = delete)
   - Optionally enter Gemini API key for AI analysis

3. **Start Cleanup**
   - Click **START CLEANUP** button
   - Confirm in the dialog box
   - Review results in the Results tab

4. **View Results**
   - Real-time log of cleanup operations
   - Total space freed in human-readable format
   - Operation timestamps

## 🔧 Configuration

### Safe Mode (Recommended)
When enabled, scans all folders and calculates total space that could be freed **without actually deleting anything**. Perfect for preview and analysis.

```powershell
$chkSafeMode.Checked = $true  # Enable Safe Mode
```

### Gemini AI Integration
Optional: Provide your Google Gemini API key for advanced analysis:

```powershell
# Set environment variable or use the GUI input field
$env:GEMINI_API_KEY = "your-api-key-here"
```

## 📊 Logging & Results

The Results tab provides:
- **Timestamps**: Exact time of each operation
- **Category Breakdown**: Space freed per cleanup category
- **Total Freed**: Aggregated space recovered
- **Error Messages**: Any issues encountered

Example output:
```
[16:45:23] Cleanup started in PREVIEW MODE
Scanning and cleaning system...

✓ Temp: Freed 2.4 GiB

[16:45:45] Cleanup complete!
```

## 🔐 Safety Features

1. **Confirmation Dialog**: Always ask before deleting
2. **Safe Mode Preview**: Test without actual deletion
3. **Error Handling**: Gracefully skip inaccessible files
4. **Size Validation**: Track exactly what will be deleted
5. **Pattern Matching**: Only delete known safe file types

## 🐛 Troubleshooting

### "Permission Denied" Error
Run PowerShell as Administrator:
```powershell
# Right-click PowerShell > Run as Administrator
.\AI-Cleaner.ps1
```

### Script Execution Policy
If you get execution policy error:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\AI-Cleaner.ps1
```

### UI Not Displaying
Ensure you're on Windows 10/11 with .NET Framework 4.7+:
```powershell
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name Version,Release -EA 0
```

## 📝 Changelog

### v6.2 (Current)
- ✅ Complete UI rewrite with proper initialization
- ✅ Functional START CLEANUP button
- ✅ Safe Mode toggle implementation
- ✅ Helper functions for folder discovery
- ✅ Complete cleanup logic with size tracking
- ✅ Results tab with detailed logging
- ✅ Error handling and graceful fallbacks

### v6.1 ULTIMATE
- BackgroundWorker for non-blocking operations
- Parallel scanning with throttling
- Professional UI enhancements
- Multiple cleanup categories

### v6.0
- Initial release
- Basic GUI implementation
- Temp folder cleanup

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs via Issues
- Submit feature requests
- Create pull requests
- Improve documentation

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software.

## 👨‍💻 Author

**Gzeu** - [GitHub Profile](https://github.com/Gzeu)

## 🙏 Acknowledgments

- Built with PowerShell 7
- Uses Windows Forms for UI
- Google Gemini API integration
- Community feedback and testing

## 📮 Contact & Support

For questions, feedback, or support:
- Open an issue on GitHub
- Check existing documentation
- Review troubleshooting section

---

**Made with ❤️ by Gzeu** | Last updated: January 10, 2026
