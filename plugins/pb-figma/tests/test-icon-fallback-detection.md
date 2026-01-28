# Test: Icon Fallback Detection

## Purpose
Verify that design-validator detects all card icons even when figma_list_assets misses some.

## Input

3-card layout where:
- Card 1 icon: detected by figma_list_assets (weui:time-filled, node 3:318)
- Card 2 icon: detected by figma_list_assets (streamline:flask, node 3:321)
- Card 3 icon: NOT detected by figma_list_assets (node 3:400, lucide:trending-up)

## Expected Output (Validation Report)

### Assets Inventory

| Asset | Type | Node ID | Figma Name | Export Name | Notes |
|-------|------|---------|------------|-------------|-------|
| Card 1 Icon | icon | 3:318 | weui:time-filled | icon-time-filled.svg | |
| Card 2 Icon | icon | 3:321 | streamline:flask | icon-flask.svg | |
| Card 3 Icon | icon | 3:400 | lucide:trending-up | icon-trending-up.svg | [FALLBACK] |

## Expected Behavior

1. figma_list_assets returns only Card 1 and Card 2 icons
2. design-validator detects Card 3 is missing icon
3. Fallback detection queries Card 3 children
4. Finds icon candidate by size heuristic (32x32, leftmost child)
5. Queries node 3:400 directly → gets name "lucide:trending-up"
6. Adds to Assets Inventory with [FALLBACK] tag

## Expected Output (Implementation Spec - Design Analyst)

If fallback still can't resolve the icon name:

### Unresolved Assets

| Node ID | Type | Issue | Fallback |
|---------|------|-------|----------|
| 3:400 | icon | Name not detected | Screenshot captured — visual identification needed |

## Expected Output (SwiftUI - Code Generator)

If icon is unresolved:

```swift
// TODO: Unresolved icon asset (Node ID: 3:400)
// Visual reference: See figma-reports/{file_key}-spec.md Unresolved Assets section
Image(systemName: "questionmark.square.dashed")
    .resizable()
    .aspectRatio(contentMode: .fit)
    .frame(width: 32, height: 32)
```

## Verification Steps (Design Validator)

1. [ ] All 3 card icons appear in Assets Inventory
2. [ ] Card 3 icon has [FALLBACK] tag
3. [ ] No icon shows as "(not identified)"
4. [ ] Each card has unique icon node ID
5. [ ] Icon names follow kebab-case export convention

## Verification Steps (Design Analyst)

1. [ ] Unresolved icons documented in "Unresolved Assets" section
2. [ ] Screenshot captured for unresolved icons
3. [ ] No silent icon substitution

## Verification Steps (Code Generator)

1. [ ] Unresolved icons use SF Symbol placeholder
2. [ ] TODO comment includes Node ID
3. [ ] No wrong icon fallback used

## Verification Steps (Compliance Checker)

1. [ ] Unresolved assets trigger FAIL status
2. [ ] Placeholder icons trigger FAIL status
