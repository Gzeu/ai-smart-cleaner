# AI Smart Cleaner v11 - Enhanced UI Specification

## Overview

The v11 Enhanced UI represents a complete redesign of the user interface, focusing on modern glassmorphism aesthetics, accessibility, and multi-platform compatibility. This document specifies all UI components, themes, interactions, and technical implementation.

---

## Part 1: Design Philosophy

### Core Principles
1. **Glassmorphism with Dark Theme**: Frosted glass effect, high contrast
2. **Accessibility First**: WCAG 2.1 AA compliance, keyboard navigation
3. **Responsive Design**: Scales from tablet (1024px) to ultra-wide (4K)
4. **Low Resource Usage**: <300MB memory footprint
5. **Multi-Language**: 15+ languages with RTL support

---

## Part 2: Color Palette

### Primary Palette (Modern 2026)
```
Background:        #0A0E27  (Deep Navy)
Surface:           #121727  (Darker Navy)
Primary:           #00D9FF  (Cyan)
Secondary:         #0096FF  (Blue)
Accent:            #FF00FF  (Magenta)
Success:           #00FF88  (Green)
Warning:           #FFAA00  (Orange)
Error:             #FF3366  (Red)
```

### Semantic Usage
- **Primary**: Action buttons, active states, highlights
- **Secondary**: Secondary buttons, links, badges
- **Accent**: Decorative elements, hover states
- **Success**: Positive feedback, completion status
- **Warning**: Caution states, slow operations
- **Error**: Destructive actions, failed states

---

## Part 3: Typography

### Font Stack
```
Headings:     Segoe UI, -apple-system, sans-serif
Body:         Segoe UI, -apple-system, sans-serif
Mono:         Consolas, Monaco, monospace
```

### Font Sizes
- H1 (Page Title):    24px / Bold / Line 1.2
- H2 (Section):       18px / SemiBold / Line 1.3
- H3 (Subsection):    14px / Medium / Line 1.4
- Body:               12px / Regular / Line 1.5
- Small/Caption:      11px / Regular / Line 1.6
- Code:               10px / Regular / Line 1.5

---

## Part 4: Component Library

### 4.1 Buttons

**Variants**:
- **Primary**: Cyan background, black text, glowing border
- **Secondary**: Blue background, white text
- **Outline**: Transparent, cyan border, cyan text
- **Ghost**: Transparent, hover overlay only
- **Destructive**: Red background, white text, warning tooltip

**States**:
- Default, Hover, Active, Disabled, Loading
- All include smooth transitions (150ms)

```powershell
function New-EnhancedButton {
    param(
        [string]$Text,
        [ValidateSet('Primary','Secondary','Outline','Ghost','Destructive')]
        [string]$Variant = 'Primary',
        [ValidateSet('sm','md','lg')]
        [string]$Size = 'md',
        [scriptblock]$OnClick
    )
    
    # Sizes: sm=32px, md=40px, lg=48px
    # Hover: +5% brightness
    # Active: -10% brightness
    # Disabled: 50% opacity + no cursor
}
```

### 4.2 Input Fields

**Features**:
- Glassmorphic background (10% opacity overlay)
- Cyan border on focus
- Smooth transitions
- Built-in validation indicators
- Clear button (X icon) for text inputs
- Password toggle for password fields

```powershell
function New-EnhancedInput {
    param(
        [string]$Placeholder,
        [ValidateSet('text','password','number','email')]
        [string]$Type = 'text',
        [string]$ValidationRegex,
        [ValidateSet('sm','md','lg')]
        [string]$Size = 'md'
    )
    
    # Validation states: valid (green), invalid (red), warning (orange)
    # Auto-displays message below field
}
```

### 4.3 Checkboxes & Toggles

**Checkbox**:
- Square shape, 18x18px
- Cyan border, cyan fill on checked
- Smooth animation on toggle

**Toggle Switch**:
- Rounded rectangle, 44x24px
- Cyan fill when ON
- Smooth slide animation
- Built-in labels (ON/OFF or custom)

