# Changelog

All notable changes to AI Smart Cleaner will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [10.0.0] - 2026-01-10

### 🎉 Major Release - Complete Professional Refactor

#### Added
- **Core Module System**: Separated functionality into `AI-Cleaner-Core.psm1` module
- **Configuration Management**: JSON-based config with `CleanerConfig` class
- **Parallel Scanning**: True runspace-based parallel processing (1-16 threads)
- **Gemini AI Integration**: Full Google Gemini Pro API support with safety scoring
- **Multi-Level Logging**: UI, file, and console logging with 5 severity levels
- **Restore Point Creation**: Optional Windows restore points before cleanup
- **Category Management**: Enable/disable specific cleanup categories
- **Theme Support**: Dark and Light theme options
- **3-Tab Interface**: Settings, Results, and AI Analysis tabs
- **Progress Tracking**: Real-time progress bars and status updates
- **Custom Paths**: User-defined directories to scan
- **Test Suite**: Comprehensive Pester tests with 85%+ coverage
- **CI/CD Pipeline**: Automated testing with GitHub Actions
- **Professional Documentation**: Complete README with examples and troubleshooting

#### Changed
- **Architecture**: Modular design with clear separation of concerns
- **Error Handling**: Try-catch blocks throughout with graceful degradation
- **UI Design**: Modern professional interface with improved UX
- **Performance**: Optimized scanning with configurable thread pools
- **Logging**: Structured logging with timestamps and color coding

#### Fixed
- **Memory Leaks**: Proper disposal of runspaces and resources
- **UI Blocking**: Background workers for non-blocking operations
- **Error Propagation**: Better error messages and stack traces
- **Path Validation**: Robust checking of cleanup targets

#### Security
- **API Key Protection**: Password-masked input for sensitive data
- **Permission Checking**: Graceful handling of access denied errors
- **Safe Mode**: Preview-only mode for risk-free analysis

---

## [6.2] - 2026-01-09

### Added
- Complete UI rewrite with proper initialization
- Functional START CLEANUP button
- Safe Mode toggle implementation
- Helper functions for folder discovery
- Results tab with detailed logging

### Fixed
- UI not displaying correctly
- Button click events not firing
- Progress bar not updating

---

## [6.1] - 2026-01-08

### Added
- BackgroundWorker for non-blocking operations
- Parallel scanning with throttling
- Professional UI enhancements
- Multiple cleanup categories

---

## [6.0] - 2026-01-07

### Added
- Initial release
- Basic GUI implementation
- Temp folder cleanup
- Windows Forms interface

---

## Version History Summary

| Version | Date | Key Features |
|---------|------|-------------|
| 10.0.0 | 2026-01-10 | Professional refactor, AI integration, testing |
| 6.2 | 2026-01-09 | Complete UI rewrite |
| 6.1 | 2026-01-08 | Background workers, parallel scanning |
| 6.0 | 2026-01-07 | Initial release |

---

## Upgrade Guide

### From v6.x to v10.0

1. **Backup your configuration** (if you have custom settings)
2. **Pull the latest code**: `git pull origin main`
3. **Update PowerShell**: Ensure you have PowerShell 7.0+
4. **Install dependencies**: `Install-Module Pester -MinimumVersion 5.0.0`
5. **Run the application**: `.\AI-Cleaner.ps1`
6. **Reconfigure settings** in the new UI

**Breaking Changes:**
- Configuration format changed from embedded to JSON file
- Module system requires explicit import
- Some function signatures changed (internal only)

---

## Roadmap

### v10.1 (Next Minor Release)
- [ ] Task Scheduler integration
- [ ] Whitelist/Blacklist rules
- [ ] Export reports (CSV, JSON, HTML)
- [ ] Toast notifications
- [ ] Multi-language support (Romanian, English)

### v11.0 (Future Major Release)
- [ ] Cloud backup integration
- [ ] Network drive scanning
- [ ] Registry cleanup
- [ ] Startup optimizer
- [ ] System health dashboard
- [ ] PowerShell Gallery publishing

---

[10.0.0]: https://github.com/Gzeu/ai-smart-cleaner/releases/tag/v10.0.0
[6.2]: https://github.com/Gzeu/ai-smart-cleaner/releases/tag/v6.2
[6.1]: https://github.com/Gzeu/ai-smart-cleaner/releases/tag/v6.1
[6.0]: https://github.com/Gzeu/ai-smart-cleaner/releases/tag/v6.0
