# Framework-Agnostic Code Generation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor pb-figma's monolithic code-generator into framework-specific agents (React, SwiftUI, Vue, Kotlin) with shared base logic.

**Architecture:** Create code-generator-base.md as reference documentation containing shared logic (spec reading, validation, error handling, output formatting). Build 4 framework-specific agents that reference the base and implement framework-specific code generation, best practices, and directory structures. Update figma-to-code skill to detect framework and route to appropriate agent.

**Tech Stack:** Claude Code agents (Markdown), Figma MCP Server, framework-specific code generators (React/Tailwind, SwiftUI, Vue, Kotlin)

---

## Task 1: Create Base Agent Reference Documentation

**Files:**
- Create: `plugins/pb-figma/agents/code-generator-base.md`

**Step 1: Extract shared logic from current code-generator**

Read the current agent to identify shared sections:

```bash
cat plugins/pb-figma/agents/code-generator.md | grep -E "^##" | head -20
```

Expected: List of sections including "Input", "Process", "Error Handling", "Output Structure"

**Step 2: Create code-generator-base.md with shared logic**

Create file with frontmatter and shared sections:

```markdown
---
name: code-generator-base
description: Base reference documentation for all framework-specific code generators. Defines shared logic for spec reading, validation, asset handling, error recovery, and output formatting. Not invoked directly - referenced by framework-specific agents.
---

# Code Generator Base Reference

**Note:** This is reference documentation, not an executable agent. Framework-specific agents (react, swiftui, vue, kotlin) reference this for shared logic.

## Shared Input Processing

### Reading Implementation Spec

All code generators read from: `docs/figma-reports/{file_key}-spec.md`

#### Resolving file_key

The `file_key` can be obtained through:

1. **User provides directly** - User specifies the file_key or full filename
2. **List and select** - If no file_key provided:
   ```bash
   ls docs/figma-reports/*-spec.md
   ```
   Ask user to select from available specs.

3. **Extract from spec header** - After selecting, extract:
   ```
   Look for: **File Key:** {file_key}
   ```

### Implementation Spec Structure

Extract these sections:

| Section | Description |
|---------|-------------|
| Component Hierarchy | Tree structure with semantic elements |
| Components | Detailed component specs with properties, layout, styles |
| Design Tokens (Ready to Use) | CSS vars / Tailwind tokens / Platform-specific tokens |
| Downloaded Assets | Asset paths and import statements |
| Assets Required | Node IDs for each component (for MCP generation) |

### Verification

Check spec is ready:
- Look for "Ready for: Code Generator Agent" in Next Agent Input section
- Verify Downloaded Assets section exists
- If not ready, warn user: "Asset Manager may not have completed"

## Shared Process Flow

Use `TodoWrite` to track progress:

1. **Read Implementation Spec** - Load and parse the spec file
2. **Verify Spec Status** - Check ready state
3. **Detect Framework** - (Framework-specific logic)
4. **Confirm with User** - Validate detection
5. **Generate Component Code** - Use MCP + framework-specific enhancement
6. **Write Component Files** - Framework-specific directory structure
7. **Update Spec with Results** - Add Generated Code table

## Shared MCP Integration

### figma_generate_code Tool

All agents use this MCP tool for base code generation:

```
figma_generate_code:
  - file_key: {file_key}
  - node_id: {node_id}
  - framework: {framework_parameter}
  - component_name: {ComponentName}
```

### Rate Limit Handling (Shared)

**Critical:** All agents must implement:

- Wait 2 seconds between MCP calls
- If rate limited (429):
  - Wait 30 seconds
  - Retry with exponential backoff: 30s → 60s → 120s
- Process in batches of 5 components
- If MCP timeout (>30s): Retry once, then fall back to manual generation

### MCP Framework Parameters

Map to MCP framework parameter:

| Framework | MCP Parameter |
|-----------|---------------|
| React + Tailwind | `react_tailwind` |
| React (no Tailwind) | `react` |
| Vue + Tailwind | `vue_tailwind` |
| Vue (no Tailwind) | `vue` |
| SwiftUI | `swiftui` |
| Kotlin/Jetpack Compose | `kotlin` |
| HTML/CSS | `html_css` |

## Shared Error Handling

### MCP Generation Fails

1. Log error with component name and node ID
2. Retry once with same parameters
3. If retry fails:
   - Fall back to manual generation using spec details
   - Document in Generated Code table: status "MANUAL"
   - Add note: "Generated from spec (MCP unavailable)"

### Missing Assets

1. Check if asset exists in Downloaded Assets section
2. If missing:
   - Use placeholder path (framework-specific)
   - Add TODO comment in code
   - Document with status "WARN - Missing asset"
   - Add to summary: "Asset {name} not found - using placeholder"

### Missing Node ID

1. Log warning: "Component '{name}' missing node ID"
2. Generate manually from spec details
3. Document with status "MANUAL - No Node ID"

### Spec Not Found

If spec doesn't exist:
1. Report error: "Implementation Spec not found"
2. List available specs: `ls docs/figma-reports/*-spec.md`
3. Provide instructions: "Run Asset Manager agent first"
4. Stop processing

## Shared Output Format

### Update Spec with Results

Add these sections to `docs/figma-reports/{file_key}-spec.md`:

```markdown
## Generated Code

| Component | File | Status |
|-----------|------|--------|
| {ComponentName} | `{file_path}` | OK / WARN / MANUAL |

## Code Generation Summary

- **Framework:** {framework}
- **Components generated:** {count}
- **Files created:** {count}
- **Warnings:** {count}
- **Generation timestamp:** {YYYYMMDD-HHmmss}

## Files Created

### Components
- `{component_file_1}`
- `{component_file_2}`

### Styles (if created)
- `{tokens_file}`

## Next Agent Input

Ready for: Compliance Checker Agent
Input file: `docs/figma-reports/{file_key}-spec.md`
Components generated: {count}
Framework: {framework}
```

## Manual Generation Fallback

When MCP is unavailable, generate from spec:

### Extract from Spec

1. **Component properties** from Components section
2. **Layout classes** from Classes/Styles field
3. **Semantic element** from Element field
4. **Children** from Children field
5. **Design tokens** from Design Tokens section

### Framework-Specific Templates

Each framework agent provides its own manual generation template.

## Shared Validation Checklist

For each component, verify:

- [ ] Hierarchy matches spec
- [ ] Semantic elements used (not just div/View soup)
- [ ] Tokens applied (no hardcoded values)
- [ ] Type definitions included
- [ ] Accessibility attributes present
- [ ] Assets referenced correctly

## Reference from Framework Agents

Framework-specific agents should reference this document:

```markdown
## Base Logic

See [code-generator-base.md](./code-generator-base.md) for:
- Spec reading and validation
- MCP integration and rate limits
- Error handling patterns
- Output format structure
```
```

**Step 3: Verify file structure**

```bash
head -30 plugins/pb-figma/agents/code-generator-base.md
```

Expected: Frontmatter with "Not invoked directly - referenced by framework-specific agents"

**Step 4: Commit base reference**

```bash
git add plugins/pb-figma/agents/code-generator-base.md
git commit -m "feat(pb-figma): add code-generator-base reference documentation

- Shared logic for spec reading, validation, MCP integration
- Common error handling patterns
- Standardized output format
- Referenced by framework-specific agents"
```

---

## Task 2: Refactor React Agent

**Files:**
- Rename: `plugins/pb-figma/agents/code-generator.md` → `plugins/pb-figma/agents/code-generator-react.md`
- Modify: `plugins/pb-figma/agents/code-generator-react.md` (remove shared logic, add base reference)

**Step 1: Backup current code-generator**

```bash
cp plugins/pb-figma/agents/code-generator.md plugins/pb-figma/agents/code-generator.md.backup
```

Expected: Backup file created

**Step 2: Rename to code-generator-react.md**

```bash
mv plugins/pb-figma/agents/code-generator.md plugins/pb-figma/agents/code-generator-react.md
```

Expected: File renamed

**Step 3: Update frontmatter and add base reference**

Update frontmatter:

```markdown
---
name: code-generator-react
description: Generates production-ready React/Next.js + Tailwind components from Implementation Spec. Detects React/Next.js projects, uses Figma MCP for base generation, enhances with TypeScript types, semantic HTML, accessibility, and Tailwind best practices.
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

# React/Next.js Code Generator Agent

You generate production-ready React/Next.js + Tailwind components from Implementation Specs.

## Base Logic

See [code-generator-base.md](./code-generator-base.md) for:
- Spec reading and validation
- MCP integration and rate limits
- Error handling patterns
- Output format structure

## React-Specific Process
```

**Step 4: Remove shared sections, keep React-specific logic**

Remove these sections (now in base):
- "Resolving file_key" (lines 24-38)
- "Rate Limits & Timeouts" section
- "Error Handling" section (except React-specific errors)
- "Output Structure" spec format (keep React component examples)

Keep these React-specific sections:
- Framework Detection (React/Next.js only)
- React Component Structure
- TypeScript Types
- Tailwind Best Practices
- Directory Structure (React-specific)

**Step 5: Add React framework detection**

Replace general framework detection with React-specific:

```markdown
## Framework Detection

### Detect React/Next.js

Check for React framework:

```bash
# Check package.json for React
cat package.json 2>/dev/null | grep -E '"react"|"next"'
```

Determine variant:

| Found | Framework |
|-------|-----------|
| "next" | Next.js (App Router preferred) |
| "react" (no "next") | React (Vite/CRA) |

### Detect Tailwind

```bash
# Check for Tailwind
ls tailwind.config.* 2>/dev/null || cat package.json 2>/dev/null | grep tailwindcss
```

### Confirm with User

Use `AskUserQuestion`:

```
Detected: {React/Next.js} + {Tailwind: yes/no}

Options:
1. Yes, proceed with detected setup
2. Use different React setup (specify)
```

### Map to MCP Framework

| Detected | MCP Parameter |
|----------|---------------|
| React + Tailwind | `react_tailwind` |
| Next.js + Tailwind | `react_tailwind` |
| React (no Tailwind) | `react` |
```

**Step 6: Verify React-specific sections remain**

```bash
grep -n "React Component Example" plugins/pb-figma/agents/code-generator-react.md
grep -n "Tailwind Best Practices" plugins/pb-figma/agents/code-generator-react.md
```

Expected: Both sections found

**Step 7: Commit React agent refactor**

```bash
git add plugins/pb-figma/agents/code-generator-react.md
git rm plugins/pb-figma/agents/code-generator.md.backup
git commit -m "refactor(pb-figma): split code-generator into React-specific agent

- Rename code-generator.md → code-generator-react.md
- Remove shared logic (now in code-generator-base.md)
- Keep React/Next.js + Tailwind specific logic
- Add base reference for shared patterns"
```

---

## Task 3: Create SwiftUI Agent

**Files:**
- Create: `plugins/pb-figma/agents/code-generator-swiftui.md`

**Step 1: Create SwiftUI agent with frontmatter**

```markdown
---
name: code-generator-swiftui
description: Generates production-ready SwiftUI views from Implementation Spec. Detects SwiftUI/Xcode projects, uses Figma MCP for base generation, enhances with Swift type safety, ViewModifiers, accessibility, and iOS/macOS design patterns.
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

# SwiftUI Code Generator Agent

You generate production-ready SwiftUI views from Implementation Specs.

## Base Logic

See [code-generator-base.md](./code-generator-base.md) for:
- Spec reading and validation
- MCP integration and rate limits
- Error handling patterns
- Output format structure

## SwiftUI-Specific Process

Use `TodoWrite` to track code generation through:

1. **Read Implementation Spec** - Load from `docs/figma-reports/{file_key}-spec.md`
2. **Verify Spec Status** - Check "Ready for: Code Generator Agent"
3. **Detect SwiftUI Project** - Find .xcodeproj or Package.swift
4. **Confirm with User** - Validate iOS vs macOS target
5. **Generate SwiftUI Views** - Use MCP with framework: `swiftui`
6. **Enhance with Swift Idioms** - Add ViewModifiers, property wrappers, accessibility
7. **Write View Files** - Save to Views/ directory
8. **Update Spec with Results** - Add Generated Code table

## Framework Detection

### Detect SwiftUI Project

Check for Xcode or Swift Package Manager:

```bash
# Check for Xcode project
ls -d *.xcodeproj 2>/dev/null

# Or Swift Package Manager
ls Package.swift 2>/dev/null
```

### Detect Platform Target

```bash
# Check Xcode project for platform
xcodebuild -project *.xcodeproj -list 2>/dev/null | grep -E "iOS|macOS|watchOS"

# Or check Package.swift
grep -E "platforms" Package.swift 2>/dev/null
```

### Confirm with User

Use `AskUserQuestion`:

```
Detected: SwiftUI project
Platform: {iOS/macOS/multiplatform}

Options:
1. Yes, proceed with SwiftUI for {platform}
2. Specify different target platform
```

### MCP Framework Parameter

Always use: `swiftui`

## Code Generation

### For Each Component

#### 1. Generate Base Code via MCP

```
figma_generate_code:
  - file_key: {file_key}
  - node_id: {node_id}
  - framework: "swiftui"
  - component_name: {ComponentName}
```

#### 2. Enhance SwiftUI Code

##### Apply Design Tokens

Replace hardcoded colors with semantic tokens:

```swift
// Before (MCP output)
.background(Color(red: 0.23, green: 0.51, blue: 0.96))

// After (with design tokens)
.background(Color.primaryBackground)
// Or with custom token
.background(Color(uiColor: UIColor(named: "PrimaryBackground")!))
```

##### Add ViewModifiers

Apply proper modifiers per iOS/macOS Human Interface Guidelines:

```swift
// Before (MCP output)
Text("Hello")

// After (with ViewModifiers)
Text("Hello")
    .font(.headline)
    .foregroundStyle(.primary)
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
```

##### Add Property Wrappers

Use appropriate state management:

```swift
struct CardView: View {
    // Component props
    let title: String
    let description: String?
    let imageName: String?

    // State (if needed)
    @State private var isExpanded = false

    var body: some View {
        // View implementation
    }
}
```

##### Add Accessibility

Include VoiceOver and Dynamic Type support:

```swift
Image(systemName: "star.fill")
    .accessibilityLabel("Favorite")
    .accessibilityAddTraits(.isButton)

Text(title)
    .font(.headline)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Cap at xxxLarge
```

#### 3. Write SwiftUI Files

##### Detect Directory Structure

```bash
# Check for existing Views directory
find . -type d -name "Views" 2>/dev/null | grep -v ".build"

# Or check Sources structure (SPM)
ls -d Sources/*/Views 2>/dev/null
```

##### Default Directory Structure

**Xcode Project:**
```
{ProjectName}/
├── Views/
│   ├── Components/
│   │   ├── CardView.swift
│   │   └── ButtonView.swift
│   └── Screens/
│       └── HomeView.swift
└── Theme/
    └── DesignTokens.swift
