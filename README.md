# Figma-to-Code Skill

A Claude Code skill for pixel-perfect Figma design conversion. Converts Figma designs to React/Next.js/Tailwind code using the official Figma MCP Server (Local Desktop).

![Figma to Code](https://img.shields.io/badge/Figma-to-Code-blue?style=flat-square&logo=figma)
![Claude Code](https://img.shields.io/badge/Claude-Code-orange?style=flat-square)
![React](https://img.shields.io/badge/React-19-61DAFB?style=flat-square&logo=react)
![Tailwind](https://img.shields.io/badge/Tailwind-v4-38B2AC?style=flat-square&logo=tailwindcss)

## ✨ Features

- 🎨 **Pixel-Perfect Conversion** - 85%+ accuracy target
- 🔗 **Code Connect Support** - Automatic mapping with existing components
- 🎯 **Design Token Extraction** - Colors, spacing, typography
- 🖼️ **Visual Validation** - Hybrid validation with Playwright MCP
- 📱 **Responsive Code** - Mobile-first approach
- ♿ **WCAG 2.1 AA** - Accessibility compliance

## 📋 Requirements

- **Figma Desktop App** (latest version)
- **Claude Code** with MCP support
- **Figma MCP Plugin** (figma-desktop)
- **Playwright MCP** (for visual validation)
- **Node.js** >= 18

## 🚀 Installation

### 1. Figma Desktop MCP Server

In Figma Desktop App:
1. Enable Dev Mode (`Shift+D`)
2. Enable MCP Server in the inspect panel
3. Server will run at `http://127.0.0.1:3845/mcp`

### 2. Claude Code MCP Configuration

```json
{
  "mcpServers": {
    "figma-desktop": {
      "url": "http://127.0.0.1:3845/mcp"
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp"]
    }
  }
}
```

### 3. Install the Skill

```bash
# Copy skill directory to ~/.claude/skills/
cp -r figma-to-code-skill ~/.claude/skills/
```

## 📖 How It Works

### 5-Phase Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    FIGMA-TO-CODE WORKFLOW                        │
└─────────────────────────────────────────────────────────────────┘

     ┌──────────────┐
     │   PHASE 1    │  Context Acquisition
     │ Data Gather  │
     └──────┬───────┘
            │
            ▼
    ┌───────────────────────────────────────┐
    │ 1. get_design_context                 │
    │    → React + Tailwind code            │
    │                                       │
    │ 2. get_variable_defs                  │
    │    → Design tokens                    │
    │                                       │
    │ 3. get_code_connect_map               │
    │    → Component mappings               │
    │                                       │
    │ 4. get_screenshot                     │
    │    → Visual reference                 │
    │                                       │
    │ 5. Read existing codebase             │
    │    → Existing components              │
    └───────────────┬───────────────────────┘
                    │
                    ▼
     ┌──────────────┐
     │   PHASE 2    │  Mapping & Planning
     │   Planning   │
     └──────┬───────┘
            │
            ▼
    ┌───────────────────────────────────────┐
    │ • Check Code Connect mappings         │
    │ • If component exists → use it        │
    │ • If not → plan new component         │
    │ • Create token mapping                │
    │ • Define responsive strategy          │
    └───────────────┬───────────────────────┘
                    │
                    ▼
     ┌──────────────┐
     │   PHASE 3    │  Code Generation
     │  Generation  │
     └──────┬───────┘
            │
            ▼
    ┌───────────────────────────────────────┐
    │ • Use get_design_context output       │
    │   as starting point                   │
    │ • Integrate design tokens             │
    │ • Apply semantic HTML                 │
    │ • Optimize Tailwind classes           │
    │ • Add TypeScript types                │
    └───────────────┬───────────────────────┘
                    │
                    ▼
     ┌──────────────┐
     │   PHASE 4    │  Visual Validation
     │  Validation  │◄────────┐
     └──────┬───────┘         │
            │                 │ Max 3
            ▼                 │ iterations
    ┌───────────────────────────────────────┐
    │ HYBRID VALIDATION:                    │
    │                                       │
    │ 1. Take Playwright screenshot         │
    │ 2. Compare with Figma reference       │
    │ 3. Diff < 2% → ✅ Success             │
    │ 4. Diff > 2% → Claude Vision analyze  │
    │ 5. Auto-fix → re-test                 │
    └───────────────┬───────────────────────┘
                    │
                    ▼
     ┌──────────────┐
     │   PHASE 5    │  Handoff
     │   Delivery   │
     └──────┬───────┘
            │
            ▼
    ┌───────────────────────────────────────┐
    │ • Generate final report               │
    │ • Report accuracy percentage          │
    │ • List used components                │
    │ • Document TODOs                      │
    │ • Provide usage example               │
    └───────────────────────────────────────┘
```

## 🔧 MCP Tools Used

### Figma MCP (figma-desktop)

| Tool | Purpose |
|------|---------|
| `get_design_context` | React + Tailwind code generation |
| `get_variable_defs` | Design tokens (colors, spacing, typography) |
| `get_code_connect_map` | Component mappings |
| `get_screenshot` | Visual reference |
| `add_code_connect_map` | Add new component mapping |

### Playwright MCP

| Tool | Purpose |
|------|---------|
| `browser_navigate` | Navigate to preview page |
| `browser_take_screenshot` | Capture rendered component |
| `browser_evaluate` | Execute JavaScript |

## 📁 Skill Structure

```
figma-to-code-skill/
├── SKILL.md                    # Main skill file
├── README.md                   # This file
├── assets/
│   ├── examples/
│   │   └── card-component.md   # Example component
│   └── templates/
│       └── component.tsx.hbs   # React template
└── references/
    ├── figma-mcp-server.md     # MCP tool reference
    ├── visual-validation-loop.md
    ├── token-mapping.md        # Conversion formulas
    ├── validation-guide.md
    ├── common-issues.md        # Common issues
    ├── preview-setup.md
    ├── ci-cd-integration.md
    ├── storybook-integration.md
    ├── testing-strategy.md
    └── prompts/
        ├── analyze-design.md
        ├── mapping-planning.md
        ├── generate-component.md
        ├── validate-refine.md
        └── handoff.md
```

## 💡 Usage

### Basic Usage

1. Select a frame in Figma
2. Trigger the skill in Claude Code:

```
/figma-to-code-skill
```

Or with a Figma URL:

```
Convert this design to code: https://www.figma.com/design/xxx/MyDesign?node-id=123-456
```

### Example Output

```markdown
## ✅ Conversion Complete

**Component:** HeroCard.tsx
**Accuracy:** 98.5% pixel match
**Iterations:** 2

### Code Connect Components Used:
- Button (src/components/ui/button.tsx)
- Badge (src/components/ui/badge.tsx)

### Design Tokens Applied:
- colors/primary → var(--color-primary)
- spacing/lg → var(--spacing-lg)

### Files Created:
- src/features/hero/components/HeroCard.tsx
```

## ⚙️ Configuration

### Rate Limits

| Plan | Limit |
|------|-------|
| Starter | 6 tool calls/month |
| Professional+ | Per-minute (Tier 1) |

### Recommended Settings

```json
{
  "figma-desktop": {
    "url": "http://127.0.0.1:3845/mcp"
  }
}
```

## 🐛 Troubleshooting

### Server Connection Error

```bash
# Check server status
curl http://127.0.0.1:3845/mcp
```

**Solution:**
1. Is Figma Desktop open?
2. Is Dev Mode active? (Shift+D)
3. Is MCP Server enabled?

### Selection Not Detected

**Solution:**
- Make sure a frame is selected (not just a layer)
- Refresh Dev Mode toggle

### Rate Limit Exceeded

**Solution:**
- Wait for monthly limit reset (Starter)
- Upgrade to Professional plan

## 📚 References

- [Figma MCP Server Docs](https://developers.figma.com/docs/figma-mcp-server/)
- [Local Server Setup](https://developers.figma.com/docs/figma-mcp-server/local-server-installation/)
- [Claude Code Skills](https://docs.anthropic.com/claude-code/skills)

## 📄 License

MIT License

## 🤝 Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

**Made with ❤️ for Claude Code**
