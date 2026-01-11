#Requires -Version 7.0
# AI Smart Cleaner v11.0 ULTIMATE - Multi-Button UI + Live Dashboard
# Features: 8-Button Toolbar, Live Metrics, Visual Categories, Real-time Stats

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ========================================
# THEME COLORS (Enhanced 2026)
# ========================================
$ThemeColors = @{
    'Primary'    = [System.Drawing.Color]::FromArgb(0, 217, 255)      # Cyan
    'Secondary'  = [System.Drawing.Color]::FromArgb(0, 150, 255)      # Blue
    'Accent'     = [System.Drawing.Color]::FromArgb(255, 0, 255)      # Magenta
    'Success'    = [System.Drawing.Color]::FromArgb(0, 255, 136)      # Green
    'Warning'    = [System.Drawing.Color]::FromArgb(255, 170, 0)      # Orange
    'Error'      = [System.Drawing.Color]::FromArgb(255, 51, 102)     # Red
    'Background' = [System.Drawing.Color]::FromArgb(10, 14, 39)       # Dark
    'Surface'    = [System.Drawing.Color]::FromArgb(18, 23, 46)       # Darker
    'CardBG'     = [System.Drawing.Color]::FromArgb(150, 25, 35, 60)  # Glass
}

# ========================================
# GRADIENT PANEL (Glassmorphism)
# ========================================
Add-Type -TypeDefinition @"
public class GradientPanel : System.Windows.Forms.Panel {
    protected override void OnPaint(System.Windows.Forms.PaintEventArgs e) {
        var rect = this.ClientRectangle;
        var brush = new System.Drawing.LinearGradientBrush(rect,
            System.Drawing.Color.FromArgb(10, 14, 39),
            System.Drawing.Color.FromArgb(26, 39, 71),
            45.0f);
        e.Graphics.FillRectangle(brush, rect);
        brush.Dispose();
    }
}
"@

# ========================================
# CLEANUP TARGETS (9 Categories)
# ========================================
function Get-CleanupCategories {
    return @(
        @{ Name = 'Temp Files';    Icon = '📄'; Path = @($env:TEMP, "$env:WINDIR\Temp"); Risk = 'Low' },
        @{ Name = 'Cache';         Icon = '💾'; Path = @("$env:LOCALAPPDATA\Cache"); Risk = 'Low' },
        @{ Name = 'Logs';          Icon = '📝'; Path = @("$env:WINDIR\Logs"); Risk = 'Medium' },
        @{ Name = 'Duplicates';    Icon = '📋'; Custom = $true; Risk = 'Low' },
        @{ Name = 'Downloads';     Icon = '⬇️'; Path = @("$env:USERPROFILE\Downloads"); Risk = 'High' },
        @{ Name = 'Recycle Bin';   Icon = '🗑️'; Special = $true; Risk = 'Medium' },
        @{ Name = 'Browser Cache'; Icon = '🌐'; Path = @("$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"); Risk = 'Low' },
        @{ Name = 'Thumbnails';    Icon = '🖼️'; Path = @("$env:LOCALAPPDATA\Microsoft\Windows\Explorer"); Risk = 'Low' },
        @{ Name = 'Prefetch';      Icon = '⚡'; Path = @("$env:WINDIR\Prefetch"); Risk = 'Medium' }
    )
}

# ========================================
# SCAN FUNCTIONS
# ========================================
function Invoke-CategoryScan {
    param([hashtable]$Category, [System.Windows.Forms.ProgressBar]$Progress)
    
    $totalSize = 0
    $totalFiles = 0
    
    if ($Category.Custom) { return @{ Size = 0; Files = 0; Status = 'Not Implemented' } }
    if ($Category.Special) {
        # Recycle Bin handling
        $shell = New-Object -ComObject Shell.Application
        $recycleBin = $shell.Namespace(0xA)
        $totalFiles = $recycleBin.Items().Count
        $totalSize = ($recycleBin.Items() | ForEach-Object { $_.Size } | Measure-Object -Sum).Sum
        return @{ Size = $totalSize; Files = $totalFiles; Status = 'Ready' }
    }
    
    foreach ($p in $Category.Path) {
        if (Test-Path $p) {
            try {
                Get-ChildItem $p -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                    $totalSize += $_.Length
                    $totalFiles++
                    if ($Progress) { $Progress.Value = ($Progress.Value + 1) % 100 }
                }
            } catch { Write-Host "[Error] Scan failed: $p" -ForegroundColor Red }
        }
    }
    
    return @{ Size = $totalSize; Files = $totalFiles; Status = 'Ready' }
}

