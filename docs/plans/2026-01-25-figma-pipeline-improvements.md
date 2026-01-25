# Figma Pipeline Improvements Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Improve the pb-figma Figma-to-code pipeline by fixing inconsistencies, adding test generation, and enhancing validation workflows.

**Architecture:** Incremental improvements to existing agent pipeline. Updates to reference docs, SKILL.md phases, and adding new documentation for missing workflows.

**Tech Stack:** Claude Code Agents, Pixelbyte Figma MCP, Claude in Chrome MCP, Vitest/Jest, Playwright

---

## Priority Summary

| Priority | Task | Description |
|----------|------|-------------|
| P1 | Task 1-2 | QA Report Template → Claude Vision alignment |
| P1 | Task 3-4 | Test generation in Phase 5 Handoff |
| P2 | Task 5-6 | Code Connect workflow guide |
| P2 | Task 7-8 | Responsive validation checklist |
| P2 | Task 9-10 | Accessibility automation in Phase 4 |
| P2 | Task 11-12 | Error recovery patterns |

---

## Task 1: Backup Current QA Report Template

**Files:**
- Read: `plugins/pb-figma/skills/figma-to-code/references/qa-report-template.md`
- Create: `plugins/pb-figma/skills/figma-to-code/references/archive/qa-report-template-rmse.md`

**Step 1: Create archive directory**

```bash
mkdir -p plugins/pb-figma/skills/figma-to-code/references/archive
```

**Step 2: Copy current template to archive**

```bash
cp plugins/pb-figma/skills/figma-to-code/references/qa-report-template.md \
   plugins/pb-figma/skills/figma-to-code/references/archive/qa-report-template-rmse.md
```

**Step 3: Verify backup exists**

```bash
ls -la plugins/pb-figma/skills/figma-to-code/references/archive/
```

Expected: `qa-report-template-rmse.md` file exists

**Step 4: Commit**

```bash
git add plugins/pb-figma/skills/figma-to-code/references/archive/
git commit -m "chore(pb-figma): archive RMSE-based QA report template

- Preserve original template before Claude Vision migration
- Archive directory for deprecated reference docs"
```

---

## Task 2: Update QA Report Template to Claude Vision Approach

**Files:**
- Modify: `plugins/pb-figma/skills/figma-to-code/references/qa-report-template.md`

**Step 1: Read current visual-validation-loop.md for reference**

Ensure alignment with Claude Vision workflow documented in `visual-validation-loop.md`.

**Step 2: Replace qa-report-template.md content**

```markdown
# QA Report Template (Claude Vision)

Bu şablon, Phase 4 Visual Validation sonrasında `.qa/report.md` dosyası için kullanılır.

---

## Şablon: .qa/report.md

```markdown
# QA Validation Report

**Component:** [ComponentName]
**Date:** [YYYY-MM-DD HH:MM:SS]
**Iterations:** [N]
**Status:** ✅ PASS / ⚠️ ACCEPTABLE / ❌ MANUAL REVIEW

---

## Summary

| Metric | Value |
|--------|-------|
| Initial Differences | [count] |
| Final Differences | [count] |
| Iterations | [N] |
| Max Iterations | 3 |
| Validation Method | Claude Vision |

---

## Screenshots

| Type | Path | Description |
|------|------|-------------|
| Figma Reference | `.qa/figma-reference.png` | Original Figma design |
| Implementation | `.qa/implementation-final.png` | Final browser screenshot |
| Iteration 1 | `.qa/iteration-1.png` | First implementation |
| Iteration 2 | `.qa/iteration-2.png` | After first fixes |
| Iteration 3 | `.qa/iteration-3.png` | After second fixes |

---

## Claude Vision Analysis

### Iteration 1

**Differences Found:**

| Category | Element | Figma | Implementation | Tailwind Fix |
|----------|---------|-------|----------------|--------------|
| Typography | Title | 32px bold | 28px medium | `text-3xl font-bold` |
| Spacing | Card padding | 24px | 16px | `p-6` |
| Colors | Button | #FE4601 | #3B82F6 | `bg-orange-500` |

**TodoWrite Items Created:**
1. Title font-size: text-2xl → text-3xl
2. Card padding: p-4 → p-6
3. Button background: bg-blue-500 → bg-orange-500

### Iteration 2

**Remaining Differences:**

| Category | Element | Figma | Implementation | Tailwind Fix |
|----------|---------|-------|----------------|--------------|
| Spacing | Gap | 12px | 8px | `gap-3` |

**TodoWrite Items Created:**
1. Button gap: gap-2 → gap-3

### Iteration 3

**Status:** ✅ No significant differences found

---

## Tolerance Criteria

| Difference Type | Tolerance | Status |
|-----------------|-----------|--------|
| Typography (font-size) | ±2px | ✅ |
| Spacing (padding/gap) | ±4px | ✅ |
| Colors (hex) | Exact match | ✅ |
| Border radius | ±2px | ✅ |
| Layout (flex/grid) | Must match | ✅ |

**Final Decision:** [PASS / ACCEPTABLE / MANUAL REVIEW]

---

## Check Categories Used

- [ ] Typography (font family, size, weight, line-height, color)
- [ ] Spacing (padding, margin, gap)
- [ ] Colors (background, border, text, shadow)
- [ ] Layout (flex direction, alignment, justify, width, height)
- [ ] Assets (icon size/color, image aspect ratio, border-radius)

---

## Files Generated

| File | Description |
|------|-------------|
| `.qa/figma-reference.png` | Figma screenshot via MCP |
| `.qa/implementation-final.png` | Final browser screenshot |
| `.qa/iteration-*.png` | Each iteration screenshot |
| `.qa/report.md` | This report |

---

## MCP Tools Used

### Figma Screenshot
```javascript
mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_get_screenshot({
  params: {
    file_key: "FILE_KEY",
    node_ids: ["NODE_ID"],
    format: "png",
    scale: 2
  }
})
```

### Browser Screenshot
```javascript
mcp__claude-in-chrome__computer({
  action: "screenshot",
  tabId: TAB_ID
})
```

---

## Stuck Detection (If Applicable)

> ⚠️ Only include this section if 3 iterations completed without achieving PASS

### Stuck Report

**Triggered After:** Iteration 3
**Remaining Differences:** [count]

### Possible Causes

- [ ] **Font Mismatch:** Custom font not installed locally
- [ ] **Missing Assets:** Icons not exported from Figma
- [ ] **Viewport Size:** Browser viewport ≠ Figma frame size
- [ ] **Subpixel Rendering:** Anti-aliasing differences
- [ ] **CSS Specificity:** Styles being overridden

