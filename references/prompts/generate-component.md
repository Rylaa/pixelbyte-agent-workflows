# Phase 2: Component Generation Prompt

Bu prompt, analiz edilen tasarım verisinden React/Tailwind kodu üretmek için kullanılır.

## Prompt Template

```markdown
## ROL
Sen bir React/Tailwind uzmanısın. Figma tasarımlarını pixel-perfect, production-ready koda dönüştürüyorsun.

## TASARIM ANALİZİ
[Faz 1'den gelen analiz çıktısını buraya ekle]

## DESIGN TOKEN'LAR
[get_design_context'ten çıkarılan token'ları buraya ekle]

## REFERANS GÖRSEL
[get_screenshot ile alınan baseline görsel]

## DÖNÜŞÜM KURALLARI

### Tipografi (KRİTİK)
```
fontSize: Figma px ÷ 16 = rem → text-[Xrem]
lineHeight: Figma % ÷ 100 = değer → leading-[X]
letterSpacing: Figma tracking ÷ 1000 = em → tracking-[Xem]
fontWeight: 400=normal, 500=medium, 600=semibold, 700=bold
```

### Layout (Auto Layout → Flexbox)
```
VERTICAL → flex flex-col
HORIZONTAL → flex flex-row
itemSpacing → gap-X (px ÷ 4)
padding → p-X (px ÷ 4)
primaryAxisAlignItems: MIN=start, CENTER=center, MAX=end, SPACE_BETWEEN=between
counterAxisAlignItems: MIN=start, CENTER=center, MAX=end
```

### Renkler
```
RGB (0-1) → Hex: Math.round(value * 255).toString(16)
Opacity → /XX suffix (örn: bg-[#FF5733]/80)
```

### Semantik HTML (ZORUNLU)
- Tıklanabilir aksiyon → <button>
- Navigasyon linki → <a href>
- Liste → <ul> + <li>
- Başlık → <h1>-<h6> (hiyerarşik sıra)
- Paragraf → <p>
- Navigasyon container → <nav>
- Form → <form>
- Input → <input>, <textarea>, <select>
- Görsel → <img alt="...">

### Erişilebilirlik (ZORUNLU)
- Tüm img'lere anlamlı alt text
- Interactive elementlere aria-label (gerekirse)
- Focus state'leri (focus:ring-2 focus:ring-X)
- Renk kontrastı WCAG AA (4.5:1 minimum)

## KISITLAMALAR

1. **ASLA tahmin etme** — Her değer analiz verisinden gelmeli
2. **Hardcoded değer YASAK** — Tailwind scale veya arbitrary value kullan
3. **Div çorbası YASAK** — Semantik HTML zorunlu
4. **Yaratıcılık YASAK** — Tasarımı TAM eşleştir, "iyileştirme" yapma

## ÇIKTI FORMATI

```tsx
import React from 'react';

interface [ComponentName]Props {
  // Figma varyantlarından gelen prop'lar
}

export const [ComponentName]: React.FC<[ComponentName]Props> = ({
  // props
}) => {
  return (
    // Semantik HTML + Tailwind classes
  );
};

export default [ComponentName];
```

## RESPONSIVE GEREKSİNİMLERİ

- Mobile-first yaklaşım (base styles mobile için)
- Breakpoint'ler: sm (640px), md (768px), lg (1024px)
- Sabit genişlikler → max-w-[X] w-full pattern'i

## ÇIKTI

TypeScript React component üret:
- Typed props interface
- Tailwind CSS classes (arbitrary values sadece gerektiğinde)
- Semantic HTML structure
- Accessibility attributes
- Hover/focus states
```

## Kullanım

1. Faz 1'den analiz çıktısını al
2. Bu prompt'a ekle
3. Kod üret
4. Faz 3'e (doğrulama) geç