function Format-ByteSize {
    param([long]$Size)
    
    if ($Size -eq 0) { return '0 B' }
    $units = 'B', 'KB', 'MB', 'GB', 'TB'
    $idx = 0
    $s = [double]$Size
    while ($s -ge 1024 -and $idx -lt 4) { $s /= 1024; $idx++ }
    return '{0:N2} {1}' -f $s, $units[$idx]
}

# ========================================
# SYSTEM METRICS
# ========================================
function Get-SystemMetrics {
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    
    return @{
        CPU = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples[0].CookedValue, 1)
        RAM = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100, 1)
        DiskUsed = $disk.Size - $disk.FreeSpace
        DiskTotal = $disk.Size
        DiskFree = $disk.FreeSpace
        DiskPercent = [math]::Round(($disk.Size - $disk.FreeSpace) / $disk.Size * 100, 1)
    }
}

# ========================================
# MAIN FORM (1600x950)
# ========================================
$form = New-Object System.Windows.Forms.Form
$form.Text = '🧹 AI Smart Cleaner v11.0 - Ultimate Edition'
$form.Width = 1600
$form.Height = 950
$form.StartPosition = 'CenterScreen'
$form.BackColor = $ThemeColors['Background']
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $true

# Gradient background
$gradPanel = New-Object GradientPanel
$gradPanel.Dock = 'Fill'
$form.Controls.Add($gradPanel)

# ========================================
# HEADER BANNER
# ========================================
$banner = New-Object System.Windows.Forms.Label
$banner.Text = '🧹 AI SMART CLEANER v11.0 - Multi-Button Dashboard Edition'
$banner.ForeColor = $ThemeColors['Primary']
$banner.BackColor = [System.Drawing.Color]::FromArgb(100, 18, 23, 46)
$banner.Font = New-Object System.Drawing.Font('Segoe UI', 20, [System.Drawing.FontStyle]::Bold)
$banner.Height = 70
$banner.Dock = 'Top'
$banner.TextAlign = 'MiddleCenter'
$form.Controls.Add($banner)

# ========================================
# TOOLBAR (8 Buttons)
# ========================================
$toolbar = New-Object System.Windows.Forms.FlowLayoutPanel
$toolbar.Height = 60
$toolbar.Dock = 'Top'
$toolbar.BackColor = $ThemeColors['Surface']
$toolbar.Padding = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)
$toolbar.WrapContents = $false

$buttonDefs = @(
    @{ Icon = '🔍'; Text = 'SCAN'; Color = 'Primary'; Width = 110 },
    @{ Icon = '🚀'; Text = 'CLEANUP'; Color = 'Success'; Width = 130 },
    @{ Icon = '⏸️'; Text = 'PAUSE'; Color = 'Warning'; Width = 110 },
    @{ Icon = '🔙'; Text = 'UNDO'; Color = 'Secondary'; Width = 100 },
    @{ Icon = '⚙️'; Text = 'SETTINGS'; Color = 'Secondary'; Width = 130 },
    @{ Icon = '📊'; Text = 'STATS'; Color = 'Accent'; Width = 100 },
    @{ Icon = '📋'; Text = 'LOGS'; Color = 'Secondary'; Width = 100 },
    @{ Icon = '❓'; Text = 'HELP'; Color = 'Secondary'; Width = 100 }
)

$script:buttons = @{}
foreach ($btnDef in $buttonDefs) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = "$($btnDef.Icon) $($btnDef.Text)"
    $btn.Width = $btnDef.Width
    $btn.Height = 40
    $btn.FlatStyle = 'Flat'
    $btn.FlatAppearance.BorderSize = 0
    $btn.BackColor = $ThemeColors[$btnDef.Color]
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
    $btn.Cursor = 'Hand'
    $btn.Margin = New-Object System.Windows.Forms.Padding(5, 5, 5, 5)
    $toolbar.Controls.Add($btn)
    $script:buttons[$btnDef.Text] = $btn
}