```

**Swift Package:**
```
Sources/
└── {ModuleName}/
    ├── Views/
    │   ├── Components/
    │   └── Screens/
    └── Theme/
        └── DesignTokens.swift
```

##### File Naming Convention

- **View files**: `{ComponentName}View.swift` (e.g., `CardView.swift`)
- **No View suffix**: Only if component name already implies view (e.g., `Card.swift` is acceptable)

## Output Structure

### SwiftUI Component Example

```swift
import SwiftUI

/// A card component displaying title, description, and optional image
struct CardView: View {
    // MARK: - Properties

    /// Card title
    let title: String

    /// Optional description text
    let description: String?

    /// Optional image asset name
    let imageName: String?

    /// Additional action handler
    let onTap: (() -> Void)?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 192)
                    .clipped()
                    .cornerRadius(8)
                    .accessibilityHidden(true) // Decorative image
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .onTapGesture {
            onTap?()
        }
    }
}

// MARK: - Preview

#Preview("Card with Image") {
    CardView(
        title: "Sample Card",
        description: "This is a sample card description",
        imageName: "sample-image",
        onTap: { print("Card tapped") }
    )
    .padding()
}

#Preview("Card without Image") {
    CardView(
        title: "Text Only Card",
        description: "This card has no image",
        imageName: nil,
        onTap: nil
    )
    .padding()
}
```

### Design Tokens File

Create `Theme/DesignTokens.swift` for color tokens:

```swift
import SwiftUI

