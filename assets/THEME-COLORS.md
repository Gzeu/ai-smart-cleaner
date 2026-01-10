# AI Smart Cleaner - Design System (v10.3)

## 🎨 Color Palette

### Primary Colors
- **Cyan**: `#00D9FF` (RGB: 0, 217, 255)
  - Primary accent, buttons, active states
  - Used for titles, headers, highlights
  - Main brand color

- **Blue**: `#0096FF` (RGB: 0, 150, 255)
  - Secondary accent, backgrounds
  - Complementary to cyan
  - Gradient partner

### Neutral Colors
- **Dark BG**: `#1A1A2E` (RGB: 26, 26, 46)
  - Main container background
  - Panel backgrounds
  - Sidebar

- **Darker BG**: `#0A0A0F` (RGB: 10, 10, 15)
  - Window background
  - Gradient start
  - Deep backgrounds

- **White**: `#FFFFFF`
  - Text on colored backgrounds
  - Contrast element

- **Light Gray**: `#E0E0E0`
  - Default text color
  - Secondary text

### Status Colors
- **Success**: `#4CAF50` (Green) ✓
  - Completed operations
  - Healthy status
  - Positive feedback

- **Warning**: `#FFC107` (Yellow) ⚠️
  - Caution needed
  - Attention required
  - Pending operations

- **Error**: `#F44336` (Red) ✗
  - Critical errors
  - Failed operations
  - Alerts

- **Info**: `#2196F3` (Light Blue) ℹ️
  - Informational messages
  - Neutral notifications

## 🎯 Design Elements

### Typography
- **Header Font**: Arial Bold, 20px
- **Title Font**: Arial Bold, 16px
- **Body Font**: Segoe UI, 12px
- **Monospace Font**: Consolas, 10px (logs)
- **Icon Font**: Emoji (system default)

### Spacing
- **Padding**: 10-20px
- **Margin**: 10-20px
- **Border Radius**: 4-8px
- **Line Height**: 1.5

### Shadows & Effects
- **Box Shadow**: `0 0 40px rgba(0, 217, 255, 0.2)`
- **Glow**: Cyan (#00D9FF) with 20% opacity
- **Hover**: Scale 1.05, brightness 110%
- **Active**: Opacity 0.9

## 🎪 Component Styling

### Buttons
- **Background**: Cyan → Blue gradient
- **Text**: Black (on Cyan)
- **Hover**: 5% scale increase
- **Active**: Opacity reduced
- **Font**: Arial Bold, 12px

### DataGridView
- **Header BG**: Blue
- **Header Text**: White
- **Row BG**: Dark
- **Row Text**: Light Gray
- **Selection BG**: Cyan
- **Selection Text**: Black
- **Alt Row**: Dark (slightly darker)

### Log Box
- **Background**: Darker BG
- **Text**: Cyan (default)
- **Success**: Green
- **Warning**: Yellow
- **Error**: Red
- **Font**: Consolas, 10px

### Tabs
- **Inactive**: Gray text
- **Active**: Cyan text + underline
- **Hover**: Cyan text
- **Background**: Dark

## 🎭 Gradients

### Linear Gradient (Buttons)
```
from: #00D9FF (Cyan)
to: #0096FF (Blue)
angle: 135deg
```

### Radial Gradient (Backgrounds)
```
from: rgba(0, 217, 255, 0.15)
to: rgba(0, 150, 255, 0.05)
center: 50% 30%
radius: 70%
```

### Linear Gradient (Panels)
```
from: #0A0A0F (Darker)
to: #1A272F (Slightly lighter)
angle: 45deg
```

## 📐 Icon Usage

- 🧹 Clean/Cleanup
- 🚀 Run/Start
- 📊 Results/Statistics
- 📝 Logs
- ⚙️ Settings
- ✓ Success
- ⚠️ Warning
- ✗ Error
- 💾 Save
- 📥 Download
- 📤 Export

## 🎯 Responsive Design

- **Min Window Size**: 1200x800px
- **Max Panel Width**: 400px
- **Min Button Size**: 40px height
- **Table Row Height**: 25px
- **Font Scaling**: 100% (no zoom)

## 📱 Dark Mode

All colors optimized for dark mode:
- Low contrast for accessibility
- Eye-friendly brightness
- Proper WCAG AA compliance
- Reduced eye strain at night