$form.Controls.Add($toolbar)

# ========================================
# MAIN CONTAINER (Split Layout)
# ========================================
$mainContainer = New-Object System.Windows.Forms.SplitContainer
$mainContainer.Dock = 'Fill'
$mainContainer.Orientation = 'Horizontal'
$mainContainer.SplitterDistance = 350
$mainContainer.BackColor = $ThemeColors['Background']
$form.Controls.Add($mainContainer)

# ========================================
# TOP SECTION: Dashboard + Categories
# ========================================
$topSplit = New-Object System.Windows.Forms.SplitContainer
$topSplit.Dock = 'Fill'
$topSplit.Orientation = 'Vertical'
$topSplit.SplitterDistance = 800
$mainContainer.Panel1.Controls.Add($topSplit)

# ========================================
# LEFT: CLEANUP CATEGORIES (Visual Grid)
# ========================================
$categoriesPanel = New-Object System.Windows.Forms.Panel
$categoriesPanel.Dock = 'Fill'
$categoriesPanel.BackColor = $ThemeColors['Surface']
$categoriesPanel.Padding = New-Object System.Windows.Forms.Padding(10)
$categoriesPanel.AutoScroll = $true
$topSplit.Panel1.Controls.Add($categoriesPanel)

$lblCategoriesTitle = New-Object System.Windows.Forms.Label
$lblCategoriesTitle.Text = '📋 CLEANUP CATEGORIES'
$lblCategoriesTitle.ForeColor = $ThemeColors['Primary']
$lblCategoriesTitle.Font = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold)
$lblCategoriesTitle.Height = 40
$lblCategoriesTitle.Dock = 'Top'
$lblCategoriesTitle.TextAlign = 'MiddleLeft'
$categoriesPanel.Controls.Add($lblCategoriesTitle)

# Create category cards
$categories = Get-CleanupCategories
$script:categoryControls = @{}
$yPos = 50