### 4.4 Dropdowns/Combobox

**Features**:
- Searchable options
- Multi-select support
- Keyboard navigation (arrow keys)
- Fuzzy search filtering
- Virtual scrolling for 1000+ items

### 4.5 Data Grid

**Features**:
- Sortable columns
- Filterable rows
- Selectable rows (checkbox column)
- Horizontal scroll on narrow screens
- Alternating row colors (subtle)
- Export to CSV/JSON

### 4.6 Charts & Graphs

**Supported Types**:
- Line chart (space freed over time)
- Pie chart (category breakdown)
- Bar chart (top junk categories)
- Progress bars (cleanup status)

**Library**: Chart.js v3+ or custom SVG rendering

### 4.7 Modals & Dialogs

**Types**:
- **Info Modal**: Informational message
- **Confirmation Modal**: Yes/No action
- **Input Modal**: Text input dialog
- **Progress Modal**: Long operation with cancel button

**Features**:
- Backdrop blur effect
- Keyboard shortcuts (Enter to confirm, Esc to cancel)
- Scrollable content area
- Focus trap (keyboard stays in modal)

---

## Part 5: Layout & Spacing

### Grid System
- Base unit: 8px
- 12-column grid on desktop (1400px+)
- 8-column on tablet (1024px-1399px)
- Full width on mobile (< 1024px)

### Spacing Scale
```
2px  = 0.25rem
4px  = 0.5rem
8px  = 1rem   (base)
12px = 1.5rem
16px = 2rem
24px = 3rem
32px = 4rem
```

### Container Width
- Mobile: Full width - 16px margin
- Tablet: 768px
- Desktop: 1200px
- Wide: 1400px
- Max: 1600px

---

## Part 6: Theme System

### Built-in Themes (10 Options)

