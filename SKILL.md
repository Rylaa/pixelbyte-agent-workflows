---
name: figma-to-code
description: This skill handles pixel-perfect Figma design conversion to React/Next.js/Tailwind code using the official Figma MCP Server. It should be used when a Figma URL or design selection needs to be converted to production-ready code. The skill employs a 5-phase workflow targeting 85%+ accuracy with Code Connect support for component mapping. Use cases include (1) generating code from Figma selections, (2) design implementation with design tokens, (3) creating design system components with Code Connect, (4) pixel-perfect UI development, and (5) responsive web components. Automatic QA is performed via Playwright MCP for visual validation.
---

# Figma-to-Code Pixel-Perfect Conversion

This skill converts Figma designs to pixel-perfect React/Tailwind code using the **official Figma MCP Server** with a **5-phase workflow** and **iterative validation**.

## Prerequisites

- **Figma Desktop App** (latest version) - Required for local MCP server
- **Dev Mode** enabled in Figma (Shift+D)
- **Playwright MCP** - Required for visual validation
- **Node.js** - Runtime environment

## MCP Server Configuration

### Local Desktop Server Setup

Add to your MCP configuration:

```json
{
  "mcpServers": {
    "figma-desktop": {
      "url": "http://127.0.0.1:3845/mcp"
    }
  }
}
```

**Activation Steps:**
1. Open Figma Desktop App
2. Toggle Dev Mode (Shift+D)
3. Enable MCP Server in inspect panel
4. Verify server is running at `http://127.0.0.1:3845/mcp`

## Core Principles

1. **Never guess** — Always extract design tokens from MCP
2. **Use semantic HTML** — Prefer correct elements over `<div>` soup
3. **Apply hybrid validation** — Combine Playwright (pixel) + Claude Vision (semantic)
4. **Match exactly** — No creative interpretation, match the design precisely
5. **Leverage Code Connect** — Map Figma components to existing codebase components
6. **Require Auto Layout** — Warn if source design lacks Auto Layout

## Source Design Requirements

**Auto Layout is REQUIRED.** Designs without Auto Layout cannot be converted to proper HTML structure.

Design check:
- ✅ Auto Layout used → Proceed
- ❌ Absolute positioning → Warn user, request Auto Layout

```
WARNING: This design does not use Auto Layout. 
Request the designer to restructure with Auto Layout 
for pixel-perfect conversion.
```

## Figma MCP Server Tools

### Primary Tools

**get_design_context** — Generate code from Figma selection
```
Returns: React + Tailwind code representation
Customization: Framework, component library, styling approach
Note: Selection-based prompting (select frame in Figma first)
```

**get_variable_defs** — Extract design tokens
```
Returns: Variables and styles (colors, spacing, typography)
Use: Reference tokens directly in generated code
File Types: Figma Design only
```

**get_screenshot** — Capture visual reference
```
Returns: Screenshot of selection
Use: Visual validation baseline
File Types: Figma Design, FigJam
```

### Code Connect Tools

**get_code_connect_map** — Get component mappings
```
Returns: Object mapping Figma node IDs to code components
Format: { nodeId: { codeConnectSrc, codeConnectName } }
Purpose: Enables seamless design-to-code workflows
```

**add_code_connect_map** — Add component mapping
```
Parameters: Figma node ID + code component info
Purpose: Improves design-to-code output quality
```

### Advanced Tools

**create_design_system_rules** — Generate design system rules
```
Returns: Rule file for agent context
Save to: rules/ or instructions/ directory
```

**get_metadata** — Get sparse XML metadata
```
Returns: Layer IDs, names, types, positions, sizes
Use Case: Large designs where context size is a concern
```

### Rate Limiting

| Plan | Limit |
|------|-------|
| Starter / View / Collab | 6 tool calls per month |
| Professional / Organization / Enterprise (Dev/Full seat) | Per-minute (Tier 1 API limits) |

**Best Practices:**
1. Cache responses when possible
2. Use `get_metadata` for large designs to reduce context size
3. Batch related operations in single sessions

## 5-Phase Workflow

### Phase 1: Context Acquisition

Upon receiving a Figma selection or URL:

**Step 1: Figma MCP Data Collection (ZORUNLU - Tümü çağrılmalı)**