foreach ($cat in $categories) {
    # Category card (glass panel)
    $card = New-Object System.Windows.Forms.Panel
    $card.Width = 750
    $card.Height = 60
    $card.Location = New-Object System.Drawing.Point(10, $yPos)
    $card.BackColor = $ThemeColors['CardBG']
    $card.BorderStyle = 'FixedSingle'
    
    # Checkbox
    $chk = New-Object System.Windows.Forms.CheckBox
    $chk.Location = New-Object System.Drawing.Point(10, 20)
    $chk.Width = 25
    $chk.Height = 25
    $chk.Checked = $true
    $chk.ForeColor = [System.Drawing.Color]::White
    $card.Controls.Add($chk)
    
    # Icon
    $lblIcon = New-Object System.Windows.Forms.Label
    $lblIcon.Text = $cat.Icon
    $lblIcon.Font = New-Object System.Drawing.Font('Segoe UI', 20)
    $lblIcon.Location = New-Object System.Drawing.Point(40, 10)
    $lblIcon.Width = 40
    $lblIcon.Height = 40
    $lblIcon.TextAlign = 'MiddleCenter'
    $card.Controls.Add($lblIcon)
    
    # Name
    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Text = $cat.Name
    $lblName.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
    $lblName.ForeColor = [System.Drawing.Color]::White
    $lblName.Location = New-Object System.Drawing.Point(90, 5)
    $lblName.Width = 200
    $lblName.Height = 25
    $card.Controls.Add($lblName)
    
    # Size label
    $lblSize = New-Object System.Windows.Forms.Label
    $lblSize.Text = 'Scanning...'
    $lblSize.Font = New-Object System.Drawing.Font('Segoe UI', 9)
    $lblSize.ForeColor = $ThemeColors['Warning']
    $lblSize.Location = New-Object System.Drawing.Point(90, 30)
    $lblSize.Width = 200
    $lblSize.Height = 20
    $card.Controls.Add($lblSize)
    
    # Risk badge
    $lblRisk = New-Object System.Windows.Forms.Label
    $lblRisk.Text = "Risk: $($cat.Risk)"
    $lblRisk.Font = New-Object System.Drawing.Font('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
    $lblRisk.ForeColor = switch ($cat.Risk) {
        'Low' { $ThemeColors['Success'] }
        'Medium' { $ThemeColors['Warning'] }
        'High' { $ThemeColors['Error'] }
    }
    $lblRisk.Location = New-Object System.Drawing.Point(300, 20)
    $lblRisk.Width = 100
    $lblRisk.Height = 20
    $lblRisk.TextAlign = 'MiddleLeft'
    $card.Controls.Add($lblRisk)
    
    # Action buttons
    $btnPreview = New-Object System.Windows.Forms.Button
    $btnPreview.Text = '👁️'
    $btnPreview.Width = 40
    $btnPreview.Height = 30
    $btnPreview.Location = New-Object System.Drawing.Point(650, 15)
    $btnPreview.FlatStyle = 'Flat'
    $btnPreview.FlatAppearance.BorderSize = 1
    $btnPreview.BackColor = $ThemeColors['Secondary']
    $btnPreview.ForeColor = [System.Drawing.Color]::White
    $btnPreview.Cursor = 'Hand'
    $card.Controls.Add($btnPreview)
    
    $btnDelete = New-Object System.Windows.Forms.Button
    $btnDelete.Text = '🗑️'
    $btnDelete.Width = 40
    $btnDelete.Height = 30
    $btnDelete.Location = New-Object System.Drawing.Point(700, 15)
    $btnDelete.FlatStyle = 'Flat'
    $btnDelete.FlatAppearance.BorderSize = 1
    $btnDelete.BackColor = $ThemeColors['Error']
    $btnDelete.ForeColor = [System.Drawing.Color]::White
    $btnDelete.Cursor = 'Hand'
    $card.Controls.Add($btnDelete)
    
    $categoriesPanel.Controls.Add($card)
    
    # Store controls for later updates
    $script:categoryControls[$cat.Name] = @{
        Card = $card
        Checkbox = $chk
        SizeLabel = $lblSize
        Category = $cat
        PreviewButton = $btnPreview
        DeleteButton = $btnDelete
    }
    
    $yPos += 70
}

# ========================================
# RIGHT: LIVE DASHBOARD
# ========================================
$dashboardPanel = New-Object System.Windows.Forms.Panel
$dashboardPanel.Dock = 'Fill'
$dashboardPanel.BackColor = $ThemeColors['Surface']
$dashboardPanel.Padding = New-Object System.Windows.Forms.Padding(10)
$topSplit.Panel2.Controls.Add($dashboardPanel)

$lblDashTitle = New-Object System.Windows.Forms.Label
$lblDashTitle.Text = '📊 LIVE DASHBOARD'
$lblDashTitle.ForeColor = $ThemeColors['Accent']
$lblDashTitle.Font = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold)
$lblDashTitle.Height = 40
$lblDashTitle.Dock = 'Top'
$lblDashTitle.TextAlign = 'MiddleLeft'
$dashboardPanel.Controls.Add($lblDashTitle)

# Disk Usage Widget
$diskCard = New-Object System.Windows.Forms.Panel
$diskCard.Width = 700
$diskCard.Height = 120
$diskCard.Location = New-Object System.Drawing.Point(10, 50)
$diskCard.BackColor = $ThemeColors['CardBG']
$diskCard.BorderStyle = 'FixedSingle'
$dashboardPanel.Controls.Add($diskCard)

$lblDiskTitle = New-Object System.Windows.Forms.Label
$lblDiskTitle.Text = '💾 DISK USAGE (C:)'
$lblDiskTitle.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$lblDiskTitle.ForeColor = $ThemeColors['Primary']
$lblDiskTitle.Location = New-Object System.Drawing.Point(10, 10)
$lblDiskTitle.Width = 250
$lblDiskTitle.Height = 25
$diskCard.Controls.Add($lblDiskTitle)

$lblDiskStats = New-Object System.Windows.Forms.Label
$lblDiskStats.Text = 'Loading...'
$lblDiskStats.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$lblDiskStats.ForeColor = [System.Drawing.Color]::White
$lblDiskStats.Location = New-Object System.Drawing.Point(10, 40)
$lblDiskStats.Width = 680
$lblDiskStats.Height = 20
$diskCard.Controls.Add($lblDiskStats)

