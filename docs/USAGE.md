# Usage Guide

## Quick Start (30 seconds)

1. Launch: `.\ AI-Cleaner.ps1` or `AI-Smart-Cleaner.exe`
2. Safe Mode ON (default) = Preview only
3. Click **RUN CLEANUP**
4. Watch logs & charts populate
5. Enable **Safe Mode OFF** to delete real files
6. Click **RUN CLEANUP** again

## GUI Tabs

### ⚙️ Settings
- Toggle Safe Mode (preview vs delete)
- Select cleanup categories
- Whitelist custom folders
- Set AI analysis (Gemini API)

### 📊 Results Table
- Category | Size | Files | Deleted | Errors
- Sort by clicking headers
- Right-click for details

### 📝 Logs (Real-time)
- Color-coded messages
- Timestamps on every action
- Auto-scroll to latest

### 📈 Charts
- Pie chart: Space by category
- Interactive legend
- Hover for details

### ⏰ Schedule
- Set daily cleanup time
- Windows Task Scheduler integration

## Cleanup Categories

| Category | What It Cleans |
|----------|----------------|
| **Temp** | %TEMP% folder |
| **Cache** | Edge/Chrome cache |
| **Logs** | Old log files |
| **Downloads** | 30+ day old files |
| **Thumbnails** | Thumbnail cache |
| **Prefetch** | Prefetch files |

## Whitelist

Protect folders from cleanup:
```
Documents, Photos, Important
```

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| F5 | Refresh |
| Ctrl+S | Save config |
| Ctrl+E | Export report |

## Safe Mode

**ON** = Preview (no deletion)
**OFF** = Real cleanup (delete files)

⚠️ Always test in Safe Mode first!
