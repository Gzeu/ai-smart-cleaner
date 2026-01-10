# Contributing to AI Smart Cleaner

Thank you for your interest in contributing to AI Smart Cleaner! 🎉

This document provides guidelines and instructions for contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing Guidelines](#testing-guidelines)
- [Coding Standards](#coding-standards)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)

## Code of Conduct

This project follows a simple code of conduct:

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```powershell
   git clone https://github.com/YOUR-USERNAME/ai-smart-cleaner.git
   cd ai-smart-cleaner
   ```
3. **Add upstream remote**:
   ```powershell
   git remote add upstream https://github.com/Gzeu/ai-smart-cleaner.git
   ```

## Development Setup

### Prerequisites

- **PowerShell 7.0+** ([Download](https://github.com/PowerShell/PowerShell/releases))
- **Pester 5.0+** (for testing):
  ```powershell
  Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck
  ```
- **Git** for version control
- **Visual Studio Code** (recommended) with PowerShell extension

### Initial Setup

```powershell
# Create your config file
Copy-Item AI-Cleaner-Config.json.template AI-Cleaner-Config.json

# Import the module
Import-Module ./AI-Cleaner-Core.psm1

# Run tests to verify setup
Invoke-Pester ./Tests
```

## Making Changes

### Branching Strategy

- `main` - Stable release branch
- `develop` - Development branch (if applicable)
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical fixes for production

### Create a Feature Branch

```powershell
git checkout -b feature/your-feature-name
```

### Work on Your Changes

1. Make your changes in logical, focused commits
2. Write or update tests for your changes
3. Update documentation as needed
4. Test thoroughly on Windows 10 and 11

## Testing Guidelines

### Running Tests

```powershell
# Run all tests
Invoke-Pester ./Tests

# Run specific test file
Invoke-Pester ./Tests/AI-Cleaner.Tests.ps1

# Run with code coverage
$config = New-PesterConfiguration
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = './AI-Cleaner-Core.psm1'
Invoke-Pester -Configuration $config
```

### Writing Tests

- Use Pester 5+ syntax
- Test both success and failure scenarios
- Mock external dependencies (API calls, file system)
- Aim for 80%+ code coverage

**Example Test:**

```powershell
Describe 'New-Function' {
    Context 'When given valid input' {
        It 'Returns expected result' {
            $result = New-Function -Parameter 'value'
            $result | Should -Be 'expected'
        }
    }
    
    Context 'When given invalid input' {
        It 'Throws appropriate error' {
            { New-Function -Parameter $null } | Should -Throw
        }
    }
}
```

## Coding Standards

### PowerShell Style Guide

1. **Indentation**: 4 spaces (no tabs)
2. **Line Length**: Maximum 120 characters
3. **Naming Conventions**:
   - Functions: `Verb-Noun` (e.g., `Get-CleanupTargets`)
   - Variables: `$camelCase` (e.g., `$totalSize`)
   - Constants: `$UPPER_CASE` (e.g., `$MAX_THREADS`)

4. **Function Structure**:
   ```powershell
   <#
   .SYNOPSIS
       Brief description
   
   .DESCRIPTION
       Detailed description
   
   .PARAMETER ParamName
       Parameter description
   
   .EXAMPLE
       Example usage
   #>
   function Verb-Noun {
       [CmdletBinding()]
       param(
           [Parameter(Mandatory)]
           [string]$ParamName
       )
       
       # Implementation
   }
   ```

5. **Error Handling**:
   ```powershell
   try {
       # Risky operation
   }
   catch {
       Write-CleanerLog -Message "Error: $($_.Exception.Message)" -Level Error
       # Handle gracefully
   }
   ```

6. **Comments**:
   - Use `#` for inline comments
   - Use `<# #>` for block comments
   - Document complex logic
   - Avoid obvious comments

### Best Practices

- ✅ Use approved PowerShell verbs (`Get-Verb` to list)
- ✅ Add parameter validation attributes
- ✅ Use `[CmdletBinding()]` for advanced functions
- ✅ Write pipeline-friendly functions
- ✅ Handle errors gracefully
- ✅ Use `Write-Verbose` for debug info
- ✅ Avoid aliases in scripts (use full cmdlet names)
- ✅ Use single quotes unless string interpolation needed
- ❌ Don't use `Write-Host` (use `Write-Output` or logging)
- ❌ Don't suppress errors without good reason

## Commit Messages

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, etc.)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks
- `perf` - Performance improvements

### Examples

```
feat(core): add parallel scanning with runspaces

Implements true parallel scanning using PowerShell runspaces
instead of jobs for better performance.

- Configurable thread count (1-16)
- Progress callbacks
- Error isolation per thread

Closes #42
```

```
fix(ui): resolve progress bar not updating

Progress bar was not updating due to UI thread blocking.
Added DoEvents calls to refresh UI during operations.

Fixes #38
```

## Pull Request Process

### Before Submitting

1. ✅ Update your branch with latest upstream:
   ```powershell
   git fetch upstream
   git rebase upstream/main
   ```

2. ✅ Run all tests:
   ```powershell
   Invoke-Pester ./Tests
   ```

3. ✅ Update documentation:
   - README.md for user-facing changes
   - CHANGELOG.md with your changes
   - Inline documentation for new functions

4. ✅ Check code quality:
   ```powershell
   # Run PSScriptAnalyzer
   Install-Module -Name PSScriptAnalyzer
   Invoke-ScriptAnalyzer -Path . -Recurse
   ```

### Submitting PR

1. **Push your changes**:
   ```powershell
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request** on GitHub with:
   - Clear title describing the change
   - Description of what changed and why
   - Reference any related issues
   - Screenshots for UI changes

3. **PR Template**:
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update
   
   ## Testing
   - [ ] Tests pass locally
   - [ ] Added new tests
   - [ ] Updated documentation
   
   ## Related Issues
   Closes #XX
   
   ## Screenshots (if applicable)
   ```

### Review Process

- Maintainer will review within 1-3 days
- Address review feedback promptly
- Keep PR focused and small when possible
- Be open to suggestions and discussions

## Reporting Bugs

### Before Reporting

1. Check [existing issues](https://github.com/Gzeu/ai-smart-cleaner/issues)
2. Try latest version
3. Gather error messages and logs

### Bug Report Template

```markdown
**Describe the Bug**
Clear description of the bug

**To Reproduce**
1. Step 1
2. Step 2
3. See error

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Screenshots**
If applicable

**Environment**
- OS: Windows 10/11
- PowerShell Version: 7.x
- AI Cleaner Version: 10.0.0

**Error Messages**
```
Paste error messages here
```

**Additional Context**
Any other relevant information
```

## Feature Requests

### Template

```markdown
**Feature Description**
Clear description of the feature

**Problem It Solves**
What problem does this solve?

**Proposed Solution**
How should it work?

**Alternatives Considered**
Other approaches you've thought about

**Additional Context**
Mockups, examples, etc.
```

## Questions?

If you have questions about contributing:

- 💬 Open a [Discussion](https://github.com/Gzeu/ai-smart-cleaner/discussions)
- 📧 Contact maintainer via GitHub profile
- 🐛 File an issue for bugs

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in commit history

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to AI Smart Cleaner!** 🎉