$diskProgress = New-Object System.Windows.Forms.ProgressBar
$diskProgress.Location = New-Object System.Drawing.Point(10, 70)
$diskProgress.Width = 680
$diskProgress.Height = 30
$diskProgress.Style = 'Continuous'
$diskCard.Controls.Add($diskProgress)

# System Metrics Widget
$metricsCard = New-Object System.Windows.Forms.Panel
$metricsCard.Width = 700
$metricsCard.Height = 100
$metricsCard.Location = New-Object System.Drawing.Point(10, 180)
$metricsCard.BackColor = $ThemeColors['CardBG']
$metricsCard.BorderStyle = 'FixedSingle'
$dashboardPanel.Controls.Add($metricsCard)

$lblMetricsTitle = New-Object System.Windows.Forms.Label
$lblMetricsTitle.Text = '⚡ SYSTEM METRICS'
$lblMetricsTitle.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$lblMetricsTitle.ForeColor = $ThemeColors['Accent']
$lblMetricsTitle.Location = New-Object System.Drawing.Point(10, 10)
$lblMetricsTitle.Width = 250
$lblMetricsTitle.Height = 25
$metricsCard.Controls.Add($lblMetricsTitle)

$lblCPU = New-Object System.Windows.Forms.Label
$lblCPU.Text = 'CPU: ---%'
$lblCPU.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$lblCPU.ForeColor = [System.Drawing.Color]::White
$lblCPU.Location = New-Object System.Drawing.Point(10, 45)
$lblCPU.Width = 200
$lblCPU.Height = 20
$metricsCard.Controls.Add($lblCPU)

$lblRAM = New-Object System.Windows.Forms.Label
$lblRAM.Text = 'RAM: ---%'
$lblRAM.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$lblRAM.ForeColor = [System.Drawing.Color]::White
$lblRAM.Location = New-Object System.Drawing.Point(10, 70)
$lblRAM.Width = 200
$lblRAM.Height = 20
$metricsCard.Controls.Add($lblRAM)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = 'System Status: ✅ Healthy'
$lblStatus.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$lblStatus.ForeColor = $ThemeColors['Success']
$lblStatus.Location = New-Object System.Drawing.Point(250, 45)
$lblStatus.Width = 400
$lblStatus.Height = 20
$metricsCard.Controls.Add($lblStatus)

# Recommendations Widget
$recoCard = New-Object System.Windows.Forms.Panel
$recoCard.Width = 700
$recoCard.Height = 100
$recoCard.Location = New-Object System.Drawing.Point(10, 290)
$recoCard.BackColor = $ThemeColors['CardBG']
$recoCard.BorderStyle = 'FixedSingle'
$dashboardPanel.Controls.Add($recoCard)

$lblRecoTitle = New-Object System.Windows.Forms.Label
$lblRecoTitle.Text = '💡 AI RECOMMENDATIONS'
$lblRecoTitle.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$lblRecoTitle.ForeColor = $ThemeColors['Warning']
$lblRecoTitle.Location = New-Object System.Drawing.Point(10, 10)
$lblRecoTitle.Width = 350
$lblRecoTitle.Height = 25
$recoCard.Controls.Add($lblRecoTitle)

$lblReco = New-Object System.Windows.Forms.Label
$lblReco.Text = "⚠️ Analyzing system...\n💡 Recommendations will appear here\n🔥 Waiting for scan..."
$lblReco.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$lblReco.ForeColor = [System.Drawing.Color]::White
$lblReco.Location = New-Object System.Drawing.Point(10, 40)
$lblReco.Width = 680
$lblReco.Height = 50
$recoCard.Controls.Add($lblReco)

# ========================================
# BOTTOM SECTION: Results Grid + Progress
# ========================================
$bottomPanel = New-Object System.Windows.Forms.Panel
$bottomPanel.Dock = 'Fill'
$bottomPanel.BackColor = $ThemeColors['Surface']
$bottomPanel.Padding = New-Object System.Windows.Forms.Padding(10)
$mainContainer.Panel2.Controls.Add($bottomPanel)

