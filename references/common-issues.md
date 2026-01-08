# Common Issues and Solutions

Figma-to-code dönüşümünde karşılaşılan yaygın sorunlar ve çözümleri.

## Tipografi Sorunları

### Sorun: Line-Height Uyumsuzluğu

**Belirti:** Metin satırları arası boşluk Figma'dan farklı

**Neden:** Figma ve CSS line-height'ı farklı hesaplar
- Figma: Ekstra boşluğu sonraki satırın üstüne koyar
- CSS: Boşluğu eşit olarak üste ve alta dağıtır (half-leading)

**Çözüm:**
```jsx
// YANLIŞ
<p className="leading-[150%]">

// DOĞRU
<p className="leading-[1.5]">
```

**Formül:** `CSS line-height = Figma yüzdesi ÷ 100`

---

### Sorun: Letter-Spacing Yanlış

**Belirti:** Harfler arası boşluk eşleşmiyor

**Neden:** Figma tracking değeri farklı birimde

**Çözüm:**
```jsx
// Figma tracking: -20

// YANLIŞ
<p className="tracking-[-20px]">

// DOĞRU
<p className="tracking-[-0.02em]">
```

**Formül:** `CSS em = Figma tracking ÷ 1000`

---

### Sorun: Font Render Farklı Görünüyor

**Belirti:** Aynı font farklı kalınlıkta görünüyor

**Çözümler:**

1. Font smoothing ekle:
```css
-webkit-font-smoothing: antialiased;
-moz-osx-font-smoothing: grayscale;
```

2. Font dosyasının doğru yüklendiğini kontrol et:
```jsx
// globals.css veya tailwind.config.js'de font tanımı doğru mu?
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');
```

3. Font-weight eşleşmesini kontrol et:
```
Figma "Semi Bold" → font-semibold (600)
Figma "Medium" → font-medium (500)
```

## Layout Sorunları

### Sorun: Div Çorbası

**Belirti:** Her şey `<div>` ile yapılmış, accessibility yok

**Neden:** AI semantik anlamı dikkate almamış

**Çözüm:** Semantik HTML kullan

```jsx
// YANLIŞ
<div onClick={handleClick}>Click me</div>
<div>
  <div>Item 1</div>
  <div>Item 2</div>
</div>

// DOĞRU
<button onClick={handleClick}>Click me</button>
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
</ul>
```

**Kural tablosu:**

| Element türü | Semantik HTML |
|--------------|---------------|
| Tıklanabilir aksiyon | `<button>` |
| Link/navigasyon | `<a href>` |
| Liste | `<ul>` + `<li>` |
| Sıralı liste | `<ol>` + `<li>` |
| Navigasyon | `<nav>` |
| Header | `<header>` |
| Footer | `<footer>` |
| Ana içerik | `<main>` |
| Bölüm | `<section>` |
| Form | `<form>` |

---

### Sorun: Flexbox Yönü Yanlış

**Belirti:** Elementler yatay yerine dikey (veya tersi)

**Neden:** Auto Layout yönü yanlış çevrilmiş

**Çözüm:**
```jsx
// Figma: Horizontal Auto Layout
<div className="flex flex-row">

// Figma: Vertical Auto Layout  
<div className="flex flex-col">
```

---

### Sorun: Gap/Spacing Tutarsız

**Belirti:** Elementler arası boşluk Figma'dan farklı

**Çözümler:**

1. Gap değerini doğru çevir:
```jsx
// Figma gap: 16px
<div className="flex gap-4">  // ✓ 4 × 4 = 16px
```

2. Padding ve margin'i karıştırma:
```jsx
// Container padding ayrı, element gap ayrı
<div className="p-6 flex gap-4">
```

3. Tailwind scale'de yoksa arbitrary value:
```jsx
// 18px gap → scale'de yok
<div className="gap-[18px]">
```

---

### Sorun: Fill Container Çalışmıyor

**Belirti:** Element container'ı doldurmuyorlar

**Çözüm:**
```jsx
// Parent flex olmalı
<div className="flex">
  {/* Fill container için flex-1 */}
  <div className="flex-1">Bu dolar</div>
  <div className="w-fit">Bu hug</div>
</div>
```

## Renk Sorunları

### Sorun: Opacity Uygulanmamış

**Belirti:** Renkler beklenenden daha koyu/açık

**Çözüm:**
```jsx
// Figma: #FF5733 at 80% opacity

// YANLIŞ
<div className="bg-[#FF5733]">

// DOĞRU
<div className="bg-[#FF5733]/80">

// VEYA
<div className="bg-[rgba(255,87,51,0.8)]">
```