### Recommended Actions

1. Check custom fonts: `fc-list | grep FontName`
2. Verify viewport size matches Figma frame
3. Check for CSS specificity issues in DevTools
4. Consider `-webkit-font-smoothing: antialiased`

---

## Handoff Checklist

Before proceeding to Phase 5:

- [ ] All iteration screenshots saved
- [ ] Claude Vision analysis documented
- [ ] Differences resolved or documented
- [ ] Report complete
- [ ] Code changes committed (if applicable)

---

*Generated by Figma-to-Code Skill - Phase 4 Visual Validation*
*Validation Method: Claude Vision (not RMSE)*
```

---

## Örnek Doldurulmuş Rapor

```markdown
# QA Validation Report

**Component:** HeroCard
**Date:** 2026-01-25 14:32:15
**Iterations:** 2
**Status:** ✅ PASS

---

## Summary

| Metric | Value |
|--------|-------|
| Initial Differences | 4 |
| Final Differences | 0 |
| Iterations | 2 |
| Max Iterations | 3 |
| Validation Method | Claude Vision |

---

## Claude Vision Analysis

### Iteration 1

**Differences Found:**

| Category | Element | Figma | Implementation | Tailwind Fix |
|----------|---------|-------|----------------|--------------|
| Typography | Title | 32px bold | 28px medium | `text-3xl font-bold` |
| Typography | Description | gray-500 | gray-400 | `text-gray-500` |
| Spacing | Card padding | 24px | 16px | `p-6` |
| Spacing | Button gap | 12px | 8px | `gap-3` |

### Iteration 2

**Status:** ✅ No differences found

All issues resolved.

---

## Handoff Checklist

- [x] All iteration screenshots saved
- [x] Claude Vision analysis documented
- [x] Differences resolved
- [x] Report complete
- [x] Code changes committed

---

*Generated by Figma-to-Code Skill - Phase 4 Visual Validation*
```

---

## Kullanım

Phase 4 tamamlandığında bu şablonu kullanarak `.qa/report.md` dosyasını oluştur:

1. Şablonu kopyala
2. `[placeholder]` değerlerini gerçek değerlerle değiştir
3. Her iteration için Claude Vision analizi ekle
4. Kullanılmayan bölümleri kaldır (örn: stuck detection yoksa o bölümü sil)
5. `.qa/report.md` olarak kaydet
```

**Step 3: Verify file updated**

```bash
head -30 plugins/pb-figma/skills/figma-to-code/references/qa-report-template.md
```

Expected: "# QA Report Template (Claude Vision)" header visible

**Step 4: Commit**

```bash
git add plugins/pb-figma/skills/figma-to-code/references/qa-report-template.md
git commit -m "refactor(pb-figma): migrate QA report to Claude Vision approach

- Remove RMSE/ImageMagick methodology
- Align with visual-validation-loop.md workflow
- Add Claude Vision analysis sections
- Update MCP tool examples
- Simplify tolerance criteria"
```

---

## Task 3: Create Test Generation Reference Document

**Files:**
- Create: `plugins/pb-figma/skills/figma-to-code/references/test-generation.md`

**Step 1: Create test generation reference**

```markdown
# Test Generation Reference

Bu döküman, Phase 5 Handoff'ta otomatik test üretimi için kullanılır.

---

## Test Generation Workflow

```
Component Code → Analyze Props/Variants → Generate Tests
                                              │
                    ┌─────────────────────────┼─────────────────────────┐
                    │                         │                         │
                    ▼                         ▼                         ▼
              Unit Tests              Integration Tests          Visual Tests
           (Vitest/Jest)           (Testing Library)            (Playwright)
```

---

## Phase 5 Test Generation Checklist

Her component için aşağıdaki testleri oluştur:

- [ ] Unit test dosyası (`*.test.tsx`)
- [ ] Accessibility test (`jest-axe`)
- [ ] Snapshot test (optional)
- [ ] Visual test dosyası (`*.visual.spec.ts`) - if Playwright available

---

## Unit Test Template

**Dosya:** `{ComponentName}.test.tsx`

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { axe, toHaveNoViolations } from 'jest-axe';
import { {ComponentName} } from './{ComponentName}';

expect.extend(toHaveNoViolations);

describe('{ComponentName}', () => {
  // ==========================================
  // RENDERING TESTS
  // ==========================================

  describe('Rendering', () => {
    it('renders without crashing', () => {
      render(<{ComponentName} />);
      expect(screen.getByTestId('{component-name}')).toBeInTheDocument();
    });

    it('renders with default props', () => {
      render(<{ComponentName} />);
      // Check default values rendered
    });

    it('renders children correctly', () => {
      render(
        <{ComponentName}>
          <span data-testid="child">Child content</span>
        </{ComponentName}>
      );
      expect(screen.getByTestId('child')).toBeInTheDocument();
    });
  });

  // ==========================================
  // PROPS TESTS
  // ==========================================

  describe('Props', () => {
    // Generate for each variant prop
    describe('variant prop', () => {
      it('renders primary variant correctly', () => {
        render(<{ComponentName} variant="primary" />);
        expect(screen.getByTestId('{component-name}')).toHaveClass('bg-primary');
      });

      it('renders secondary variant correctly', () => {
        render(<{ComponentName} variant="secondary" />);
        expect(screen.getByTestId('{component-name}')).toHaveClass('bg-secondary');
      });
    });

    it('applies custom className', () => {
      render(<{ComponentName} className="custom-class" />);
      expect(screen.getByTestId('{component-name}')).toHaveClass('custom-class');
    });
  });

  // ==========================================
  // INTERACTION TESTS
  // ==========================================

  describe('Interactions', () => {
    it('calls onClick when clicked', async () => {
      const handleClick = vi.fn();
      render(<{ComponentName} onClick={handleClick} />);

      await userEvent.click(screen.getByTestId('{component-name}'));
      expect(handleClick).toHaveBeenCalledTimes(1);
    });

    it('is keyboard accessible', async () => {
      render(<{ComponentName} />);
      const element = screen.getByTestId('{component-name}');

      await userEvent.tab();
      expect(element).toHaveFocus();
    });
  });

  // ==========================================
  // ACCESSIBILITY TESTS
  // ==========================================

  describe('Accessibility', () => {
    it('has no accessibility violations', async () => {
      const { container } = render(<{ComponentName} />);
      const results = await axe(container);
      expect(results).toHaveNoViolations();
    });
  });

  // ==========================================
  // SNAPSHOT TESTS
  // ==========================================

  describe('Snapshots', () => {
    it('matches snapshot', () => {
      const { container } = render(<{ComponentName} />);
      expect(container.firstChild).toMatchSnapshot();
    });
  });
});
```

