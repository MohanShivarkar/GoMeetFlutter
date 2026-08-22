# GoMeet Flutter PWA Migration & Development Plan

## Current Workspace Analysis
First, let's summarize what we found in the existing codebase:

| Item | Details |
|------|---------|
| **Project Type** | Flutter mobile dating app (Android/iOS) |
| **Web Directory** | Missing (needs to be initialized) |
| **Routing** | Uses custom route generator in [routes.dart](../lib/core/routes.dart) |
| **Key Dependencies** | Firebase, Google Maps, Agora RTC, image_picker, camera, Razorpay, etc. |
| **Fonts/Assets** | Custom Satoshi fonts, images, icons, and Lottie animations in `assets/` |

---

## Phase 1: Environment & Web Initialization

### Step 1.1: Verify Flutter Version
First, confirm you're using a Flutter version with stable web support (>= 3.2.0 as per pubspec.yaml).
```powershell
flutter --version
```

### Step 1.2: Initialize Web Platform
```powershell
flutter create . --platforms web
```
This will create the `web/` directory with default files.

### Step 1.3: Identify Mobile-Only Dependencies
Based on `pubspec.yaml`, here are plugins that are **not web-compatible** or need conditional usage:

| Plugin | Status | Alternative/Action |
|--------|--------|--------------------|
| `camera: ^0.11.0+2` | Limited web support | Use `dart:html` MediaDevices API for web, conditional imports |
| `geolocator: ^13.0.2` | Web support available | Verify via plugin docs |
| `agora_rtc_engine: ^6.5.2` | Web support available | Use Agora Web SDK alongside |
| `razorpay_flutter: ^1.4.0` | No web support | Implement web-specific payment flow (Razorpay Web SDK) |
| `onesignal_flutter: ^5.2.7` | Web support available | Verify configuration |
| `google_maps_flutter: ^2.7.0` | Web support available | Ensure correct API key configuration |
| `flutter_local_notifications: ^18.0.1` | No web support | Use Web Notifications API for web |

---

### Local Verification Workflow for Phase 1
1. **How to run locally:**
   - After initializing web, run:
     ```powershell
     flutter run -d chrome --web-renderer canvakit
     ```
   - Open Chrome DevTools (F12)

2. **What to look for:**
   - App loads without errors in Chrome
   - Check `web/` directory is created with `index.html`, `manifest.json`, etc.
   - Check DevTools Console for any plugin compatibility errors

3. **Sign-off Criteria:**
   - [ ] `web/` directory successfully created
   - [ ] App launches in Chrome without fatal errors
   - [ ] No critical plugin errors in DevTools Console

---

## Phase 2: PWA Manifest & Customization Setup

### Step 2.1: Update `manifest.json`
Here's a production-ready manifest for a dating app:
```json
{
  "name": "GoMeet - Dating App",
  "short_name": "GoMeet",
  "description": "Find your perfect match",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#ff4081",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-maskable-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "icons/Icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```

### Step 2.2: Update `index.html`
```html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="GoMeet - Find your perfect match">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="GoMeet">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <title>GoMeet</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script>
    var serviceWorkerVersion = null;
    var scriptLoaded = false;
    function loadMainDartJs() {
      if (scriptLoaded) {
        return;
      }
      scriptLoaded = true;
      var scriptTag = document.createElement('script');
      scriptTag.src = 'main.dart.js';
      scriptTag.type = 'application/javascript';
      document.body.append(scriptTag);
    }
    if ('serviceWorker' in navigator) {
      window.addEventListener('load', function () {
        var serviceWorkerUrl = 'flutter_service_worker.js?v=' + serviceWorkerVersion;
        navigator.serviceWorker.register(serviceWorkerUrl);
      });
    }
    loadMainDartJs();
  </script>
</body>
</html>
```

### Step 2.3: Place PWA Assets
- App icons in `web/icons/` (192x192, 512x512, maskable versions)
- `manifest.json` and `index.html` in `web/`
- Splash screens (optional but recommended) in `web/`

---

### Local Verification Workflow for Phase 2
1. **How to run locally:**
   ```powershell
   flutter run -d chrome --web-renderer canvakit
   ```
   - Open Chrome DevTools → **Application** tab