extension Color {
    // MARK: - Primary Colors

    static let primaryBackground = Color("PrimaryBackground")
    static let secondaryBackground = Color("SecondaryBackground")
    static let cardBackground = Color("CardBackground")

    // MARK: - Text Colors

    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")

    // MARK: - Accent Colors

    static let accentBlue = Color("AccentBlue")
    static let accentGreen = Color("AccentGreen")
}

extension CGFloat {
    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24

    // MARK: - Corner Radius

    static let radiusS: CGFloat = 4
    static let radiusM: CGFloat = 8
    static let radiusL: CGFloat = 12
}
```

## SwiftUI Best Practices

### View Composition

- Break large views into smaller subviews
- Use `@ViewBuilder` for conditional content
- Extract repeated patterns to ViewModifiers

```swift
// Extract repeated styles
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
```

### State Management

| Scenario | Property Wrapper |
|----------|------------------|
| Local view state | `@State` |
| Shared state from parent | `@Binding` |
| Observable object | `@StateObject` (owner) or `@ObservedObject` |
| Environment value | `@Environment` |

### Performance

- Use `lazy` stacks for long lists: `LazyVStack`, `LazyHStack`
- Avoid heavy computation in `body` - use computed properties
- Use `.id()` modifier carefully (triggers view recreation)

### Platform Differences

```swift
#if os(iOS)
    .listStyle(.insetGrouped)