---

## Visual Test Template (Playwright)

**Dosya:** `{ComponentName}.visual.spec.ts`

```typescript
import { test, expect } from '@playwright/test';

test.describe('{ComponentName} Visual Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/preview?component={ComponentName}');
    await page.waitForSelector('[data-testid="{component-name}"]');
  });

  test('matches Figma design', async ({ page }) => {
    const component = page.locator('[data-testid="{component-name}"]');

    await expect(component).toHaveScreenshot('{component-name}-default.png', {
      maxDiffPixels: 100,
      threshold: 0.2,
    });
  });

  test('matches at mobile viewport', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    const component = page.locator('[data-testid="{component-name}"]');

    await expect(component).toHaveScreenshot('{component-name}-mobile.png', {
      maxDiffPixels: 100,
    });
  });

  test('hover state matches design', async ({ page }) => {
    const component = page.locator('[data-testid="{component-name}"]');
    await component.hover();

    await expect(component).toHaveScreenshot('{component-name}-hover.png', {
      maxDiffPixels: 50,
    });
  });
});
```

---

## Test Generation Rules

### 1. Analyze Component Props

Component'ın prop'larını analiz et:

```typescript
interface ComponentProps {
  variant?: 'primary' | 'secondary';  // → Generate variant tests
  size?: 'sm' | 'md' | 'lg';          // → Generate size tests
  disabled?: boolean;                  // → Generate disabled state test
  onClick?: () => void;                // → Generate click handler test
  children?: React.ReactNode;          // → Generate children rendering test
}
```

### 2. Generate Tests Based on Props

| Prop Type | Test Type |
|-----------|-----------|
| Union type (variant) | Test each variant |
| Boolean (disabled) | Test true/false states |
| Function (onClick) | Test handler called |
| Children | Test children rendered |
| className | Test className applied |

### 3. Required Tests

Her component için **zorunlu** testler:

1. ✅ Renders without crashing
2. ✅ Has no accessibility violations (jest-axe)
3. ✅ Applies custom className
4. ✅ Renders children (if accepts children)

### 4. Optional Tests

İhtiyaca göre eklenecek testler:

- 🔲 Snapshot test
- 🔲 Visual regression test (Playwright)
- 🔲 Responsive behavior test
- 🔲 Animation test

---

## Integration with Phase 5

Phase 5 Handoff'ta test generation:

```
1. Read generated component file
2. Extract props interface
3. Analyze variants, handlers, states
4. Generate unit test file
5. Generate visual test file (if Playwright)
6. Run tests to verify
7. Add to handoff checklist
```

---

## Test File Naming

| Component | Unit Test | Visual Test |
|-----------|-----------|-------------|
| `Button.tsx` | `Button.test.tsx` | `Button.visual.spec.ts` |
| `HeroCard.tsx` | `HeroCard.test.tsx` | `HeroCard.visual.spec.ts` |
| `Navigation.tsx` | `Navigation.test.tsx` | `Navigation.visual.spec.ts` |

---

## Running Tests

```bash
# Run unit tests
npm run test

# Run unit tests with coverage
npm run test:coverage

# Run visual tests
npm run test:visual

# Update visual snapshots
npm run test:visual -- --update-snapshots
```

---

## Coverage Requirements

| Metric | Minimum |
|--------|---------|
| Statements | 80% |
| Branches | 80% |
| Functions | 80% |
| Lines | 80% |
```

**Step 2: Verify file created**

```bash
head -20 plugins/pb-figma/skills/figma-to-code/references/test-generation.md
```

Expected: "# Test Generation Reference" header

**Step 3: Commit**

```bash
git add plugins/pb-figma/skills/figma-to-code/references/test-generation.md
git commit -m "feat(pb-figma): add test generation reference

- Unit test template with Testing Library
- Visual test template with Playwright
- Props analysis for test generation
- Integration guidelines for Phase 5"
```

---

## Task 4: Update SKILL.md Phase 5 with Test Generation

**Files:**
- Modify: `plugins/pb-figma/skills/figma-to-code/SKILL.md`

**Step 1: Read current SKILL.md to find Phase 5 section**

```bash
grep -n "Phase 5" plugins/pb-figma/skills/figma-to-code/SKILL.md
```

**Step 2: Add test generation to Phase 5**

Find the Phase 5 section and add after existing handoff steps:

```markdown
### 5.3 Test Generation

Generate tests for each component created in Phase 3:

**Reference:** `references/test-generation.md`

**Steps:**

1. **Analyze Component**
   - Read component file
   - Extract props interface
   - Identify variants, handlers, states

2. **Generate Unit Test**
   - Create `{ComponentName}.test.tsx`
   - Include rendering tests
   - Include props/variant tests
   - Include accessibility test (jest-axe)
   - Include interaction tests

3. **Generate Visual Test (Optional)**
   - Create `{ComponentName}.visual.spec.ts`
   - Include default state screenshot
   - Include mobile viewport screenshot
   - Include hover state screenshot

4. **Run Tests**
   ```bash
   npm run test -- {ComponentName}
   ```

5. **Add to Handoff Checklist**
   - [ ] Unit tests passing
   - [ ] Accessibility tests passing
   - [ ] Visual tests passing (if applicable)
   - [ ] Coverage meets minimum (80%)
```

**Step 3: Update Phase 5 checklist**

Find existing handoff checklist and add test items:

```markdown
## Phase 5 Handoff Checklist

- [ ] All components generated
- [ ] Design tokens applied
- [ ] Assets downloaded and imported
- [ ] Compliance check passed
- [ ] **Unit tests generated and passing**
- [ ] **Accessibility tests passing**
- [ ] **Visual tests passing (if Playwright available)**
- [ ] Code committed
- [ ] Documentation updated
```

**Step 4: Commit**

```bash
git add plugins/pb-figma/skills/figma-to-code/SKILL.md
git commit -m "feat(pb-figma): add test generation to Phase 5 Handoff

