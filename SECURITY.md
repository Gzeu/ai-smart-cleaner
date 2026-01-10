# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Currently supported versions:

| Version | Supported          |
| ------- | ------------------ |
| 10.x    | :white_check_mark: |
| 6.x     | :x:                |

## Security Features

AI Smart Cleaner implements several security measures:

### 🔒 Data Protection

1. **API Key Security**
   - API keys stored in config files are not tracked by Git
   - Password-masked input in UI
   - Environment variable support for CI/CD
   - No hardcoded credentials

2. **Safe Mode**
   - Preview-only mode prevents accidental deletion
   - Explicit user confirmation required
   - Dry-run capability for testing

3. **Permission Handling**
   - Graceful handling of access denied errors
   - No elevation prompt without user consent
   - File operations respect Windows ACLs

### 🛡️ Code Security

1. **Input Validation**
   - All user inputs validated
   - Path validation prevents directory traversal
   - Type checking on all parameters

2. **Error Handling**
   - Try-catch blocks throughout
   - No sensitive data in error messages
   - Secure error logging

3. **Dependencies**
   - Minimal external dependencies
   - Built-in PowerShell modules only
   - No untrusted third-party code

### 🔐 Best Practices

1. **Execution Policy**
   ```powershell
   # Run with restricted execution for safety
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
   ```

2. **API Key Management**
   ```powershell
   # Never commit config with real API key
   # Use environment variables for automation
   $env:GEMINI_API_KEY = "your-key-here"
   ```

3. **Testing**
   - Always test in Safe Mode first
   - Review cleanup targets before deletion
   - Create restore points for critical systems

## Reporting a Vulnerability

### How to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, report security issues privately:

1. **GitHub Security Advisory**
   - Go to [Security Advisories](https://github.com/Gzeu/ai-smart-cleaner/security/advisories)
   - Click "Report a vulnerability"
   - Fill out the form with details

2. **Email**
   - Send details to the maintainer via GitHub profile
   - Include "SECURITY" in the subject line
   - Provide detailed description of the issue

### What to Include

Please provide:

- **Type of vulnerability** (e.g., privilege escalation, data exposure)
- **Steps to reproduce** the issue
- **Potential impact** of the vulnerability
- **Affected versions**
- **Suggested fix** (if you have one)
- **Your contact information** for follow-up

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Target**: Within 30 days for critical issues

### Disclosure Policy

1. **Coordinated Disclosure**
   - We follow coordinated disclosure principles
   - Security issues will not be disclosed until patched
   - Credit will be given to reporters (if desired)

2. **Public Disclosure**
   - After fix is released
   - Includes CVE if applicable
   - Details posted in security advisory

## Known Security Considerations

### File Deletion Operations

⚠️ **Warning**: This application deletes files. Use with caution.

- Always run in Safe Mode first
- Review cleanup targets carefully
- Create backups of important data
- Test on non-production systems first

### API Communications

- Gemini API calls use HTTPS
- API keys transmitted securely
- No sensitive data sent to external services
- User data stays on local machine

### PowerShell Execution

- Requires PowerShell 7+
- May require administrator privileges
- Execution policy must allow scripts
- Code signing recommended for production

## Security Checklist for Users

- [ ] Review code before running (open source advantage)
- [ ] Use Safe Mode for first run
- [ ] Keep API keys secure
- [ ] Run as limited user when possible
- [ ] Enable restore point creation
- [ ] Review logs after cleanup
- [ ] Keep PowerShell updated
- [ ] Use antivirus/antimalware software

## Security Updates

Security updates are released as soon as possible:

1. **Critical** (CVE): Immediate patch, same day if possible
2. **High**: Within 7 days
3. **Medium**: Within 30 days
4. **Low**: Next regular release

### How to Stay Updated

- ⭐ Star the repository
- 👁️ Watch for releases
- 📧 Subscribe to security advisories
- 🔔 Enable GitHub notifications

## Secure Configuration

### Example Secure Setup

```json
{
  "GeminiApiKey": "",
  "SafeMode": true,
  "MaxThreads": 4,
  "CreateBackup": true,
  "CleanupCategories": {
    "Temp": true,
    "Cache": false,
    "Logs": false,
    "Downloads": false
  }
}
```

### Security Recommendations

1. **Start Conservative**
   - Enable only Temp cleanup initially
   - Keep Safe Mode enabled
   - Use lower thread counts

2. **Gradual Expansion**
   - Add categories one at a time
   - Test each configuration
   - Monitor results carefully

3. **Production Use**
   - Document your configuration
   - Schedule regular backups
   - Test updates in staging first
   - Keep audit logs

## Compliance

### Data Privacy

- **No telemetry**: Application does not send usage data
- **No analytics**: No tracking or metrics collected
- **Local processing**: All operations performed locally
- **User control**: Complete control over data

### Open Source

- **Transparency**: All code is public
- **Auditable**: Anyone can review the code
- **Community**: Security through peer review
- **No backdoors**: Open source prevents hidden functionality

## Contact

For security concerns:

- 🔒 [Report Security Issue](https://github.com/Gzeu/ai-smart-cleaner/security/advisories/new)
- 💬 [Security Discussions](https://github.com/Gzeu/ai-smart-cleaner/discussions)
- 👤 [Maintainer Profile](https://github.com/Gzeu)

## Acknowledgments

We appreciate responsible disclosure from:

- Security researchers
- Community members
- Users who report issues

*Thank you for helping keep AI Smart Cleaner secure!*

---

**Last Updated**: January 10, 2026
**Policy Version**: 1.0
