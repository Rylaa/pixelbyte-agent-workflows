# Asset Pipeline + Text Decoration + Opacity Fixes Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix pixel-perfect rendering issues by debugging existing agent logic and adding text decoration color extraction

**Architecture:** The pb-figma plugin already has opacity, gradient, and asset download features implemented. This plan focuses on debugging existing logic, adding missing text decoration extraction, and end-to-end testing to ensure TypeSceneText.swift matches Figma design exactly.

**Tech Stack:** Pixelbyte Figma MCP Server, 5-agent pipeline (Design Validator → Design Analyst → Asset Manager → Code Generator SwiftUI → Compliance Checker), SwiftUI, Claude Vision

---

## Task 1: Add Text Decoration Color Extraction to Design Analyst

**Files:**
- Modify: `plugins/pb-figma/agents/design-analyst.md:288-350` (new section after gradient detection)

**Step 1: Write the failing test**

Create test file:
```bash
touch plugins/pb-figma/tests/test-text-decoration.md
```

Test content:
```markdown
# Test: Text Decoration Color Extraction

## Input
Figma node with:
- Text: "Hook"
- Underline: SINGLE
- Underline color: #ffd100 (yellow)
- Underline thickness: 1.0

## Expected Output in Implementation Spec

```markdown
### Text Decoration

**Component:** HookText
- **Decoration:** Underline
- **Color:** #ffd100 (opacity: 1.0)
- **Thickness:** 1.0

**SwiftUI Mapping:** `.underline(color: Color(hex: "#ffd100"))`
```
```

**Step 2: Run test to verify it fails**

Run: Read the design-analyst.md and verify text decoration section does not exist
Expected: FAIL - section missing

**Step 3: Write minimal implementation**

Add to `plugins/pb-figma/agents/design-analyst.md` after line 287:

```markdown
#### Text Decoration Detection

Extract text decoration (underline, strikethrough) from text nodes via `figma_get_node_details`:

**Detection criteria:**
- Check `textDecoration` property on TEXT nodes
- Values: NONE, UNDERLINE, STRIKETHROUGH

**For each decorated text:**

1. **Extract decoration properties:**
   ```
   figma_get_node_details:
     - file_key: {file_key}
     - node_id: {text_node_id}

   Read from response:
     - textDecoration: UNDERLINE | STRIKETHROUGH
     - decorationColor: { r, g, b, a }  # RGBA 0-1
     - decorationThickness: number (px)
   ```

2. **Convert to hex:**
   ```
   decorationColor: { r: 1.0, g: 0.82, b: 0.0, a: 1.0 }
   → #ffd100 (opacity: 1.0)
   ```

**In Implementation Spec - Add Text Decoration Section:**

```markdown
### Text Decoration

**Component:** {ComponentName}
- **Decoration:** Underline | Strikethrough
- **Color:** #ffd100 (opacity: 1.0)
- **Thickness:** 1.0

**SwiftUI Mapping:** `.underline(color: Color(hex: "#ffd100"))` or `.strikethrough(color: Color(hex: "#color"))`
```

**Rules:**
- Only add this section if text has decoration (textDecoration ≠ NONE)
- Include opacity even if 1.0 for consistency
- Default thickness: 1.0 if not specified in Figma
```

**Step 4: Run test to verify it passes**

Run: Read the updated design-analyst.md
Expected: PASS - new section exists with correct format

**Step 5: Commit**

```bash
git add plugins/pb-figma/agents/design-analyst.md plugins/pb-figma/tests/test-text-decoration.md
git commit -m "feat(design-analyst): add text decoration color extraction

- Extract underline/strikethrough color from TEXT nodes
- Add Text Decoration section to Implementation Spec format
- Include decoration type, color, opacity, thickness
- Map to SwiftUI .underline() or .strikethrough() modifiers

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Debug Design Analyst Opacity Extraction

**Files:**
- Read: `plugins/pb-figma/agents/design-analyst.md:170-220`
- Test: New test file

**Step 1: Create test case with known opacity values**

Create test file:
```bash
touch plugins/pb-figma/tests/test-opacity-extraction.md
```

Test content:
```markdown
# Test: Opacity Extraction