- Add 5.3 Test Generation section
- Include unit test, visual test, a11y test steps
- Update handoff checklist with test items
- Reference test-generation.md"
```

---

## Task 5: Create Code Connect Workflow Guide

**Files:**
- Create: `plugins/pb-figma/skills/figma-to-code/references/code-connect-guide.md`

**Step 1: Create code connect guide**

```markdown
# Code Connect Workflow Guide

Bu döküman, mevcut codebase component'larını Figma component'larına map'leme sürecini açıklar.

---

## Code Connect Nedir?

Code Connect, Figma component'ları ile codebase'deki gerçek component implementasyonları arasında bağlantı kurar.

**Faydaları:**
- Figma'dan kod üretirken mevcut component'ları kullan
- Component prop'larını Figma variant'larına map'le
- Duplicate kod üretimini önle
- Design-code sync'i sağla

---

## MCP Tools

### figma_get_code_connect_map

Mevcut mapping'leri al:

```javascript
mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_get_code_connect_map({
  params: {
    file_key: "ABC123xyz"
  }
})
```

### figma_add_code_connect_map

Yeni mapping ekle:

```javascript
mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_add_code_connect_map({
  params: {
    file_key: "ABC123xyz",
    node_id: "123:456",
    component_path: "src/components/Button.tsx",
    component_name: "Button",
    props_mapping: {
      "Variant": "variant",
      "Size": "size"
    },
    variants: {
      "primary": { "variant": "primary" },
      "secondary": { "variant": "secondary" }
    },
    example: "<Button variant='primary' size='md'>Click me</Button>"
  }
})
```

### figma_remove_code_connect_map

Mapping kaldır:

```javascript
mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_remove_code_connect_map({
  params: {
    file_key: "ABC123xyz",
    node_id: "123:456"
  }
})
```

---

## Workflow

### Phase 1: Component Inventory

Mevcut codebase'deki component'ları listele:

```bash
# React/Next.js
find src/components -name "*.tsx" -type f | head -20

# Vue
find src/components -name "*.vue" -type f | head -20
```

### Phase 2: Figma Component Analysis

Figma dosyasındaki component'ları al:

```javascript
mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_get_file_structure({
  params: {
    file_key: "ABC123xyz",
    depth: 5
  }
})
```

Component'ları filtrele:
- Type: COMPONENT veya COMPONENT_SET
- Name patterns: Button, Card, Input, etc.

### Phase 3: Matching

Figma ve codebase component'larını eşleştir:

| Figma Component | Codebase Component | Match Score |
|-----------------|-------------------|-------------|
| Button | src/components/ui/button.tsx | ✅ Exact |
| Card | src/components/ui/card.tsx | ✅ Exact |
| HeroSection | - | ❌ Not found |
| NavItem | src/components/Navigation/NavItem.tsx | ⚠️ Partial |

### Phase 4: Props Mapping

Her eşleşen component için props mapping oluştur:

**Figma Variants:**
```
Button
├── Variant: Primary, Secondary, Ghost
├── Size: Small, Medium, Large
└── State: Default, Hover, Disabled
```

**Codebase Props:**
```typescript
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
}
```

**Mapping:**
```json
{
  "props_mapping": {
    "Variant": "variant",
    "Size": "size"
  },
  "variants": {
    "Primary": { "variant": "primary" },
    "Secondary": { "variant": "secondary" },
    "Ghost": { "variant": "ghost" },
    "Small": { "size": "sm" },
    "Medium": { "size": "md" },
    "Large": { "size": "lg" }
  }
}
```

### Phase 5: Register Mappings

Her eşleşme için Code Connect mapping kaydet:

```javascript
// Button mapping
mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_add_code_connect_map({
  params: {
    file_key: "ABC123xyz",
    node_id: "123:456",  // Button component node ID
    component_path: "src/components/ui/button.tsx",
    component_name: "Button",
    props_mapping: {
      "Variant": "variant",
      "Size": "size"
    },
    variants: {
      "Primary": { "variant": "primary" },
      "Secondary": { "variant": "secondary" }
    },
    example: "<Button variant='primary' size='md'>Click</Button>"
  }
})
```

---

## Code Generation with Code Connect

Phase 3 Code Generation'da Code Connect kullanımı:

```
1. figma_get_code_connect_map ile mevcut mapping'leri al
2. Her Figma node için mapping var mı kontrol et
3. Mapping varsa → Mevcut component'ı import et
4. Mapping yoksa → Yeni component üret
```

**Örnek:**

```typescript
// Mapping var → Import existing
import { Button } from '@/components/ui/button';

// Mapping yok → Generate new
export function HeroSection({ title, subtitle }: HeroSectionProps) {
  return (
    <section className="...">
      <h1>{title}</h1>
      <p>{subtitle}</p>
      {/* Button has mapping, use existing */}
      <Button variant="primary" size="lg">
        Get Started
      </Button>
    </section>
  );
}
```

---

## Best Practices

1. **Map atomic components first** - Button, Input, Icon, Badge
2. **Use consistent naming** - Figma ve codebase'de aynı isimler
3. **Document unmapped components** - Yeni üretilecek component'ları listele
4. **Update mappings regularly** - Design system değişikliklerinde güncelle
5. **Validate mappings** - Mapping'lerin doğru çalıştığını test et

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Mapping not applied | Check node_id format (use `:` not `-`) |
| Props not matching | Verify props_mapping keys match Figma variant names exactly |
| Component not found | Check component_path is correct |
| Variants not working | Ensure variants object has correct structure |
```

**Step 2: Commit**

```bash
git add plugins/pb-figma/skills/figma-to-code/references/code-connect-guide.md
git commit -m "feat(pb-figma): add Code Connect workflow guide

- Document Code Connect MCP tools
- 5-phase workflow: inventory, analysis, matching, mapping, register
- Props mapping examples
- Integration with code generation
- Best practices and troubleshooting"
```

---

## Task 6: Update SKILL.md with Code Connect Integration

**Files:**
- Modify: `plugins/pb-figma/skills/figma-to-code/SKILL.md`

**Step 1: Add Code Connect section to Phase 1**

Find Phase 1 (Context Acquisition) and add:

```markdown
### 1.4 Code Connect Check

Before generating new components, check for existing mappings:

**Reference:** `references/code-connect-guide.md`

```javascript
mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_get_code_connect_map({
  params: { file_key: "FILE_KEY" }
})
```

**If mappings exist:**
- Document mapped components
- Note which Figma nodes use existing code
- Flag unmapped nodes for generation

**If no mappings:**
- Proceed with full generation
- Offer to create mappings after generation
```

**Step 2: Commit**

```bash
git add plugins/pb-figma/skills/figma-to-code/SKILL.md
git commit -m "feat(pb-figma): integrate Code Connect into Phase 1