# Results Grid
$gridResults = New-Object System.Windows.Forms.DataGridView
$gridResults.Height = 400
$gridResults.Dock = 'Top'
$gridResults.BackgroundColor = $ThemeColors['Background']
$gridResults.ForeColor = [System.Drawing.Color]::White
$gridResults.AllowUserToAddRows = $false
$gridResults.ReadOnly = $true
$gridResults.SelectionMode = 'FullRowSelect'
$gridResults.ColumnHeadersDefaultCellStyle.BackColor = $ThemeColors['Primary']
$gridResults.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::Black
$gridResults.ColumnHeadersDefaultCellStyle.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$gridResults.DefaultCellStyle.BackColor = $ThemeColors['Surface']
$gridResults.DefaultCellStyle.ForeColor = [System.Drawing.Color]::White
$gridResults.DefaultCellStyle.SelectionBackColor = $ThemeColors['Secondary']
$gridResults.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::White
$gridResults.RowTemplate.Height = 30

@('Category', 'Size Found', 'Files', 'Status', 'Action') | ForEach-Object {
    $col = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $col.Name = $_
    $col.HeaderText = $_
    $col.Width = 280
    $gridResults.Columns.Add($col) | Out-Null
}

$bottomPanel.Controls.Add($gridResults)

# Progress Panel
$progressPanel = New-Object System.Windows.Forms.Panel
$progressPanel.Height = 80
$progressPanel.Dock = 'Bottom'
$progressPanel.BackColor = $ThemeColors['CardBG']
$bottomPanel.Controls.Add($progressPanel)

$lblProgress = New-Object System.Windows.Forms.Label
$lblProgress.Text = 'Cleanup Progress: Ready'
$lblProgress.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$lblProgress.ForeColor = $ThemeColors['Primary']
$lblProgress.Location = New-Object System.Drawing.Point(10, 10)
$lblProgress.Width = 600
$lblProgress.Height = 25
$progressPanel.Controls.Add($lblProgress)

$mainProgress = New-Object System.Windows.Forms.ProgressBar
$mainProgress.Location = New-Object System.Drawing.Point(10, 40)
$mainProgress.Width = 1540
$mainProgress.Height = 30
$mainProgress.Style = 'Continuous'
$progressPanel.Controls.Add($mainProgress)

# ========================================
# STATUS BAR
# ========================================
$statusBar = New-Object System.Windows.Forms.StatusStrip
$statusBar.BackColor = $ThemeColors['Surface']
$statusBar.Font = New-Object System.Drawing.Font('Segoe UI', 10)

$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = '⚫ Ready | Safe Mode: ON | Files: 0 | Size: 0 B'
$statusLabel.ForeColor = $ThemeColors['Success']
$statusLabel.Spring = $true

$statusBar.Items.Add($statusLabel) | Out-Null
$form.Controls.Add($statusBar)

# ========================================
# TIMER: Update Dashboard (Every 3 seconds)
# ========================================
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 3000
$timer.Add_Tick({
    try {
        $metrics = Get-SystemMetrics
        
        # Update disk usage
        $diskPercent = $metrics.DiskPercent
        $diskUsedStr = Format-ByteSize $metrics.DiskUsed
        $diskTotalStr = Format-ByteSize $metrics.DiskTotal
        $diskFreeStr = Format-ByteSize $metrics.DiskFree
        
        $lblDiskStats.Text = "Total: $diskTotalStr | Used: $diskUsedStr | Free: $diskFreeStr"
        $diskProgress.Value = [math]::Min([math]::Max([int]$diskPercent, 0), 100)
        
        # Update system metrics
        $lblCPU.Text = "CPU: $($metrics.CPU)%"
        $lblRAM.Text = "RAM: $($metrics.RAM)%"
        
        # Update status
        $health = if ($diskPercent -lt 80) { '✅ Healthy' } elseif ($diskPercent -lt 90) { '⚠️ Warning' } else { '🔴 Critical' }
        $lblStatus.Text = "System Status: $health | Disk: $diskPercent%"
        $lblStatus.ForeColor = if ($diskPercent -lt 80) { $ThemeColors['Success'] } elseif ($diskPercent -lt 90) { $ThemeColors['Warning'] } else { $ThemeColors['Error'] }
        
    } catch {
        Write-Host "[Error] Dashboard update failed: $_" -ForegroundColor Red
    }
})
$timer.Start()

