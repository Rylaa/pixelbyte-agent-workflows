# Figma Agent Pipeline Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a 5-agent pipeline that converts Figma designs to production code through step-by-step validation, analysis, asset management, code generation, and compliance checking.

**Architecture:** Chain of agents where each agent produces a Markdown report consumed by the next. Orchestrated via a skill that invokes agents sequentially. Each agent has a single responsibility and passes structured output to the next in the chain.

**Tech Stack:** Claude Code Agents, Pixelbyte Figma MCP Server, Markdown reports

---

## Task 1: Create Design Validator Agent

**Files:**
- Create: `plugins/pb-figma/agents/design-validator.md`

**Step 1: Create agent file with frontmatter**

```markdown
---
name: design-validator
description: Validates Figma design completeness by checking all required design tokens, assets, typography, colors, spacing, and effects. Uses Pixelbyte Figma MCP to fetch missing details. Outputs a Validation Report for the next agent in the pipeline.
tools:
  - mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_get_file_structure
  - mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_get_node_details
  - mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_get_design_tokens
  - mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_get_styles
  - mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_list_assets
  - mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_get_screenshot
  - Write
  - TodoWrite
---

# Design Validator Agent

You validate Figma designs for completeness before code generation.

## Input

You receive a Figma URL. Parse it to extract:
- `file_key`: The file identifier (e.g., `abc123XYZ`)
- `node_id`: Optional node identifier from URL (e.g., `?node-id=1:234`)

URL formats:
- `https://www.figma.com/design/{file_key}/{name}?node-id={node_id}`
- `https://www.figma.com/file/{file_key}/{name}?node-id={node_id}`

## Validation Checklist

For each node and its children, verify:

### 1. Structure
- [ ] File structure retrieved successfully
- [ ] Target node exists and is accessible
- [ ] Node hierarchy is complete (all children loaded)
- [ ] Auto Layout is used (WARN if absolute positioning)

### 2. Design Tokens
- [ ] Colors extracted (fills, strokes)
- [ ] Typography defined (font family, size, weight, line-height)
- [ ] Spacing values captured (padding, gap, margins)
- [ ] Border radius values present
- [ ] Effects documented (shadows, blurs)

### 3. Assets
- [ ] Images identified with node IDs
- [ ] Icons identified with node IDs
- [ ] Vectors identified (if any)
- [ ] Export settings checked

### 4. Missing Data Resolution
If any data is unclear or missing:
1. Use `figma_get_node_details` for specific nodes
2. Use `figma_get_design_tokens` for token extraction
3. Use `figma_get_styles` for published styles
4. Document what could NOT be resolved

## Process

1. **Parse URL** - Extract file_key and node_id
2. **Get Structure** - Use `figma_get_file_structure` with depth=10
3. **Get Screenshot** - Capture visual reference with `figma_get_screenshot`
4. **Extract Tokens** - Use `figma_get_design_tokens` for colors, typography, spacing
5. **List Assets** - Use `figma_list_assets` to catalog images, icons, vectors
6. **Deep Inspection** - For each component, use `figma_get_node_details`
7. **Resolve Gaps** - Attempt to fill missing data with additional MCP calls
8. **Generate Report** - Write Validation Report

## Output: Validation Report

Write to: `docs/figma-reports/{file_key}-validation.md`

```markdown
# Validation Report: {design_name}

**File Key:** {file_key}
**Node ID:** {node_id}
**Generated:** {timestamp}
**Status:** PASS | WARN | FAIL

## Screenshot
![Design Screenshot]({screenshot_path})

## Structure Summary
- Total nodes: {count}
- Frames: {count}
- Components: {count}
- Text nodes: {count}
- Auto Layout: YES/NO (WARNING if NO)

## Design Tokens

### Colors
| Name | Value | Usage |
|------|-------|-------|
| primary | #3B82F6 | Button backgrounds |
| text | #1F2937 | Body text |

### Typography
| Style | Font | Size | Weight | Line Height |
|-------|------|------|--------|-------------|
| heading-1 | Inter | 32px | 700 | 1.2 |
| body | Inter | 16px | 400 | 1.5 |

### Spacing
| Token | Value |
|-------|-------|
| spacing-xs | 4px |
| spacing-sm | 8px |
| spacing-md | 16px |

### Effects
| Name | Type | Properties |
|------|------|------------|
| shadow-sm | drop-shadow | 0 1px 2px rgba(0,0,0,0.05) |

## Assets Inventory
| Asset | Type | Node ID | Export Format |
|-------|------|---------|---------------|
| logo | image | 1:234 | SVG |
| hero-bg | image | 1:567 | PNG |

## Node Hierarchy
```
Frame: Main Container (1:100)
├── Frame: Header (1:101)
│   ├── Image: Logo (1:102)
│   └── Frame: Navigation (1:103)
└── Frame: Content (1:110)
    └── ...