- Add 1.4 Code Connect Check section
- Check for existing component mappings
- Document mapped vs unmapped components"
```

---

## Task 7: Create Responsive Validation Checklist

**Files:**
- Create: `plugins/pb-figma/skills/figma-to-code/references/responsive-validation.md`

**Step 1: Create responsive validation reference**

```markdown
# Responsive Validation Checklist

Bu döküman, Phase 4 Visual Validation'da responsive davranışı doğrulamak için kullanılır.

---

## Viewport Breakpoints

| Breakpoint | Width | Device |
|------------|-------|--------|
| Mobile S | 320px | iPhone SE |
| Mobile M | 375px | iPhone 12/13 |
| Mobile L | 425px | Large phones |
| Tablet | 768px | iPad Mini |
| Laptop | 1024px | Small laptops |
| Desktop | 1440px | Standard desktop |
| 4K | 2560px | Large monitors |

---

## Validation Workflow

```
Desktop (1440px) → Tablet (768px) → Mobile (375px)
      │                  │                │
      ▼                  ▼                ▼
  Screenshot        Screenshot        Screenshot
      │                  │                │
      ▼                  ▼                ▼
  Compare          Compare          Compare
```

---

## Claude in Chrome MCP Commands

### Resize Viewport

```javascript
// Desktop
mcp__claude-in-chrome__resize_window({
  width: 1440,
  height: 900,
  tabId: TAB_ID
})

// Tablet
mcp__claude-in-chrome__resize_window({
  width: 768,
  height: 1024,
  tabId: TAB_ID
})

// Mobile
mcp__claude-in-chrome__resize_window({
  width: 375,
  height: 812,
  tabId: TAB_ID
})
```

### Take Screenshot

```javascript
mcp__claude-in-chrome__computer({
  action: "screenshot",
  tabId: TAB_ID
})
```

---

## Responsive Check Categories

### Layout Changes

| Breakpoint | Expected Behavior |
|------------|-------------------|
| Desktop | Full layout, sidebar visible |
| Tablet | Adjusted grid, sidebar collapsed |
| Mobile | Single column, hamburger menu |

### Typography Scaling

| Element | Desktop | Tablet | Mobile |
|---------|---------|--------|--------|
| H1 | 48px | 40px | 32px |
| H2 | 36px | 32px | 28px |
| Body | 16px | 16px | 14px |

### Spacing Adjustments

| Property | Desktop | Tablet | Mobile |
|----------|---------|--------|--------|
| Container padding | 64px | 32px | 16px |
| Section gap | 80px | 48px | 32px |
| Card padding | 24px | 20px | 16px |

### Component Visibility

| Component | Desktop | Tablet | Mobile |
|-----------|---------|--------|--------|
| Desktop nav | ✅ | ✅ | ❌ |
| Mobile nav | ❌ | ❌ | ✅ |
| Sidebar | ✅ | Collapsed | ❌ |
| Footer columns | 4 | 2 | 1 |

---

## Validation Checklist

### Desktop (1440px)
- [ ] Layout matches Figma desktop design
- [ ] All elements visible
- [ ] Grid/columns correct
- [ ] Spacing appropriate
- [ ] No horizontal scroll

### Tablet (768px)
- [ ] Layout adapts correctly
- [ ] Touch targets min 44px
- [ ] Navigation accessible
- [ ] Content readable
- [ ] No overlap issues

### Mobile (375px)
- [ ] Single column layout (if expected)
- [ ] Mobile navigation works
- [ ] Text readable without zoom
- [ ] Buttons full width (if expected)
- [ ] No horizontal scroll

---

## Common Responsive Issues

| Issue | Symptom | Fix |
|-------|---------|-----|
| Fixed widths | Horizontal scroll on mobile | Use `max-w-full` or percentages |
| Missing breakpoints | Layout breaks between sizes | Add intermediate breakpoints |
| Font too small | Text unreadable on mobile | Use responsive font sizes |
| Touch targets too small | Hard to tap buttons | Min 44x44px touch area |
| Images overflow | Images break layout | Use `max-w-full h-auto` |

---

## Figma Frame Sizes

Figma'da farklı viewport'lar için frame'ler varsa:

```javascript
// Get all frames in file
mcp__plugin_pb-figma_pixelbyte-figma-mcp__figma_get_file_structure({
  params: {
    file_key: "FILE_KEY",
    depth: 2
  }
})
```

Frame naming convention:
- `Desktop - ComponentName`
- `Tablet - ComponentName`
- `Mobile - ComponentName`

---

## TodoWrite for Responsive Issues

```javascript
TodoWrite({
  todos: [
    {
      content: "Desktop: Fix container max-width (expected: 1280px, found: 100%)",
      status: "pending",
      activeForm: "Fixing desktop container width"
    },
    {
      content: "Tablet: Navigation should collapse to hamburger",
      status: "pending",
      activeForm: "Implementing tablet navigation"
    },
    {
      content: "Mobile: Button should be full width (w-full)",
      status: "pending",
      activeForm: "Fixing mobile button width"
    }
  ]
})
```
```

**Step 2: Commit**

```bash
git add plugins/pb-figma/skills/figma-to-code/references/responsive-validation.md
git commit -m "feat(pb-figma): add responsive validation checklist

- Define standard viewport breakpoints
- Claude in Chrome MCP resize commands
- Check categories: layout, typography, spacing, visibility
- Common responsive issues and fixes
- TodoWrite template for responsive issues"
```

---

## Task 8: Update Visual Validation Loop with Responsive

**Files:**
- Modify: `plugins/pb-figma/skills/figma-to-code/references/visual-validation-loop.md`

**Step 1: Add responsive section**

Add after "Step 5: Fix and Re-check" section:

```markdown
---

## Step 6: Responsive Validation (Optional but Recommended)

After desktop validation passes, validate responsive breakpoints:

**Reference:** `references/responsive-validation.md`

### Viewport Order

1. **Desktop (1440px)** - Already validated
2. **Tablet (768px)** - Validate next
3. **Mobile (375px)** - Validate last

### Process

For each breakpoint:

1. **Resize viewport**
```javascript
mcp__claude-in-chrome__resize_window({
  width: 768,  // or 375 for mobile
  height: 1024,
  tabId: <tab-id>
})
```

2. **Wait for reflow**
```javascript
mcp__claude-in-chrome__computer({
  action: "wait",
  duration: 1,
  tabId: <tab-id>
})
```

