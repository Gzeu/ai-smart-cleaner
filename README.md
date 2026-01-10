# 🚀 AI Smart Cleaner v4.2

> **Advanced PowerShell GUI Application for Intelligent Windows Disk Cleanup with AI-Powered Decision Making**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Repository](https://img.shields.io/badge/GitHub-Gzeu%2Fai--smart--cleaner-green)](https://github.com/Gzeu/ai-smart-cleaner)
[![Language](https://img.shields.io/badge/Language-PowerShell%207-cyan)]()
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-orange)]()

## 📋 Overview

AI Smart Cleaner is a powerful Windows disk cleanup utility that combines:
- **🤖 AI-Powered Analysis**: Intelligent C: drive scanning with machine learning-based safe-to-delete scoring
- **🎨 High-Resolution GUI**: Modern Windows Forms interface with dark theme and real-time progress tracking
- **⚡ Lightning-Fast Cleanup**: Ultra-rapid deletion of cache, temp files, and junk data
- **🔐 Safety First**: AI scoring system (0-100) ensures only truly safe items are cleaned
- **🌐 Gemini CLI Integration**: Optional advanced analysis via Google Gemini AI API
- **📊 Live Statistics**: Real-time size calculations and cleanup metrics

## ✨ Features

### 🤖 AI-Powered Decision Making
- Automatic C: drive scanning with 30+ folder analysis
- AI scoring algorithm (safety threshold 80%+)
- Multi-tab configuration system
- Safe-to-delete pattern matching

### 🎨 Premium UI
- High-DPI support (1200x800 resolution)
- Dark theme with cyan/green accents
- Real-time progress bars (main + detail)
- Live statistics dashboard
- RichTextBox logging with syntax highlighting
- Responsive buttons and controls

### 🧹 Cleanup Targets
- Chrome/Edge cache & cookies
- Browser cache & temporary files
- Slack/Teams cache
- Windows temporary folders
- Recycle Bin
- Prefetch files
- And 20+ more cache locations

### ⚙️ Configuration
- OpenAI/Gemini API key management
- Safe Mode toggle (90%+ AI score only)
- AI vs Classic mode selection
- Scan-only option (no actual deletion)

## 🚀 Quick Start

### Requirements
- **Windows 10/11** (64-bit)
- **PowerShell 7.0+** (pwsh.exe)
- **Administrator Rights** (for folder cleanup)

### Installation

1. **Clone or Download**
   ```bash
   git clone https://github.com/Gzeu/ai-smart-cleaner.git
   cd ai-smart-cleaner
   ```

2. **Run PowerShell 7**
   ```powershell
   pwsh.exe
   ```

3. **Execute the Script**
   ```powershell
   .\AI-Cleaner.ps1
   ```

## 📖 Usage Guide

### Basic Cleanup
```powershell
# Start with GUI (recommended)
pwsh.exe .\AI-Cleaner.ps1

# Click "🚀 START ULTRA CLEANUP"
# Watch real-time progress & statistics
# Wait for completion (typically 1-5 minutes)
```

### AI Scan Only (Preview Mode)
1. Click **🔍 AI SCAN C:** tab
2. Click **"🔍 AI SCAN C: (90s)"** button
3. Review candidates before cleanup
4. Choose **"🧹 CLEAN AI SAFE"** for safe items only

### Configuration
1. Click **⚙️ CONFIGURARE** tab
2. Set OpenAI/Gemini API key (optional)
3. Toggle **"✅ SAFE MODE ONLY"** for maximum safety
4. Customize AI score thresholds

## 📊 AI Scoring System

| Score | Category | Action | Risk |
|-------|----------|--------|------|
| 90-100 | 🔥 PRIORITY | Auto-clean | Minimal |
| 70-89 | ✅ SAFE | Recommend clean | Low |
| 50-69 | ⚠️ REVIEW | Manual review | Medium |
| <50 | 🛑 DANGEROUS | Skip | High |

## 🔧 Advanced Features

### Gemini CLI Integration
```powershell
# Set your Gemini API key in Configuration tab
$env:GEMINI_API_KEY = "your-api-key-here"

# Script will use AI for enhanced analysis
```

### Custom Folder Scanning
Edit the `$rules` hashtable in the script to add custom folders:
```powershell
$rules = @{
    'MyCustomCache*' = 95
    '*\\CustomTemp' = 85
    # Add more patterns...
}
```

## 📈 Performance Metrics

- **Scan Speed**: 30 folders in ~90 seconds
- **Cleanup Speed**: 500MB-2GB per minute (depends on disk speed)
- **Memory Usage**: <150MB average
- **CPU Usage**: <10% average during cleanup

## 🛡️ Safety Features

✅ **Protected Folders** (never deleted):
- Windows System32
- Program Files
- User Documents
- AppData\\Roaming (user data)

✅ **AI Safety Scoring**:
- Configurable thresholds
- Pattern matching validation
- Folder size verification
- Safe Mode option

## 📝 Changelog

### v4.2 (Latest)
- ✨ Complete GUI with tabs (AI/Config/Classic)
- 🤖 AI C: drive scanner with 90s analysis
- 🎨 High-resolution dark theme
- ⚙️ Configuration management
- 📊 Real-time statistics
- 🌐 Gemini CLI integration ready

### v4.1
- Fixed Windows Forms initialization order
- Added status labels across all tabs
- Improved error handling

### v4.0
- Initial GUI implementation
- Multi-tab interface
- AI scoring system

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

## 🙋 Support & Issues

- **Report Bugs**: [GitHub Issues](https://github.com/Gzeu/ai-smart-cleaner/issues)
- **Feature Requests**: [Discussions](https://github.com/Gzeu/ai-smart-cleaner/discussions)
- **Documentation**: [Wiki](https://github.com/Gzeu/ai-smart-cleaner/wiki)

## ⚠️ Disclaimer

**Use at your own risk!** While this tool is designed with safety in mind:
- Always backup important data before running
- Test in Safe Mode first
- Understand what you're deleting
- Not responsible for data loss

## 🎯 Roadmap

- [ ] Cloud backup integration
- [ ] Scheduled cleanup tasks
- [ ] Network drive scanning
- [ ] Docker containerization
- [ ] PowerShell Module (PSM1)
- [ ] Advanced logging to file
- [ ] Undo functionality

## 👨‍💻 Author

**AI Smart Cleaner Team** - Building intelligent Windows utilities

---

**⭐ If you find this useful, please star the repository! It helps others discover this tool.**
