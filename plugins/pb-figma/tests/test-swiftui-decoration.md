# Test: SwiftUI Text Decoration Support

## Input

Implementation Spec with Text Decoration section:

```markdown
### Text Decoration

**Component:** HookText
- **Decoration:** Underline
- **Color:** #ffd100 (opacity: 1.0)
- **Thickness:** 1.0

**SwiftUI Mapping:** `.underline(color: Color(hex: "#ffd100"))`

**Component:** StrikeText
- **Decoration:** Strikethrough
- **Color:** #ff0000 (opacity: 0.8)
- **Thickness:** 1.0

**SwiftUI Mapping:** `.strikethrough(color: Color(hex: "#ff0000").opacity(0.8))`

**Component:** BasicUnderline
- **Decoration:** Underline
- **Color:** (default)
- **Thickness:** 1.0

**SwiftUI Mapping:** `.underline()`
```

## Expected SwiftUI Output

```swift
// Scenario 1: Underline with custom color (iOS 16+)
@available(iOS 16.0, *)
struct HookText: View {
    var body: some View {
        Text("Hook")
            .font(.system(size: 14, weight: .regular))
            .underline(color: Color(hex: "#ffd100"))
    }
}

// Scenario 2: Strikethrough with color and opacity (iOS 16+)
@available(iOS 16.0, *)
struct StrikeText: View {
    var body: some View {
        Text("Strike")
            .font(.system(size: 14, weight: .regular))
            .strikethrough(color: Color(hex: "#ff0000").opacity(0.8))
    }
}

// Scenario 3: Basic underline without color (iOS 15 compatible)
struct BasicUnderline: View {
    var body: some View {
        Text("Basic")
            .font(.system(size: 14, weight: .regular))
            .underline()
    }
}

// Alternative: With iOS 15 fallback
struct HookTextWithFallback: View {
    var body: some View {
        if #available(iOS 16.0, *) {
            Text("Hook")
                .font(.system(size: 14, weight: .regular))
                .underline(color: Color(hex: "#ffd100"))
        } else {
            Text("Hook")
                .font(.system(size: 14, weight: .regular))
                .underline()
        }
    }
}
```

## Test Scenarios

| Scenario | Decoration | Color | Opacity | Expected Modifier | iOS Version |
|----------|-----------|-------|---------|-------------------|-------------|
| 1 | Underline | #ffd100 | 1.0 | `.underline(color: Color(hex: "#ffd100"))` | iOS 16+ |
| 2 | Strikethrough | #ff0000 | 0.8 | `.strikethrough(color: Color(hex: "#ff0000").opacity(0.8))` | iOS 16+ |
| 3 | Underline | (default) | - | `.underline()` | iOS 15+ |

## Success Criteria

- ✅ code-generator-swiftui.md documents text decoration support
- ✅ Reads decoration type from "Decoration" field (Underline | Strikethrough)
- ✅ Reads decoration color from "Color" field
- ✅ Applies `.underline(color:)` or `.strikethrough(color:)` with exact hex value
- ✅ Includes `.opacity()` modifier when decoration color opacity < 1.0
- ✅ Places decoration modifier AFTER `.font()` modifier (typography first)
- ✅ Adds `@available(iOS 16.0, *)` when using color parameter
- ✅ Documents fallback pattern for iOS 15 compatibility
- ✅ Uses `.underline()` without color parameter for basic decoration
- ✅ Preserves exact color from spec using `Color(hex:)` extension

## Critical Implementation Rules

**From plan (lines 542-676):**

1. **Apply after .font() modifier** - Decoration goes after typography
2. **Use exact color from spec** - Copy hex value from "Color" field
3. **Include opacity if < 1.0** - Add `.opacity(0.8)` to Color
4. **iOS 16+ API** - Add `@available(iOS 16.0, *)` for color parameter
5. **Fallback for iOS 15** - Use `.underline()` without color for older iOS

## Edge Cases

### No color specified (default decoration)
```swift
// Input: Decoration: Underline, Color: (default)
// Output:
Text("Basic")
    .underline()  // No color parameter, works on iOS 15+
```

### Full opacity (1.0)
```swift
// Input: Decoration: Underline, Color: #ffd100 (opacity: 1.0)
// Output:
Text("Full opacity")
    .underline(color: Color(hex: "#ffd100"))  // No .opacity() modifier
```

### Partial opacity
```swift
// Input: Decoration: Strikethrough, Color: #ff0000 (opacity: 0.5)
// Output:
Text("Partial opacity")
    .strikethrough(color: Color(hex: "#ff0000").opacity(0.5))
```

### Multiple decorations (rare)
```swift
// If spec has both underline AND strikethrough (rare case):
Text("Multiple")
    .underline(color: Color(hex: "#ffd100"))
    .strikethrough(color: Color(hex: "#ff0000"))
```