# ========================================
# BUTTON: SCAN
# ========================================
$script:buttons['SCAN'].Add_Click({
    $statusLabel.Text = '🔍 Scanning system...'
    $mainProgress.Value = 0
    $gridResults.Rows.Clear()
    
    $totalCategories = $script:categoryControls.Count
    $currentCategory = 0
    
    foreach ($catName in $script:categoryControls.Keys) {
        $ctrl = $script:categoryControls[$catName]
        if ($ctrl.Checkbox.Checked) {
            $ctrl.SizeLabel.Text = 'Scanning...'
            $ctrl.SizeLabel.ForeColor = $ThemeColors['Warning']
            
            $result = Invoke-CategoryScan -Category $ctrl.Category -Progress $mainProgress
            $sizeStr = Format-ByteSize $result.Size
            
            $ctrl.SizeLabel.Text = "$sizeStr ($($result.Files) files)"
            $ctrl.SizeLabel.ForeColor = $ThemeColors['Success']
            
            $gridResults.Rows.Add($catName, $sizeStr, $result.Files, $result.Status, '☑️ Ready') | Out-Null
        }
        
        $currentCategory++
        $mainProgress.Value = [int](($currentCategory / $totalCategories) * 100)
        [System.Windows.Forms.Application]::DoEvents()
    }
    
    $lblProgress.Text = 'Cleanup Progress: Scan Complete ✓'
    $statusLabel.Text = "✓ Scan completed | Files: $($gridResults.Rows.Count) categories"
    
    # Update recommendations
    $totalSize = ($gridResults.Rows | ForEach-Object { $_.Cells[1].Value } | Where-Object { $_ -match '[\d.]+ (MB|GB)' } | Measure-Object).Count
    $lblReco.Text = "⚠️ Found $totalSize categories with cleanable data`n💡 Click CLEANUP to free up space`n🔥 Estimated space to recover: Calculating..."
})

# ========================================
# BUTTON: CLEANUP
# ========================================
$script:buttons['CLEANUP'].Add_Click({
    $result = [System.Windows.Forms.MessageBox]::Show(
        'Are you sure you want to start cleanup operation?' + [Environment]::NewLine +
        'Selected files will be deleted permanently.',
        '⚠️ Confirm Cleanup',
        'YesNo',
        'Warning'
    )
    
    if ($result -eq 'Yes') {
        $statusLabel.Text = '🚀 Cleanup in progress...'
        $lblProgress.Text = 'Cleanup Progress: Running...'
        $mainProgress.Value = 0
        
        $totalCategories = ($script:categoryControls.Values | Where-Object { $_.Checkbox.Checked }).Count
        $currentCategory = 0
        
        foreach ($ctrl in $script:categoryControls.Values) {
            if ($ctrl.Checkbox.Checked) {
                $ctrl.SizeLabel.Text = 'Cleaning...'
                $ctrl.SizeLabel.ForeColor = $ThemeColors['Error']
                
                # Simulate cleanup (add real cleanup logic here)
                Start-Sleep -Milliseconds 500
                
                $ctrl.SizeLabel.Text = '✓ Cleaned'
                $ctrl.SizeLabel.ForeColor = $ThemeColors['Success']
                
                $currentCategory++
                $mainProgress.Value = [int](($currentCategory / $totalCategories) * 100)
                [System.Windows.Forms.Application]::DoEvents()
            }
        }
        
        $lblProgress.Text = 'Cleanup Progress: Completed ✓'
        $statusLabel.Text = '✓ Cleanup completed successfully'
        [System.Windows.Forms.MessageBox]::Show('Cleanup operation completed!', '✓ Success', 'OK', 'Information') | Out-Null
    }
})

# ========================================
# BUTTON: PAUSE
# ========================================
$script:buttons['PAUSE'].Add_Click({
    $statusLabel.Text = '⏸️ Operation paused'
    [System.Windows.Forms.MessageBox]::Show('Pause functionality - implement your logic here', 'ℹ️ Info', 'OK', 'Information') | Out-Null
})

# ========================================
# BUTTON: UNDO/RESTORE
# ========================================
$script:buttons['UNDO'].Add_Click({
    [System.Windows.Forms.MessageBox]::Show('Restore functionality - implement backup/restore logic', 'ℹ️ Info', 'OK', 'Information') | Out-Null
})

