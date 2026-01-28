# Opacity Extraction Reference

## Compound Opacity Calculation

Figma stores opacity at multiple levels. Calculate effective opacity:

```typescript
effectiveOpacity = fillOpacity * nodeOpacity
```

**Example:**
- Fill opacity: 0.8
- Node opacity: 0.5
- Effective: 0.8 * 0.5 = 0.4

## Extraction from Figma

```typescript
const nodeDetails = figma_get_node_details({
  file_key: "{file_key}",
  node_id: "{node_id}"
});

// Extract BOTH fill opacity and node opacity
const fillOpacity = nodeDetails.fills?.[0]?.opacity ?? 1.0;  // Default to 1.0 if undefined
const nodeOpacity = nodeDetails.opacity ?? 1.0;              // Default to 1.0 if undefined

// Calculate effective opacity (compound multiplication)
const effectiveOpacity = fillOpacity * nodeOpacity;
```

## Opacity Sources

| Source | Figma Property | Priority |
|--------|---------------|----------|
| Fill | `fills[0].opacity` | Primary |
| Node | `opacity` | Multiplier |
| Effect | `effects[].opacity` | Additive |

## Warning Conditions

Flag for review when:
- `effectiveOpacity < 0.1` - Nearly invisible
- `effectiveOpacity !== 1.0 AND effectiveOpacity !== 0.0` - Partial transparency
- Multiple opacity sources combined
- Border/stroke opacity < 0.8 - May appear faded
- Text opacity < 1.0 - May reduce readability

## Calculation Examples

| Fill Opacity | Node Opacity | Effective | Usage |
|--------------|--------------|-----------|-------|
| 0.4 | 1.0 | 0.4 | `.stroke(Color.white.opacity(0.4))` |
| 0.5 | 0.8 | 0.4 | `.opacity(0.4)` |
| undefined | 0.6 | 0.6 | `.opacity(0.6)` |
| 1.0 | 1.0 | 1.0 | No `.opacity()` modifier needed |

## SwiftUI Application

### Pattern 1: Color-level opacity (for fills, strokes, text)

```swift
// Border with opacity
RoundedRectangle(cornerRadius: 12)
    .stroke(Color.white.opacity(0.4), lineWidth: 1.0)

// Background with opacity
Rectangle()
    .fill(Color(hex: "#150200").opacity(0.8))

// Text with opacity
Text(title)
    .foregroundColor(Color(hex: "#333333").opacity(0.9))
```

### Pattern 2: View-level opacity (for gradients, overlays)

```swift
// Gradient overlay with view-level opacity
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

## Critical Rules

1. **Always extract BOTH opacities** from `figma_get_node_details`
2. **Calculate effective opacity** before adding to spec
3. **opacity: 1.0** - Omit `.opacity()` modifier (SwiftUI default)
4. **opacity: 0.0** - Element is invisible, verify intentional
5. **Copy Usage column** from Design Tokens table directly into code
