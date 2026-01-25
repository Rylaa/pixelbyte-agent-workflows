# PB Workflows

Claude Code plugin collection with modular installation. Install only what you need.

## Installation

Add the marketplace to your `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": [
    "https://github.com/Rylaa/pixelbyte-agent-workflows"
  ]
}
```

Then install individual plugins:

```bash
# Install all plugins
claude plugin install pb-figma
claude plugin install pb-frontend
claude plugin install pb-agents

# Or install only what you need
claude plugin install pb-figma  # Just Figma-to-code
```

## Available Plugins

| Plugin | Description | Category |
|--------|-------------|----------|
| `pb-figma` | Figma-to-code conversion with pixel-perfect accuracy | Design |
| `pb-frontend` | Senior-level frontend development guidelines | Development |
| `pb-agents` | Prompt compliance checker and component documentation agents | Quality |

---

## pb-figma

Converts Figma designs to pixel-perfect code for multiple frameworks using a 5-phase workflow with 85%+ accuracy target.

### Requirements

Set up a Figma Personal Access Token:

```bash
export FIGMA_PERSONAL_ACCESS_TOKEN="your-token-here"
```

Get your token: Figma → Settings → Personal Access Tokens

### Supported Frameworks

pb-figma supports multiple frontend frameworks with specialized agents:

- **React + TypeScript + Tailwind** - Production-ready React components with modern patterns
- **SwiftUI** - Native iOS/macOS components with accessibility and MARK organization
- **Vue 3** - Coming soon (v1.2.0)
- **Kotlin Compose** - Coming soon (v1.2.0)

Framework detection is automatic based on project structure.

### Features

- **Multi-framework support** - React, SwiftUI, Vue, Kotlin (framework auto-detection)
- **Framework-specific best practices** - Each agent follows platform conventions
- Figma design extraction via Pixelbyte Figma MCP
- Design token mapping (colors, typography, spacing)
- Code Connect support for component mapping
- Visual validation via Claude in Chrome MCP
- Automatic QA with iterative refinement

### 5-Phase Workflow

1. **Context Acquisition** - Extract design structure, tokens, and screenshots
2. **Mapping & Planning** - Map Figma components to codebase components
3. **Code Generation** - Generate framework-specific code (React/SwiftUI/Vue/Kotlin)
4. **Visual Validation** - Compare implementation with Figma using Claude Vision
5. **Handoff** - Final documentation and TODO items

### Framework Documentation

| Framework | Agent | Status | Documentation |
|-----------|-------|--------|---------------|
| React + Tailwind | `code-generator-react` | ✅ Production | Auto-invoked for .tsx/.jsx projects |
| SwiftUI | `code-generator-swiftui` | ✅ Production | Auto-invoked for .swift projects |
| Vue 3 | `code-generator-vue` | 🚧 Coming v1.2.0 | Planned |
| Kotlin Compose | `code-generator-kotlin` | 🚧 Coming v1.2.0 | Planned |

### Usage

Provide a Figma URL or mention "figma-to-code", "convert Figma", "implement design".

**Examples:**
- "Convert this Figma design to React: [URL]"
- "Generate SwiftUI code from this Figma component: [URL]"

Framework is detected automatically based on project file extensions.

### MCP Server

Automatically configures `pixelbyte-figma-mcp` with these tools:
- `figma_get_file_structure` - Get file/node hierarchy
- `figma_get_node_details` - Get detailed node info
- `figma_generate_code` - Generate code from node
- `figma_get_design_tokens` - Extract design tokens
- `figma_get_screenshot` - Capture visual reference
- `figma_get_code_connect_map` - Get component mappings

---

## pb-frontend

Senior-level frontend development guidelines for React/TypeScript applications.

### Features

- Modern React patterns (Suspense, lazy loading, useSWR)
- TypeScript best practices
- Next.js App Router conventions
- shadcn/ui + Tailwind CSS styling
- Performance optimization techniques
- Security and error handling
- Testing strategies

### Topics Covered

- Component patterns with `React.FC<Props>`
- Data fetching with `useSWR` and `suspense: true`
- File organization with features directory
- Accessibility (WCAG 2.1 AA)
- Browser compatibility (Safari focus)
- Advanced TypeScript patterns

### Usage

Automatically invoked when creating components, pages, or features. Mention "frontend guidelines", "React patterns", or "TypeScript best practices".

---

## pb-agents

Pixelbyte agent collection for specialized development workflows.

### Available Agents

**prompt-compliance-checker**
- Validates implementation matches original prompt/request
- Detects regressions and logical errors
- Evidence-based feedback with file paths and line numbers

**component-documentation**
- Generates comprehensive technical documentation for React/TypeScript components
- Analyzes import trees recursively (max 3 levels)
- Maps state & data flow, detects API endpoints

### Usage

Via Task tool:
```
Task(subagent_type="pb-agents:prompt-compliance-checker", prompt="Review my changes against the original prompt")
Task(subagent_type="pb-agents:component-documentation", prompt="Document the UserProfile component")
```

Or ask: "Check if my changes match what was requested" or "Document this component"

---

## License

MIT
