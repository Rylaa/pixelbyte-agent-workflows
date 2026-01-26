# Test: Gradient Detection

## Purpose
Verify Design Analyst correctly extracts ALL gradient stops with EXACT locations (4 decimal places) from Figma API, including gradient type, color, and opacity for each stop.

## Input
Figma node with angular gradient on text:
- **File Key:** bt65gbJ6sSdKRP4x3IY151
- **Node ID:** 10203:16369
- **Component:** TypeSceneText
- **Text:** "Type a scene to generate your video"

## API Response Example (from figma_get_node_details)

```json
{
  "fills": [
    {
      "type": "GRADIENT_ANGULAR",
      "gradientStops": [
        {
          "position": 0.16733333468437195,
          "color": { "r": 0.737, "g": 0.510, "b": 0.953, "a": 1.0 }
        },
        {
          "position": 0.23650000989437103,
          "color": { "r": 0.957, "g": 0.725, "b": 0.918, "a": 1.0 }
        },
        {
          "position": 0.35183331370353699,
          "color": { "r": 0.553, "g": 0.596, "b": 1.0, "a": 1.0 }
        },
        {
          "position": 0.58150000870227814,
          "color": { "r": 0.667, "g": 0.431, "b": 0.933, "a": 1.0 }
        },
        {
          "position": 0.69699996709823608,
          "color": { "r": 1.0, "g": 0.404, "b": 0.467, "a": 1.0 }
        },
        {
          "position": 0.80950003862380981,
          "color": { "r": 1.0, "g": 0.729, "b": 0.443, "a": 1.0 }
        },
        {
          "position": 0.92416667938232422,
          "color": { "r": 0.776, "g": 0.525, "b": 1.0, "a": 1.0 }
        }
      ]
    }
  ],
  "opacity": 1.0
}
```

## Expected Output in Implementation Spec

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

## Expected Conversion Logic

### Position Precision
- API returns: `0.16733333468437195`
- Must round to 4 decimal places: `0.1673`
- NOT round to 2 decimals (0.17) - this loses precision

### Color Conversion
- API returns RGB as 0-1 floats: `{ r: 0.737, g: 0.510, b: 0.953 }`
- Convert to 0-255 integers: `r=188, g=130, b=243`
- Format as hex: `#bc82f3`

### Opacity Extraction
- Extract `color.a` from each gradient stop (default: 1.0)
- Multiply by node-level opacity if present
- Include in output: `(opacity: 1.0)`

## Gradient Type Mapping

| Figma API Type | SwiftUI Type | Output Format |
|----------------|--------------|---------------|
| GRADIENT_LINEAR | LinearGradient | LINEAR |
| GRADIENT_RADIAL | RadialGradient | RADIAL |
| GRADIENT_ANGULAR | AngularGradient | ANGULAR |
| GRADIENT_DIAMOND | (Custom) | DIAMOND |

## Bug Detection Criteria

Test FAILS if:
- ❌ Gradient stops are missing (e.g., only 3 of 7 stops extracted)
- ❌ Position values are rounded (0.17 instead of 0.1673)
- ❌ Opacity is missing from output
- ❌ Gradient type is incorrect or missing
- ❌ Wrong API used (`figma_get_design_tokens` instead of `figma_get_node_details`)

Test PASSES if:
- ✅ ALL 7 gradient stops are extracted
- ✅ Positions match exactly: 0.1673, 0.2365, 0.3518, 0.5815, 0.697, 0.8095, 0.9241
- ✅ Colors match exactly: #bc82f3, #f4b9ea, #8d98ff, #aa6eee, #ff6777, #ffba71, #c686ff
- ✅ Opacity is included for each stop: (opacity: 1.0)
- ✅ Gradient type is ANGULAR
- ✅ Uses `figma_get_node_details` (not `figma_get_design_tokens`)

## Edge Cases to Handle

### Case 1: Gradient with varying opacity
```json
{
  "gradientStops": [
    { "position": 0.0, "color": { "r": 1.0, "g": 0.0, "b": 0.0, "a": 1.0 } },
    { "position": 0.5, "color": { "r": 0.0, "g": 1.0, "b": 0.0, "a": 0.5 } },
    { "position": 1.0, "color": { "r": 0.0, "g": 0.0, "b": 1.0, "a": 0.0 } }
  ]
}
```
Expected:
- 0.0: #ff0000 (opacity: 1.0)
- 0.5: #00ff00 (opacity: 0.5)
- 1.0: #0000ff (opacity: 0.0)

### Case 2: Linear gradient (different type)
```json
{
  "type": "GRADIENT_LINEAR",
  "gradientStops": [...]
}
```
Expected output: `**Gradient Type:** LINEAR`

### Case 3: Many stops (10+ color stops)
- ALL stops must be preserved
- No truncation at 5 or 7 stops
- Add performance warning if 10+ stops

## Real-World Test Case

**Figma URL:** https://www.figma.com/design/bt65gbJ6sSdKRP4x3IY151?node-id=10203-16369

**Test Command:**
```bash
# Run design-validator to get node details
# Then run design-analyst on validation report
# Check that gradient section matches expected output
```

**Validation:**
1. Count gradient stops in output → Should be 7
2. Check position precision → Should be 4 decimals (0.1673, not 0.17)
3. Verify opacity present → Each stop shows (opacity: X.X)
4. Confirm gradient type → Should show ANGULAR
