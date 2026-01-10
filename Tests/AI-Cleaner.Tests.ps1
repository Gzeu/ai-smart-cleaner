#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }
<#
.SYNOPSIS
    Pester tests for AI Smart Cleaner

.DESCRIPTION
    Comprehensive unit tests for core functionality of the AI Smart Cleaner.
    Tests utility functions, scanning operations, and configuration management.

.NOTES
    Author: Gzeu
    Version: 10.0
    Requires: Pester 5.0+
#>

BeforeAll {
    # Import the module
    $modulePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'AI-Cleaner-Core.psm1'
    Import-Module $modulePath -Force
}

Describe 'Format-ByteSize' {
    Context 'Basic formatting' {
        It 'Formats 0 bytes correctly' {
            Format-ByteSize -Size 0 | Should -Be '0 B'
        }

        It 'Formats bytes correctly' {
            Format-ByteSize -Size 512 | Should -Be '512.00 B'
        }

        It 'Formats KiB correctly' {
            Format-ByteSize -Size 1024 | Should -Be '1.00 KiB'
            Format-ByteSize -Size 2048 | Should -Be '2.00 KiB'
        }

        It 'Formats MiB correctly' {
            Format-ByteSize -Size 1048576 | Should -Be '1.00 MiB'
            Format-ByteSize -Size (5 * 1024 * 1024) | Should -Be '5.00 MiB'
        }

        It 'Formats GiB correctly' {
            Format-ByteSize -Size (1024 * 1024 * 1024) | Should -Be '1.00 GiB'
            Format-ByteSize -Size (10 * 1024 * 1024 * 1024) | Should -Be '10.00 GiB'
        }

        It 'Formats TiB correctly' {
            Format-ByteSize -Size ([long]1024 * 1024 * 1024 * 1024) | Should -Be '1.00 TiB'
        }

        It 'Handles negative sizes' {
            Format-ByteSize -Size -100 | Should -Be 'Invalid Size'
        }
    }

    Context 'Edge cases' {
        It 'Handles maximum long value' {
            $maxLong = [long]::MaxValue
            $result = Format-ByteSize -Size $maxLong
            $result | Should -Match 'PiB$'
        }

        It 'Formats decimal values correctly' {
            Format-ByteSize -Size 1536 | Should -Be '1.50 KiB'
        }
    }
}

Describe 'Get-CleanupTargets' {
    Context 'Target discovery' {
        It 'Returns a hashtable' {
            $targets = Get-CleanupTargets
            $targets | Should -BeOfType [hashtable]
        }

        It 'Contains expected categories' {
            $targets = Get-CleanupTargets
            $targets.Keys | Should -Contain 'Temp'
            $targets.Keys | Should -Contain 'Cache'
            $targets.Keys | Should -Contain 'Logs'
        }

        It 'Returns arrays of paths' {
            $targets = Get-CleanupTargets
            $targets['Temp'] | Should -BeOfType [array]
        }

        It 'Only includes valid paths' {
            $targets = Get-CleanupTargets
            foreach ($category in $targets.Keys) {
                foreach ($path in $targets[$category]) {
                    Test-Path $path | Should -Be $true -Because "Path $path should exist"
                }
            }
        }
    }

    Context 'Custom paths' {
        It 'Includes custom paths when provided' {
            $customPath = $env:TEMP
            $targets = Get-CleanupTargets -IncludeCustomPaths @($customPath)
            $targets.Keys | Should -Contain 'Custom'
            $targets['Custom'] | Should -Contain $customPath
        }
    }
}

