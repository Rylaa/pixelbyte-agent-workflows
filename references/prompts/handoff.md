# Phase 5: Handoff Prompt

Bu prompt, doğrulama tamamlandıktan sonra final çıktıyı sunmak için kullanılır.

## Prompt Template

```markdown
## ROL
Sen bir teknik dokümantasyon uzmanısın. Tamamlanan Figma-to-code dönüşümünü profesyonel bir şekilde raporluyorsun.

## DÖNÜŞÜM VERİLERİ

### Üretilen Kod
[Final React component kodu]

### Doğrulama Sonuçları
[Faz 4'ten gelen validation sonuçları]

### Planlama Verileri
[Faz 2'den gelen mapping bilgileri]

## HANDOFF RAPORU OLUŞTUR

### 1. Özet Bilgiler

```markdown
## ✅ Dönüşüm Tamamlandı

| Metrik | Değer |
|--------|-------|
| **Bileşen** | ComponentName.tsx |
| **Doğruluk** | %XX.X piksel eşleşme |
| **İterasyonlar** | X/3 |
| **Süre** | ~X dakika |
| **Durum** | Başarılı / Uyarılı / Manuel gerekli |
```

### 2. Dosya Listesi

```markdown
### 📁 Oluşturulan Dosyalar

| Dosya | Açıklama | Durum |
|-------|----------|-------|
| `src/components/HeroCard.tsx` | Ana bileşen | ✅ Yeni |
| `src/components/HeroCard.test.tsx` | Unit testler | ⏳ Opsiyonel |
| `src/components/HeroCard.stories.tsx` | Storybook | ⏳ Opsiyonel |
```

### 3. Kullanılan Bileşenler

```markdown
### 🔗 Mevcut Bileşen Kullanımı

Bu dönüşümde aşağıdaki mevcut bileşenler kullanıldı:

- `Button` (src/components/Button.tsx)
  - Props: `variant="primary"`, `size="lg"`
  
- `Badge` (src/components/Badge.tsx)
  - Props: `variant="success"`
```

### 4. Varsayımlar ve Kararlar

```markdown
### 📝 Yapılan Varsayımlar

| # | Varsayım | Gerekçe |
|---|----------|---------|
| 1 | Font ailesi 'Inter' olarak ayarlandı | Figma'da font bilgisi eksikti |
| 2 | Hover state opacity %90 olarak eklendi | Tasarımda hover state yoktu |
| 3 | Focus ring blue-500 kullanıldı | Proje standardına uygun |
```

### 5. Manuel Kontrol Listesi

```markdown
### ⚠️ Manuel Kontrol Gereken

Aşağıdaki öğeler otomatik çözülemedi ve manuel kontrol gerektirir:

- [ ] **İkon asset'i** — `icon-arrow.svg` bulunamadı, placeholder kullanıldı
- [ ] **Renk token'ı** — `colors/accent` eşleşmedi, `// TODO: Check color` eklendi
- [ ] **Custom font** — 'Playfair Display' yüklü değil, fallback kullanıldı
```

### 6. Kullanım Örneği

```markdown
### 💡 Kullanım

\`\`\`tsx
import { HeroCard } from '@/components/HeroCard';

export default function HomePage() {
  return (
    <HeroCard
      title="Welcome"
      description="Lorem ipsum..."
      imageUrl="/hero.jpg"
      ctaText="Get Started"
      onCtaClick={() => console.log('clicked')}
    />
  );
}
\`\`\`
```

### 7. Responsive Davranış

```markdown
### 📱 Responsive Breakpoints

| Breakpoint | Davranış |
|------------|----------|
| Mobile (<640px) | Dikey layout, tam genişlik |
| Tablet (640-1024px) | Yatay layout, 50/50 bölünme |
| Desktop (>1024px) | Maksimum 1200px, ortalanmış |
```

## ÇIKTI FORMATI

Handoff raporunu Markdown formatında oluştur.
Kullanıcı bu raporu okuyarak:
1. Ne üretildiğini anlayabilmeli
2. Manuel kontrol gereken yerleri görebilmeli
3. Bileşeni nasıl kullanacağını öğrenebilmeli

## KRİTİK KURALLAR

1. **Şeffaf ol** — Varsayımları ve TODO'ları gizleme
2. **Actionable ol** — Manuel kontrol listesi net olmalı
3. **Örnekle göster** — Kullanım örneği her zaman ekle
4. **Metrik ver** — Doğruluk yüzdesi ve iterasyon sayısı
```

## Kullanım

1. Tüm fazlar tamamlandıktan sonra
2. Doğrulama sonuçlarını ve kodu al
3. Bu prompt'u kullanarak handoff raporu oluştur
4. Kullanıcıya sun
