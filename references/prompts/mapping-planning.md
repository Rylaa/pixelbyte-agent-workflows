# Phase 2: Mapping & Planning Prompt

Bu prompt, tasarım verisini analiz ettikten sonra kod yazmadan ÖNCE planlama yapmak için kullanılır.

## Prompt Template

```markdown
## ROL
Sen bir mimari planlama uzmanısın. Figma tasarım verisini inceleyip, kod üretimi için optimal strateji belirliyorsun.

## TASARIM ANALİZİ
[Faz 1'den gelen analiz çıktısını buraya ekle]

## PROJE ORTAMI

### Mevcut Bileşenler
[src/components/ içeriğini listele]

### Tailwind Konfigürasyonu
[tailwind.config.js'den tema bilgisi]

### Kullanılan Kütüphaneler
[package.json'dan ilgili dependencies]

## PLANLAMA GÖREVLERİ

### 1. Mevcut Bileşen Eşleştirmesi

Figma'daki her element için mevcut bileşen kontrolü yap:

```
Figma Node: "Primary Button"
├── Mevcut bileşen var mı? → src/components/Button.tsx ✓
├── Props eşleşiyor mu? → variant="primary" ✓
└── Karar: KULLAN (yeniden oluşturma)

Figma Node: "Hero Card"
├── Mevcut bileşen var mı? → ✗
├── Benzer bileşen var mı? → src/components/Card.tsx (kısmen)
└── Karar: YENİ OLUŞTUR (Card'ı extend et)
```

### 2. Token Eşleştirme Tablosu

```json
{
  "colors": {
    "VariableID:123": {
      "figmaName": "colors/primary",
      "tailwindClass": "bg-primary",
      "fallback": "bg-blue-600",
      "status": "matched"
    },
    "VariableID:456": {
      "figmaName": "colors/accent",
      "tailwindClass": null,
      "fallback": "bg-amber-500",
      "status": "TODO"
    }
  },
  "spacing": {
    "16px": "4",
    "24px": "6",
    "32px": "8"
  },
  "typography": {
    "Heading/H1": "text-4xl font-bold",
    "Body/Regular": "text-base font-normal"
  }
}
```

### 3. Layout Stratejisi

```
Root Container:
├── Layout: flex-col (VERTICAL)
├── Responsive: md:flex-row (>768px'de yatay)
├── Gap: gap-6 (24px)
└── Padding: p-8 (32px)

Child Elements:
├── Image: w-full md:w-1/2 (responsive width)
├── Content: flex-1 (fill remaining)
└── Button: w-full md:w-auto (responsive)
```

### 4. Responsive Planlama

```
Mobile First Yaklaşım:

Base (320px+):
- flex-col
- w-full
- text-center
- p-4

sm (640px+):
- p-6

md (768px+):
- flex-row
- text-left
- p-8

lg (1024px+):
- max-w-6xl mx-auto
```

### 5. Erişilebilirlik Planı

```
Semantik Etiketler:
├── "Card Container" → <article>
├── "Title" → <h2>
├── "Description" → <p>
├── "CTA Button" → <button> veya <a>
└── "Image" → <img alt="...">

ARIA Gereksinimleri:
├── İkon butonlar → aria-label
├── Dekoratif görseller → aria-hidden="true"
└── Form elemanları → label bağlantısı
```

## ÇIKTI FORMATI

```json
{
  "componentPlan": {
    "name": "HeroCard",
    "type": "new",
    "extendsFrom": null,
    "dependencies": ["Button", "Badge"]
  },
  "reusedComponents": [
    {
      "figmaNode": "Primary Button",
      "componentPath": "src/components/Button.tsx",
      "props": {
        "variant": "primary",
        "size": "lg"
      }
    }
  ],
  "newComponents": [
    {
      "name": "HeroCard",
      "semanticTag": "article",
      "layout": "flex-col md:flex-row"
    }
  ],
  "tokenMappings": {
    "matched": 12,
    "fallback": 3,
    "todo": 1
  },
  "responsiveBreakpoints": ["base", "md", "lg"],
  "accessibilityNotes": [
    "Image alt text gerekli",
    "Button focus ring ekle"
  ]
}
```

## ÇIKTI

Planlama çıktısını JSON formatında ver.
Faz 3'te bu plan takip edilerek kod üretilecek.

## KRİTİK KURALLAR

1. **Asla mevcut bileşeni yeniden oluşturma** — Import et ve kullan
2. **Token bulunamazsa TODO işaretle** — Fallback kullan, yorum ekle
3. **Responsive planı mobile-first yap** — Base stiller mobile için
4. **Semantik HTML planla** — div son çare
```

## Kullanım

1. Faz 1'den analiz çıktısını al
2. Proje ortamını incele (components, config)
3. Bu prompt'a ekle
4. Planlama çıktısını al
5. Faz 3'e (kod üretimi) geç