1. **Dark (Default)**: Navy + Cyan (current)
2. **Deep Space**: Black + Purple
3. **Ocean**: Dark Blue + Teal
4. **Sunset**: Dark Orange + Pink
5. **Matrix**: Black + Green (#00FF00)
6. **Neon**: Black + Magenta
7. **Nord**: Dark Gray + Light Blue (Nord palette)
8. **Dracula**: Dark Purple + Pink (Dracula palette)
9. **One Dark**: Dark Blue + Cyan (Atom One Dark)
10. **Gruvbox**: Brown + Orange (Gruvbox palette)

### Theme Configuration
```json
{
  "name": "custom",
  "colors": {
    "background": "#0A0E27",
    "surface": "#121727",
    "primary": "#00D9FF",
    "secondary": "#0096FF",
    "accent": "#FF00FF",
    "success": "#00FF88",
    "warning": "#FFAA00",
    "error": "#FF3366"
  },
  "fonts": {
    "heading": "Segoe UI",
    "body": "Segoe UI",
    "mono": "Consolas"
  }
}
```

### Theme Switching
```powershell
function Set-UITheme {
    param(
        [ValidateSet('dark','deep-space','ocean','sunset','matrix','neon','nord','dracula','onedark','gruvbox')]
        [string]$ThemeName
    )
    
    # Update all UI elements
    # Save to config.json
    # Persist across sessions
}
```

---

## Part 7: Dark Mode & Light Mode

### Light Mode Palette
```
Background:        #FFFFFF
Surface:           #F5F5F5
Primary:           #0096FF  (Blue)
Secondary:         #005ACC  (Dark Blue)
Text Primary:      #1A1A1A
Text Secondary:    #666666
```

### Toggle Implementation
```powershell
$toggleDarkMode = New-Object System.Windows.Forms.CheckBox
$toggleDarkMode.Text = "Dark Mode"
$toggleDarkMode.Checked = $true

$toggleDarkMode.Add_CheckedChanged({
    if ($this.Checked) {
        Apply-Theme -Theme 'dark'
    } else {
        Apply-Theme -Theme 'light'
    }
})
```

---

## Part 8: Multi-Language Support

### Supported Languages (Phase 1)
1. English
2. Romanian (Română)
3. German (Deutsch)
4. French (Français)
5. Spanish (Español)
6. Italian (Italiano)
7. Portuguese (Português)
8. Russian (Русский)
9. Chinese Simplified (中文)
10. Japanese (日本語)

### Implementation
```powershell
function Get-LocalizedString {
    param(
        [string]$Key,  # e.g., "button.start.cleanup"
        [string]$Language = (Get-SystemLanguage)
    )
    
    # Load from: ./Localization/{Language}.json
    # Return translated string
    # Fallback to English if not found
}
```

### Language Selection UI
- Dropdown in settings
- Flag icons for quick recognition
- RTL auto-detection for Arabic/Hebrew future support

---

## Part 9: Accessibility (WCAG 2.1 AA)

### Keyboard Navigation
- Tab: Move to next interactive element
- Shift+Tab: Previous element
- Enter: Activate button/link
- Space: Toggle checkbox/radio
- Arrow Keys: Navigate lists/menus
- Esc: Close modal/menu

### Screen Reader Support
- ARIA labels on all buttons
- ARIA live regions for status updates
- Semantic HTML structure
- Image alt text for icons

### Color Contrast
- All text 4.5:1 minimum (AA standard)
- Focus indicators: 3px cyan border
- High contrast mode support

### Focus Management
```powershell
function Set-FocusIndicator {
    param([System.Windows.Forms.Control]$Control)
    
    # Add 3px cyan border
    # 2px outer offset
    # Remove default ugly rectangle
}
```

---

## Part 10: Responsive Breakpoints

```
Mobile:    < 768px    (100% width, full height)
Tablet:    768-1024px (80% width, adjusted spacing)
Desktop:   1024+px    (1200px container, full features)
Wide:      1400+px    (1400px container, extra panels)
Ultra:     1920+px    (1600px max, side-by-side layouts)
```

### Mobile Optimizations
- Stack tabs vertically
- Collapsible menu
- Touch-friendly buttons (48px+)
- Full-screen modals
- Single-column layout

---

## Part 11: Animation & Transitions

### Standard Timings
- Fade: 150ms ease-in-out
- Slide: 200ms ease-out
- Scale: 150ms cubic-bezier(0.34, 1.56, 0.64, 1)
- Color change: 100ms ease-in

### Performance
- GPU-accelerated (transform, opacity only)
- No animations on reduced-motion preference
- 60fps target

---

## Part 12: Main UI Screens

### Screen 1: Dashboard
**Components**:
- Header with title + Dark Mode toggle
- System metrics widget (CPU, Memory, Disk)
- Action buttons (Scan, Cleanup, Settings)
- Recent cleanup history chart
- Quick stats panel

### Screen 2: Scan Results
**Components**:
- Filterable data grid
- Category breakdown pie chart
- Total size & file count
- Export to CSV button
- Action buttons (Cleanup, Schedule)

### Screen 3: Cleanup Progress
**Components**:
- Progress bar with percentage
- Real-time log output (scrollable)
- Current file being deleted
- Pause/Resume buttons
- Cancel button (with confirmation)

### Screen 4: Settings
**Tabs**:
- **General**: Language, theme, startup behavior
- **Cleanup**: Categories to scan, exclusion patterns
- **Schedule**: Auto-cleanup schedule
- **Advanced**: ML confidence threshold, API port
- **About**: Version, license, help links

---

## Part 13: Implementation Roadmap

**Sprint 2.4 Deliverables** (Week 8):
1. UI module: `UI-Modern.psm1` (400+ lines)
2. Component library functions
3. Theme system with 10 presets
4. Multi-language support
5. Responsive layout system
6. Accessibility compliance tests
7. Documentation & examples

**Estimated Effort**: 120 hours (3 weeks)

---

**Version**: 1.0  
**Last Updated**: January 11, 2026  
**Status**: Ready for Development  
**Owner**: @Gzeu
