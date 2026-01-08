# Visual Validation Loop - Detailed Guide

This document provides detailed instructions for Phase 4: Visual Validation using Playwright MCP and Claude Vision hybrid approach.

## Hybrid Approach Overview

**Industry Research Findings:**
- Pixel-based tools (Playwright, Chromatic): **99%+ reliable**
- AI Vision (Claude, GPT-4V) alone: **47.8% accuracy** — INSUFFICIENT for pixel-perfect
- **Hybrid approach**: Best results

**This skill's approach:**
```
1. Playwright pixel comparison → "Is there a difference?" (definitive answer)
2. If different, Claude Vision → "What's different, how to fix?" (smart answer)
3. Auto-fix → Claude updates code based on suggestions
4. Re-test → Maximum 3 iterations
```

## Why Hybrid?

| Method | Strength | Weakness |
|--------|----------|----------|
| **Playwright Pixel** | Exact diff detection (99%+) | No answer to "what's different?" |
| **Claude Vision** | Semantic understanding, fix suggestions | Misses small differences (47.8%) |
| **Hybrid** | Benefits of both | ✅ Best results |

## Step-by-Step Process

### Step 4.1: Save Generated Code

```javascript
write_file("src/components/[ComponentName].tsx", generatedCode)
```

### Step 4.2: Dev Server Check

```javascript
// Using Playwright MCP (Plugin Format)
mcp__plugin_playwright_playwright__browser_navigate({
  url: "http://localhost:3000"
})

// If page doesn't load, warn user:
// "⚠️ Dev server not running. Please run 'npm run dev' and try again."
```

### Step 4.3: Render Component and Take Screenshot

```javascript
// 1. Navigate to component page
mcp__plugin_playwright_playwright__browser_navigate({
  url: "http://localhost:3000/test-preview?component=[ComponentName]"
})

// 2. Wait for component to load (2 seconds)
mcp__plugin_playwright_playwright__browser_evaluate({
  function: "() => new Promise(r => setTimeout(r, 2000))"
})

// 3. Take screenshot
mcp__plugin_playwright_playwright__browser_take_screenshot({
  element: "preview-component",
  ref: "[data-testid='preview-component']",
  filename: "rendered.png"
})
```

**Note:** If no preview page exists, use direct URL:
```javascript
mcp__plugin_playwright_playwright__browser_navigate({
  url: "http://localhost:3000/components/[ComponentName]"
})
mcp__plugin_playwright_playwright__browser_take_screenshot({
  filename: "rendered.png"
})
```

### Step 4.4: Pixel Comparison

**Method: Playwright's built-in visual comparison**

```javascript
// Pixel comparison using Playwright MCP (Plugin Format)
mcp__plugin_playwright_playwright__browser_evaluate({
  function: `() => {
    async function compareImages(img1Path, img2Path) {
      const canvas1 = document.createElement('canvas');
      const canvas2 = document.createElement('canvas');
      // ... pixel comparison logic
      return { diffPercent: X.XX, hasDiff: true/false };
    }
    return compareImages();
  }`
})
```

**OR simple visual check:**

```
1. reference.png → Captured via get_screenshot in Phase 1
2. rendered.png → Just captured via Playwright
3. Place both images side by side and ask Claude
```

### Step 4.5: Hybrid Decision Tree

```
┌─────────────────────────────────────────────────────────────────┐
│                    HYBRID VALIDATION FLOW                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 1: PIXEL COMPARISON (Playwright)                          │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Compare two screenshots                                 │    │
│  │ → Same dimensions?                                      │    │
│  │ → Visually similar?                                     │    │
│  └─────────────────────────────────────────────────────────┘    │
│                            │                                     │
│              ┌─────────────┴─────────────┐                      │
│              ▼                           ▼                       │
│     ┌─────────────┐             ┌─────────────┐                 │
│     │ SAME/Similar│             │  DIFFERENT  │                 │
│     │ (< 2% diff) │             │ (> 2% diff) │                 │
│     └──────┬──────┘             └──────┬──────┘                 │
│            │                           │                         │
│            ▼                           ▼                         │
│     ┌─────────────┐      STEP 2: CLAUDE VISION ANALYSIS         │
│     │ ✅ SUCCESS  │      ┌─────────────────────────────────┐   │
│     │ Go to Faz 5 │      │ Show both images to Claude      │   │
│     └─────────────┘      │ and ASK:                        │   │
│                          │                                  │   │
│                          │ "What are the differences       │   │
│                          │  between these two images?      │   │
│                          │  How should I fix the code?"    │   │
│                          └──────────────┬──────────────────┘   │
│                                         │                       │
│                                         ▼                       │
│                          ┌─────────────────────────────────┐   │
│                          │ Claude Vision response:         │   │
│                          │ - "Padding 4px short"           │   │
│                          │ - "Font-weight should be 600"   │   │
│                          │ - "Gap is 16px not 24px"        │   │
│                          └──────────────┬──────────────────┘   │
│                                         │                       │
│                                         ▼                       │
│                          ┌─────────────────────────────────┐   │
│                          │ STEP 3: AUTO-FIX                │   │
│                          │ Claude updates code based       │   │
│                          │ on suggestions                  │   │
│                          └──────────────┬──────────────────┘   │
│                                         │                       │
│                                         ▼                       │
│                          ┌─────────────────────────────────┐   │
│                          │ STEP 4: RE-TEST                 │   │
│                          │ → Go back to Step 4.3           │   │
│                          │ → Maximum 3 iterations          │   │
│                          └─────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Step 4.6: Claude Vision Analysis (If Different)

**Prompt to show Claude:**

```markdown
## VISUAL COMPARISON

