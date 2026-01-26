# Test: COMPLEX_VECTOR Asset Download

## Test Case Details

**Figma File:** ElHzcNWC8pSYTz2lhPP9h0 (ViralZ)
**Node:** 6:46 ("iPhone 13 & 14 - 7")
**Test Asset:** Frame 2121316823 (node 210:145) containing multiple vector illustrations

## Input

### File Information
- File Key: `ElHzcNWC8pSYTz2lhPP9h0`
- File Name: ViralZ
- Node ID: `210:145` (Frame 2121316823 - complex vector illustration)

### Asset Characteristics
The Frame 2121316823 contains:
- Multiple vector paths (Vector 685-722)
- Complex chart/illustration with 40+ individual vector elements
- Image fills (ChatGPT generated images)
- Overall dimensions: 1024×1024px

### Expected Behavior

Asset Manager should:
1. **Detect** it as COMPLEX_VECTOR (not SIMPLE_ICON)
   - Criteria: Contains multiple vector children (>10 paths)
   - Criteria: Complex structure (nested frames with vectors)
   - Criteria: Illustration/chart use case (not a simple icon)

2. **Download** as PNG at 2x scale (not SVG)
   - Reason: Complex vectors render better as raster at target size
   - Format: PNG
   - Scale: 2
   - Expected file size: >50KB

3. **Save** to appropriate directory structure
   - For web: `public/assets/images/viral-chart-illustration.png`
   - For iOS: `.xcassets/ViralChartIllustration.imageset/`
   - Include Contents.json with proper metadata

## Current Behavior (Bug)

Asset Manager currently:
- Has NO COMPLEX_VECTOR classification logic (lines 79-140)
- Only supports:
  - Icons (SVG, scale: 1) - line 83-90
  - Images (PNG, scale: 2) - line 92-99
  - Image Fills - line 101-107
- Would incorrectly classify complex vector as "Icon" → download as SVG
- SVG would be huge file size and render poorly

## Expected Output

### 1. Classification Result
```
Asset Type: COMPLEX_VECTOR
Reason: Contains 40+ vector paths in nested structure
Download Strategy: PNG at 2x scale
```

### 2. Download Call
```
figma_export_assets:
  - file_key: ElHzcNWC8pSYTz2lhPP9h0
  - node_ids: [210:145]
  - format: png
  - scale: 2
```

### 3. File Validation
```bash
ls -lh temp_downloads/Frame_2121316823.png
# Expected: File size >50KB, PNG format

file temp_downloads/Frame_2121316823.png
# Expected: PNG image data, 2048 x 2048 (2x scale)
```

### 4. Final Location
```
public/assets/images/viral-chart-illustration.png
```

### 5. Spec Update
```markdown
## Downloaded Assets

| Asset | Local Path | Size | Status |
|-------|------------|------|--------|
| Viral Chart Illustration | `public/assets/images/viral-chart-illustration.png` | 156 KB | OK |
```

## Test Steps

1. **Read asset-manager.md lines 79-140**
   - Confirm: No COMPLEX_VECTOR detection logic exists

2. **Inspect Figma node 210:145**
   - Verify: Contains 40+ vector children
   - Verify: Complex nested structure

3. **Fix asset-manager.md**
   - Add COMPLEX_VECTOR classification section
   - Add detection criteria
   - Add download strategy (PNG at 2x)

4. **Run asset-manager agent** (theoretical - we're fixing the docs)
   - Expected: Detects as COMPLEX_VECTOR
   - Expected: Downloads as PNG at 2x scale
   - Expected: Saves to correct location

5. **Verify result**
   - Check file exists
   - Check file size >50KB
   - Check format is PNG
   - Check dimensions are 2x original

## Success Criteria

- [ ] asset-manager.md includes COMPLEX_VECTOR classification logic
- [ ] Detection criteria clearly documented (>10 vector paths, nested structure)
- [ ] Download strategy specified (PNG at 2x, not SVG)
- [ ] Example provided for complex vectors
- [ ] Bug fixed and documented in commit message

## Bug Analysis

**Root Cause:**
Asset Manager only has binary classification:
- SVG → Icons (line 83-90)
- PNG → Images (line 92-99)

**Missing:**
- No semantic asset type classification
- No detection of complex vectors vs simple icons
- No guidance for charts/illustrations with many paths

**Fix Required:**
Add new section to asset-manager.md between lines 79-140:
```markdown
#### Complex Vectors (Charts, Illustrations)
For assets with multiple vector paths (>10 child vectors), download as PNG:
```
figma_export_assets:
  - file_key: {file_key}
  - node_ids: [{node_id}]
  - format: png
  - scale: 2
```

**Detection Criteria:**
- Node type: FRAME or GROUP containing vectors
- Child count: >10 vector paths
- Use case: Charts, graphs, complex illustrations
- Not suitable as inline SVG due to complexity
```

## References

- Plan: `docs/plans/2026-01-26-asset-pipeline-opacity-fixes.md` (Task 4)
- Asset Manager: `plugins/pb-figma/agents/asset-manager.md`
- Figma File: https://www.figma.com/design/ElHzcNWC8pSYTz2lhPP9h0/ViralZ?node-id=210-145
