# Test: SwiftUI Opacity Application

## Input
Implementation Spec with 3 opacity scenarios:

| Property | Color | Opacity | Expected SwiftUI |
|----------|-------|---------|------------------|
| Border | #ffffff | 0.4 | `Color.white.opacity(0.4)` |
| Background | #150200 | 1.0 | `Color(hex: "#150200")` (no modifier) |
| Overlay | #f02912 | 0.2 | `.opacity(0.2)` |

## Expected SwiftUI Output

```swift
// Scenario 1: Border with opacity applied to Color
RoundedRectangle(cornerRadius: 24)
    .stroke(Color.white.opacity(0.4), lineWidth: 1.0)

// Scenario 2: Background without opacity modifier (1.0)
Color(hex: "#150200")

// Scenario 3: Gradient overlay with opacity applied to view
RadialGradient(
    gradient: Gradient(stops: [
        .init(color: Color(hex: "#f02912"), location: 0.0),
        .init(color: Color(hex: "#150200"), location: 1.0)
    ]),
    center: .center,
    startRadius: 0,
    endRadius: 200
)
.opacity(0.2)
```

## Current Behavior

**Analysis of code-generator-swiftui.md lines 175-222:**

### What Works:
- ✅ Lines 207-208: Correctly instructs to copy Usage column and never ignore opacity modifiers
- ✅ Line 210: Correctly states no modifier needed when opacity = 1.0
- ✅ Lines 192-194: Shows correct pattern for Color-level opacity (border case)

### Bug Found:
- ❌ **Missing view-level opacity example**: Lines 191-203 only show Color-level opacity patterns (`Color.white.opacity(0.4)`)
- ❌ **No example for view modifier**: Missing example of `.opacity(0.2)` applied to entire view (like gradient overlay)
- ❌ **Potential confusion**: Agent might not understand when to use `Color.opacity()` vs `.opacity()` modifier

### Issue:
Examples only demonstrate:
```swift
// Color-level (border, fill, text)
.stroke(Color.white.opacity(0.4))
.fill(Color(hex: "#150200").opacity(0.8))
.foregroundColor(Color(hex: "#333333").opacity(0.9))
```

But missing:
```swift
// View-level (gradient, overlay, entire element)
RadialGradient(...)
    .opacity(0.2)
```

The instructions rely on Usage column having correct code (which is good), but examples don't show both patterns.

## Fix Applied

**Updated code-generator-swiftui.md lines 191-251:**

1. Added **Pattern 1: Color-level opacity** section with clear examples
2. Added **Pattern 2: View-level opacity** section with gradient and shape overlay examples
3. Updated "Common mistakes" to show both patterns (Color-level and View-level)

**Key changes:**
- Lines 191-226: Now shows both opacity patterns with clear labels
- Lines 208-226: New view-level opacity examples including `RadialGradient(...).opacity(0.2)`
- Lines 236-251: Updated mistakes section to cover both patterns

## Success Criteria
- ✅ code-generator-swiftui.md correctly handles opacity extraction from Implementation Spec
- ✅ Applies `.opacity()` modifier when opacity < 1.0 (both Color and View levels)
- ✅ Applies `Color.opacity()` for border/stroke cases (Pattern 1)
- ✅ Applies `.opacity()` modifier for view cases (Pattern 2)
- ✅ No modifier when opacity = 1.0 (documented in Critical Rules)
- ✅ Test documents all 3 scenarios (border, background, overlay)
