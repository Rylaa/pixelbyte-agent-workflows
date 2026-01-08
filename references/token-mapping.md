# Design Token Mapping Reference

Figma'dan Tailwind/CSS'e dönüşüm için kapsamlı formüller ve örnekler.

## Tipografi Dönüşümü

### Font Size

```
CSS rem = Figma px ÷ 16

Örnekler:
12px → 0.75rem  → text-xs
14px → 0.875rem → text-sm
16px → 1rem     → text-base
18px → 1.125rem → text-lg
20px → 1.25rem  → text-xl
24px → 1.5rem   → text-2xl
30px → 1.875rem → text-3xl
36px → 2.25rem  → text-4xl
48px → 3rem     → text-5xl
60px → 3.75rem  → text-6xl

Özel değerler: text-[2.5rem] veya text-[40px]
```

### Line Height

**KRITIK:** Figma ve CSS line-height'ı farklı hesaplar.

```
CSS line-height = Figma yüzdesi ÷ 100

Örnekler:
100% → 1      → leading-none
120% → 1.2    → leading-tight (yakın)
140% → 1.4    → leading-snug (yakın)
150% → 1.5    → leading-normal
160% → 1.6    → leading-relaxed (yakın)
175% → 1.75   → leading-relaxed
200% → 2      → leading-loose

Piksel bazlı:
24px line-height, 16px font → 24÷16 = 1.5 → leading-normal
Veya: leading-[24px]
```

### Letter Spacing (Tracking)

```
CSS em = Figma tracking ÷ 1000

Örnekler:
-50  → -0.05em → tracking-tighter
-25  → -0.025em → tracking-tight
0    → 0em     → tracking-normal
25   → 0.025em → tracking-wide
50   → 0.05em  → tracking-wider
100  → 0.1em   → tracking-widest

Özel: tracking-[-0.02em] veya tracking-[0.5px]
```

### Font Weight

```
Figma → Tailwind
Thin (100)       → font-thin
Extra Light (200)→ font-extralight
Light (300)      → font-light
Regular (400)    → font-normal
Medium (500)     → font-medium
Semi Bold (600)  → font-semibold
Bold (700)       → font-bold
Extra Bold (800) → font-extrabold
Black (900)      → font-black
```

### Tam Tipografi Örneği

Figma'da:
- Font: Inter
- Size: 24px
- Weight: Semi Bold (600)
- Line Height: 130%
- Letter Spacing: -20

Tailwind çıktısı:
```jsx
<h2 className="font-inter text-2xl font-semibold leading-[1.3] tracking-[-0.02em]">
```

## Spacing Dönüşümü

### Tailwind Spacing Scale

```
Figma px → Tailwind class → CSS rem

0px   → 0    → 0rem
1px   → px   → 1px
2px   → 0.5  → 0.125rem
4px   → 1    → 0.25rem
6px   → 1.5  → 0.375rem
8px   → 2    → 0.5rem
10px  → 2.5  → 0.625rem
12px  → 3    → 0.75rem
14px  → 3.5  → 0.875rem
16px  → 4    → 1rem
20px  → 5    → 1.25rem
24px  → 6    → 1.5rem
28px  → 7    → 1.75rem
32px  → 8    → 2rem
36px  → 9    → 2.25rem
40px  → 10   → 2.5rem
44px  → 11   → 2.75rem
48px  → 12   → 3rem
56px  → 14   → 3.5rem
64px  → 16   → 4rem
80px  → 20   → 5rem
96px  → 24   → 6rem
```

### Özel Spacing Değerleri

Tailwind scale'de olmayan değerler için arbitrary value:
```jsx
// 18px padding
<div className="p-[18px]">

// 22px gap
<div className="gap-[22px]">

// 15px margin-top
<div className="mt-[15px]">
```

## Renk Dönüşümü

### Hex Renkleri

```jsx
// Düz renk
<div className="bg-[#FF5733] text-[#1A1A1A]">

// Opacity ile
<div className="bg-[#FF5733]/80">  // %80 opacity

// RGBA eşdeğeri
<div className="bg-[rgba(255,87,51,0.8)]">
```

### Gradientler

Figma gradient → CSS/Tailwind:

```jsx
// Linear gradient
<div className="bg-gradient-to-r from-[#FF5733] to-[#33FF57]">

// Açı ile
<div className="bg-[linear-gradient(135deg,#FF5733_0%,#33FF57_100%)]">

// Çoklu stop
<div className="bg-[linear-gradient(to_right,#FF5733_0%,#FFFF33_50%,#33FF57_100%)]">
```

### Renk Uzayı Farkındalığı

Modern tarayıcılar için Display P3 desteği:
```css
.element {
  /* sRGB fallback */
  background: rgb(71.942% 0% 5.7326%);
  /* P3 destekleyenler için */
  background: color(display-p3 0.6583 0.1125 0.1125);
}
```