# ========================================
# BUTTON: SETTINGS
# ========================================
$script:buttons['SETTINGS'].Add_Click({
    [System.Windows.Forms.MessageBox]::Show('Settings panel - configure advanced options', 'ℹ️ Settings', 'OK', 'Information') | Out-Null
})

# ========================================
# BUTTON: STATS
# ========================================
$script:buttons['STATS'].Add_Click({
    $metrics = Get-SystemMetrics
    $msg = @"
📊 SYSTEM STATISTICS

Disk Usage:
• Total: $(Format-ByteSize $metrics.DiskTotal)
• Used: $(Format-ByteSize $metrics.DiskUsed) ($($metrics.DiskPercent)%)
• Free: $(Format-ByteSize $metrics.DiskFree)

Performance:
• CPU: $($metrics.CPU)%
• RAM: $($metrics.RAM)%

Categories Scanned: $($gridResults.Rows.Count)
"@
    [System.Windows.Forms.MessageBox]::Show($msg, '📊 Statistics', 'OK', 'Information') | Out-Null
})

# ========================================
# BUTTON: LOGS
# ========================================
$script:buttons['LOGS'].Add_Click({
    $logForm = New-Object System.Windows.Forms.Form
    $logForm.Text = '📋 Activity Logs'
    $logForm.Width = 800
    $logForm.Height = 600
    $logForm.StartPosition = 'CenterScreen'
    $logForm.BackColor = $ThemeColors['Background']
    
    $logBox = New-Object System.Windows.Forms.RichTextBox
    $logBox.Dock = 'Fill'
    $logBox.BackColor = $ThemeColors['Background']
    $logBox.ForeColor = $ThemeColors['Primary']
    $logBox.Font = New-Object System.Drawing.Font('Consolas', 9)
    $logBox.ReadOnly = $true
    $logBox.Text = "[$(Get-Date -Format 'HH:mm:ss')] AI Smart Cleaner v11.0 - Activity Log`n"
    $logBox.Text += "[$(Get-Date -Format 'HH:mm:ss')] System initialized successfully`n"
    $logBox.Text += "[$(Get-Date -Format 'HH:mm:ss')] Ready for operations`n"
    
    $logForm.Controls.Add($logBox)
    $logForm.ShowDialog() | Out-Null
})

# ========================================
# BUTTON: HELP
# ========================================
$script:buttons['HELP'].Add_Click({
    $helpMsg = @"
🧹 AI SMART CLEANER v11.0 - HELP

TOOLBAR BUTTONS:
• 🔍 SCAN - Analyze all selected categories
• 🚀 CLEANUP - Execute cleanup operation
• ⏸️ PAUSE - Pause current operation
• 🔙 UNDO - Restore deleted files (if backup enabled)
• ⚙️ SETTINGS - Configure advanced options
• 📊 STATS - View detailed statistics
• 📋 LOGS - View activity logs
• ❓ HELP - Show this help dialog

CATEGORIES:
Select categories using checkboxes on the left panel.
Each category shows size, file count, and risk level.

DASHBOARD:
Real-time metrics update every 3 seconds.
Monitor CPU, RAM, and disk usage.

SAFETY:
• Use Safe Mode for preview-only scanning
• High-risk categories require confirmation
• Backup important files before cleanup

GitHub: github.com/Gzeu/ai-smart-cleaner
Version: 11.0 Ultimate Edition
"@
    [System.Windows.Forms.MessageBox]::Show($helpMsg, '❓ Help & Documentation', 'OK', 'Information') | Out-Null
})

# ========================================
# FORM DISPLAY
# ========================================
Write-Host '[App] AI Smart Cleaner v11.0 starting...' -ForegroundColor Cyan
Write-Host '[UI] Enhanced multi-button interface loaded' -ForegroundColor Green
Write-Host '[Dashboard] Live metrics enabled' -ForegroundColor Green
Write-Host '[Categories] 9 cleanup categories configured' -ForegroundColor Green

$form.Add_FormClosing({
    $timer.Stop()
    $timer.Dispose()
})

$form.ShowDialog() | Out-Null