## Input
Figma node bt65gbJ6sSdKRP4x3IY151, node 10203:16369 (TypeSceneText)

Expected opacities from Figma:
- Background layer #150200: opacity 1.0
- Radial gradient overlay: opacity 0.2
- Border stroke white: opacity 0.4
- Text fill gradient: opacity 1.0

## Expected Output

Design Tokens table should show:

| Property | Color | Opacity | Usage |
|----------|-------|---------|-------|
| Background | #150200 | 1.0 | `Color(hex: "#150200")` |
| Gradient overlay | #f02912 → #150200 | 0.2 | `.opacity(0.2)` |
| Border | #ffffff | 0.4 | `.stroke(Color.white.opacity(0.4))` |
| Text gradient | Angular gradient | 1.0 | `AngularGradient(...)` |
```

**Step 2: Run design-analyst agent on test node**

Run:
```bash
# Invoke design-analyst agent with file_key and node_id
# Check Implementation Spec output in docs/figma-reports/
```

Expected: Design Tokens table with Opacity column

**Step 3: Verify opacity values match Figma**

Compare generated Implementation Spec against expected values above.

If mismatch found:
- Read design-analyst.md lines 170-220
- Identify bug in opacity extraction logic
- Fix the logic

**Step 4: Re-run test**

Run design-analyst agent again after fix
Expected: PASS - all opacity values correct

**Step 5: Commit**

```bash
git add plugins/pb-figma/agents/design-analyst.md plugins/pb-figma/tests/test-opacity-extraction.md
git commit -m "fix(design-analyst): correct opacity extraction logic

- [describe the bug found and fix applied]
- Verified with TypeSceneText test case
- All opacity values now match Figma exactly

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Debug Design Analyst Gradient Detection

**Files:**
- Read: `plugins/pb-figma/agents/design-analyst.md:222-287`
- Test: New test file

**Step 1: Create test case with known gradient**

Create test file:
```bash
touch plugins/pb-figma/tests/test-gradient-detection.md
```

Test content:
```markdown
# Test: Gradient Detection

## Input
Figma node bt65gbJ6sSdKRP4x3IY151, node 10203:16369
Text: "Type a scene to generate your video"

Expected gradient from Figma:
- Type: ANGULAR
- 7 color stops from #bc82f3 to #c686ff
- Locations: 0.1673, 0.2365, 0.3518, 0.5815, 0.697, 0.8095, 0.9241

## Expected Output

Implementation Spec should show:

```markdown
### Text with Gradient

**Component:** TypeSceneText
- **Gradient Type:** ANGULAR
- **Stops:**
  - 0.1673: #bc82f3 (opacity: 1.0)
  - 0.2365: #f4b9ea (opacity: 1.0)
  - 0.3518: #8d98ff (opacity: 1.0)
  - 0.5815: #aa6eee (opacity: 1.0)
  - 0.697: #ff6777 (opacity: 1.0)
  - 0.8095: #ffba71 (opacity: 1.0)
  - 0.9241: #c686ff (opacity: 1.0)

**SwiftUI Mapping:** `AngularGradient` with 7 color stops
**Minimum iOS:** iOS 15.0+
```
```

**Step 2: Run design-analyst agent on test node**

Run design-analyst agent with test file_key and node_id
Expected: "Text with Gradient" section in Implementation Spec

**Step 3: Verify gradient stops match Figma**

Compare generated stops against expected values.

If mismatch found:
- Read design-analyst.md lines 222-287
- Identify bug (truncation, rounding, missing stops)
- Fix the logic

**Step 4: Re-run test**

Run design-analyst agent again
Expected: PASS - all 7 stops with exact locations

**Step 5: Commit**