```
┌─────────────────────────────────────────────────────────────────┐
│  1. get_design_context                                          │
│     → React + Tailwind kod                                      │
│     → Temel stil bilgileri                                      │
│     → Image asset URL'leri (localhost:3845)                     │
│     → Node ID'ler (data-node-id)                                │
├─────────────────────────────────────────────────────────────────┤
│  2. get_variable_defs                                           │
│     → Color tokens (primary, secondary, etc.)                   │
│     → Spacing tokens (sm, md, lg, etc.)                         │
│     → Typography tokens (font-family, sizes, weights)           │
├─────────────────────────────────────────────────────────────────┤
│  3. get_code_connect_map                                        │
│     → Mevcut component mapping'leri                             │
│     → { nodeId: { codeConnectSrc, codeConnectName } }          │
├─────────────────────────────────────────────────────────────────┤
│  4. get_screenshot                                              │
│     → Görsel referans (validation için)                         │
└─────────────────────────────────────────────────────────────────┘
```

**Step 2: Codebase Analysis**

```
5. Read mevcut component dosyaları
   → get_code_connect_map'ten gelen path'leri oku
   → Mevcut component pattern'lerini analiz et

6. Analyze project environment:
   - tailwind.config.js → Existing theme/tokens
   - src/shared/components/ui/ → shadcn/ui components
   - src/features/*/components/ → Feature components
   - package.json → Libraries in use
```

**Analysis output:**
- Component structure from design context
- Complete design tokens (colors, spacing, typography)
- Existing component mappings and their source code
- Layout info from generated code
- Screenshot for validation baseline
### Phase 2: Mapping & Planning

**Before writing code, create a plan:**

1. **Check Code Connect mappings:**
   - Use `get_code_connect_map` data from Phase 1
   - Match Figma nodes to codebase components
   - If mapping exists → Use existing component
   - If no mapping → Plan new component creation

2. **Layout strategy:**
   - Analyze generated Tailwind classes
   - Plan responsive behavior adjustments

3. **Token mapping:**
   - Use `get_variable_defs` data from Phase 1
   - Missing token → Mark with TODO comment

4. **Responsive planning:**
   - Width >1024px → Assume desktop view
   - Plan mobile-first overrides

**Mapping output:**
```json
{
  "codeConnectComponents": ["Button", "Input"],
  "newComponents": ["HeroCard"],
  "tokenMappings": {
    "colors/primary": "bg-primary",
    "spacing/lg": "p-6"
  },
  "layoutStrategy": "flex-col md:flex-row"
}
```

### Phase 3: Code Generation

**Start with `get_design_context` output, then refine:**

1. **Typography refinement** (if needed):
   ```
   font-size:      Figma px ÷ 16 = rem
   line-height:    Figma % ÷ 100 = value
   letter-spacing: Figma tracking ÷ 1000 = em
   ```

2. **Layout verification** (Auto Layout → Flexbox):

   | Figma | Tailwind |
   |-------|----------|
   | Direction: Horizontal | `flex-row` |
   | Direction: Vertical | `flex-col` |
   | Gap: 16px | `gap-4` |
   | Primary: Space Between | `justify-between` |
   | Counter: Center | `items-center` |
   | Fill Container | `flex-1` |
   | Hug Contents | `w-fit` |

3. **Design token integration:**
   - Use values from `get_variable_defs`
   - Map to CSS variables or Tailwind theme

4. **Semantic HTML enforcement:**
   - Clickable → `<button>` or `<a>`
   - List → `<ul>/<ol>` + `<li>`
   - Navigation → `<nav>`
   - Form → `<form>` + `<input>/<select>`
   - Heading → `<h1>`-`<h6>` (hierarchical)

5. **Responsive breakpoints:**
   - Mobile-first approach: base → `sm:` → `md:` → `lg:`
   - Single size in design: Add reasonable responsive behavior

### Phase 4: Visual Validation (ZORUNLU - ASLA ATLAMA)

**Hybrid approach: Playwright (pixel comparison) + Claude Vision (semantic analysis)**

⛔ **NEVER SKIP VALIDATION - KRİTİK KURALLAR:**
- Phase 4 ZORUNLUDUR - ASLA atlanmaz
- Phase 5'e geçmeden ÖNCE Phase 4 tamamlanmalıdır
- Playwright MCP kullanılamıyorsa → Kullanıcıya bildir, manuel validation iste
- Bu phase atlandıysa → Phase 5'te "❌ Validation atlandı" notu düşülmeli
- Mental/checklist validation YETERSİZDİR - Playwright screenshot ZORUNLU

