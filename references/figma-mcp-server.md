# Official Figma MCP Server Reference

The official Figma MCP Server provides design context to AI agents for code generation. This skill uses the **Local Desktop Server** configuration.

## Server Configuration

### Local Desktop Server

**Endpoint:** `http://127.0.0.1:3845/mcp`

```json
{
  "mcpServers": {
    "figma-desktop": {
      "url": "http://127.0.0.1:3845/mcp"
    }
  }
}
```

### Prerequisites

1. **Figma Desktop App** (latest version)
2. **Dev Mode** enabled (Shift+D in Figma)
3. **MCP Server** enabled in inspect panel
4. Active Figma Design file open

### Activation Steps

1. Open Figma Desktop App
2. Open your design file
3. Press `Shift+D` to toggle Dev Mode
4. In the inspect panel, enable MCP Server
5. Verify server is running at `http://127.0.0.1:3845/mcp`

## Available Tools

### Primary Tools

#### get_design_context

Generates a structured React + Tailwind representation of your Figma selection.

**Usage:**
```
Select a frame in Figma → Call get_design_context
```

**Returns:**
- React + Tailwind code representation
- Component structure
- Layout classes
- Styling information

**Customization Options:**
- Framework (React, Vue, etc.)
- Component library
- Styling approach (Tailwind, CSS-in-JS, etc.)

**Example Prompts:**
- "Generate my Figma selection in Vue"
- "Generate using components from src/components/ui"
- "Use CSS modules instead of Tailwind"

**Note:** Selection-based prompting only works with desktop server. Remote server requires explicit frame links.

---

#### get_variable_defs

Extracts variables and styles used in your selection.

**Usage:**
```
Select elements in Figma → Call get_variable_defs
```

**Returns:**
```json
{
  "colors": {
    "primary": "#3B82F6",
    "secondary": "#6B7280"
  },
  "spacing": {
    "sm": "8px",
    "md": "16px",
    "lg": "24px"
  },
  "typography": {
    "heading": {
      "fontFamily": "Inter",
      "fontSize": "24px",
      "fontWeight": 600,
      "lineHeight": "1.2"
    }
  }
}
```

**Use Cases:**
- Extract color palette
- Get spacing tokens
- Retrieve typography definitions
- Map to Tailwind theme

**File Types:** Figma Design only

---

#### get_screenshot

Captures a visual screenshot of the selection.

**Usage:**
```
Select frame in Figma → Call get_screenshot
```

**Returns:**
- PNG image of selection
- Use as validation baseline

**File Types:** Figma Design, FigJam

---

### Code Connect Tools

#### get_code_connect_map

Retrieves mappings between Figma node IDs and code components.

**Usage:**
```
Call get_code_connect_map
```

**Returns:**
```json
{
  "123:456": {
    "codeConnectSrc": "src/components/Button.tsx",
    "codeConnectName": "Button"
  },
  "123:789": {
    "codeConnectSrc": "src/components/Input.tsx",
    "codeConnectName": "Input"
  }
}
```

**Purpose:**
- Identify existing component mappings
- Avoid recreating mapped components
- Ensure design-to-code consistency

**File Types:** Figma Design

---

#### add_code_connect_map

Adds a mapping between a Figma node and a code component.

**Usage:**
```
add_code_connect_map(nodeId, componentInfo)
```

**Parameters:**
- `nodeId`: Figma node ID
- `componentInfo`: Object with `codeConnectSrc` and `codeConnectName`

**Purpose:**
- Improve future design-to-code output
- Build component library mapping
- Enable consistent component reuse

**File Types:** Figma Design

---

### Design System Tools

#### create_design_system_rules

Generates design system rules for your codebase.

**Usage:**
```
Call create_design_system_rules
```

**Returns:**
- Rule file content for agent context
- Tailored to your design system

**Setup:**
Save output to `rules/` or `instructions/` directory in your project.

**Purpose:**
- Translate designs into codebase-aware frontend code
- Establish consistent patterns
- Guide AI code generation

---

### Metadata Tools

