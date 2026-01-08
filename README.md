# Figma-to-Code Skill

Pixel-perfect Figma tasarım dönüşümü için Claude Code skill'i. Resmi Figma MCP Server (Local Desktop) kullanarak Figma tasarımlarını React/Next.js/Tailwind koduna dönüştürür.

![Figma to Code](https://img.shields.io/badge/Figma-to-Code-blue?style=flat-square&logo=figma)
![Claude Code](https://img.shields.io/badge/Claude-Code-orange?style=flat-square)
![React](https://img.shields.io/badge/React-19-61DAFB?style=flat-square&logo=react)
![Tailwind](https://img.shields.io/badge/Tailwind-v4-38B2AC?style=flat-square&logo=tailwindcss)

## ✨ Özellikler

- 🎨 **Pixel-Perfect Dönüşüm** - %85+ doğruluk hedefi
- 🔗 **Code Connect Desteği** - Mevcut component'larla otomatik eşleştirme
- 🎯 **Design Token Çıkarma** - Colors, spacing, typography
- 🖼️ **Görsel Doğrulama** - Playwright MCP ile hibrit validation
- 📱 **Responsive Kod** - Mobile-first yaklaşım
- ♿ **WCAG 2.1 AA** - Erişilebilirlik standartları

## 📋 Gereksinimler

- **Figma Desktop App** (güncel versiyon)
- **Claude Code** with MCP support
- **Figma MCP Plugin** (figma-desktop)
- **Playwright MCP** (görsel doğrulama için)
- **Node.js** >= 18

## 🚀 Kurulum

### 1. Figma Desktop MCP Server

Figma Desktop App'te:
1. Dev Mode'u aktif et (`Shift+D`)
2. Inspect panel'den MCP Server'ı enable et
3. Server `http://127.0.0.1:3845/mcp` adresinde çalışacak

### 2. Claude Code MCP Konfigürasyonu

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

### 3. Skill'i Yükle

```bash
# Skill dizinini ~/.claude/skills/ altına kopyala
cp -r figma-to-code-skill ~/.claude/skills/
```

## 📖 Nasıl Çalışır?

### 5 Fazlı Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    FIGMA-TO-CODE WORKFLOW                        │
└─────────────────────────────────────────────────────────────────┘

     ┌──────────────┐
     │   PHASE 1    │  Context Acquisition
     │  Veri Toplama │
     └──────┬───────┘
            │
            ▼
    ┌───────────────────────────────────────┐
    │ 1. get_design_context                 │
    │    → React + Tailwind kod             │
    │                                       │
    │ 2. get_variable_defs                  │
    │    → Design tokens                    │
    │                                       │
    │ 3. get_code_connect_map               │
    │    → Component mappings               │
    │                                       │
    │ 4. get_screenshot                     │
    │    → Görsel referans                  │
    │                                       │
    │ 5. Read mevcut codebase               │
    │    → Existing components              │
    └───────────────┬───────────────────────┘
                    │
                    ▼
     ┌──────────────┐
     │   PHASE 2    │  Mapping & Planning
     │   Planlama   │
     └──────┬───────┘
            │
            ▼
    ┌───────────────────────────────────────┐
    │ • Code Connect eşleştirmelerini       │
    │   kontrol et                          │
    │ • Mevcut component varsa → kullan     │
    │ • Yoksa → yeni component planla       │
    │ • Token mapping oluştur               │
    │ • Responsive strateji belirle         │
    └───────────────┬───────────────────────┘
                    │
                    ▼
     ┌──────────────┐
     │   PHASE 3    │  Code Generation
     │  Kod Üretimi │
     └──────┬───────┘
            │
            ▼
    ┌───────────────────────────────────────┐
    │ • get_design_context çıktısını        │
    │   başlangıç noktası olarak kullan     │
    │ • Design token'ları entegre et        │
    │ • Semantic HTML uygula                │
    │ • Tailwind classes optimize et        │
    │ • TypeScript types ekle               │
    └───────────────┬───────────────────────┘
                    │
                    ▼
     ┌──────────────┐
     │   PHASE 4    │  Visual Validation
     │  Doğrulama   │◄────────┐
     └──────┬───────┘         │
            │                 │ Max 3
            ▼                 │ iterasyon
    ┌───────────────────────────────────────┐
    │ HYBRID VALIDATION:                    │
    │                                       │
    │ 1. Playwright screenshot al           │
    │ 2. Figma referansı ile karşılaştır    │
    │ 3. Fark < 2% → ✅ Başarılı            │
    │ 4. Fark > 2% → Claude Vision analiz   │
    │ 5. Otomatik düzeltme → tekrar test    │
    └───────────────┬───────────────────────┘
                    │
                    ▼
     ┌──────────────┐
     │   PHASE 5    │  Handoff
     │    Teslim    │
     └──────┬───────┘
            │
            ▼
    ┌───────────────────────────────────────┐
    │ • Final rapor oluştur                 │
    │ • Doğruluk yüzdesini belirt           │
    │ • Kullanılan component'ları listele   │
    │ • TODO'ları dokümante et              │
    │ • Kullanım örneği ver                 │
    └───────────────────────────────────────┘
```

## 🔧 Kullanılan MCP Araçları

### Figma MCP (figma-desktop)

| Araç | Amaç |
|------|------|
| `get_design_context` | React + Tailwind kod üretimi |
| `get_variable_defs` | Design tokens (colors, spacing, typography) |
| `get_code_connect_map` | Component mapping'leri |
| `get_screenshot` | Görsel referans |
| `add_code_connect_map` | Yeni component mapping ekle |

### Playwright MCP

| Araç | Amaç |
|------|------|
| `playwright_navigate` | Preview sayfasına git |
| `playwright_screenshot` | Rendered component screenshot |
| `playwright_evaluate` | CSS değerlerini oku |

## 📁 Skill Yapısı

```
figma-to-code-skill/
├── SKILL.md                    # Ana skill dosyası
├── README.md                   # Bu dosya
├── assets/
│   ├── examples/
│   │   └── card-component.md   # Örnek component
│   └── templates/
│       └── component.tsx.hbs   # React template
└── references/
    ├── figma-mcp-server.md     # MCP araç referansı
    ├── visual-validation-loop.md
    ├── token-mapping.md        # Dönüşüm formülleri
    ├── validation-guide.md
    ├── common-issues.md        # Sık sorunlar
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

## 💡 Kullanım

### Temel Kullanım

1. Figma'da bir frame seç
2. Claude Code'da skill'i tetikle:

```
/figma-to-code-skill
```

veya direkt Figma URL'si ile:

```
Bu tasarımı koda dönüştür: https://www.figma.com/design/xxx/MyDesign?node-id=123-456
```

### Örnek Çıktı

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

## ⚙️ Konfigürasyon

### Rate Limits

| Plan | Limit |
|------|-------|
| Starter | 6 tool calls/ay |
| Professional+ | Per-minute (Tier 1) |

### Önerilen Ayarlar

```json
{
  "figma-desktop": {
    "url": "http://127.0.0.1:3845/mcp"
  }
}
```

## 🐛 Troubleshooting

### Server Bağlantı Hatası

```bash
# Server durumunu kontrol et
curl http://127.0.0.1:3845/mcp
```

**Çözüm:**
1. Figma Desktop açık mı?
2. Dev Mode aktif mi? (Shift+D)
3. MCP Server enabled mı?

### Selection Algılanmıyor

**Çözüm:**
- Frame seçildiğinden emin ol (layer değil)
- Dev Mode'u refresh et

### Rate Limit Aşıldı

**Çözüm:**
- Monthly limit'i bekle (Starter)
- Professional plana yükselt

## 📚 Referanslar

- [Figma MCP Server Docs](https://developers.figma.com/docs/figma-mcp-server/)
- [Local Server Setup](https://developers.figma.com/docs/figma-mcp-server/local-server-installation/)
- [Claude Code Skills](https://docs.anthropic.com/claude-code/skills)

## 📄 Lisans

MIT License

## 🤝 Katkıda Bulunma

1. Fork et
2. Feature branch oluştur (`git checkout -b feature/amazing-feature`)
3. Commit et (`git commit -m 'feat: Add amazing feature'`)
4. Push et (`git push origin feature/amazing-feature`)
5. Pull Request aç

---

**Made with ❤️ for Claude Code**