```

## Warnings
- {list any warnings}

## Unresolved Items
- {list items that could not be fetched}

## Next Agent Input
Ready for: Design Analyst Agent
```

## Error Handling

- If URL parsing fails → Report error, stop
- If file_key invalid → Report error, stop
- If node not found → Try parent node, warn
- If MCP call fails → Retry once, then document failure
```

**Step 2: Verify agent file syntax**

```bash
head -20 plugins/pb-figma/agents/design-validator.md
```

Expected: YAML frontmatter with name, description, tools

**Step 3: Commit**

```bash
git add plugins/pb-figma/agents/design-validator.md
git commit -m "feat(pb-figma): add design-validator agent

- Validates Figma design completeness
- Extracts design tokens, assets, structure
- Outputs Validation Report for pipeline"
```

---

## Task 2: Create Design Analyst Agent

**Files:**
- Create: `plugins/pb-figma/agents/design-analyst.md`

**Step 1: Create agent file**

```markdown
---
name: design-analyst
description: Analyzes Validation Report to create Implementation Spec. Produces component hierarchy, implementation notes, and coding guidelines. Acts as a Business Analyst translating design into development requirements.
tools:
  - Read
  - Write
  - Glob
  - TodoWrite
---

# Design Analyst Agent

You analyze the Validation Report and create an Implementation Spec for developers.

## Input

Read the Validation Report from: `docs/figma-reports/{file_key}-validation.md`

## Analysis Process

### 1. Component Breakdown
Analyze the node hierarchy and identify:
- Container components (frames with children)
- Atomic components (buttons, inputs, icons)
- Composite components (cards, headers, forms)
- Repeated patterns (list items, grid cells)

### 2. Implementation Strategy
For each component determine:
- HTML semantic element (header, nav, main, section, article, aside, footer)
- CSS layout method (flexbox, grid, absolute)
- Responsive behavior (fixed, fluid, breakpoints)
- State variations (hover, active, disabled)

### 3. Token Application
Map design tokens to implementation:
- Colors → CSS custom properties or Tailwind classes
- Typography → Font classes or text utilities
- Spacing → Padding/margin/gap utilities
- Effects → Shadow/blur utilities

### 4. Asset Requirements
List assets needed with:
- Recommended filename
- Required format (SVG for icons, PNG/WebP for images)
- Optimization notes

## Output: Implementation Spec

Write to: `docs/figma-reports/{file_key}-spec.md`