#### get_metadata

Retrieves sparse XML metadata for large designs.

**Usage:**
```
Select frames in Figma → Call get_metadata
```

**Returns:**
```xml
<layer id="123:456" name="Card" type="FRAME" x="0" y="0" width="320" height="480">
  <layer id="123:457" name="Title" type="TEXT" x="16" y="16" width="288" height="24"/>
  <layer id="123:458" name="Image" type="RECTANGLE" x="16" y="56" width="288" height="160"/>
</layer>
```

**Use Cases:**
- Large designs where context size is a concern
- Get structure without full styling details
- Support multiple selections

**File Types:** Figma Design

---

### FigJam Tools

#### get_figjam

Retrieves FigJam diagram data.

**Usage:**
```
Open FigJam file → Call get_figjam
```

**Returns:**
- XML metadata
- Basic properties
- Node screenshots

**File Types:** FigJam only

---

### Utility Tools

#### whoami (Remote Server Only)

Returns user information.

**Returns:**
```json
{
  "email": "user@example.com",
  "plans": [
    {
      "planName": "Professional",
      "seatType": "Dev"
    }
  ]
}
```

**Note:** Only available on remote server, not local desktop server.

---

### Alpha/Experimental Tools

#### get_strategy_for_mapping (Alpha, Local Only)

Gets component-to-codebase mapping strategy.

**Status:** Alpha/experimental

**Usage:**
```
Select Figma component → Call get_strategy_for_mapping
```

**Returns:**
- Mapping strategy recommendations
- Component matching suggestions

**File Types:** Figma Design

---

#### send_get_strategy_response (Alpha, Local Only)

Sends response to mapping strategy query.

**Status:** Alpha/experimental

**Usage:**
Follow-up to `get_strategy_for_mapping`

**File Types:** Figma Design

---

## Rate Limits

| Plan Type | Limit |
|-----------|-------|
| Starter | 6 tool calls per month |
| View / Collab seats | 6 tool calls per month |
| Professional / Organization / Enterprise (Dev/Full seat) | Per-minute (Tier 1 API limits) |

### Best Practices for Rate Limiting

1. **Cache Responses**
   - Store `get_design_context` output for repeated access
   - Don't call same selection multiple times

2. **Use Metadata for Large Designs**
   - `get_metadata` provides lighter-weight structure
   - Reduce context size for large files

3. **Batch Related Operations**
   - Get all needed data in single session
   - Plan tool calls before execution

4. **Monitor Usage**
   - Track monthly tool calls
   - Consider upgrading for heavy usage

## Workflow Integration

### Typical Tool Call Sequence

```
1. Select frame in Figma
2. get_design_context → Starting code
3. get_variable_defs → Design tokens
4. get_code_connect_map → Existing components
5. get_screenshot → Validation baseline
```

### Code Connect Workflow

```
1. get_code_connect_map → Check existing mappings
2. If component exists → Use mapped component
3. If new component → Create and add mapping
4. add_code_connect_map → Register new mapping
```

## Troubleshooting

### Server Not Responding

1. Verify Figma Desktop is running
2. Check Dev Mode is enabled (Shift+D)
3. Confirm MCP Server is enabled in inspect panel
4. Test endpoint: `curl http://127.0.0.1:3845/mcp`

### Selection Not Detected

1. Ensure frame is selected (not just layer)
2. Try clicking away and reselecting
3. Refresh Dev Mode toggle

### Rate Limit Exceeded

1. Wait for limit reset (monthly for Starter)
2. Consider upgrading to Dev/Full seat
3. Optimize tool call frequency

## Resources

- [Figma MCP Server Documentation](https://developers.figma.com/docs/figma-mcp-server/)
- [Local Server Setup](https://developers.figma.com/docs/figma-mcp-server/local-server-installation/)
- [Tools and Prompts Reference](https://developers.figma.com/docs/figma-mcp-server/tools-and-prompts/)
- [Figma Help Center Guide](https://help.figma.com/hc/en-us/articles/32132100833559-Guide-to-the-Figma-MCP-server)
