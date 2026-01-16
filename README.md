# Pixelbyte Agent Workflows

Claude Code plugin containing specialized agents for code review and compliance checking.

## Installation

Add to your `.claude/settings.json`:

```json
{
  "plugins": [
    "https://github.com/Rylaa/pixelbyte-agent-workflows"
  ]
}
```

## Agents

### prompt-compliance-checker

Validates that implementation matches the original prompt/request.

**Checks:**
- Does implementation match prompt requirements?
- Is existing functionality preserved?
- Are there any logical or technical errors?

**Usage:**
```
@pixelbyte-agent-workflows:prompt-compliance-checker
```

Or via Task tool:
```
Task(subagent_type="pixelbyte-agent-workflows:prompt-compliance-checker", prompt="Review my changes against the original prompt")
```

**Triggers:**
- "review et", "kontrol et"
- "prompt'a uyumlu mu?"
- "implementasyon doğru mu?"

## License

MIT
