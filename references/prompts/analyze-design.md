# Phase 1: Design Analysis Prompt

Bu prompt, Figma tasarım verisini analiz etmek için kullanılır.

## Prompt Template

```markdown
## ROL
Sen bir Figma tasarım analisti olarak görev yapıyorsun. Verilen tasarım verisini analiz edip kod üretimi için gerekli bilgileri çıkaracaksın.

## TASARIM VERİSİ
[get_design_context yanıtını buraya ekle]

## ANALİZ GÖREVLERİ

### 1. Bileşen Hiyerarşisi
Tasarımdaki tüm elementleri listele:
- Root container özellikleri
- Children elementleri ve tipleri (FRAME, TEXT, RECTANGLE, vb.)
- İç içe geçme derinliği

### 2. Layout Analizi
Auto Layout bilgilerini çıkar:
- layoutMode: VERTICAL veya HORIZONTAL
- itemSpacing (gap değeri)
- padding değerleri (top, bottom, left, right)
- primaryAxisAlignItems (justify-content)
- counterAxisAlignItems (align-items)

### 3. Design Token'lar

**Renkler:**
- Her fill için: RGB değerleri → Hex dönüşümü
- Opacity değerleri
- Gradient varsa: yön ve stop'lar

**Tipografi:**
- fontFamily
- fontSize (px)
- fontWeight
- lineHeightPercent (%)
- letterSpacing

**Efektler:**
- Shadow: offset, radius, spread, color
- Border: width, color, radius

### 4. Semantik Analiz
Her element için uygun HTML tag'i belirle:
- Tıklanabilir görünen → button veya a
- Metin listesi → ul/li
- Başlık görünen → h1-h6
- Görsel → img
- Input alanı → input/textarea

### 5. Responsive İpuçları
- Sabit genişlikler vs. esnek genişlikler
- Minimum/maksimum boyutlar
- Breakpoint önerileri

## ÇIKTI FORMATI

```json
{
  "componentName": "...",
  "rootLayout": {
    "direction": "flex-col | flex-row",
    "gap": "gap-X",
    "padding": "p-X | px-X py-X",
    "justify": "justify-X",
    "align": "items-X"
  },
  "tokens": {
    "colors": {
      "background": "#XXXXXX",
      "text": "#XXXXXX",
      ...
    },
    "typography": {
      "heading": {
        "size": "text-X",
        "weight": "font-X",
        "lineHeight": "leading-X",
        "tracking": "tracking-X"
      },
      ...
    },
    "spacing": {
      "gap": "X",
      "padding": "X"
    },
    "effects": {
      "shadow": "shadow-X | shadow-[...]",
      "borderRadius": "rounded-X"
    }
  },
  "elements": [
    {
      "name": "...",
      "figmaType": "TEXT | FRAME | ...",
      "htmlTag": "h1 | p | button | ...",
      "content": "...",
      "styles": "..."
    }
  ],
  "responsive": {
    "fixedWidth": true | false,
    "suggestedBreakpoints": ["sm", "md", "lg"]
  }
}
```
```

## Kullanım

1. `get_design_context` çağır
2. Yanıtı bu prompt'a ekle
3. Analiz çıktısını al
4. Faz 2'ye (kod üretimi) geç
