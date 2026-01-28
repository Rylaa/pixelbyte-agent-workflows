# Test: Image-with-Text Detection

## Purpose
Verify that design-analyst suppresses text children of DOWNLOAD_AS_IMAGE nodes and code-generator skips duplicate text.

## Input

Figma design where node 6:32 (GrowthSection) is flagged as DOWNLOAD_AS_IMAGE.
Node 6:32 has a TEXT child "PROJECTED GROWTH" (node 6:33).

Flagged for LLM Review table:
| Node ID | Name | LLM Decision |
|---------|------|--------------|
| 6:32 | GrowthSection | DOWNLOAD_AS_IMAGE |

## Expected Output (Implementation Spec - Design Analyst)

### GrowthSectionView

| Property | Value |
|----------|-------|
| **Children** | ChartIllustration |
| **Asset Children** | `IMAGE:growth-chart:6:32:354:132 [contains-text: "PROJECTED GROWTH"]` |

Note: TitleText suppressed — text node 6:33 ("PROJECTED GROWTH") is baked into IMAGE:growth-chart.

## Verification Steps (Design Analyst)

1. [ ] design-analyst reads Flagged for LLM Review section
2. [ ] Identifies DOWNLOAD_AS_IMAGE entries
3. [ ] Queries flagged node children for TEXT nodes
4. [ ] Suppresses TEXT children from component spec
5. [ ] Adds [contains-text] annotation to Asset Children

## Expected Output (SwiftUI - Code Generator)

```swift
struct GrowthSectionView: View {
    var body: some View {
        // "PROJECTED GROWTH" text is embedded in the growth-chart image asset
        Image("growth-chart")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("PROJECTED GROWTH chart showing upward trend")
    }
}
```

## NOT Expected (Bug)

```swift
// This is WRONG - Creates duplicate text
VStack {
    Text("PROJECTED GROWTH")  // This duplicates text in image!

    Image("growth-chart")
}
```

## Verification Steps (Code Generator)

1. [ ] code-generator reads [contains-text] annotation from Asset Children
2. [ ] Skips Text("PROJECTED GROWTH") generation
3. [ ] Image() has accessibilityLabel with text content
4. [ ] No duplicate "PROJECTED GROWTH" in output
5. [ ] Code comment explains text is embedded in image
