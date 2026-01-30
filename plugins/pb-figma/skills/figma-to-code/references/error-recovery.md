# Error Recovery Patterns

> **Used by:** all agents

Bu dokuman, agent pipeline'da hata durumlarinda recovery stratejilerini tanimlar.

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
"MCP baglantisi basarisiz oldu. Nasil devam edelim?

A) Yeniden dene
B) Atlayip devam et
C) Islemi iptal et"
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

### Checkpoint System (Planned)

> ⚠️ **Status:** This checkpoint system is documented as a future feature. Currently, pipeline state is passed through spec files (`{file_key}-spec.md`). Agents do not yet produce `.qa/checkpoint-*.json` files.

**Future Implementation:**

When implemented, save intermediate state after each phase:

```
.qa/checkpoint-1-validation.json    (Phase 1)
.qa/checkpoint-2-spec.json          (Phase 2)
.qa/checkpoint-3-assets.json        (Phase 3)
.qa/checkpoint-4-code.json          (Phase 4)
```

**Current Recovery Mechanism:**

Pipeline currently recovers by:
1. Re-reading the spec file from `docs/figma-reports/`
2. Checking which sections are already populated
3. Resuming from the last completed phase

---

## Checkpoint-Based Recovery

Each pipeline agent writes a JSON checkpoint to `.qa/checkpoint-{N}-{agent}.json` upon successful completion. When recovering from errors:

1. **Check existing checkpoints:** Read `.qa/checkpoint-*.json` files
2. **Find highest completed phase:** The highest phase number indicates last successful step
3. **Resume from next phase:** Skip already-completed phases and their agents
4. **Use checkpoint output_file:** Read the output file path from the checkpoint to pass to the next agent

**Checkpoint files:**
| Phase | File | Agent |
|-------|------|-------|
| 1 | `checkpoint-1-design-validator.json` | design-validator |
| 2 | `checkpoint-2-design-analyst.json` | design-analyst |
| 3 | `checkpoint-3-asset-manager.json` | asset-manager |
| 4 | `checkpoint-4-code-generator.json` | code-generator-* |
| 5 | `checkpoint-5-compliance-checker.json` | compliance-checker |

**Clean start:** Delete `.qa/checkpoint-*.json` to force full pipeline re-run.

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
