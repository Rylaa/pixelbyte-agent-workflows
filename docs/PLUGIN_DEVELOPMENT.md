# Claude Code Plugin Development Guide

Bu rehber, pixelbyte-agent-workflows projesi için Claude Code plugin geliştirme kurallarını ve best practice'leri tanımlar.

## Plugin Yapısı

### Dizin Yapısı

```
plugins/
└── plugin-name/
    ├── .claude-plugin/
    │   └── plugin.json          # Plugin manifest (ZORUNLU)
    ├── skills/
    │   └── skill-name/
    │       ├── SKILL.md         # Skill içeriği (ZORUNLU)
    │       └── resources/       # Ek kaynaklar (opsiyonel)
    ├── agents/
    │   └── agent-name.md        # Agent tanımı
    └── hooks/
        └── hooks.json           # Hook tanımları (dikkatli kullan)
```

### plugin.json Formatı

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin açıklaması",
  "author": {
    "name": "Author Name",
    "url": "https://github.com/username"
  },
  "repository": "https://github.com/org/repo",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"]
}
```

**Önemli:** `hooks` alanını plugin.json'a eklemekten kaçının. Hook'lar ayrı `hooks/hooks.json` dosyasında tanımlanmalı.

---

## Skills

Skills, Claude'a domain-spesifik bilgi ve rehberlik sağlayan markdown dosyalarıdır.

### SKILL.md Formatı

```markdown
---
description: Skill'in kısa açıklaması (invocation için kullanılır)
---

# Skill Başlığı

## Overview
Skill'in ne yaptığının açıklaması

## Guidelines
- Kural 1
- Kural 2

## Examples
Örnek kullanımlar
```

### Skill Çağırma

Kullanıcılar skill'leri şu şekillerde çağırabilir:

```bash
# Slash command ile
/skill-name

# Veya doğal dil ile
"Use frontend-dev-guidelines"
```

### Best Practices

- Skill içeriği kısa ve öz olmalı
- Progressive disclosure kullan - temel bilgiler önce
- Kod örnekleri gerçek senaryolardan alınmalı
- Resources klasörünü büyük referanslar için kullan

---

## Agents

Agents, Task tool ile çağrılan otonom subagent'lardır.

### Agent Markdown Formatı

```markdown
---
model: sonnet|opus|haiku
description: "Agent'ın Task tool açıklamasında görünecek metin"
tools:
  - Read
  - Grep
  - Glob
  - WebFetch
---

# Agent System Prompt

Agent'ın davranışını tanımlayan system prompt buraya yazılır.

## Görevler
- Görev 1
- Görev 2

## Output Format
Çıktı formatı açıklaması
```

### Model Seçimi

| Model | Kullanım Alanı |
|-------|----------------|
| `haiku` | Hızlı, basit görevler (varsayılan) |
| `sonnet` | Orta karmaşıklıkta görevler |
| `opus` | Karmaşık reasoning gerektiren görevler |

### Tools Seçimi

Agent'ın erişebileceği tool'ları kısıtlayın:

```yaml
tools:
  - Read      # Dosya okuma
  - Grep      # İçerik arama
  - Glob      # Dosya pattern eşleştirme
  - WebFetch  # Web içeriği çekme
  - WebSearch # Web araması
```

**Önemli:** Agent'lara Write/Edit vermeyin, sadece araştırma yapacaklarsa.

### Agent Çağırma

```
Task(subagent_type="plugin-name:agent-name", prompt="...")
```

---

## Hooks

> **UYARI:** Hook'ları dikkatli kullanın. Yanlış yapılandırılmış hook'lar plugin'in farklı projelerde çalışmamasına neden olur.

### Hook Türleri

#### 1. Prompt-Based Hooks (Önerilen)

LLM tabanlı karar verme için:

```json
{
  "type": "prompt",
  "prompt": "Evaluate if this is appropriate: $TOOL_INPUT",
  "timeout": 30
}
```

#### 2. Pure Bash Hooks

Deterministik kontroller için:

```json
{
  "type": "command",
  "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/validate.sh",
  "timeout": 10
}
```

### YAPMAYIN: TypeScript/Node.js Hook'ları

```bash
# YANLIŞ - Node.js bağımlılığı oluşturur
npx tsx hook.ts