Analyze differences between two images:

**Image 1: Figma Design (reference.png)**
[reference.png image]

**Image 2: Generated Code (rendered.png)**  
[rendered.png image]

## QUESTIONS

1. What are the visible differences between these two images?
2. Which CSS/Tailwind values are wrong?
3. How should I fix the code? (give specific values)

## EXPECTED OUTPUT

```json
{
  "differences": [
    { "area": "padding", "issue": "top padding missing", "fix": "pt-6 → pt-8" },
    { "area": "font", "issue": "font too thin", "fix": "font-medium → font-semibold" }
  ],
  "estimated_match": "85%",
  "critical_fixes": ["padding", "font-weight"]
}
```
```

### Step 4.7: Auto-Fix

After Claude Vision analysis:

```javascript
// 1. Read current code
const currentCode = read_file("src/components/[ComponentName].tsx")

// 2. Fix based on Claude's suggestions
// Example: "pt-6 → pt-8" → update with str_replace

// 3. Save file
write_file("src/components/[ComponentName].tsx", updatedCode)

// 4. Re-test (go back to Step 4.3)
```

### Step 4.8: Iteration Limit

```
iteration = 0

WHILE iteration < 3:
    take_screenshot()
    compare()
    
    IF similar:
        BREAK → Go to Phase 5
    ELSE:
        claude_vision_analyze()
        fix()
        iteration += 1

IF iteration >= 3:
    → Go to Phase 5
    → Note "Manual check required" in report
```

## Playwright MCP Command Reference (Plugin Format)

> **Not:** Playwright, Claude Code plugin olarak yüklüyse araç isimleri `mcp__plugin_playwright_playwright__` prefix'i ile başlar.

```javascript
// Navigate to page
mcp__plugin_playwright_playwright__browser_navigate({
  url: "http://localhost:3000/preview"
})

// Take screenshot (full page)
mcp__plugin_playwright_playwright__browser_take_screenshot({
  filename: "screenshot.png",
  fullPage: true
})

// Take screenshot (specific element)
mcp__plugin_playwright_playwright__browser_take_screenshot({
  element: "component",
  ref: "[data-testid='component']",
  filename: "component.png"
})

// Wait for element
mcp__plugin_playwright_playwright__browser_evaluate({
  function: "() => document.querySelector('.loaded') !== null"
})

// Change viewport (responsive test)
mcp__plugin_playwright_playwright__browser_resize({
  width: 375,
  height: 812
})

// Read CSS value (for validation)
mcp__plugin_playwright_playwright__browser_evaluate({
  function: `() => {
    const el = document.querySelector('[data-testid="component"]');
    return JSON.stringify({
      padding: getComputedStyle(el).padding,
      fontSize: getComputedStyle(el).fontSize,
      gap: getComputedStyle(el).gap
    });
  }`
})
```

## Responsive Validation (Optional)

```javascript
// Mobile (375px)
mcp__plugin_playwright_playwright__browser_resize({ width: 375, height: 812 })
mcp__plugin_playwright_playwright__browser_take_screenshot({ filename: "mobile.png" })

// Tablet (768px)
mcp__plugin_playwright_playwright__browser_resize({ width: 768, height: 1024 })
mcp__plugin_playwright_playwright__browser_take_screenshot({ filename: "tablet.png" })

// Desktop (1280px)
mcp__plugin_playwright_playwright__browser_resize({ width: 1280, height: 800 })
mcp__plugin_playwright_playwright__browser_take_screenshot({ filename: "desktop.png" })

// Compare each viewport with Claude Vision
```
