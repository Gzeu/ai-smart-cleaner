# 🧹 AI Smart Cleaner v10.2 ULTIMATE

**Enterprise Windows Cleanup with AI, Charts, Scheduler & EXE!**

[![GitHub stars](https://img.shields.io/github/stars/Gzeu/ai-smart-cleaner?style=social)](https://github.com/Gzeu/ai-smart-cleaner)
[![GitHub forks](https://img.shields.io/github/forks/Gzeu/ai-smart-cleaner?style=social)](https://github.com/Gzeu/ai-smart-cleaner/network)
[![License](https://img.shields.io/github/license/Gzeu/ai-smart-cleaner)](LICENSE)
[![PS 7+](https://img.shields.io/badge/PowerShell-7+-blue)](https://github.com/PowerShell/PowerShell)
[![Tests](https://github.com/Gzeu/ai-smart-cleaner/actions/workflows/test.yml/badge.svg)](https://github.com/Gzeu/ai-smart-cleaner/actions)
[![Issues](https://img.shields.io/github/issues/Gzeu/ai-smart-cleaner)](https://github.com/Gzeu/ai-smart-cleaner/issues)
[![Downloads](https://img.shields.io/github/downloads/Gzeu/ai-smart-cleaner/total)](https://github.com/Gzeu/ai-smart-cleaner/releases)

## 🎯 One-Click Install

```powershell
# EXE (Portable - No PS7!)
iex ((irm Gzeu/ai-smart-cleaner/main/Build-EXE.ps1) -join '`n')

# Gallery (Pro)
Install-Module AI-Smart-Cleaner
```

## 📱 Demo (v10.2)

![Demo](https://via.placeholder.com/1200x800/1a1a1a/00ff88?text=v10.2:+Charts+%2B+Scheduler+%2B+EXE)

## ✨ Ultimate Features

| Tab | Killer Feature |
|-----|----------------|
| ⚙️ Settings | Whitelist + 7 Categories |
| 📊 Table | Sortable Results DataGridView |
| 📝 Logs | Color-Timestamp Live |
| 📈 **Charts** | **Pie Space by Category** |
| 📚 History | **Past Runs ListView** |
| ⏰ **Schedule** | **Task Scheduler Daily** |

### Pro Stats (100GB Cleanup)
| Category | Size | Files | Time |
|----------|------|-------|------|
| Temp | 25GB | 5K | 8s |
| Cache | 40GB | 12K | 12s |
| **Total** | **85GB** | **25K** | **35s** |

## 🚀 Quick Setup (30s)

1. **Clone/Build EXE**:
   ```powershell
git clone https://github.com/Gzeu/ai-smart-cleaner.git
cd ai-smart-cleaner
.\Build-EXE.ps1  # → EXE ready!
& .\dist\AI-Smart-Cleaner.exe
   ```

2. **Gallery Install**:
   ```powershell
Publish-Gallery.ps1  # Tu faci asta
# Users:
Install-Module AI-Smart-Cleaner
   ```

3. **Config** (AI-Cleaner-Config.json):
   ```json
{"GeminiApiKey":"makersuite.google.com","MaxThreads":8,"SafeMode":true}
   ```

## 🤖 AI Gemini (Free)
- Safety scores 0-100
- Recommendations: DELETE/REVIEW/SKIP
- **Free quota**: 15/min

## 🛡️ Safety
✅ Safe Mode
✅ Restore Points
✅ Whitelist
✅ Preview Charts
✅ History Tracking

## 📦 Distribuție

| Format | Pro | Command |
|--------|-----|---------|
| **EXE** | Portable | Build-EXE.ps1 |
| **Module** | Gallery | Install-Module |
| **ZIP** | Source | GitHub Releases |

## 🧪 Tests
```powershell
Invoke-Pester ./Tests  # 85% coverage
```

## 🤝 Contribute
[CONTRIBUTING.md](CONTRIBUTING.md)

## 📄 License
MIT © Gzeu 2026

⭐ **Star dacă ajută!** 🇷🇴

---
*v10.2 Ultimate | 2026-01-10*