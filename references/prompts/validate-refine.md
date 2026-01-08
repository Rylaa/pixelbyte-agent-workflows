# Phase 4: Validation & Refinement (Hibrit Yaklaşım)

Bu prompt, Playwright pixel karşılaştırma + Claude Vision semantik analiz ile doğrulama yapar.

## Araştırma Bulgusu

| Yöntem | Doğruluk | Kullanım |
|--------|----------|----------|
| Pixel-based (Playwright) | %99+ | Fark tespiti |
| AI Vision (Claude) | %47.8 | Tek başına YETERSİZ |
| **Hibrit** | %99+ | ✅ En iyi sonuç |

## Hibrit Workflow

```
┌─────────────────────────────────────────────────────────┐
│ ADIM 1: Playwright ile screenshot al                    │
│         → rendered.png                                  │
├─────────────────────────────────────────────────────────┤
│ ADIM 2: Figma reference ile GÖRSEL karşılaştır         │
│         → Boyut aynı mı? Benziyor mu?                  │
├─────────────────────────────────────────────────────────┤
│ ADIM 3: Fark varsa → Claude Vision'a SOR               │
│         "Bu iki görsel arasındaki farklar neler?"      │
│         "Kodu nasıl düzeltmeliyim?"                    │
├─────────────────────────────────────────────────────────┤
│ ADIM 4: Claude önerilerine göre DÜZELT                 │
├─────────────────────────────────────────────────────────┤
│ ADIM 5: Tekrar test (maks 3 iterasyon)                 │
└─────────────────────────────────────────────────────────┘
```

## Prompt Template

```markdown
## ROL
Sen bir QA uzmanısın. Üretilen React kodunu Figma tasarımıyla karşılaştırıp düzeltme önerileri sunuyorsun.

## GÖRSELLER

**Görsel 1: Figma Tasarımı (Referans)**
[reference.png - Figma MCP ile indirildi]

**Görsel 2: Üretilen Kod (Rendered)**
[rendered.png - Playwright MCP ile alındı]

## ANALİZ GÖREVİ

Bu iki görseli karşılaştır ve şu soruları cevapla:

### 1. Genel Benzerlik
- İki görsel genel olarak benziyor mu?
- Tahmini uyum yüzdesi nedir? (%0-100)

### 2. Tespit Edilen Farklar
Her fark için:
- **Alan**: Hangi element/bölge? (örn: header, button, card)
- **Sorun**: Ne yanlış? (örn: padding eksik, renk farklı)
- **Düzeltme**: Tailwind class değişikliği (örn: p-4 → p-6)

### 3. Kritik vs Minor Farklar
- **Kritik**: Layout bozuk, renk tamamen yanlış, element eksik
- **Minor**: 1-2px fark, hafif ton farkı

## BEKLENEN ÇIKTI FORMAT

```json
{
  "benzerlik_yuzdesi": 85,
  "durum": "DÜZELTME_GEREKLI",
  "farklar": [
    {
      "alan": "header padding",
      "sorun": "Üst padding yetersiz",
      "mevcut": "pt-4",
      "olmasi_gereken": "pt-8",
      "oncelik": "kritik"
    },
    {
      "alan": "button font",
      "sorun": "Font weight hafif",
      "mevcut": "font-medium",
      "olmasi_gereken": "font-semibold",
      "oncelik": "minor"
    }
  ],
  "duzeltme_talimatlari": [
    "className içindeki pt-4 → pt-8 değiştir",
    "Button'daki font-medium → font-semibold değiştir"
  ]
}
```

## KARAR

Benzerlik yüzdesine göre:
- **>95%**: ✅ BAŞARILI - Faz 5'e geç
- **80-95%**: ⚠️ DÜZELT - Önerileri uygula, tekrar test et
- **<80%**: 🔴 BÜYÜK FARK - Detaylı analiz gerekli
```

## Claude Vision Karşılaştırma Prompt'u

Fark tespit edildiğinde kullanılacak prompt:

```markdown
İki görsel arasındaki farkları analiz et.

**Figma Tasarımı (Hedef):**
[reference.png]

**Kod Çıktısı (Mevcut):**
[rendered.png]

**Sorular:**
1. Görünür farklar neler? (spacing, color, font, layout)
2. Her fark için spesifik Tailwind düzeltmesi ne?
3. Kritik düzeltmeler hangileri?

**Cevap formatı:**
- Kısa ve öz
- Direkt Tailwind class değişiklikleri
- Öncelik sırası
```

## İterasyon Takibi

```
İterasyon 1:
├── Screenshot al
├── Karşılaştır
├── Farklar: [padding, font-weight]
├── Düzelt
└── Sonuç: %78 → Tekrar dene

İterasyon 2:
├── Screenshot al
├── Karşılaştır
├── Farklar: [minor renk farkı]
├── Düzelt
└── Sonuç: %94 → Tekrar dene

İterasyon 3:
├── Screenshot al
├── Karşılaştır
├── Farklar: [yok]
└── Sonuç: %98 → ✅ BAŞARILI
```

## Responsive Doğrulama (Opsiyonel)

Eğer responsive test gerekiyorsa:

```
Viewport'lar:
├── Mobile (375px): reference-mobile.png vs rendered-mobile.png
├── Tablet (768px): reference-tablet.png vs rendered-tablet.png
└── Desktop (1280px): reference-desktop.png vs rendered-desktop.png

Her viewport için ayrı karşılaştırma yap.
```

## Kullanım

1. Playwright MCP ile rendered.png al
2. reference.png ile yan yana göster
3. Bu prompt'u kullanarak Claude'a analiz ettir
4. Düzeltmeleri uygula
5. Tekrar test et (maks 3 iterasyon)