```markdown
# Implementation Spec: {design_name}

**Source:** {validation_report_path}
**Generated:** {timestamp}

## Component Hierarchy

```
{ComponentName} (semantic: <main>)
├── Header (semantic: <header>)
│   ├── Logo (semantic: <img>)
│   └── Navigation (semantic: <nav>)
│       └── NavItem[] (semantic: <a>)
├── HeroSection (semantic: <section>)
│   ├── Heading (semantic: <h1>)
│   ├── Subheading (semantic: <p>)
│   └── CTAButton (semantic: <button>)
└── Footer (semantic: <footer>)
```

## Components

### {ComponentName}

**Element:** `<tag>`
**Layout:** flexbox | grid | block
**Classes/Styles:**
```
flex flex-col gap-4 p-6 bg-white rounded-lg shadow-sm
```

**Props/Variants:**
- variant: primary | secondary
- size: sm | md | lg

**Children:**
- {ChildComponent}

**Notes:**
- {implementation notes}

---

## Design Tokens (Ready to Use)

### Colors
```css
--color-primary: #3B82F6;
--color-primary-hover: #2563EB;
--color-text: #1F2937;
--color-text-muted: #6B7280;
--color-background: #FFFFFF;
--color-border: #E5E7EB;
```

### Typography
```css
--font-family: 'Inter', sans-serif;
--font-size-xs: 12px;
--font-size-sm: 14px;
--font-size-base: 16px;
--font-size-lg: 18px;
--font-size-xl: 20px;
--font-size-2xl: 24px;
--font-size-3xl: 32px;
```

### Spacing
```css
--spacing-1: 4px;
--spacing-2: 8px;
--spacing-3: 12px;
--spacing-4: 16px;
--spacing-6: 24px;
--spacing-8: 32px;
```

### Effects
```css
--shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
--shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
--radius-sm: 4px;
--radius-md: 8px;
--radius-lg: 12px;
```

## Assets Required

| Asset | Filename | Format | Node ID | Notes |
|-------|----------|--------|---------|-------|
| Logo | logo.svg | SVG | 1:234 | Preserve colors |
| Hero Image | hero.webp | WebP | 1:567 | Optimize for web |

## Implementation Checklist

- [ ] Create component files
- [ ] Apply design tokens
- [ ] Download and place assets
- [ ] Implement responsive behavior
- [ ] Add hover/active states
- [ ] Test against design screenshot

## Next Agent Input
Ready for: Asset Manager Agent
Assets to download: {count}
```

## Guidelines

- Keep component names in PascalCase
- Use semantic HTML elements
- Prefer Tailwind utilities over custom CSS
- Document any assumptions made
- Flag unclear design decisions for review
```

**Step 2: Verify agent file**

```bash
head -20 plugins/pb-figma/agents/design-analyst.md
```

**Step 3: Commit**

```bash
git add plugins/pb-figma/agents/design-analyst.md
git commit -m "feat(pb-figma): add design-analyst agent

- Analyzes Validation Report
- Creates Implementation Spec with component hierarchy
- Maps design tokens to CSS/Tailwind"
```

---

## Task 3: Create Asset Manager Agent

**Files:**
- Create: `plugins/pb-figma/agents/asset-manager.md`

**Step 1: Create agent file**

```markdown
---
name: asset-manager
description: Downloads and organizes assets from Figma based on Implementation Spec. Validates downloaded assets, organizes them in project structure, and updates the spec with final asset paths.
tools:
  - Read
  - Write
  - Bash
  - Glob
  - mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_get_screenshot
  - mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_export_assets
  - mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_get_images
  - TodoWrite
---

# Asset Manager Agent

You download and organize Figma assets based on the Implementation Spec.

## Input

Read the Implementation Spec from: `docs/figma-reports/{file_key}-spec.md`

Extract from "Assets Required" table:
- Asset name
- Target filename
- Required format (SVG, PNG, WebP)
- Node ID

## Process

### 1. Prepare Directories
```bash
mkdir -p public/assets/images
mkdir -p public/assets/icons
mkdir -p src/assets
```

### 2. Download Assets

For each asset in the spec:

**Icons (SVG):**
```
Use figma_export_assets with:
- file_key: {from spec}
- node_ids: ["{node_id}"]
- format: "svg"
- scale: 1
```

**Images (PNG/WebP):**
```
Use figma_export_assets with:
- file_key: {from spec}
- node_ids: ["{node_id}"]
- format: "png"
- scale: 2 (for retina)
```

### 3. Validate Downloads

For each downloaded asset:
- [ ] File exists at expected path
- [ ] File size > 0
- [ ] Format matches requested
- [ ] Dimensions are reasonable

### 4. Organize Files

Move assets to project structure:
- Icons → `public/assets/icons/` or `src/assets/icons/`
- Images → `public/assets/images/`
- Keep original filenames from spec

### 5. Update Spec

Add "Asset Paths" section to spec:

```markdown
## Asset Paths (Downloaded)

| Asset | Path | Status |
|-------|------|--------|
| Logo | /public/assets/icons/logo.svg | ✅ |
| Hero | /public/assets/images/hero.webp | ✅ |
```

## Output: Updated Spec

Modify: `docs/figma-reports/{file_key}-spec.md`

Add section:

```markdown
## Downloaded Assets

| Asset | Local Path | Size | Status |
|-------|------------|------|--------|
| logo.svg | public/assets/icons/logo.svg | 2.4KB | ✅ Ready |
| hero.webp | public/assets/images/hero.webp | 45KB | ✅ Ready |

## Asset Import Statements

```javascript
// Icons
import Logo from '@/assets/icons/logo.svg';

// Images
import HeroImage from '@/assets/images/hero.webp';
```

## Next Agent Input
Ready for: Code Generator Agent
All assets downloaded: YES/NO
```

## Error Handling

- Download fails → Retry once, then document failure
- Wrong format → Re-export with correct format
- Corrupt file → Re-download, verify
- Missing node → Log error, continue with others

## Validation Checklist

Before marking complete:
- [ ] All assets from spec downloaded
- [ ] Files in correct directories
- [ ] Spec updated with paths
- [ ] Import statements generated
```

**Step 2: Verify agent file**

```bash
head -20 plugins/pb-figma/agents/asset-manager.md
```

**Step 3: Commit**

```bash
git add plugins/pb-figma/agents/asset-manager.md
git commit -m "feat(pb-figma): add asset-manager agent

- Downloads assets from Figma via MCP
- Organizes in project structure
- Updates spec with local paths"
```

---

## Task 4: Create Code Generator Agent

**Files:**
- Create: `plugins/pb-figma/agents/code-generator.md`

**Step 1: Create agent file**

```markdown
---
name: code-generator
description: Generates production code from Implementation Spec. Detects project framework, generates components matching the spec exactly, and writes files to the codebase. Supports React, Vue, SwiftUI, and Kotlin.
tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_generate_code
  - TodoWrite
  - AskUserQuestion
---

# Code Generator Agent

You generate production code from the Implementation Spec.

## Input

Read the Updated Spec from: `docs/figma-reports/{file_key}-spec.md`

## Framework Detection

### Step 1: Detect Project Type

Check for framework indicators:

```bash
# React/Next.js
ls package.json 2>/dev/null && grep -l "react" package.json

# Vue
ls package.json 2>/dev/null && grep -l "vue" package.json

# SwiftUI
ls Package.swift 2>/dev/null || ls *.xcodeproj 2>/dev/null

# Kotlin/Android
ls build.gradle 2>/dev/null || ls build.gradle.kts 2>/dev/null
```

### Step 2: Confirm with User

Use AskUserQuestion:

```
Detected: {framework}

Generate code for this framework?

A) Yes, proceed with {framework}
B) Use different framework
C) Let me specify
```

### Step 3: Map to MCP Framework

| Detected | MCP Framework |
|----------|---------------|
| React + Tailwind | react_tailwind |
| React (no Tailwind) | react |
| Vue + Tailwind | vue_tailwind |
| Vue (no Tailwind) | vue |
| Next.js | react_tailwind |
| SwiftUI | swiftui |
| Kotlin/Android | kotlin |
| HTML only | html_css |

## Code Generation

### For Each Component in Spec:

1. **Use MCP for base code:**
```
figma_generate_code with:
- file_key: {from spec}
- node_id: {component node_id}
- framework: {detected_framework}
- component_name: {PascalCase name}
```

2. **Enhance with spec details:**
- Apply exact design tokens from spec
- Add semantic HTML elements
- Include accessibility attributes
- Add TypeScript types (if applicable)

3. **Write component file:**
```
For React: src/components/{ComponentName}.tsx
For Vue: src/components/{ComponentName}.vue
For SwiftUI: Sources/Views/{ComponentName}.swift
For Kotlin: app/src/main/java/.../ui/{ComponentName}.kt
```

## Output Structure

### React/Next.js Example:

```typescript
// src/components/{ComponentName}.tsx

import React from 'react';
import { cn } from '@/lib/utils';

interface {ComponentName}Props {
  className?: string;
  // props from spec variants
}

export function {ComponentName}({ className, ...props }: {ComponentName}Props) {
  return (
    <{semantic_element}
      className={cn(
        // Base styles from spec
        "{tailwind_classes}",
        className
      )}
      {...props}
    >
      {/* Children from spec hierarchy */}
    </{semantic_element}>
  );
}
```