3. **Take screenshot**
```javascript
mcp__claude-in-chrome__computer({
  action: "screenshot",
  tabId: <tab-id>
})
```

4. **Compare with Claude Vision**
- Check layout changes
- Check typography scaling
- Check component visibility
- Check spacing adjustments

5. **Create todos for differences**

6. **Fix and re-check**

### Skip Conditions

Skip responsive validation if:
- Figma design has only desktop frame
- User explicitly requests desktop-only
- Time constraints (document in report)
```

**Step 2: Update checklist**

```markdown
## Checklist (Updated)

```
□ Tab context obtained (tabs_context_mcp)
□ Figma screenshot taken
□ Browser screenshot taken (desktop)
□ Claude Vision comparison done
□ Differences listed with TodoWrite
□ All todos completed
□ Final check performed
□ Desktop validation passed
□ Tablet validation passed (optional)
□ Mobile validation passed (optional)
□ Proceed to Phase 5
```
```

**Step 3: Commit**

```bash
git add plugins/pb-figma/skills/figma-to-code/references/visual-validation-loop.md
git commit -m "feat(pb-figma): add responsive validation to visual loop

- Add Step 6: Responsive Validation
- Define viewport order: desktop → tablet → mobile
- Include resize, wait, screenshot, compare process
- Update checklist with responsive items"
```

---

## Task 9: Create Accessibility Validation Reference

**Files:**
- Create: `plugins/pb-figma/skills/figma-to-code/references/accessibility-validation.md`

**Step 1: Create accessibility validation reference**

```markdown
# Accessibility Validation Reference

Bu döküman, Phase 4'te accessibility (a11y) kontrollerini otomatikleştirmek için kullanılır.

---

## A11y Validation Workflow

```
Generated Code → Browser Render → A11y Audit → Fix Issues → Re-check
                      │
         ┌────────────┼────────────┐
         │            │            │
         ▼            ▼            ▼
    Semantic      Keyboard      Screen
      HTML        Navigation    Reader
```

---

## WCAG 2.1 AA Quick Checklist

### Perceivable

- [ ] **1.1.1** Images have alt text
- [ ] **1.3.1** Semantic HTML used (header, main, nav, footer)
- [ ] **1.4.3** Color contrast ratio ≥ 4.5:1 (text), ≥ 3:1 (large text)
- [ ] **1.4.4** Text resizable to 200% without loss

### Operable

- [ ] **2.1.1** All functionality keyboard accessible
- [ ] **2.4.1** Skip links provided (for complex pages)
- [ ] **2.4.4** Link purpose clear from text
- [ ] **2.4.7** Focus visible on interactive elements

### Understandable

- [ ] **3.1.1** Page language declared (`<html lang="en">`)
- [ ] **3.2.1** Focus doesn't change context unexpectedly
- [ ] **3.3.2** Form inputs have labels

### Robust

- [ ] **4.1.1** HTML is valid
- [ ] **4.1.2** ARIA attributes used correctly

---

## Automated Checks (jest-axe)

### Test Template

```typescript
import { axe, toHaveNoViolations } from 'jest-axe';
import { render } from '@testing-library/react';

expect.extend(toHaveNoViolations);

it('has no accessibility violations', async () => {
  const { container } = render(<Component />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

### Common Violations

| Violation | Description | Fix |
|-----------|-------------|-----|
| `image-alt` | Image missing alt text | Add `alt="description"` |
| `button-name` | Button has no accessible name | Add text content or `aria-label` |
| `link-name` | Link has no accessible name | Add text content or `aria-label` |
| `color-contrast` | Insufficient contrast | Darken text or lighten background |
| `label` | Form input missing label | Add `<label>` or `aria-label` |
| `region` | Content not in landmark | Wrap in `<main>`, `<nav>`, etc. |

---

## Manual Checks (Claude Vision)

### Keyboard Navigation Test

```javascript
// In browser, execute keyboard navigation
mcp__claude-in-chrome__computer({
  action: "key",
  text: "Tab",
  repeat: 5,  // Tab through interactive elements
  tabId: <tab-id>
})

// Take screenshot to verify focus visibility
mcp__claude-in-chrome__computer({
  action: "screenshot",
  tabId: <tab-id>
})
```

**Check:**
- Focus indicator visible on each interactive element
- Logical tab order (left-to-right, top-to-bottom)
- No focus traps (can Tab away from any element)

### Color Contrast Check

Use Claude Vision to identify:
- Text on colored backgrounds
- Icon-only buttons
- Placeholder text
- Disabled states

**Contrast Requirements:**
| Element | Minimum Ratio |
|---------|---------------|
| Normal text | 4.5:1 |
| Large text (18px+ or 14px+ bold) | 3:1 |
| UI components | 3:1 |

---

## Claude in Chrome A11y Audit

### Read Accessibility Tree

```javascript
mcp__claude-in-chrome__read_page({
  tabId: <tab-id>,
  filter: "interactive"  // Focus on interactive elements
})
```

**Check output for:**
- Missing accessible names
- Incorrect roles
- Missing labels

### Find Specific Elements

```javascript
mcp__claude-in-chrome__find({
  query: "buttons without accessible name",
  tabId: <tab-id>
})
```

---

## Common A11y Fixes (Tailwind/React)

### Missing Button Name

```tsx
// ❌ Bad
<button onClick={handleClick}>
  <Icon name="close" />
</button>

// ✅ Good
<button onClick={handleClick} aria-label="Close dialog">
  <Icon name="close" />
</button>
```

### Missing Image Alt

```tsx
// ❌ Bad
<img src="/hero.jpg" />

// ✅ Good (informative)
<img src="/hero.jpg" alt="Team collaboration in modern office" />

// ✅ Good (decorative)
<img src="/hero.jpg" alt="" role="presentation" />
```

### Missing Form Label

```tsx
// ❌ Bad
<input type="email" placeholder="Email" />

// ✅ Good
<label>
  Email
  <input type="email" />
</label>

// ✅ Also good
<input type="email" aria-label="Email address" placeholder="Email" />
```

### Color Contrast

```tsx
// ❌ Bad - gray-400 on white ≈ 2.7:1
<p className="text-gray-400">Muted text</p>

// ✅ Good - gray-600 on white ≈ 5.7:1
<p className="text-gray-600">Muted text</p>
```

### Focus Visibility

```tsx
// ❌ Bad - removes focus outline
<button className="focus:outline-none">Click</button>