### RGB → Display P3 Dönüşümü

```javascript
// Figma RGB (0-1) → Display P3
function rgbToP3(r, g, b) {
  // Basit linear dönüşüm (yaklaşık)
  // Gerçek dönüşüm renk profili gerektirir
  return `color(display-p3 ${r.toFixed(4)} ${g.toFixed(4)} ${b.toFixed(4)})`;
}

// sRGB fallback ile birlikte
function colorWithP3Fallback(r, g, b) {
  const hex = rgbToHex(r, g, b);
  const p3 = rgbToP3(r, g, b);
  
  return `
    background: ${hex};
    background: ${p3};
  `;
}
```

### Tailwind'de P3 Renk Kullanımı

```jsx
// Arbitrary value ile
<div className="bg-[color(display-p3_0.6583_0.1125_0.1125)]">

// CSS variable ile (önerilen)
<div style={{ '--color-p3': 'color(display-p3 0.6583 0.1125 0.1125)' }} 
     className="bg-[var(--color-p3)]">
```

**Not:** P3 renk uzayı özellikle canlı kırmızılar, yeşiller ve turuncular için fark yaratır. Pastel ve nötr tonlarda fark minimal.

## Border ve Shadow

### Border Radius

```
Figma px → Tailwind

0px   → rounded-none
2px   → rounded-sm
4px   → rounded
6px   → rounded-md
8px   → rounded-lg
12px  → rounded-xl
16px  → rounded-2xl
24px  → rounded-3xl
9999px→ rounded-full

Özel: rounded-[10px]
```

### Border Width

```
1px → border
2px → border-2
4px → border-4
8px → border-8

Özel: border-[3px]
```

### Box Shadow

Figma shadow → Tailwind:

```jsx
// Standart shadowlar
<div className="shadow-sm">   // küçük
<div className="shadow">      // normal
<div className="shadow-md">   // orta
<div className="shadow-lg">   // büyük
<div className="shadow-xl">   // çok büyük
<div className="shadow-2xl">  // en büyük

// Özel shadow (X, Y, Blur, Spread, Color)
<div className="shadow-[0px_4px_6px_-1px_rgba(0,0,0,0.1)]">

// Çoklu shadow
<div className="shadow-[0_4px_6px_rgba(0,0,0,0.1),0_2px_4px_rgba(0,0,0,0.06)]">
```

## Auto Layout → Flexbox

### Yön ve Hizalama

```
| Figma Auto Layout | Tailwind |
|-------------------|----------|
| Horizontal        | flex-row |
| Vertical          | flex-col |
| Wrap              | flex-wrap |
```

### Primary Axis (Ana Eksen)

```
| Figma             | Tailwind (row)     | Tailwind (col)     |
|-------------------|--------------------|--------------------|
| Left/Top          | justify-start      | justify-start      |
| Center            | justify-center     | justify-center     |
| Right/Bottom      | justify-end        | justify-end        |
| Space Between     | justify-between    | justify-between    |
| Space Around      | justify-around     | justify-around     |
| Space Evenly      | justify-evenly     | justify-evenly     |
```

### Counter Axis (Çapraz Eksen)

```
| Figma             | Tailwind           |
|-------------------|-------------------|
| Top/Left          | items-start       |
| Center            | items-center      |
| Bottom/Right      | items-end         |
| Stretch           | items-stretch     |
| Baseline          | items-baseline    |
```

### Child Sizing

```
| Figma             | Tailwind          |
|-------------------|-------------------|
| Fixed Width       | w-[Xpx]           |
| Hug Contents      | w-fit             |
| Fill Container    | flex-1 veya w-full|
```

### Gap

```
Figma Gap → Tailwind gap-X

8px  → gap-2
12px → gap-3
16px → gap-4
20px → gap-5
24px → gap-6
32px → gap-8

Farklı eksenler:
gap-x-4 gap-y-2  // Horizontal: 16px, Vertical: 8px
```

## Tam Örnek: Card Component

**Figma Tasarımı:**
- Container: 320px x auto
- Padding: 24px
- Gap: 16px (vertical)
- Border Radius: 12px
- Background: #FFFFFF
- Shadow: 0 4px 6px rgba(0,0,0,0.1)
- Title: Inter Semi Bold 18px, #1A1A1A
- Description: Inter Regular 14px, #666666, 150% line-height

**Tailwind Çıktısı:**

```tsx
<div className="w-[320px] p-6 flex flex-col gap-4 rounded-xl bg-white shadow-md">
  <h3 className="font-inter text-lg font-semibold text-[#1A1A1A]">
    Card Title
  </h3>
  <p className="font-inter text-sm font-normal leading-normal text-[#666666]">
    Card description text goes here.
  </p>
</div>
```