### File Organization

```
src/
├── components/
│   ├── {ComponentName}/
│   │   ├── index.tsx
│   │   ├── {ComponentName}.tsx
│   │   └── {ComponentName}.stories.tsx (optional)
│   └── ui/
│       └── {atomic_components}.tsx
└── styles/
    └── tokens.css (if needed)
```

## Component Checklist

For each component verify:
- [ ] Matches spec hierarchy
- [ ] Uses correct semantic HTML
- [ ] Applies all design tokens
- [ ] Includes proper TypeScript types
- [ ] Has accessibility attributes
- [ ] Imports assets correctly

## Output

Write generated files and update spec:

```markdown
## Generated Code

| Component | File | Status |
|-----------|------|--------|
| Header | src/components/Header.tsx | ✅ |
| Navigation | src/components/Navigation.tsx | ✅ |
| HeroSection | src/components/HeroSection.tsx | ✅ |

## Next Agent Input
Ready for: Compliance Checker Agent
Components generated: {count}
Framework: {framework}
```

## Error Handling

- MCP generation fails → Fall back to manual code from spec
- Type errors → Fix and re-validate
- Missing assets → Reference placeholder, note in report
```

**Step 2: Verify agent file**

```bash
head -20 plugins/pb-figma/agents/code-generator.md
```

**Step 3: Commit**

```bash
git add plugins/pb-figma/agents/code-generator.md
git commit -m "feat(pb-figma): add code-generator agent

- Detects project framework automatically
- Generates components from spec
- Supports React, Vue, SwiftUI, Kotlin"
```

---

## Task 5: Create Compliance Checker Agent

**Files:**
- Create: `plugins/pb-figma/agents/compliance-checker.md`

**Step 1: Create agent file**

```markdown
---
name: compliance-checker
description: Validates generated code against Implementation Spec. Performs checklist verification to ensure all design requirements are met. Produces Final Report with pass/fail status and any discrepancies.
tools:
  - Read
  - Write
  - Glob
  - Grep
  - TodoWrite
---

# Compliance Checker Agent

You verify that generated code matches the Implementation Spec.

## Input

Read:
1. Implementation Spec: `docs/figma-reports/{file_key}-spec.md`
2. Generated component files from spec's "Generated Code" section

## Compliance Checklist

### 1. Component Structure
For each component in spec:
- [ ] Component file exists
- [ ] Component name matches spec
- [ ] Semantic HTML element correct
- [ ] Children hierarchy matches
- [ ] Props/variants implemented

### 2. Design Tokens
Verify in code:
- [ ] Colors match spec values
- [ ] Typography (font, size, weight) correct
- [ ] Spacing values applied
- [ ] Border radius correct
- [ ] Shadows/effects applied

### 3. Assets
- [ ] All assets imported
- [ ] Import paths correct
- [ ] Assets used in correct components

### 4. Accessibility
- [ ] Semantic elements used
- [ ] Alt text for images
- [ ] ARIA labels where needed
- [ ] Focus states (if applicable)

### 5. Code Quality
- [ ] No TypeScript errors
- [ ] Consistent naming
- [ ] No hardcoded values (uses tokens)
- [ ] Clean structure

## Verification Process

### Step 1: Load Spec Requirements

Parse spec for:
- Component list with properties
- Design token values
- Asset paths
- Hierarchy structure

### Step 2: Scan Generated Code

For each component file:
```
Read file → Extract:
- Element types used
- Class names / styles
- Imported assets
- Props defined
```

### Step 3: Compare

Create comparison matrix:

| Requirement | Spec Value | Code Value | Match |
|-------------|------------|------------|-------|
| Primary color | #3B82F6 | #3B82F6 | ✅ |
| Font size | 16px | 1rem | ✅ |
| Padding | 24px | p-6 | ✅ |

### Step 4: Report Discrepancies

For each mismatch:
- What: Specific requirement
- Expected: Spec value
- Found: Code value
- Severity: Critical | Warning | Info
- Fix: Suggested correction

## Output: Final Report

Write to: `docs/figma-reports/{file_key}-final.md`