**PREREQUISITES CHECK (Phase 4 öncesi):**
```
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 4 BAŞLAMADAN ÖNCE KONTROL ET:                           │
├─────────────────────────────────────────────────────────────────┤
│  □ Phase 1'de get_screenshot çağrıldı mı?                      │
│    → HAYIR ise: get_screenshot çağır, reference.png al         │
│                                                                  │
│  □ Playwright MCP konfigüre mi?                                 │
│    → Test: browser_navigate({ url: "about:blank" })            │
│    → HAYIR ise: Kullanıcıya "Playwright MCP gerekli" bildir    │
│                                                                  │
│  □ Dev server çalışıyor mu?                                     │
│    → Test: browser_navigate({ url: "http://localhost:3000" })  │
│    → HAYIR ise: "npm run dev çalıştırın" uyarısı ver           │
│                                                                  │
│  □ Preview route var mı?                                        │
│    → Kontrol: /test-preview sayfası mevcut mu?                 │
│    → HAYIR ise: preview-setup.md'ye yönlendir                  │
│                                                                  │
│  ❌ Herhangi biri HAYIR → Kullanıcıyı bilgilendir, bekle       │
│  ✅ Hepsi EVET → Aşağıdaki adımlara devam et                   │
└─────────────────────────────────────────────────────────────────┘
```

**ZORUNLU ADIMLAR:**

```
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: Dev Server Kontrolü                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ browser_navigate({ url: "http://localhost:3000" })        │  │
│  │                                                            │  │
│  │ ❌ Yüklenmezse → "npm run dev çalıştırın" uyarısı         │  │
│  │ ✅ Yüklendiyse → Devam                                     │  │
│  └───────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│  STEP 2: Rendered Screenshot Al                                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ browser_navigate({                                         │  │
│  │   url: "http://localhost:3000/[component-path]"           │  │
│  │ })                                                         │  │
│  │                                                            │  │
│  │ browser_take_screenshot({                                  │  │
│  │   filename: "rendered.png"                                 │  │
│  │ })                                                         │  │
│  └───────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│  STEP 3: Görsel Karşılaştırma (Claude Vision)                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ İki görseli yan yana koy:                                  │  │
│  │ - reference.png (Figma'dan - Phase 1'de alındı)           │  │
│  │ - rendered.png (Playwright'tan - az önce alındı)          │  │
│  │                                                            │  │
│  │ Claude Vision analizi:                                     │  │
│  │ "Bu iki görsel arasındaki farklar neler?"                 │  │
│  │ "Hangi CSS değerleri düzeltilmeli?"                       │  │
│  └───────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│  STEP 4: Karar                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ Fark yok veya minimal → ✅ Phase 5'e geç                  │  │
│  │ Fark var → Düzelt → Step 2'ye dön (max 3 iterasyon)       │  │
│  │ 3 iterasyon sonra hala fark → Phase 5 + "manuel kontrol"  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Playwright MCP Araçları:**

| Araç | Kullanım |
|------|----------|
| `browser_navigate` | URL'ye git |
| `browser_take_screenshot` | Screenshot al |
| `browser_snapshot` | Accessibility snapshot (opsiyonel) |
| `browser_evaluate` | JavaScript çalıştır |

**Detailed instructions:** See `references/visual-validation-loop.md`

### Phase 5: Handoff

⚠️ **VALIDATION GATE - BU KONTROLÜ ASLA ATLAMA:**
```
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 5'E GEÇMEDEN ÖNCE:                                       │
├─────────────────────────────────────────────────────────────────┤
│  Phase 4 tamamlandı mı?                                         │
│  ├── ✅ EVET → Devam et                                         │
│  └── ❌ HAYIR → DUR! Phase 4'e dön, ASLA Phase 5'e geçme       │
│                                                                  │
│  Validation sonucu ne?                                          │
│  ├── ✅ %98+ match → "Accuracy: X%" yaz, devam                  │
│  ├── ⚠️ %85-97 match → "Manual check required" notu ekle        │
│  └── ❌ <%85 match → Kullanıcıya bildir, onay al                │
│                                                                  │
│  Phase 4 atlandıysa handoff'a şu notu ekle:                     │
│  "❌ Validation atlandı - Manuel kontrol gerekli"               │
└─────────────────────────────────────────────────────────────────┘
```

**Final output format:**

```markdown
## ✅ Conversion Complete

**Component:** HeroCard.tsx
**Accuracy:** 98.5% pixel match
**Iterations:** 2