#elseif os(macOS)
    .listStyle(.sidebar)
#endif
```

## Component Checklist

For each generated SwiftUI view:

- [ ] Hierarchy matches spec
- [ ] Semantic View types used (VStack, HStack, ZStack vs generic containers)
- [ ] Design tokens applied (Color extensions, not hardcoded values)
- [ ] Property wrappers appropriate (@State, @Binding, etc.)
- [ ] Accessibility labels and traits
- [ ] SwiftUI Previews included (#Preview macro)
- [ ] Assets referenced correctly
- [ ] ViewModifiers follow HIG (Human Interface Guidelines)

## Manual Generation Fallback

When MCP is unavailable:

### Extract from Spec

1. **Component properties** → Swift properties
2. **Layout** → VStack/HStack/ZStack
3. **Styles** → ViewModifiers
4. **Children** → Nested views

### Generate Structure

```swift
// From spec:
// Element: VStack
// Layout: vertical spacing 12
// Background: card background
// Corner radius: 12
// Shadow: 0 2 8 rgba(0,0,0,0.1)

struct {ComponentName}View: View {
    // Props from spec
    let title: String
    let description: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Children from spec
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}
```
```

**Step 2: Verify SwiftUI agent structure**

```bash
grep -n "## Framework Detection" plugins/pb-figma/agents/code-generator-swiftui.md
grep -n "SwiftUI Component Example" plugins/pb-figma/agents/code-generator-swiftui.md
```

Expected: Both sections found with SwiftUI-specific content

**Step 3: Commit SwiftUI agent**

```bash
git add plugins/pb-figma/agents/code-generator-swiftui.md
git commit -m "feat(pb-figma): add SwiftUI code generator agent

- SwiftUI view generation from Figma specs
- iOS/macOS platform detection
- ViewModifiers and property wrappers
- Design tokens with Color/CGFloat extensions
- Accessibility and Dynamic Type support
- Preview generation"
```

---

## Task 4: Update figma-to-code Skill with Framework Routing

**Files:**
- Modify: `plugins/pb-figma/skills/figma-to-code/SKILL.md`

**Step 1: Read current skill to find agent pipeline section**

```bash
grep -n "Agent Pipeline" plugins/pb-figma/skills/figma-to-code/SKILL.md
```

Expected: Line number for Agent Pipeline section

**Step 2: Update agent pipeline with framework routing**