// ✅ Good - visible focus ring
<button className="focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
  Click
</button>
```

---

## TodoWrite for A11y Issues

```javascript
TodoWrite({
  todos: [
    {
      content: "A11y: Add aria-label to icon button (close)",
      status: "pending",
      activeForm: "Adding aria-label to close button"
    },
    {
      content: "A11y: Increase text contrast (text-gray-400 → text-gray-600)",
      status: "pending",
      activeForm: "Fixing text contrast"
    },
    {
      content: "A11y: Add focus:ring to interactive elements",
      status: "pending",
      activeForm: "Adding focus indicators"
    }
  ]
})
```

---

## Integration with Phase 4

Add to Phase 4 Visual Validation:

1. After visual comparison passes
2. Run jest-axe automated check (if test file exists)
3. Use Claude in Chrome for keyboard navigation test
4. Use Claude Vision for contrast check
5. Create todos for any violations
6. Fix and re-check
```

**Step 2: Commit**

```bash
git add plugins/pb-figma/skills/figma-to-code/references/accessibility-validation.md
git commit -m "feat(pb-figma): add accessibility validation reference

- WCAG 2.1 AA quick checklist
- jest-axe automated test template
- Common violations and fixes
- Keyboard navigation testing
- Color contrast guidelines
- TodoWrite template for a11y issues"
```

---

## Task 10: Update Visual Validation Loop with A11y

**Files:**
- Modify: `plugins/pb-figma/skills/figma-to-code/references/visual-validation-loop.md`

**Step 1: Add a11y section after responsive**

```markdown
---

## Step 7: Accessibility Validation

After visual validation, check accessibility:

**Reference:** `references/accessibility-validation.md`

### Automated Check (if test exists)

```bash
npm run test:a11y -- {ComponentName}
```

### Manual Checks

1. **Keyboard Navigation**
```javascript
mcp__claude-in-chrome__computer({
  action: "key",
  text: "Tab",
  repeat: 5,
  tabId: <tab-id>
})

mcp__claude-in-chrome__computer({
  action: "screenshot",
  tabId: <tab-id>
})
```

2. **Accessibility Tree**
```javascript
mcp__claude-in-chrome__read_page({
  tabId: <tab-id>,
  filter: "interactive"
})
```

### Check For

- [ ] All images have alt text
- [ ] All buttons have accessible names
- [ ] Focus visible on interactive elements
- [ ] Color contrast sufficient
- [ ] Semantic HTML used

### Create Todos

For each a11y issue found:
```
"A11y: [Issue description] → [Fix]"
```

### Fix and Verify

1. Fix each a11y todo
2. Re-run automated check
3. Re-test keyboard navigation
4. Proceed to Phase 5
```

**Step 2: Update final checklist**

```markdown
## Final Checklist

```
□ Tab context obtained
□ Figma screenshot taken
□ Browser screenshot taken
□ Visual comparison done
□ Visual differences fixed
□ Desktop validation passed
□ Responsive validation passed (optional)
□ Accessibility validation passed
□ All todos completed
□ Ready for Phase 5
```
```

**Step 3: Commit**

```bash
git add plugins/pb-figma/skills/figma-to-code/references/visual-validation-loop.md
git commit -m "feat(pb-figma): add accessibility validation to visual loop

- Add Step 7: Accessibility Validation
- Automated jest-axe check
- Manual keyboard navigation test
- Accessibility tree analysis
- Update final checklist"
```

---

## Task 11: Create Error Recovery Patterns Document

**Files:**
- Create: `plugins/pb-figma/skills/figma-to-code/references/error-recovery.md`

**Step 1: Create error recovery reference**

```markdown
# Error Recovery Patterns

Bu döküman, agent pipeline'da hata durumlarında recovery stratejilerini tanımlar.

---

## Error Categories

| Category | Examples | Severity |
|----------|----------|----------|
| Network | MCP timeout, API rate limit | Recoverable |
| Data | Invalid node ID, missing data | Partially recoverable |
| System | File write failed, permission denied | Recoverable |
| Logic | Invalid state, missing dependency | Requires intervention |

---

## Recovery Strategies

### 1. Retry with Backoff

**When:** Network errors, temporary failures

```
Attempt 1 → Fail → Wait 1s → Retry
Attempt 2 → Fail → Wait 2s → Retry
Attempt 3 → Fail → Wait 4s → Retry
Attempt 4 → Fail → Document & Continue
```

**Implementation:**
```
MAX_RETRIES = 3
BACKOFF_BASE = 1 second

for attempt in 1..MAX_RETRIES:
    try:
        result = mcp_call()
        return result
    catch error:
        if attempt < MAX_RETRIES:
            wait(BACKOFF_BASE * 2^attempt)
        else:
            document_failure(error)
            return fallback_value
```

### 2. Fallback Value

**When:** Non-critical data missing

| Data Type | Fallback |
|-----------|----------|
| Color | #000000 (black) or #FFFFFF (white) |
| Font | 'Inter', sans-serif |
| Spacing | 16px (default) |
| Border radius | 8px (default) |
| Shadow | none |

### 3. Skip and Document

**When:** Non-blocking failure

```markdown
## Skipped Items

| Item | Reason | Impact |
|------|--------|--------|
| Icon export | Node not found | Manual export needed |
| Design token | API timeout | Using fallback values |
```

### 4. User Intervention

**When:** Critical failure, ambiguous situation

```
AskUserQuestion:
"MCP bağlantısı başarısız oldu. Nasıl devam edelim?

A) Yeniden dene
B) Atlayıp devam et
C) İşlemi iptal et"
```

---

## Error Handling by Agent

### design-validator

| Error | Recovery |
|-------|----------|
| Invalid file_key | Stop, report error |
| Node not found | Try parent node, warn |
| MCP timeout | Retry 3x with backoff |
| Rate limit | Wait 60s, retry |

### design-analyst

| Error | Recovery |
|-------|----------|
| Validation report not found | Stop, require Phase 1 |
| Malformed report | Attempt parse, document issues |
| Missing tokens | Use fallback values |

### asset-manager

| Error | Recovery |
|-------|----------|
| Export failed | Retry 3x, document failure |
| Invalid format | Try PNG fallback |
| Download timeout | Retry with longer timeout |
| File write failed | Check permissions, retry |

### code-generator

| Error | Recovery |
|-------|----------|
| Spec not found | Stop, require Phase 2 |
| MCP code gen failed | Fall back to manual generation |
| Invalid framework | Ask user to specify |
| Type errors | Log, attempt fix, continue |

### compliance-checker

| Error | Recovery |
|-------|----------|
| Component file not found | Mark as FAIL, continue |
| Parse error | Log, skip component |
| Spec mismatch | Document in report |

---

## MCP-Specific Recovery

### Figma MCP

```
Error: "Rate limit exceeded"
Recovery:
1. Log error
2. Wait 60 seconds
3. Retry request
4. If still fails, ask user to wait or provide API key with higher limits

