# Validation Guide

Üretilen kodun pixel-perfect doğruluğunu sağlamak için doğrulama stratejileri.

## Doğrulama Stratejisi

### Hedef Metrikler

- **Piksel farkı:** <%2 (1x ölçekte)
- **Layout sapması:** <2px herhangi bir elemanda
- **Tipografi eşleşmesi:** %100 (font, size, weight, spacing)
- **Renk doğruluğu:** ΔE < 3 (algılanamaz fark)

### 3 Seviyeli Doğrulama

```
Seviye 1: Görsel İnceleme (her zaman)
    ↓
Seviye 2: Checklist Doğrulama (her zaman)
    ↓
Seviye 3: Screenshot Karşılaştırma (kritik tasarımlarda)
```

## Seviye 1: Görsel İnceleme

Kod üretildikten sonra mental olarak kontrol et:

**Layout Kontrolleri:**
- [ ] Elementlerin sırası doğru mu?
- [ ] Hizalamalar (left/center/right) eşleşiyor mu?
- [ ] Spacing tutarlı mı?
- [ ] Container boyutları makul mü?

**Tipografi Kontrolleri:**
- [ ] Font family doğru mu?
- [ ] Font size görsel olarak eşleşiyor mu?
- [ ] Font weight (kalınlık) doğru mu?
- [ ] Line height (satır aralığı) uygun mu?

**Renk Kontrolleri:**
- [ ] Background renkleri doğru mu?
- [ ] Text renkleri eşleşiyor mu?
- [ ] Border renkleri doğru mu?
- [ ] Opacity değerleri uygulanmış mı?

## Seviye 2: Checklist Doğrulama

Her component için bu checklist'i uygula:

### A. Semantik HTML Kontrolü

```
✓ Tıklanabilir elementler <button> veya <a> mı?
✓ Listeler <ul>/<ol> + <li> ile mi yapılmış?
✓ Başlıklar <h1>-<h6> hiyerarşisinde mi?
✓ Navigasyon <nav> içinde mi?
✓ Form elementleri <form> içinde mi?
✓ Görseller <img> ve alt text ile mi?
```

### B. Tailwind Class Kontrolü

```
✓ Hardcoded değerler yerine Tailwind scale kullanılmış mı?
✓ Arbitrary values sadece gerektiğinde mi kullanılmış?
✓ Responsive prefix'ler (sm:, md:, lg:) eklenmiş mi?
✓ Hover/focus state'leri tanımlanmış mı?
```

### C. Erişilebilirlik Kontrolü

```
✓ aria-label gerekli yerlerde var mı?
✓ role attribute'ları eklenmiş mi?
✓ Renk kontrastı yeterli mi? (WCAG AA: 4.5:1)
✓ Focus state görünür mü?
✓ Tab sırası mantıklı mı?
```

### D. Responsive Kontrolü

```
✓ Mobile (320px) görünümü düzgün mü?
✓ Tablet (768px) görünümü düzgün mü?
✓ Desktop (1024px+) görünümü düzgün mü?
✓ Ara boyutlarda kırılma var mı?
```

## Seviye 3: Screenshot Karşılaştırma

### Playwright ile Otomatik Karşılaştırma

```typescript
import { test, expect } from '@playwright/test';

test('component pixel-perfect eşleşmesi', async ({ page }) => {
  // Component'i render et
  await page.goto('http://localhost:3000/preview/component');
  
  // Belirli bir element için screenshot
  const element = page.locator('[data-testid="target-component"]');
  
  await expect(element).toHaveScreenshot('figma-baseline.png', {
    maxDiffPixels: 100,      // Maksimum piksel farkı
    threshold: 0.2,          // Piksel toleransı (0-1)
    animations: 'disabled',  // Animasyonları devre dışı bırak
  });
});
```

### Manuel Screenshot Karşılaştırma

1. **Figma'dan export:**
   - Frame'i seç
   - Export → PNG, 1x scale
   - "figma-reference.png" olarak kaydet

2. **Koddan screenshot:**
   - Component'i tarayıcıda aç
   - DevTools → Device toolbar → Aynı boyut
   - Screenshot al → "code-output.png"

3. **Karşılaştırma:**
   - Görsel diff tool kullan (ImageMagick, Beyond Compare)
   - Veya yan yana manuel karşılaştır

### ImageMagick ile Diff

```bash
# İki görsel arasındaki farkı hesapla
compare -metric AE figma-reference.png code-output.png diff.png

# Sonuç: Farklı piksel sayısı
# Hedef: <100 piksel (320x480 component için)
```

## Self-Refine Döngüsü

### Iterasyon Protokolü

```
Maksimum 3 iterasyon

İterasyon 1:
├── Kodu üret
├── Görsel incele
├── Büyük hataları düzelt (layout, renkler)
└── Devam

İterasyon 2:
├── Detaylı inceleme
├── Spacing/tipografi ince ayar
├── Edge case'leri kontrol et
└── Devam

İterasyon 3:
├── Final polish
├── Erişilebilirlik kontrolü
├── Responsive test
└── Tamamla
```

### Her İterasyonda Sorulacak Sorular

1. **"Bu tasarımla eşleşiyor mu?"**
   - Genel görünüm ve his aynı mı?
   - Belirgin farklılıklar var mı?

2. **"Spacing doğru mu?"**
   - Elementler arası boşluklar eşleşiyor mu?
   - Padding değerleri doğru mu?

3. **"Tipografi tutarlı mı?"**
   - Font boyutları doğru mu?
   - Line height görsel olarak uygun mu?
   - Letter spacing fark edilebilir mi?

4. **"Interaktif state'ler tanımlı mı?"**
   - Hover efektleri var mı?
   - Focus indicator görünür mü?
   - Active/pressed state tanımlı mı?

## Yaygın Doğrulama Hataları

### 1. Line-Height Uyumsuzluğu

**Belirti:** Metin satırları arası boşluk farklı

**Kontrol:**
```
Figma: 24px font, 150% line-height
CSS: line-height: 1.5 ✓
CSS: line-height: 150% ✗ (farklı hesaplama)
```

### 2. Subpixel Rendering

**Belirti:** Kenarlar bulanık veya 1px kayık

**Çözüm:**
- Değerleri tam piksellere yuvarla
- `transform: translateZ(0)` ekle

### 3. Font Rendering Farkları

**Belirti:** Fontlar farklı kalınlıkta görünüyor

**Çözüm:**
- `-webkit-font-smoothing: antialiased`
- Font dosyasının aynı olduğunu doğrula

### 4. Box Model Farkları

**Belirti:** Element boyutları tutmuyor

**Kontrol:**
```css
/* Tailwind varsayılan olarak border-box kullanır */
* { box-sizing: border-box; }
```

## Doğrulama Araçları

| Araç | Kullanım | Kurulum |
|------|----------|---------|
| Playwright | Otomatik screenshot test | `npm install @playwright/test` |
| ImageMagick | Manuel diff | `brew install imagemagick` |
| Chromatic | Storybook visual test | `npm install chromatic` |
| Percy | CI/CD visual test | `npm install @percy/playwright` |

## Quick Validation Checklist

Kod üretildikten sonra hızlı kontrol:

```
□ Layout yapısı korunmuş
□ Spacing değerleri doğru
□ Renkler eşleşiyor
□ Tipografi parametreleri doğru
□ Semantik HTML kullanılmış
□ Responsive davranış var
□ Hover/focus state'ler tanımlı
□ Erişilebilirlik attribute'ları var
```

Her kutuyu işaretle, hepsi ✓ ise kod hazır.