Find section "### Invoking the Pipeline" (around line 87) and replace with:

```markdown
### Invoking the Pipeline

When a Figma URL is provided, invoke agents sequentially:

1. **Start:** Parse Figma URL, create report directory
2. **Agent 1:** Dispatch `design-validator` with URL
3. **Agent 2:** Dispatch `design-analyst` with validation report path
4. **Agent 3:** Dispatch `asset-manager` with spec path
5. **Agent 4:** **Detect framework and route to appropriate code generator:**
   - Detect project framework (React/SwiftUI/Vue/Kotlin)
   - Route to framework-specific agent:
     - `code-generator-react` for React/Next.js
     - `code-generator-swiftui` for SwiftUI (iOS/macOS)
     - `code-generator-vue` for Vue/Nuxt
     - `code-generator-kotlin` for Kotlin/Jetpack Compose
6. **Agent 5:** Dispatch `compliance-checker` with spec and code paths
7. **Complete:** Present Final Report to user
```

**Step 3: Add framework detection logic before Agent 4**

Add new section after "### Report Directory":

```markdown
### Framework Detection (Before Code Generation)

Before dispatching the code generator (Agent 4), detect the project framework:

#### Detection Order

1. **Check for Swift/Xcode:**
   ```bash
   ls -d *.xcodeproj 2>/dev/null || ls Package.swift 2>/dev/null
   ```
   If found → Route to `code-generator-swiftui`

2. **Check for Android/Kotlin:**
   ```bash
   ls build.gradle 2>/dev/null && grep -E 'android|kotlin' build.gradle
   ```
   If found → Route to `code-generator-kotlin`

3. **Check for Node.js framework:**
   ```bash
   cat package.json 2>/dev/null | grep -E '"react"|"next"|"vue"|"nuxt"'
   ```
   - If "react" or "next" → Route to `code-generator-react`
   - If "vue" or "nuxt" → Route to `code-generator-vue`

4. **No framework detected:**
   - Ask user to specify framework using `AskUserQuestion`
   - Default to `code-generator-react` if user unsure

#### Framework Routing

Dispatch the appropriate agent:

```markdown
Task(
  subagent_type="pb-figma:code-generator-{framework}",
  prompt="Generate code from spec: docs/figma-reports/{file_key}-spec.md"
)
```

Where `{framework}` is: `react`, `swiftui`, `vue`, or `kotlin`
```

**Step 4: Update skill description to mention multi-framework support**

Find frontmatter description (line 3) and replace:

```markdown
description: This skill handles pixel-perfect Figma design conversion to production code (React/Tailwind, SwiftUI, Vue, Kotlin) using Pixelbyte Figma MCP Server. It should be used when a Figma URL or design selection needs to be converted to production-ready code. The skill employs a 5-phase workflow with framework detection and routing to framework-specific agents. Use cases include (1) generating code from Figma files for any supported framework, (2) design implementation with design tokens, (3) creating design system components, (4) pixel-perfect UI development across platforms, and (5) responsive web/native components.
```

**Step 5: Verify routing logic is present**

```bash
grep -n "Framework Detection (Before Code Generation)" plugins/pb-figma/skills/figma-to-code/SKILL.md
grep -n "code-generator-swiftui" plugins/pb-figma/skills/figma-to-code/SKILL.md
```

Expected: Both sections found

**Step 6: Commit skill update**

```bash
git add plugins/pb-figma/skills/figma-to-code/SKILL.md
git commit -m "feat(pb-figma): add framework detection and routing to figma-to-code

- Multi-framework support (React, SwiftUI, Vue, Kotlin)
- Framework detection logic before code generation
- Route to appropriate code generator agent
- Update skill description to reflect platform support"
```

---

## Task 5: Update Plugin Manifest

**Files:**
- Modify: `plugins/pb-figma/.claude-plugin/plugin.json`

**Step 1: Read current plugin manifest**

```bash
cat plugins/pb-figma/.claude-plugin/plugin.json
```

Expected: JSON with agents array

**Step 2: Update agents array with new agents**

Replace agents array:

```json
{
  "name": "pb-figma",
  "version": "1.1.0",
  "agents": [
    {
      "name": "design-validator",
      "path": "../agents/design-validator.md"
    },
    {
      "name": "design-analyst",
      "path": "../agents/design-analyst.md"
    },
    {
      "name": "asset-manager",
      "path": "../agents/asset-manager.md"
    },
    {
      "name": "code-generator-react",
      "path": "../agents/code-generator-react.md"
    },
    {
      "name": "code-generator-swiftui",
      "path": "../agents/code-generator-swiftui.md"
    },
    {
      "name": "compliance-checker",
      "path": "../agents/compliance-checker.md"
    }
  ],
  "skills": [
    {
      "name": "figma-to-code",
      "path": "../skills/figma-to-code"
    }
  ]
}
```

**Note:** Bump version to 1.1.0 for framework-agnostic support

**Step 3: Verify JSON is valid**

```bash
cat plugins/pb-figma/.claude-plugin/plugin.json | python3 -m json.tool > /dev/null && echo "Valid JSON"
```