### Code Connect Components Used:
- Button (mapped via Code Connect)
- Badge (mapped via Code Connect)

### New Components Created:
- HeroCard.tsx

### Design Tokens Applied:
- colors/primary → var(--color-primary)
- spacing/lg → var(--spacing-lg)

### Assumptions Made:
- Font family assumed 'Inter'
- Hover state not in design, added standard opacity

### Manual Check Required:
- [ ] Icon asset not found, placeholder used
- [ ] `colors/accent` token unmatched → `// TODO: Check color`

### Files:
- src/components/HeroCard.tsx (new)
- src/components/HeroCard.stories.tsx (optional)
```

## Output Format

**React/TypeScript component template:**

```tsx
import React from 'react';

interface ComponentNameProps {
  // Props from Figma variants
}

export const ComponentName: React.FC<ComponentNameProps> = ({ ...props }) => {
  return (
    <div className="[Tailwind classes from design context]">
      {/* Semantic HTML structure */}
    </div>
  );
};
```

**Requirements:**
- TypeScript with typed props
- Tailwind CSS (use design tokens when available)
- Semantic HTML elements
- Accessibility: `aria-*`, `role`, `alt` attributes

## WCAG 2.1 AA Accessibility

| Criterion | Requirement | Tailwind Example |
|-----------|-------------|------------------|
| Color contrast | 4.5:1 (normal), 3:1 (large) | `text-gray-900` on `bg-white` |
| Focus indicator | Visible focus ring | `focus:ring-2 focus:ring-blue-500` |
| Touch target | Min 44x44px | `min-h-[44px] min-w-[44px]` |
| Alt text | All meaningful images | `<img alt="Description">` |
| Keyboard nav | Tab accessible | `tabindex="0"` (if needed) |

## Common Issues

Quick reference for common problems:

| Issue | Symptom | Solution |
|-------|---------|----------|
| Content overflow | Text overflows on mobile | Never use `w-[Xpx]` for text elements, use `w-full` or `max-w-` |
| Icon alignment | Vertical shift | Default to `flex items-center` |
| Color mismatch | Brand color different | Check `get_variable_defs` output, use design tokens |
| Complex DOM | Unnecessary div layers | Apply flattening algorithm |
| Font weight | Font appears thin/bold | Verify against design tokens |
| Responsive break | Layout breaks on mobile | Write mobile-first, use `md:` for desktop override |

**Detailed solutions:** See `references/common-issues.md`

## DOM Flattening Rules

Skip unnecessary layers:
```
❌ SKIP:
- Frames used only for grouping (no bg/border/padding)
- Wrapper containers with single child
- Groups with no visual effect
- Default-named empty wrappers ("Frame 1", "Group 2")

✅ CONVERT TO DIV:
- Has background color
- Has border or shadow
- Has padding/margin
- Has border-radius
```

## TODO Comment Strategy

For missing or ambiguous values:
```tsx
// TODO: Check color - Design token 'colors/accent' not in theme
const accentColor = "text-blue-500"; // Temporary value

// TODO: Check font - 'Custom Font' not installed
const fontFamily = "font-sans"; // Fallback

// TODO: Check icon - Asset not found
<PlaceholderIcon className="w-6 h-6" />
```

## References

### Core References
- **Figma MCP Server details**: `references/figma-mcp-server.md`
- **Token conversion formulas**: `references/token-mapping.md`
- **Validation guide**: `references/validation-guide.md`
- **Visual validation loop**: `references/visual-validation-loop.md`
- **Common issues**: `references/common-issues.md`
- **Preview route setup**: `references/preview-setup.md`

### Enterprise References
- **CI/CD integration**: `references/ci-cd-integration.md`
- **Storybook setup**: `references/storybook-integration.md`
- **Test strategy**: `references/testing-strategy.md`

### Prompt Templates
Phase-specific prompts located in `references/prompts/`:
- `analyze-design.md` — Phase 1 analysis
- `mapping-planning.md` — Phase 2 planning
- `generate-component.md` — Phase 3 generation
- `validate-refine.md` — Phase 4 validation
- `handoff.md` — Phase 5 handoff

### Templates
- **React component template**: `assets/templates/component.tsx.hbs`

## Critical Rules

- Always use `get_design_context` as starting point for code generation
- Check `get_code_connect_map` before creating new components
- Extract design tokens with `get_variable_defs`
- Use `get_screenshot` for validation baseline
- Run visual validation, check differences
- Clearly document TODO comments