# YANLIŞ - Network gerektirir
npx some-package
```

**Neden sorunlu?**
- Python/Ruby/Go projelerinde Node.js olmayabilir
- CI/CD ortamlarında npm registry'ye erişim olmayabilir
- Corporate firewall'lar npm'i engelleyebilir
- Her prompt'ta network isteği yapılır

### Hook Events

| Event | Tetiklenme Zamanı | Kullanım |
|-------|-------------------|----------|
| `PreToolUse` | Tool çalışmadan önce | Validasyon, engelleme |
| `PostToolUse` | Tool çalıştıktan sonra | Loglama, feedback |
| `UserPromptSubmit` | Kullanıcı prompt gönderince | Context ekleme |
| `Stop` | Agent durduğunda | Tamamlanma kontrolü |
| `SessionStart` | Session başladığında | Context yükleme |

### hooks.json Formatı

```json
{
  "description": "Hook açıklaması",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Validate this file operation: $TOOL_INPUT"
          }
        ]
      }
    ]
  }
}
```

### Best Practices

1. **Hook'suz yapıyı tercih edin** - pb-agents ve pb-figma gibi
2. **Prompt-based hook kullanın** - Bash script yerine
3. **State dosyası oluşturmayın** - Hedef projede kirlilik yaratır
4. **Timeout'ları düşük tutun** - 10-30 saniye max
5. **Her zaman exit 0** - Hook hataları Claude'u engellememeli

---

## MCP Entegrasyonu

Plugin'ler MCP server'ları yapılandırabilir.

### .mcp.json Formatı

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "package-name"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

### Environment Variables

```json
{
  "env": {
    "TOKEN": "${FIGMA_PERSONAL_ACCESS_TOKEN}"
  }
}
```

Kullanıcının shell'inde tanımlı env var'ları `${VAR_NAME}` syntax'ı ile kullanılır.

---

## Marketplace

### marketplace.json Formatı

```json
{
  "name": "marketplace-name",
  "description": "Marketplace açıklaması",
  "owner": {
    "name": "Owner Name",
    "url": "https://github.com/owner"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "description": "Plugin açıklaması",
      "version": "1.0.0",
      "author": {
        "name": "Author",
        "url": "https://github.com/author"
      },
      "source": "./plugins/plugin-name",
      "category": "design|development|quality"
    }
  ]
}
```

### Plugin Kurulumu

```bash
# Marketplace'i settings'e ekle
# .claude/settings.json
{
  "extraKnownMarketplaces": [
    "https://github.com/org/repo"
  ]
}

# Plugin'i kur
claude plugin install plugin-name
```

---

## Best Practices

### 1. Portable Plugin Yazma

```
✅ DO:
- Pure markdown skills kullan
- Prompt-based hooks kullan (gerekirse)
- ${CLAUDE_PLUGIN_ROOT} ile relative path kullan
- Her plugin bağımsız çalışabilmeli

❌ DON'T:
- npx tsx veya Node.js bağımlılığı ekleme
- State dosyası oluşturma (hedef projede)
- Network gerektiren hook yazma
- Hardcoded path kullanma
```

### 2. Plugin Yapısı Örnekleri

**Minimal Plugin (Önerilen):**
```
plugin/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── skill-name/
        └── SKILL.md
```

**Agent İçeren Plugin:**
```
plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── skill-name/
│       └── SKILL.md
└── agents/
    └── agent-name.md
```

**MCP İçeren Plugin:**
```
plugin/
├── .claude-plugin/
│   ├── plugin.json
│   └── .mcp.json
└── skills/
    └── skill-name/
        └── SKILL.md
```

### 3. Version Yönetimi

- Semantic versioning kullan (MAJOR.MINOR.PATCH)
- Breaking change'lerde MAJOR artır
- marketplace.json ve plugin.json versiyonlarını senkronize tut

### 4. Test Etme

```bash
# Plugin'i test projede kur
cd /test/project
claude plugin install /path/to/plugin

# Skill'i test et
claude
> /skill-name

# Agent'ı test et
> Use Task tool with subagent_type="plugin:agent"
```

---

## Referans: Bu Projedeki Plugin'ler

| Plugin | Yapı | Hook | MCP |
|--------|------|------|-----|
| pb-figma | Skills + MCP | Yok | Var |
| pb-frontend | Skills | Yok | Yok |
| pb-agents | Agents | Yok | Yok |

Bu yapılar portable ve her projede çalışır.

---

## Sorun Giderme

### Plugin yüklenmiyor

1. plugin.json syntax'ını kontrol et
2. `claude --debug` ile hata mesajlarını gör
3. Dosya izinlerini kontrol et

### Skill çalışmıyor

1. SKILL.md frontmatter'ı kontrol et
2. Description alanının dolu olduğundan emin ol
3. `/skill-name` ile direkt çağırmayı dene

### Hook çalışmıyor

1. hooks.json syntax'ını kontrol et
2. Bash script'in çalıştırılabilir olduğundan emin ol
3. `${CLAUDE_PLUGIN_ROOT}` kullanıldığından emin ol
4. Claude Code'u yeniden başlat (hook'lar session start'ta yüklenir)