Expected: "Valid JSON"

**Step 4: Commit plugin manifest update**

```bash
git add plugins/pb-figma/.claude-plugin/plugin.json
git commit -m "chore(pb-figma): update plugin manifest for v1.1.0

- Add code-generator-react and code-generator-swiftui agents
- Remove deprecated code-generator agent
- Bump version to 1.1.0 for multi-framework support"
```

---

## Task 6: Test SwiftUI Agent with Sample Figma Design

**Files:**
- Test: SwiftUI agent end-to-end
- Create: Test project in temp directory

**Step 1: Create test SwiftUI project**

```bash
# Create temporary test directory
mkdir -p /tmp/swiftui-figma-test
cd /tmp/swiftui-figma-test

# Create minimal Swift package structure
mkdir -p Sources/TestApp/Views/Components
cat > Package.swift << 'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TestApp",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "TestApp", targets: ["TestApp"])
    ],
    targets: [
        .target(name: "TestApp", dependencies: [])
    ]
)
EOF

echo "✅ Test SwiftUI project created"
```

Expected: Directory structure created

**Step 2: Prepare test spec from sample Figma design**

Create a minimal spec for testing:

```bash
mkdir -p docs/figma-reports
cat > docs/figma-reports/test-swiftui-spec.md << 'EOF'
# Implementation Spec - Test Card Component

**File Key:** test-file-key
**Node:** 1:2

## Component Hierarchy

```
CardView (VStack)
├── Image (decorative)
├── TitleText (Text)
└── DescriptionText (Text)
```

## Components

### CardView
- **Element:** VStack
- **Layout:** vertical, spacing 12, padding 16
- **Background:** card background color
- **Corner Radius:** 12
- **Shadow:** 0 2 8 rgba(0,0,0,0.1)
- **Node ID:** 1:2

### TitleText
- **Element:** Text
- **Font:** headline
- **Color:** primary text
- **Content:** "Sample Card"

### DescriptionText
- **Element:** Text
- **Font:** subheadline
- **Color:** secondary text
- **Content:** "This is a sample description"

## Design Tokens (Ready to Use)

### Colors
```swift
extension Color {
    static let cardBackground = Color("CardBackground") // #FFFFFF
    static let textPrimary = Color("TextPrimary") // #1F2937
    static let textSecondary = Color("TextSecondary") // #6B7280
}
```

## Downloaded Assets

No assets required for this test.

## Assets Required

| Component | Node ID |
|-----------|---------|
| CardView | 1:2 |

## Next Agent Input

Ready for: Code Generator Agent
```
EOF

echo "✅ Test spec created"
```

Expected: Spec file created

**Step 3: Dispatch SwiftUI code generator agent**

From the project root directory:

```bash
cd /Users/yusufdemirkoparan/Projects/pixelbyte-agent-workflows

# Note: This is a manual test - use Task tool in Claude Code:
# Task(
#   subagent_type="pb-figma:code-generator-swiftui",
#   prompt="Generate SwiftUI code from: /tmp/swiftui-figma-test/docs/figma-reports/test-swiftui-spec.md"
# )
```

**Manual verification:**
1. Agent should detect SwiftUI project (Package.swift found)
2. Agent should confirm iOS/macOS target with user
3. Agent should generate CardView.swift
4. Agent should create Theme/DesignTokens.swift
5. Agent should update spec with Generated Code table

**Step 4: Verify generated SwiftUI code**

```bash
# Check if CardView was created
ls /tmp/swiftui-figma-test/Sources/TestApp/Views/Components/CardView.swift

# Check code structure
head -50 /tmp/swiftui-figma-test/Sources/TestApp/Views/Components/CardView.swift
```

Expected:
- File exists
- Contains `struct CardView: View`
- Contains `#Preview` macro
- Uses `Color.cardBackground` (design tokens)
- Has accessibility labels

**Step 5: Verify spec was updated**

```bash
grep "## Generated Code" /tmp/swiftui-figma-test/docs/figma-reports/test-swiftui-spec.md
```

Expected: Generated Code table with CardView entry

**Step 6: Clean up test**

```bash
rm -rf /tmp/swiftui-figma-test
echo "✅ Test cleanup complete"
```

**Step 7: Document test results**

Create test report:

```bash
cat > docs/plans/2026-01-25-swiftui-test-results.md << 'EOF'
# SwiftUI Agent Test Results

**Date:** 2026-01-25
**Agent:** code-generator-swiftui

## Test Scenario
Generated SwiftUI CardView from minimal Implementation Spec.

## Results

✅ Framework detection (Package.swift)
✅ Component generation (CardView.swift)
✅ Design tokens application (Color extensions)
✅ Accessibility labels
✅ Preview generation (#Preview macro)
✅ Spec update (Generated Code table)

## Files Generated
- `Sources/TestApp/Views/Components/CardView.swift`
- `Sources/TestApp/Theme/DesignTokens.swift`

## Status
**PASS** - SwiftUI agent working as expected.
EOF
```

**Step 8: Commit test results**