```bash
git add plugins/pb-figma/agents/design-analyst.md plugins/pb-figma/tests/test-gradient-detection.md
git commit -m "fix(design-analyst): preserve all gradient stops with exact locations

- [describe the bug found and fix applied]
- Verified with TypeSceneText angular gradient
- All 7 stops now match Figma exactly

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Debug Asset Manager COMPLEX_VECTOR Download

**Files:**
- Read: `plugins/pb-figma/agents/asset-manager.md:79-140`
- Test: New test file

**Step 1: Create test case for chart illustration**

Create test file:
```bash
touch plugins/pb-figma/tests/test-complex-vector-download.md
```

Test content:
```markdown
# Test: COMPLEX_VECTOR Asset Download

## Input
Figma file bt65gbJ6sSdKRP4x3IY151
Asset: "PROJECTED GROWTH" chart illustration

Expected:
- Asset type: COMPLEX_VECTOR (chart/graph with multiple paths)
- Download as: PNG scale 2x or SVG
- Save to: .xcassets/ProjectedGrowthChart.imageset/

## Expected Output

1. Asset Manager detects it as COMPLEX_VECTOR
2. Calls figma_export_assets with format: png, scale: 2
3. Downloads to temp_downloads/
4. Validates file size > 0
5. Moves to .xcassets with proper Contents.json
```

**Step 2: Run asset-manager agent on test file**

Run asset-manager agent with the Figma file
Expected: Chart downloads to .xcassets

**Step 3: Verify asset downloaded correctly**

Check:
```bash
ls -lh .xcassets/ProjectedGrowthChart.imageset/
# Should show PNG file + Contents.json
```

If asset not found:
- Read asset-manager.md lines 79-140
- Check COMPLEX_VECTOR detection logic
- Check download workflow
- Fix the bug

**Step 4: Re-run test**

Run asset-manager agent again
Expected: PASS - asset in .xcassets

**Step 5: Commit**

```bash
git add plugins/pb-figma/agents/asset-manager.md plugins/pb-figma/tests/test-complex-vector-download.md .xcassets/
git commit -m "fix(asset-manager): correctly download COMPLEX_VECTOR assets

- [describe the bug found and fix applied]
- Verified with PROJECTED GROWTH chart
- Asset now downloads to .xcassets correctly

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Debug SwiftUI Generator Opacity Application

**Files:**
- Read: `plugins/pb-figma/agents/code-generator-swiftui.md:175-222`
- Test: New test file

**Step 1: Create test case for opacity application**

Create test file:
```bash
touch plugins/pb-figma/tests/test-swiftui-opacity.md
```

Test content:
```markdown
# Test: SwiftUI Opacity Application

## Input
Implementation Spec with:

```markdown
| Property | Color | Opacity | Usage |
|----------|-------|---------|-------|
| Border | #ffffff | 0.4 | `.stroke(Color.white.opacity(0.4))` |
| Background | #150200 | 1.0 | `Color(hex: "#150200")` |
| Overlay | #f02912 | 0.2 | `.opacity(0.2)` |
```

## Expected SwiftUI Output

```swift
// Border with opacity from spec
RoundedRectangle(cornerRadius: 24)
    .stroke(Color.white.opacity(0.4), lineWidth: 1.0)

// Background without opacity modifier (1.0)
Color(hex: "#150200")

// Gradient overlay with opacity
RadialGradient(...)
    .opacity(0.2)
```
```

**Step 2: Run code-generator-swiftui agent on test spec**

Run code-generator-swiftui agent with test Implementation Spec
Expected: Generated Swift code includes .opacity() modifiers

**Step 3: Verify opacity modifiers in generated code**

Search generated code for:
```bash
grep -n "\.opacity(" GeneratedComponent.swift
```

Expected matches:
- Line X: `.stroke(Color.white.opacity(0.4))`
- Line Y: `.opacity(0.2)`

If missing:
- Read code-generator-swiftui.md lines 175-222
- Check if agent reads "Usage" column correctly
- Check if agent applies opacity modifiers
- Fix the bug

**Step 4: Re-run test**

Run code-generator-swiftui agent again
Expected: PASS - all opacity modifiers present

**Step 5: Commit**

