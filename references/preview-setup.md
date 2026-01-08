# Preview Route Kurulum Rehberi

Görsel doğrulama scriptinin çalışması için projenizde bir preview route oluşturmanız gerekir.

## Next.js App Router

**Dosya:** `app/test-preview/page.tsx`

```tsx
'use client';

import { useSearchParams } from 'next/navigation';
import dynamic from 'next/dynamic';
import { Suspense } from 'react';

// Bileşenleri dinamik olarak import et
const components: Record<string, React.ComponentType<any>> = {
  // Yeni bileşenler buraya eklenir
  // 'HeroCard': dynamic(() => import('@/components/HeroCard')),
};

function PreviewContent() {
  const searchParams = useSearchParams();
  const componentName = searchParams.get('component');

  if (!componentName) {
    return <div>Component name required. Use ?component=ComponentName</div>;
  }

  const Component = components[componentName];

  if (!Component) {
    return <div>Component "{componentName}" not found in preview registry.</div>;
  }

  return (
    <div 
      data-testid="preview-component"
      className="inline-block"
      style={{ 
        // Arka plan temiz olsun, karşılaştırma için
        background: 'white',
        // Figma'daki boyutla aynı olması için auto
        width: 'auto',
        height: 'auto'
      }}
    >
      <Component />
    </div>
  );
}

export default function TestPreviewPage() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <PreviewContent />
    </Suspense>
  );
}
```

## Next.js Pages Router

**Dosya:** `pages/test-preview.tsx`

```tsx
import { useRouter } from 'next/router';
import dynamic from 'next/dynamic';

const components: Record<string, React.ComponentType<any>> = {
  // 'HeroCard': dynamic(() => import('@/components/HeroCard')),
};

export default function TestPreviewPage() {
  const router = useRouter();
  const { component: componentName } = router.query;

  if (!componentName || typeof componentName !== 'string') {
    return <div>Component name required</div>;
  }

  const Component = components[componentName];

  if (!Component) {
    return <div>Component not found</div>;
  }

  return (
    <div 
      data-testid="preview-component"
      className="inline-block bg-white"
    >
      <Component />
    </div>
  );
}
```

## Vite / Create React App

**Dosya:** `src/pages/TestPreview.tsx`

```tsx
import { useSearchParams } from 'react-router-dom';

// Bileşenleri import et
import { HeroCard } from '../components/HeroCard';

const components: Record<string, React.ComponentType<any>> = {
  'HeroCard': HeroCard,
};

export function TestPreview() {
  const [searchParams] = useSearchParams();
  const componentName = searchParams.get('component');

  if (!componentName) {
    return <div>Component name required</div>;
  }

  const Component = components[componentName];

  if (!Component) {
    return <div>Component not found</div>;
  }

  return (
    <div data-testid="preview-component" className="inline-block bg-white">
      <Component />
    </div>
  );
}
```

**Router'a ekle:** `src/App.tsx`

```tsx
import { TestPreview } from './pages/TestPreview';

// Routes içinde:
<Route path="/test-preview" element={<TestPreview />} />
```

## Yeni Bileşen Ekleme

Her yeni bileşen oluşturulduğunda preview registry'ye eklenmelidir:

```tsx
const components: Record<string, React.ComponentType<any>> = {
  'Button': Button,
  'Card': Card,
  'HeroCard': HeroCard,  // Yeni eklenen
};
```

## Doğrulama Çalıştırma

### 1. Dev Server Başlat

```bash
npm run dev
```

### 2. Playwright MCP ile Screenshot Al

```javascript
// 1. Preview sayfasına git
browser_navigate({ url: "http://localhost:3000/test-preview?component=HeroCard" })

// 2. Component yüklenmesini bekle
browser_evaluate({ script: "new Promise(r => setTimeout(r, 2000))" })

// 3. Screenshot al
browser_take_screenshot({
  filename: "rendered.png"
})
```

### 3. Claude Vision ile Karşılaştır

İki görseli yan yana koy:
- `reference.png` - Figma'dan (Phase 1'de `get_screenshot` ile alındı)
- `rendered.png` - Playwright'tan (az önce alındı)

Claude Vision'a sor:
- "Bu iki görsel arasındaki farklar neler?"
- "Hangi CSS değerleri düzeltilmeli?"

## Çıktılar

Doğrulama sonrası:
- `reference.png` - Figma tasarım görseli
- `rendered.png` - Kod output'unun ekran görüntüsü
- Fark varsa → Düzelt ve tekrar test et (max 3 iterasyon)

## Troubleshooting

| Hata | Çözüm |
|------|-------|
| "Preview component bulunamadı" | `data-testid="preview-component"` ekleyin |
| "Component not found" | components registry'ye ekleyin |
| Boyut uyuşmazlığı | Container'a `inline-block` ve `bg-white` ekleyin |
| Dev server bağlantı hatası | `npm run dev` çalıştığından emin olun |