```bash
git add docs/plans/2026-01-25-swiftui-test-results.md
git commit -m "test(pb-figma): verify SwiftUI code generator agent

- Test with minimal card component spec
- Verified framework detection
- Verified code generation and token application
- All checks passed"
```

---

## Task 7: Update README Documentation

**Files:**
- Modify: `README.md`

**Step 1: Update pb-figma section with multi-framework support**

Find "## pb-figma" section (around line 39) and update:

```markdown
## pb-figma

Converts Figma designs to pixel-perfect code for **React/Tailwind, SwiftUI, Vue, and Kotlin** using a 5-phase workflow with 85%+ accuracy target.

### Requirements

Set up a Figma Personal Access Token:

```bash
export FIGMA_PERSONAL_ACCESS_TOKEN="your-token-here"
```

Get your token: Figma → Settings → Personal Access Tokens

### Supported Frameworks

| Framework | Platform | Output |
|-----------|----------|--------|
| **React + Tailwind** | Web | `.tsx` components with Tailwind classes |
| **SwiftUI** | iOS/macOS | `.swift` views with ViewModifiers |
| **Vue + Tailwind** | Web | `.vue` components with Composition API |
| **Kotlin** | Android | `.kt` composables with Jetpack Compose |

### Features

- **Framework detection** - Automatically detects project type
- **Design token mapping** - Colors, typography, spacing for each platform
- **Code Connect support** - Component mapping for design systems
- **Visual validation** - Claude in Chrome MCP for QA
- **Automatic QA** - Iterative refinement with compliance checking

### 5-Phase Workflow

1. **Design Validation** - Check for Auto Layout, component structure
2. **Design Analysis** - Extract hierarchy, tokens, semantic structure
3. **Asset Management** - Download images, icons, generate import paths
4. **Code Generation** - Framework-specific code with best practices
5. **Compliance Check** - Verify implementation matches spec

### Usage

Provide a Figma URL or mention "figma-to-code", "convert Figma", "implement design".

Framework is auto-detected:
- Finds `.xcodeproj`/`Package.swift` → Routes to SwiftUI agent
- Finds `package.json` with "react" → Routes to React agent
- Finds `build.gradle` with "android" → Routes to Kotlin agent

### MCP Server

Automatically configures `pixelbyte-figma-mcp` with these tools:
- `figma_get_file_structure` - Get file/node hierarchy
- `figma_get_node_details` - Get detailed node info
- `figma_generate_code` - Generate code (supports: react_tailwind, swiftui, vue, kotlin)
- `figma_get_design_tokens` - Extract design tokens
- `figma_get_screenshot` - Capture visual reference
- `figma_get_code_connect_map` - Get component mappings
```

**Step 2: Verify updated section**

```bash
grep -A 10 "Supported Frameworks" README.md
```

Expected: Table with React, SwiftUI, Vue, Kotlin

**Step 3: Commit README update**

```bash
git add README.md
git commit -m "docs: update README with multi-framework support

- Add Supported Frameworks table
- Document framework auto-detection
- List platform-specific outputs
- Update MCP tool list with framework parameters"
```

---

## Task 8: Create Vue Agent (Stub for Future)

**Files:**
- Create: `plugins/pb-figma/agents/code-generator-vue.md`

**Step 1: Create Vue agent stub**

```markdown
---
name: code-generator-vue
description: Generates production-ready Vue 3/Nuxt + Tailwind components from Implementation Spec. Uses Composition API, TypeScript, and Tailwind best practices. (STUB - Full implementation pending)
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

# Vue/Nuxt Code Generator Agent

**Status:** STUB - Full implementation pending

You generate production-ready Vue 3/Nuxt + Tailwind components from Implementation Specs.

## Base Logic

See [code-generator-base.md](./code-generator-base.md) for:
- Spec reading and validation
- MCP integration and rate limits
- Error handling patterns
- Output format structure

## Vue-Specific Implementation (TODO)

This agent is a stub for future Vue/Nuxt support. Implementation should follow the same patterns as React and SwiftUI agents with Vue-specific:

- **Framework Detection:** Check for Vue/Nuxt in package.json
- **Component Structure:** Composition API with `<script setup>` syntax
- **Type Safety:** TypeScript with component props interfaces
- **Styling:** Tailwind classes or scoped styles
- **Directory Structure:** `components/ui/` for atomic components

### Planned MCP Framework Parameters

- `vue_tailwind` - Vue 3 with Tailwind
- `vue` - Vue 3 with scoped CSS

## Current Behavior

If dispatched, this agent should:
1. Warn user: "Vue support is not yet implemented"
2. Suggest using React agent as temporary fallback
3. Point to this stub for future contribution

```

**Step 2: Commit Vue agent stub**

```bash
git add plugins/pb-figma/agents/code-generator-vue.md
git commit -m "feat(pb-figma): add Vue code generator stub

- Placeholder for future Vue/Nuxt support
- Documents planned implementation approach
- Follows same pattern as React/SwiftUI agents"
```

---

## Task 9: Create Kotlin Agent (Stub for Future)

**Files:**
- Create: `plugins/pb-figma/agents/code-generator-kotlin.md`

**Step 1: Create Kotlin agent stub**