```bash
git add plugins/pb-figma/agents/code-generator-swiftui.md plugins/pb-figma/tests/test-swiftui-opacity.md
git commit -m "fix(code-generator-swiftui): apply opacity modifiers from spec

- [describe the bug found and fix applied]
- Verified with TypeSceneText opacity values
- Generated code now includes all .opacity() modifiers

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Debug SwiftUI Generator Gradient Rendering

**Files:**
- Read: `plugins/pb-figma/agents/code-generator-swiftui.md:223-330`
- Test: New test file

**Step 1: Create test case for gradient rendering**

Create test file:
```bash
touch plugins/pb-figma/tests/test-swiftui-gradient.md
```

Test content:
```markdown
# Test: SwiftUI Gradient Rendering

## Input
Implementation Spec with:

```markdown
### Text with Gradient

**Component:** TypeSceneText
- **Gradient Type:** ANGULAR
- **Stops:**
  - 0.1673: #bc82f3 (opacity: 1.0)
  - 0.2365: #f4b9ea (opacity: 1.0)
  - [5 more stops...]

**SwiftUI Mapping:** `AngularGradient` with 7 color stops
**Minimum iOS:** iOS 15.0+
```

## Expected SwiftUI Output

```swift
Text("Type a scene to generate your video")
    .font(.system(size: 14, weight: .regular))
    .foregroundStyle(  // NOT .foregroundColor()
        AngularGradient(
            stops: [
                Gradient.Stop(color: Color(hex: "#bc82f3"), location: 0.1673),
                Gradient.Stop(color: Color(hex: "#f4b9ea"), location: 0.2365),
                // ALL 7 stops preserved
            ],
            center: .center
        )
    )
```
```

**Step 2: Run code-generator-swiftui agent on test spec**

Run code-generator-swiftui agent with test Implementation Spec
Expected: Generated code uses .foregroundStyle() with AngularGradient

**Step 3: Verify gradient in generated code**

Check generated code:
```bash
grep -n "foregroundStyle" GeneratedComponent.swift
grep -n "AngularGradient" GeneratedComponent.swift
grep -c "Gradient.Stop" GeneratedComponent.swift  # Should be 7
```

If wrong:
- Read code-generator-swiftui.md lines 223-330
- Check if uses .foregroundStyle() not .foregroundColor()
- Check if all 7 stops preserved
- Check if stop locations exact (not rounded)
- Fix the bug

**Step 4: Re-run test**

Run code-generator-swiftui agent again
Expected: PASS - correct gradient with all stops

**Step 5: Commit**

```bash
git add plugins/pb-figma/agents/code-generator-swiftui.md plugins/pb-figma/tests/test-swiftui-gradient.md
git commit -m "fix(code-generator-swiftui): render gradients with exact stops

- [describe the bug found and fix applied]
- Verified with TypeSceneText angular gradient
- All 7 stops preserved with exact locations
- Uses .foregroundStyle() correctly

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Add Text Decoration Support to SwiftUI Generator

**Files:**
- Modify: `plugins/pb-figma/agents/code-generator-swiftui.md:331-380` (new section)

**Step 1: Write the failing test**

Create test file:
```bash
touch plugins/pb-figma/tests/test-swiftui-decoration.md
```

Test content:
```markdown
# Test: SwiftUI Text Decoration

## Input
Implementation Spec with:

```markdown
### Text Decoration

**Component:** HookText
- **Decoration:** Underline
- **Color:** #ffd100 (opacity: 1.0)
- **Thickness:** 1.0

**SwiftUI Mapping:** `.underline(color: Color(hex: "#ffd100"))`
```

## Expected SwiftUI Output

```swift
Text("Hook")
    .font(.system(size: 14, weight: .regular))
    .underline(color: Color(hex: "#ffd100"))
```
```

**Step 2: Run test to verify it fails**

Run code-generator-swiftui agent with test spec
Expected: FAIL - .underline() modifier missing

**Step 3: Write minimal implementation**

Add to `plugins/pb-figma/agents/code-generator-swiftui.md` after line 330:

```markdown
##### Apply Text Decoration from Spec

**Read decoration from Implementation Spec "Text Decoration" section:**

When Implementation Spec includes Text Decoration section:

```markdown
### Text Decoration