Error: "Invalid file key"
Recovery:
1. Log error
2. Validate URL format
3. Ask user to verify Figma URL
4. Stop pipeline

Error: "Node not found"
Recovery:
1. Log warning
2. Try fetching parent node
3. Document missing node
4. Continue with available data
```

### Claude in Chrome MCP

```
Error: "Tab not found"
Recovery:
1. Call tabs_context_mcp to refresh
2. Create new tab if needed
3. Retry operation

Error: "Navigation failed"
Recovery:
1. Wait 2 seconds
2. Retry navigation
3. If fails, check URL validity

Error: "Screenshot timeout"
Recovery:
1. Wait for page load
2. Retry screenshot
3. If fails, document and continue
```

---

## Logging Pattern

Every error should be logged with:

```markdown
### Error Log

**Time:** 2026-01-25 14:32:15
**Agent:** asset-manager
**Operation:** figma_export_assets
**Error:** "Rate limit exceeded"
**Recovery:** Waited 60s, retried successfully
**Impact:** 60s delay, no data loss
```

---

## Pipeline Resilience

### Partial Success Handling

```
Pipeline can continue if:
- 80%+ of assets downloaded
- All critical components generated
- Minor styling differences only

Pipeline should stop if:
- Figma URL invalid
- No components generated
- Critical assets missing
- User cancels
```

### Checkpoint System

```
After each agent:
1. Save intermediate report
2. Log success/failure
3. Check continue conditions
4. Allow resume from checkpoint

Checkpoints:
- .qa/checkpoint-1-validation.json
- .qa/checkpoint-2-spec.json
- .qa/checkpoint-3-assets.json
- .qa/checkpoint-4-code.json
```

---

## TodoWrite for Errors

```javascript
TodoWrite({
  todos: [
    {
      content: "ERROR: Asset export failed for logo.svg - Retry manually",
      status: "pending",
      activeForm: "Retrying logo.svg export"
    },
    {
      content: "WARNING: Using fallback font (Inter) - Custom font not available",
      status: "completed",
      activeForm: "Documented font fallback"
    }
  ]
})
```
```

**Step 2: Commit**

```bash
git add plugins/pb-figma/skills/figma-to-code/references/error-recovery.md
git commit -m "feat(pb-figma): add error recovery patterns

- Define error categories and severity
- Recovery strategies: retry, fallback, skip, intervention
- Agent-specific error handling
- MCP-specific recovery patterns
- Checkpoint system for pipeline resilience
- Logging pattern template"
```

---

## Task 12: Update Agents with Error Recovery

**Files:**
- Modify: `plugins/pb-figma/agents/design-validator.md`
- Modify: `plugins/pb-figma/agents/asset-manager.md`

**Step 1: Add error recovery section to design-validator**

Find "## Error Handling" section and enhance:

```markdown
## Error Handling

**Reference:** `references/error-recovery.md`

### Retry Logic

For MCP calls, implement retry with backoff:

```
MAX_RETRIES = 3
Retry on: timeout, rate_limit, network_error
Backoff: 1s, 2s, 4s
```

### Error Matrix

| Error | Recovery | Action |
|-------|----------|--------|
| Invalid URL | Stop | Report error to user |
| Invalid file_key | Stop | Ask user to verify URL |
| Node not found | Warn | Try parent node |
| MCP timeout | Retry 3x | If fails, document |
| Rate limit | Wait 60s | Then retry |
| Missing tokens | Continue | Use fallbacks |

### Fallback Values

If design tokens cannot be extracted:

| Token | Fallback |
|-------|----------|
| Font family | 'Inter', sans-serif |
| Font size | 16px |
| Color | #000000 |
| Spacing | 16px |
| Border radius | 8px |
```

**Step 2: Add error recovery to asset-manager**

```markdown
## Error Handling

**Reference:** `references/error-recovery.md`

### Download Recovery

```
For each asset:
1. Attempt download
2. If fails → Retry with backoff (3 attempts)
3. If still fails → Document failure
4. Continue with other assets
5. Report partial success
```

### Format Fallback

If requested format fails:

| Requested | Fallback |
|-----------|----------|
| SVG | PNG |
| WebP | PNG |
| PDF | PNG |

### Partial Success

Continue if:
- 80%+ assets downloaded
- All critical assets (logo, hero) present

Stop if:
- 0 assets downloaded
- All critical assets failed
```

**Step 3: Commit**

```bash
git add plugins/pb-figma/agents/design-validator.md
git add plugins/pb-figma/agents/asset-manager.md
git commit -m "feat(pb-figma): add error recovery to agents

- Retry logic with backoff
- Error matrix for each error type
- Fallback values for missing data
- Partial success handling
- Reference to error-recovery.md"
```

---

## Verification Checklist

After completing all tasks:

- [ ] `references/archive/qa-report-template-rmse.md` exists (backup)
- [ ] `references/qa-report-template.md` updated to Claude Vision
- [ ] `references/test-generation.md` created
- [ ] SKILL.md Phase 5 updated with test generation
- [ ] `references/code-connect-guide.md` created
- [ ] SKILL.md Phase 1 updated with Code Connect
- [ ] `references/responsive-validation.md` created
- [ ] `references/visual-validation-loop.md` updated with responsive
- [ ] `references/accessibility-validation.md` created
- [ ] `references/visual-validation-loop.md` updated with a11y
- [ ] `references/error-recovery.md` created
- [ ] Agent files updated with error recovery
- [ ] All 12 commits in git log
- [ ] `git status` shows clean working directory

---

## Testing

After implementation:

1. **Test QA Report:** Run Phase 4 validation, verify Claude Vision report generated
2. **Test Test Generation:** Run Phase 5, verify test files created
3. **Test Code Connect:** Run with existing codebase, verify mappings checked
4. **Test Responsive:** Run Phase 4, verify all breakpoints validated
5. **Test A11y:** Run Phase 4, verify accessibility checks performed
6. **Test Error Recovery:** Simulate MCP failure, verify retry/fallback works