```markdown
# Final Compliance Report: {design_name}

**Spec:** {spec_path}
**Generated:** {timestamp}
**Status:** ✅ PASS | ⚠️ WARNINGS | ❌ FAIL

## Summary

| Category | Passed | Failed | Warnings |
|----------|--------|--------|----------|
| Structure | 5 | 0 | 0 |
| Tokens | 12 | 0 | 1 |
| Assets | 3 | 0 | 0 |
| Accessibility | 4 | 0 | 2 |
| **Total** | **24** | **0** | **3** |

## Component Status

| Component | Structure | Tokens | Assets | Status |
|-----------|-----------|--------|--------|--------|
| Header | ✅ | ✅ | ✅ | PASS |
| Navigation | ✅ | ⚠️ | ✅ | WARN |
| HeroSection | ✅ | ✅ | ✅ | PASS |

## Discrepancies

### Warnings

#### 1. Navigation - Font Weight
- **Expected:** 600 (semibold)
- **Found:** 500 (medium)
- **File:** src/components/Navigation.tsx:15
- **Fix:** Change `font-medium` to `font-semibold`

### Info

#### 1. Accessibility - Missing alt text
- **Component:** HeroSection
- **Element:** Background image
- **Fix:** Add `aria-label` for decorative image

## Files Reviewed

- src/components/Header.tsx ✅
- src/components/Navigation.tsx ⚠️
- src/components/HeroSection.tsx ✅

## Checklist

- [x] All components exist
- [x] Design tokens applied
- [x] Assets imported correctly
- [x] Semantic HTML used
- [ ] All warnings addressed (optional)

## Conclusion

{summary of results}

**Ready for:** Production / Needs fixes

---
Generated by Compliance Checker Agent
```

## Pass/Fail Criteria

**PASS:**
- All components exist
- No critical mismatches
- Tokens 90%+ match

**WARN:**
- Minor discrepancies
- Non-critical missing items

**FAIL:**
- Components missing
- Critical token mismatches
- Assets not found
```

**Step 2: Verify agent file**

```bash
head -20 plugins/pb-figma/agents/compliance-checker.md
```

**Step 3: Commit**

```bash
git add plugins/pb-figma/agents/compliance-checker.md
git commit -m "feat(pb-figma): add compliance-checker agent

- Validates code against spec
- Checklist-based verification
- Produces Final Report with pass/fail"
```

---

## Task 6: Create Pipeline Orchestrator Skill

**Files:**
- Modify: `plugins/pb-figma/skills/figma-to-code/SKILL.md`
- Create: `plugins/pb-figma/agents/README.md`

**Step 1: Update SKILL.md to use agent pipeline**

Add new section after Core Principles:

```markdown
## Agent Pipeline

This skill orchestrates a 5-agent pipeline for Figma-to-code conversion:

### Pipeline Flow

```
Figma URL
    │
    ▼
┌─────────────────────────┐
│ 1. design-validator     │ → Validation Report
└─────────────────────────┘
    │
    ▼
┌─────────────────────────┐
│ 2. design-analyst       │ → Implementation Spec
└─────────────────────────┘
    │
    ▼
┌─────────────────────────┐
│ 3. asset-manager        │ → Updated Spec + Assets
└─────────────────────────┘
    │
    ▼
┌─────────────────────────┐
│ 4. code-generator       │ → Component Files
└─────────────────────────┘
    │
    ▼
┌─────────────────────────┐
│ 5. compliance-checker   │ → Final Report
└─────────────────────────┘
```

### Invoking the Pipeline

When a Figma URL is provided, invoke agents sequentially:

1. **Start:** Parse Figma URL, create report directory
2. **Agent 1:** Dispatch `design-validator` with URL
3. **Agent 2:** Dispatch `design-analyst` with validation report path
4. **Agent 3:** Dispatch `asset-manager` with spec path
5. **Agent 4:** Dispatch `code-generator` with updated spec path
6. **Agent 5:** Dispatch `compliance-checker` with spec and code paths
7. **Complete:** Present Final Report to user

### Report Directory

All reports saved to: `docs/figma-reports/`

```
docs/figma-reports/
├── {file_key}-validation.md   # Agent 1 output
├── {file_key}-spec.md         # Agent 2+3 output
└── {file_key}-final.md        # Agent 5 output
```