---

### Sorun: Gradient Yanlış

**Belirti:** Gradient yönü veya renkleri farklı

**Çözüm:**
```jsx
// Figma: Linear gradient 135°, #FF5733 to #33FF57

// Tailwind gradient yönleri:
// to-r: 90° (sağa)
// to-br: 135° (sağ alta)
// to-b: 180° (aşağı)

<div className="bg-gradient-to-br from-[#FF5733] to-[#33FF57]">

// Özel açı için:
<div className="bg-[linear-gradient(135deg,#FF5733,#33FF57)]">
```

## Responsive Sorunları

### Sorun: Responsive Breakpoint Yok

**Belirti:** Tasarım sadece bir boyutta çalışıyor

**Çözüm:** Mobile-first responsive ekle

```jsx
// Mobile: tek kolon, Desktop: çift kolon
<div className="flex flex-col md:flex-row gap-4">
  <div className="w-full md:w-1/2">Sol</div>
  <div className="w-full md:w-1/2">Sağ</div>
</div>

// Mobile: gizle, Desktop: göster
<div className="hidden lg:block">Sadece desktop'ta görünür</div>
```

**Breakpoint referansı:**
```
sm:  640px ve üstü
md:  768px ve üstü
lg:  1024px ve üstü
xl:  1280px ve üstü
2xl: 1536px ve üstü
```

---

### Sorun: Sabit Genişlik Responsive Değil

**Belirti:** Component mobilde taşıyor

**Çözüm:**
```jsx
// YANLIŞ - sabit genişlik
<div className="w-[400px]">

// DOĞRU - max-width ile
<div className="w-full max-w-[400px]">

// VEYA responsive genişlik
<div className="w-full sm:w-[400px]">
```

## Erişilebilirlik Sorunları

### Sorun: Focus State Yok

**Belirti:** Tab ile gezildiğinde nerede olduğun belli değil

**Çözüm:**
```jsx
<button className="focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
  Click me
</button>
```

---

### Sorun: Alt Text Eksik

**Belirti:** Görsellerin açıklaması yok

**Çözüm:**
```jsx
// Dekoratif görsel
<img src="..." alt="" aria-hidden="true" />

// Anlamlı görsel
<img src="..." alt="Ürün fotoğrafı: Mavi tişört" />

// Icon button
<button aria-label="Menüyü aç">
  <MenuIcon />
</button>
```

---

### Sorun: Renk Kontrastı Yetersiz

**Belirti:** Metin zor okunuyor

**Kontrol:** WCAG AA standardı = 4.5:1 kontrast oranı

**Çözüm:** Daha koyu/açık renk kombinasyonu kullan
```jsx
// YANLIŞ - düşük kontrast
<p className="text-gray-400 bg-gray-200">

// DOĞRU - yeterli kontrast
<p className="text-gray-700 bg-gray-100">
```

## MCP ve API Sorunları

### Sorun: Rate Limit Hatası

**Belirti:** Figma API 429 döndürüyor

**Çözümler:**

1. İstekleri önbelleğe al
2. Gereksiz istek yapma
3. Bekle ve tekrar dene (exponential backoff)

```javascript
// Exponential backoff
async function fetchWithRetry(fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (error.status === 429 && i < maxRetries - 1) {
        await sleep(Math.pow(2, i) * 1000); // 1s, 2s, 4s
        continue;
      }
      throw error;
    }
  }
}
```

---

### Sorun: Node ID Bulunamıyor

**Belirti:** "Node not found" hatası

**Çözüm:**
```
URL: figma.com/design/abc123/MyDesign?node-id=1-2

Doğru format:
fileKey: abc123
nodeId: 1:2 (tire değil iki nokta üst üste!)
```

---

### Sorun: Büyük Tasarım Context Limiti Aşıyor

**Belirti:** Yanıt kesilmiş veya hata veriyor

**Çözümler:**

1. `get_metadata` ile önce yapıyı al
2. Sadece gerekli node'ları işle
3. Tasarımı parçalara böl

## Quick Fix Reference

| Sorun | Hızlı Çözüm |
|-------|-------------|
| Line-height yanlış | `%` yerine ondalık kullan |
| Tracking yanlış | `÷1000` ile em'e çevir |
| Div çorbası | Semantik HTML kullan |
| Gap tutmuyor | Tailwind scale kontrol et |
| Opacity yok | `/80` syntax kullan |
| Responsive yok | `md:` prefix ekle |
| Focus yok | `focus:ring-2` ekle |
| Alt text yok | Anlamlı `alt` yaz |