2. **What to look for:**
   - **Manifest section**: Verify manifest is loaded with correct name, icons, display mode
   - **Service Workers section**: Verify service worker is registered
   - Test "Add to Home Screen" prompt (if available)
   - Check app icon in Chrome tab and bookmarks

3. **Sign-off Criteria:**
   - [ ] Manifest loads correctly in DevTools Application tab
   - [ ] Service worker is registered and active
   - [ ] App icon appears correctly in browser
   - [ ] "Add to Home Screen" functionality works (if supported)

---

## Phase 3: Service Worker & Offline Strategy

### Caching Strategy
1. **Static Assets Cache**: Cache app shell, fonts, and icons using `CacheFirst` strategy
2. **API Data Cache**: Use `StaleWhileRevalidate` for profile data, chat messages
3. **Image Cache**: Use `CacheFirst` with expiration for user profile photos
4. **Offline Fallback**: Show a friendly offline screen when no network

---

### Local Verification Workflow for Phase 3
1. **How to run locally:**
   ```powershell
   flutter run -d chrome --web-renderer canvakit
   ```
   - Open Chrome DevTools → **Network** tab → Throttling → Offline

2. **What to look for:**
   - App still loads (app shell cached)
   - Offline fallback screen is shown
   - Chat messages and profile data load from cache
   - No network errors for cached assets

3. **Sign-off Criteria:**
   - [ ] App loads offline
   - [ ] Offline fallback screen is displayed
   - [ ] Static assets are served from cache
   - [ ] API data is available offline (where applicable)

---

## Phase 4: Web Optimization (Dating App Context)

### 4.1 Image/Media Handling
- Use `cached_network_image` (enable in pubspec.yaml) for web caching
- Configure CORS on your storage backend (S3/Firebase) for profile pictures
- Implement responsive image loading with `Image.network`

### 4.2 Routing & SEO
- Convert custom routing to `go_router` for clean URLs (removing `#`)
- Use `PathUrlStrategy` instead of `HashUrlStrategy`

### 4.3 Responsive Layout Checklist
- [ ] Make swiping UI work on desktop (mouse drag support)
- [ ] Adjust bottom navigation bar for desktop (side navigation option)
- [ ] Ensure cards scale properly on large screens
- [ ] Test portrait/landscape modes on various screen sizes

---

### Local Verification Workflow for Phase 4
1. **How to run locally:**
   ```powershell
   flutter run -d chrome --web-renderer canvakit
   ```
   - Use Chrome DevTools **Device Toolbar** to test various screen sizes

2. **What to look for:**
   - Clean URLs without `#`
   - Images load without CORS errors
   - Responsive layout works on mobile, tablet, and desktop
   - Swiping/matching UI works with mouse on desktop

3. **Sign-off Criteria:**
   - [ ] Clean URLs (no `#`)
   - [ ] No CORS errors on images
   - [ ] Layout is responsive across all screen sizes
   - [ ] All interactive features work on desktop (mouse support)

---

## Phase 5: Build & Deployment Setup

### Build Commands
For optimal performance:
```powershell
# CanvasKit (best performance, larger download size)
flutter build web --web-renderer canvakit --release

# HTML renderer (faster initial load, good for mobile web)
flutter build web --web-renderer html --release
```

### Deployment Options
- **Firebase Hosting**: Simple integration with existing Firebase project
- **Vercel/Netlify**: Auto-deployment from Git
- **AWS S3 + CloudFront**: For high scalability

---

### Local Verification Workflow for Phase 5
1. **How to test build locally:**
   ```powershell
   flutter build web --web-renderer canvakit --release
   cd build/web
   python -m http.server 8000
   ```
   - Open `http://localhost:8000` in Chrome

2. **What to look for:**
   - Build completes without errors
   - App loads correctly from local server
   - All functionality works as expected
   - Performance is good (check Lighthouse scores)

3. **Sign-off Criteria:**
   - [ ] Release build completes successfully
   - [ ] App loads correctly from local server
   - [ ] All features work as expected
   - [ ] Lighthouse PWA audit passes

---

## Modular Approval Workflow
For each phase/module, follow these steps:
1. I implement the changes
2. You test using the Local Verification Workflow
3. You mark the sign-off criteria items as complete
4. We proceed to the next phase