### Manual Override

Users can run individual agents:
- "Just validate this design" → Run only design-validator
- "Generate code from this spec" → Run only code-generator
- "Check compliance" → Run only compliance-checker
```

**Step 2: Create agents README**

```markdown
# pb-figma Agents

Agents for the Figma-to-Code pipeline.

## Pipeline Order

1. **design-validator** - Validates design completeness
2. **design-analyst** - Creates implementation spec
3. **asset-manager** - Downloads and organizes assets
4. **code-generator** - Generates production code
5. **compliance-checker** - Verifies code matches spec

## Usage

Agents are invoked automatically by the `figma-to-code` skill when a Figma URL is provided.

### Individual Agent Usage

```
@design-validator validate https://figma.com/...
@design-analyst analyze docs/figma-reports/abc123-validation.md
@asset-manager download docs/figma-reports/abc123-spec.md
@code-generator generate docs/figma-reports/abc123-spec.md
@compliance-checker verify docs/figma-reports/abc123-spec.md
```

## Reports

All outputs saved to `docs/figma-reports/`:
- `{file_key}-validation.md` - Design validation results
- `{file_key}-spec.md` - Implementation specification
- `{file_key}-final.md` - Compliance check results
```

**Step 3: Commit**

```bash
git add plugins/pb-figma/skills/figma-to-code/SKILL.md
git add plugins/pb-figma/agents/README.md
git commit -m "feat(pb-figma): integrate agent pipeline into skill

- Add pipeline documentation to SKILL.md
- Create agents README with usage guide"
```

---

## Task 7: Update Plugin Version and Manifest

**Files:**
- Modify: `plugins/pb-figma/.claude-plugin/plugin.json`

**Step 1: Update plugin.json**

```json
{
  "name": "pb-figma",
  "version": "2.0.0",
  "description": "Figma-to-code conversion with 5-agent pipeline. Validates designs, creates specs, manages assets, generates code, and verifies compliance using Pixelbyte Figma MCP Server.",
  "author": {
    "name": "Pixelbyte",
    "url": "https://github.com/Rylaa"
  },
  "repository": "https://github.com/Rylaa/pixelbyte-agent-workflows",
  "license": "MIT",
  "keywords": [
    "figma",
    "figma-to-code",
    "design-to-code",
    "react",
    "tailwind",
    "typescript",
    "pixel-perfect",
    "design-tokens",
    "agent-pipeline",
    "validation",
    "code-generation"
  ]
}
```

**Step 2: Commit**

```bash
git add plugins/pb-figma/.claude-plugin/plugin.json
git commit -m "chore(pb-figma): bump version to 2.0.0

- Major version for agent pipeline feature
- Updated description and keywords"
```

---

## Task 8: Create figma-reports Directory

**Files:**
- Create: `docs/figma-reports/.gitkeep`

**Step 1: Create directory with gitkeep**

```bash
mkdir -p docs/figma-reports
touch docs/figma-reports/.gitkeep
```

**Step 2: Commit**

```bash
git add docs/figma-reports/.gitkeep
git commit -m "chore: add figma-reports directory for agent outputs"
```

---

## Verification Checklist

After completing all tasks:

- [ ] `plugins/pb-figma/agents/design-validator.md` exists
- [ ] `plugins/pb-figma/agents/design-analyst.md` exists
- [ ] `plugins/pb-figma/agents/asset-manager.md` exists
- [ ] `plugins/pb-figma/agents/code-generator.md` exists
- [ ] `plugins/pb-figma/agents/compliance-checker.md` exists
- [ ] `plugins/pb-figma/agents/README.md` exists
- [ ] SKILL.md updated with pipeline documentation
- [ ] plugin.json version is 2.0.0
- [ ] `docs/figma-reports/` directory exists
- [ ] All 8 commits in git log
- [ ] `git status` shows clean working directory

## Testing

After implementation, test with:

```
1. Provide a Figma URL to the skill
2. Verify Agent 1 produces validation report
3. Verify Agent 2 produces implementation spec
4. Verify Agent 3 downloads assets
5. Verify Agent 4 generates code files
6. Verify Agent 5 produces compliance report
```