**Component:** HookText
- **Decoration:** Underline | Strikethrough
- **Color:** #ffd100 (opacity: 1.0)
- **Thickness:** 1.0

**SwiftUI Mapping:** `.underline(color: Color(hex: "#ffd100"))`
```

**Generate SwiftUI code with decoration modifier:**

```swift
Text("Hook")
    .font(.system(size: 14, weight: .regular))
    .underline(color: Color(hex: "#ffd100"))
```

**For strikethrough:**

```swift
Text("Canceled")
    .strikethrough(color: Color(hex: "#ff0000"))
```

**Critical rules:**

1. **Apply after .font() modifier** - decoration goes after typography
2. **Use exact color from spec** - Copy hex value from "Color" field
3. **Include opacity if < 1.0** - `.underline(color: Color(hex: "#ffd100").opacity(0.8))`
4. **iOS 16+ API** - Add `@available(iOS 16.0, *)` if using color parameter
5. **Fallback for iOS 15** - Use `.underline()` without color for older iOS

**iOS version handling:**

```swift
@available(iOS 16.0, *)
struct HookText: View {
    var body: some View {
        Text("Hook")
            .underline(color: Color(hex: "#ffd100"))
    }
}

// OR with fallback

struct HookText: View {
    var body: some View {
        if #available(iOS 16.0, *) {
            Text("Hook")
                .underline(color: Color(hex: "#ffd100"))
        } else {
            Text("Hook")
                .underline()
        }
    }
}
```
```

**Step 4: Run test to verify it passes**

Run code-generator-swiftui agent with test spec
Expected: PASS - .underline(color:) modifier present

**Step 5: Commit**

```bash
git add plugins/pb-figma/agents/code-generator-swiftui.md plugins/pb-figma/tests/test-swiftui-decoration.md
git commit -m "feat(code-generator-swiftui): add text decoration support

- Apply .underline() and .strikethrough() modifiers
- Read decoration color from Implementation Spec
- Handle iOS 16+ color parameter with fallback
- Include opacity if decoration color has opacity < 1.0

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 8: End-to-End Test with User's Figma File

**Files:**
- Read: All agent files
- Test: `plugins/pb-figma/tests/test-e2e-typescenetext.md`
- Output: `Views/Components/TypeSceneText.swift` (regenerated)

**Step 1: Create comprehensive E2E test case**

Create test file:
```bash
touch plugins/pb-figma/tests/test-e2e-typescenetext.md
```

Test content:
```markdown
# E2E Test: TypeSceneText Component

## Input
- Figma file: bt65gbJ6sSdKRP4x3IY151
- Node: 10203:16369
- Component: TypeSceneText

## Expected Behaviors

### Design Validator
- ✅ Auto Layout detected
- ✅ No validation warnings
- Output: docs/figma-reports/bt65gbJ6sSdKRP4x3IY151-validation.md

### Design Analyst
- ✅ Opacity values extracted (border 0.4, gradient overlay 0.2)
- ✅ Angular gradient with 7 stops detected
- ✅ Text decoration color extracted (if "Hook" text exists)
- Output: docs/figma-reports/bt65gbJ6sSdKRP4x3IY151-implementation-spec.md

### Asset Manager
- ✅ PROJECTED GROWTH chart identified as COMPLEX_VECTOR
- ✅ Chart downloaded to .xcassets/ProjectedGrowthChart.imageset/
- Output: Asset list in Implementation Spec

### Code Generator SwiftUI
- ✅ .opacity(0.4) applied to border
- ✅ .opacity(0.2) applied to gradient overlay
- ✅ AngularGradient with all 7 stops
- ✅ .underline(color: Color(hex: "#ffd100")) if decoration exists
- ✅ Chart referenced from .xcassets
- Output: Views/Components/TypeSceneText.swift

### Compliance Checker
- ✅ All design tokens match spec
- ✅ All assets present
- ✅ Code quality passes
- Output: docs/figma-reports/bt65gbJ6sSdKRP4x3IY151-final.md

## Visual Validation