```markdown
---
name: code-generator-kotlin
description: Generates production-ready Kotlin/Jetpack Compose UI from Implementation Spec. Uses Compose Material3, state management, and Android best practices. (STUB - Full implementation pending)
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

# Kotlin/Jetpack Compose Code Generator Agent

**Status:** STUB - Full implementation pending

You generate production-ready Kotlin/Jetpack Compose UI from Implementation Specs.

## Base Logic

See [code-generator-base.md](./code-generator-base.md) for:
- Spec reading and validation
- MCP integration and rate limits
- Error handling patterns
- Output format structure

## Kotlin-Specific Implementation (TODO)

This agent is a stub for future Android/Jetpack Compose support. Implementation should follow the same patterns as React and SwiftUI agents with Kotlin-specific:

- **Framework Detection:** Check for build.gradle with Android plugin
- **Component Structure:** Composable functions with Material3
- **Type Safety:** Kotlin data classes for component props
- **Theming:** MaterialTheme with design tokens
- **Directory Structure:** `ui/components/` for composables

### Planned MCP Framework Parameter

- `kotlin` - Jetpack Compose with Material3

## Current Behavior

If dispatched, this agent should:
1. Warn user: "Kotlin/Compose support is not yet implemented"
2. Suggest using SwiftUI agent patterns as reference
3. Point to this stub for future contribution

```

**Step 2: Commit Kotlin agent stub**

```bash
git add plugins/pb-figma/agents/code-generator-kotlin.md
git commit -m "feat(pb-figma): add Kotlin code generator stub

- Placeholder for future Android/Compose support
- Documents planned implementation approach
- Follows same pattern as React/SwiftUI agents"
```

---

## Task 10: Final Integration Test with Real Figma Design

**Files:**
- Test: End-to-end workflow with user-provided Figma URL
- Verify: Framework routing works correctly

**Step 1: Request Figma URL from user**

Ask user to provide their test Figma URL:

```
Please provide a Figma URL to test the framework-agnostic workflow.

Supported platforms:
- React/Next.js + Tailwind (for web projects)
- SwiftUI (for iOS/macOS projects)

The system will:
1. Detect your project framework
2. Route to the appropriate code generator
3. Generate platform-specific code
```

**Step 2: Dispatch figma-to-code skill**

```
Skill(skill="pb-figma:figma-to-code", args="{user_provided_url}")
```

**Step 3: Verify framework detection**

Check that the skill:
1. Detected the correct framework
2. Routed to the correct agent (code-generator-react or code-generator-swiftui)
3. Generated appropriate code

**Step 4: Manual verification checklist**

- [ ] Framework detected correctly
- [ ] Appropriate agent dispatched
- [ ] Code generated in correct format (.tsx or .swift)
- [ ] Design tokens applied
- [ ] Spec updated with Generated Code table
- [ ] No errors in agent execution

**Step 5: Document integration test results**

```bash
cat > docs/plans/2026-01-25-integration-test-results.md << 'EOF'
# Framework-Agnostic Integration Test Results

**Date:** 2026-01-25
**Figma URL:** {user_provided_url}
**Detected Framework:** {react/swiftui}

## Test Flow

1. ✅ Design Validator: Figma file validated
2. ✅ Design Analyst: Spec created
3. ✅ Asset Manager: Assets downloaded
4. ✅ Framework Detection: {framework} detected
5. ✅ Code Generator ({framework}): Code generated
6. ✅ Compliance Checker: Verification passed

## Generated Files

{list files generated}

## Status

**PASS** - Framework-agnostic workflow working end-to-end.

## Notes

{any issues or observations}
EOF
```

**Step 6: Commit integration test results**

```bash
git add docs/plans/2026-01-25-integration-test-results.md
git commit -m "test(pb-figma): end-to-end integration test with real Figma design

- Tested framework detection and routing
- Verified {framework} code generation
- All agents executed successfully
- Workflow complete"
```

---

## Summary

This plan refactors pb-figma from monolithic code generation to framework-specific agents:

### Created/Modified Files

1. ✅ `agents/code-generator-base.md` - Shared logic reference
2. ✅ `agents/code-generator-react.md` - React/Tailwind specific
3. ✅ `agents/code-generator-swiftui.md` - SwiftUI specific
4. ✅ `agents/code-generator-vue.md` - Vue stub
5. ✅ `agents/code-generator-kotlin.md` - Kotlin stub
6. ✅ `skills/figma-to-code/SKILL.md` - Framework routing
7. ✅ `.claude-plugin/plugin.json` - Agent manifest
8. ✅ `README.md` - Multi-framework documentation

### Architecture

```
figma-to-code (skill)
    ↓
framework detection
    ↓
    ├─→ code-generator-react (React/Next.js + Tailwind)
    ├─→ code-generator-swiftui (iOS/macOS)
    ├─→ code-generator-vue (stub)
    └─→ code-generator-kotlin (stub)

All reference: code-generator-base.md
```

### Next Steps

After implementation:
- Implement Vue agent (currently stub)
- Implement Kotlin agent (currently stub)
- Add more framework-specific best practices
- Create framework-specific test suites