Describe 'CleanerConfig Class' {
    Context 'Configuration management' {
        BeforeEach {
            $testConfigPath = Join-Path $TestDrive 'test-config.json'
        }

        It 'Creates default configuration' {
            $config = [CleanerConfig]::new()
            $config.SafeMode | Should -Be $true
            $config.MaxThreads | Should -Be 4
        }

        It 'Saves configuration to file' {
            $config = [CleanerConfig]::new()
            $config.SafeMode = $false
            $config.MaxThreads = 8
            $config.Save($testConfigPath)
            
            Test-Path $testConfigPath | Should -Be $true
            $content = Get-Content $testConfigPath -Raw
            $content | Should -Match '"SafeMode"'
            $content | Should -Match '"MaxThreads"'
        }

        It 'Loads configuration from file' {
            # Create a test config
            $originalConfig = [CleanerConfig]::new()
            $originalConfig.SafeMode = $false
            $originalConfig.MaxThreads = 8
            $originalConfig.GeminiApiKey = 'test-key-123'
            $originalConfig.Save($testConfigPath)
            
            # Load it back
            $loadedConfig = [CleanerConfig]::Load($testConfigPath)
            $loadedConfig.SafeMode | Should -Be $false
            $loadedConfig.MaxThreads | Should -Be 8
            $loadedConfig.GeminiApiKey | Should -Be 'test-key-123'
        }

        It 'Returns default config if file does not exist' {
            $config = [CleanerConfig]::Load((Join-Path $TestDrive 'nonexistent.json'))
            $config | Should -Not -BeNullOrEmpty
            $config.SafeMode | Should -Be $true
        }
    }
}

Describe 'Write-CleanerLog' {
    Context 'Logging functionality' {
        BeforeEach {
            $testLogPath = Join-Path $TestDrive 'test.log'
        }

        It 'Writes to file' {
            Write-CleanerLog -Message 'Test message' -Level Info -LogPath $testLogPath
            Test-Path $testLogPath | Should -Be $true
            $content = Get-Content $testLogPath
            $content | Should -Match 'Test message'
            $content | Should -Match '\[Info\]'
        }

        It 'Supports different log levels' {
            $levels = @('Info', 'Warning', 'Error', 'Success', 'Debug')
            foreach ($level in $levels) {
                Write-CleanerLog -Message "Test $level" -Level $level -LogPath $testLogPath
            }
            
            $content = Get-Content $testLogPath
            foreach ($level in $levels) {
                $content | Should -Match "\[$level\]"
            }
        }

        It 'Includes timestamps' {
            Write-CleanerLog -Message 'Test' -Level Info -LogPath $testLogPath
            $content = Get-Content $testLogPath
            $content | Should -Match '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}'
        }
    }
}

Describe 'Invoke-ParallelScan' -Tag 'Integration' {
    Context 'Parallel scanning' {
        BeforeAll {
            # Create test directory structure
            $testRoot = Join-Path $TestDrive 'scan-test'
            New-Item -Path $testRoot -ItemType Directory -Force
            
            # Create some test files
            for ($i = 1; $i -le 5; $i++) {
                $content = 'x' * (1024 * $i) # Create files of varying sizes
                Set-Content -Path (Join-Path $testRoot "file$i.txt") -Value $content
            }
        }

        It 'Scans directories and returns results' {
            $results = Invoke-ParallelScan -Paths @($testRoot) -MaxThreads 2
            $results | Should -Not -BeNullOrEmpty
            $results[0].Path | Should -Be $testRoot
            $results[0].Files | Should -Be 5
            $results[0].Success | Should -Be $true
        }

        It 'Returns size information' {
            $results = Invoke-ParallelScan -Paths @($testRoot)
            $results[0].Size | Should -BeGreaterThan 0
        }

        It 'Handles non-existent paths gracefully' {
            $results = Invoke-ParallelScan -Paths @((Join-Path $TestDrive 'nonexistent'))
            $results | Should -BeNullOrEmpty
        }

        It 'Respects MaxThreads parameter' {
            $results = Invoke-ParallelScan -Paths @($testRoot) -MaxThreads 1
            $results | Should -Not -BeNullOrEmpty
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module AI-Cleaner-Core -Force -ErrorAction SilentlyContinue
}