Use Claude Vision to compare:
- Image 1: Figma screenshot (from user)
- Image 2: Xcode preview screenshot

Expected: No visual differences
```

**Step 2: Backup current TypeSceneText.swift**

```bash
cp Views/Components/TypeSceneText.swift Views/Components/TypeSceneText.swift.backup
```

**Step 3: Run full 5-agent pipeline**

Invoke figma-to-code skill:
```bash
# In Claude Code:
# User: Convert bt65gbJ6sSdKRP4x3IY151 node 10203:16369 to SwiftUI
```

This triggers:
1. Design Validator
2. Design Analyst
3. Asset Manager
4. Code Generator SwiftUI
5. Compliance Checker

**Step 4: Verify each agent's output**

Check each report file:
```bash
cat docs/figma-reports/bt65gbJ6sSdKRP4x3IY151-validation.md
cat docs/figma-reports/bt65gbJ6sSdKRP4x3IY151-implementation-spec.md
cat docs/figma-reports/bt65gbJ6sSdKRP4x3IY151-final.md
```

Verify:
- Validation: No FAIL status
- Implementation Spec: Opacity column present, Text Decoration section present
- Final report: All compliance checks PASS

**Step 5: Visual validation with Claude Vision**

Take Xcode preview screenshot:
```bash
# Open Views/Components/TypeSceneText.swift in Xcode
# Run preview
# Take screenshot
```

Compare using Claude Vision:
```
Compare these two images:
1. Figma design (user's Image #6)
2. Xcode preview screenshot

Identify ALL visual differences in:
- Typography (font, size, weight, color)
- Spacing (padding, margins, gaps)
- Colors (backgrounds, borders, text)
- Opacity (transparency levels)
- Assets (chart illustration presence)
- Text decoration (underline color)
```

**Step 6: Fix any remaining differences**

If differences found:
- Identify which agent is responsible
- Debug that specific agent
- Re-run the pipeline
- Repeat visual validation

**Step 7: Commit regenerated component**

```bash
git add Views/Components/TypeSceneText.swift docs/figma-reports/ .xcassets/
git commit -m "fix: regenerate TypeSceneText with pixel-perfect accuracy

Pipeline execution:
- Design Validator: PASS
- Design Analyst: Opacity + gradient + decoration extracted
- Asset Manager: Chart downloaded successfully
- Code Generator: All modifiers applied correctly
- Compliance Checker: PASS

Visual validation: No differences from Figma design

Fixes applied:
- Border opacity 0.4 now correct
- Gradient overlay opacity 0.2 now correct
- Angular gradient all 7 stops preserved
- Text decoration color extracted (if present)
- PROJECTED GROWTH chart asset included

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Success Criteria

**All tests pass:**
- [ ] Text decoration color extraction works
- [ ] Opacity extraction matches Figma exactly
- [ ] Gradient detection preserves all stops
- [ ] COMPLEX_VECTOR assets download correctly
- [ ] SwiftUI code applies opacity modifiers
- [ ] SwiftUI code renders gradients with .foregroundStyle()
- [ ] SwiftUI code applies text decoration with color

**Visual validation:**
- [ ] Claude Vision confirms no differences between Figma and Xcode preview
- [ ] Border opacity 0.4 visible
- [ ] Gradient overlay opacity 0.2 visible
- [ ] Angular gradient displays correctly
- [ ] PROJECTED GROWTH chart asset loads
- [ ] Text decoration color correct (if present)

**Documentation:**
- [ ] All test files committed
- [ ] All reports generated in docs/figma-reports/
- [ ] TypeSceneText.swift regenerated and committed

**Performance:**
- [ ] Full pipeline completes in < 5 minutes
- [ ] No manual intervention required after pipeline start

---

## Handoff Options

After completing all tasks:

**Option 1: Subagent-Driven (this session)**
- Use superpowers:subagent-driven-development
- Fresh subagent per task
- Two-stage review after each (spec compliance + code quality)
- Stay in this session

**Option 2: Parallel Session (separate)**
- Open new session with superpowers:executing-plans
- Batch execution with checkpoints
- Execute in parallel session

Which approach?
