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
