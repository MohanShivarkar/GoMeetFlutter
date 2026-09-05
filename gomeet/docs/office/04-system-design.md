# System Design: GoMeet PWA

**Phase:** Architecture
**Date:** 2026-08-22
**Status:** Draft — awaiting confirmation
**Preceding Documents:** `01-vision-brief.md`, `02-prd.md`, `03-market-analysis.md`

---

## Architecture Overview

### High-Level Architecture

GoMeet PWA is not a new product — it is a **web compilation layer** added on top of the
existing Flutter mobile codebase. The architecture is therefore additive: the Firebase
backend, Firestore data model, and ~95% of Dart business logic remain unchanged. The
changes are confined to four areas:

1. **Platform entry point** — `main.dart` and `firebase_options.dart` are fixed to
   initialise Firebase on web.
2. **Package compatibility layer** — Mobile-only packages are replaced with
   conditional-import stubs or web-native equivalents.
3. **PWA shell** — `web/manifest.json`, `web/index.html`, and the Flutter service worker
   are configured for offline-first operation.
4. **Responsive layout additions** — Tablet breakpoint layouts are added to the Discover
   and Chat screens; all other screens are verified for 375–1024 px viewports.

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                             │
│                                                                 │
│   ┌─────────────────┐      ┌──────────────────────────────┐    │
│   │  Android / iOS  │      │   Browser / Installed PWA    │    │
│   │  Native Flutter │      │   Flutter Web (Auto renderer)│    │
│   │  (unchanged)    │      │   Served by Firebase Hosting │    │
│   └────────┬────────┘      └──────────────┬───────────────┘    │
│            │                              │                     │
│            └──────────────┬───────────────┘                    │
│                           │                                     │
│              Shared Dart / Flutter codebase                     │
│              (conditional imports for platform splits)          │
└───────────────────────────┬─────────────────────────────────────┘
                            │  Firebase SDKs (Auth, Firestore,
                            │  Storage, Analytics, App Check)
┌───────────────────────────▼─────────────────────────────────────┐
│                     FIREBASE BACKEND                            │
│                                                                 │
│   Firebase Auth  │  Cloud Firestore  │  Firebase Storage        │
│   Firebase Analytics  │  Firebase App Check (reCAPTCHA v3)     │
│   Firebase Hosting (serves the Flutter web build)              │
└─────────────────────────────────────────────────────────────────┘
```

### Design Principles

- **Minimise divergence** — Every web-specific change must be behind a `kIsWeb` guard or
  a conditional import. The goal is zero drift between mobile and web business logic.
- **Progressive enhancement** — Core flows (sign-up, swipe, chat) work first. Advanced
  features (App Check, offline shell, tablet layouts) are layered on top without blocking
  the baseline.
- **Firebase-first** — All persistence, auth, and real-time sync continue to go through
  Firebase SDKs. No new server infrastructure is introduced for v1.
- **Offline shell, not offline app** — Service worker caches the app shell so the UI
  loads without network. Live data (profiles, messages) still requires connectivity.
- **Security rules as the last line of defence** — The existing Firestore Security Rules
  (which enforce `request.auth != null`) are the primary data protection layer. App Check
  adds a second layer for the web surface.

---

## Components

### 1. Flutter Web Build Output

- **Purpose**: Produces the deployable PWA artifact from the existing Flutter codebase.
- **Technology**: Flutter 3.x, `flutter build web --pwa-strategy=offline-first --release`
- **Renderer**: `--web-renderer auto` — Flutter selects HTML renderer on mobile browsers
  (smaller bundle, faster first paint) and CanvasKit on desktop browsers (pixel-perfect
  fidelity). No manual override needed.
- **Responsibilities**:
  - Compile all Dart code to JavaScript (dart2js with `-O4` optimisations in release mode).
  - Emit `flutter_service_worker.js` with the offline-first caching strategy.
  - Produce `index.html` that bootstraps the Flutter engine and loads the compiled JS.
  - Reference `manifest.json` from `web/manifest.json`.

### 2. PWA Shell (`web/`)

- **Purpose**: Makes the app installable and offline-capable.
- **Technology**: Static files in `web/` directory, served by Firebase Hosting.
- **Responsibilities**:
  - `manifest.json` — Declares app name, icons (192×192, 512×512, maskable), theme
    colour (`#0F0F1A`), `start_url`, and `display: standalone`.
  - `index.html` — Includes `<meta name="apple-touch-icon">` tags for iOS, theme-color
    meta, and the Flutter bootstrap script.
  - `flutter_service_worker.js` — Caches the app shell (HTML, compiled JS, fonts, icons)
    on first visit. Serves cached assets while offline; fetches updates in the background
    (stale-while-revalidate).
  - Icons — GoMeet brand icons at 192×192, 512×512, and a maskable variant with safe-zone
    padding for adaptive icon launchers.

### 3. Firebase Initialisation (web branch)

- **Purpose**: Connects the web app to the Firebase project on startup.
- **Technology**: `firebase_core` web plugin, `firebase_options.dart`.
- **Responsibilities**:
  - `main.dart` removes the `if (!kIsWeb)` guard around `Firebase.initializeApp()`.
  - `DefaultFirebaseOptions.currentPlatform` returns the web config (apiKey, authDomain,
    projectId, storageBucket, messagingSenderId, appId, measurementId).
  - Firebase App Check is initialised for the web platform using the reCAPTCHA v3 provider
    immediately after `Firebase.initializeApp()`.

```dart
// main.dart — web-fixed initialisation
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
if (kIsWeb) {
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_V3_SITE_KEY'),
  );
}
```

### 4. Package Compatibility Layer

- **Purpose**: Allows `flutter build web` to complete without compilation errors from
  mobile-only native plugins.
- **Technology**: Dart conditional imports (`dart:io` vs `dart:html`), `kIsWeb` guards.
- **Responsibilities**:

| Package | Web Strategy | Implementation |
|---------|-------------|----------------|
| `permission_handler` | Stub returning `PermissionStatus.granted` | Conditional import: `permission_handler_web_stub.dart` |
| `flutter_local_notifications` | No-op stub | Conditional import: `notifications_web_stub.dart` |
| `agora_rtc_engine` | `kIsWeb` guard, "Coming Soon" banner | Import guard in video call screen |
| `razorpay_flutter` | `kIsWeb` guard, "Mobile only" notice | Import guard in premium screen |
| `camera` | `getUserMedia` via `dart:html` / `image_picker_for_web` | Conditional import swap |
| `geolocator` / location | `window.navigator.geolocation` via `dart:html` | Conditional import: web geolocation stub |

### 5. Web-Specific UI Layer

- **Purpose**: Adds tablet-responsive layouts and web-native interaction patterns.
- **Technology**: Flutter widgets with `MediaQuery` breakpoints; existing screen files
  extended with `LayoutBuilder`.
- **Responsibilities**:
  - **Discover screen** — At >= 600 px, centres card stack (max width 500 px) and renders
    action buttons in a right sidebar. Adds keyboard arrow-key handlers for accessibility.
  - **Chat screen** — At >= 768 px, renders a two-panel master-detail layout (conversation
    list 290 px left + active thread right). Below 768 px, retains single-panel navigation.
  - **All screens** — Verified at 375 px, 768 px, 1024 px for overflow and clipping. Modals
    and dialogs constrained to max 500 px width, centred.
  - **PWA install CTA** — Subscribes to `beforeinstallprompt` JS event (via `dart:js`
    interop) and surfaces an in-app install banner; tracks dismissals and installs as
    Firebase Analytics events.

### 6. Firebase Hosting

- **Purpose**: Serves the compiled Flutter web build over HTTPS with CDN distribution.
- **Technology**: Firebase Hosting (Spark / Blaze tier).
- **Responsibilities**:
  - Serve static files from `build/web/` with proper cache headers:
    - `index.html` — `Cache-Control: no-cache` (always re-validate entry point).
    - Hashed JS/CSS assets — `Cache-Control: public, max-age=31536000, immutable`.
  - URL rewrite: all unmatched paths → `index.html` (required for Flutter's client-side
    router to handle deep links).
  - Automatic HTTPS (TLS termination at Firebase CDN edge).
  - Custom domain support available post-launch if needed.

```json
// firebase.json (key sections)
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*"],
    "headers": [
      {
        "source": "/index.html",
        "headers": [{ "key": "Cache-Control", "value": "no-cache" }]
      },
      {
        "source": "**/*.@(js|css|wasm)",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }]
      }
    ],
    "rewrites": [{ "source": "**", "destination": "/index.html" }]
  }
}
```

---

## Data Architecture

### Data Models

The Firestore data model is **unchanged from the mobile app**. No schema migrations are
needed. The web client reads and writes to the same collections.

```
users/{userId}
  ├── name, age, gender, bio, preferences
  ├── photoUrls: []
  ├── location: GeoPoint
  ├── fcmTokens: { android: "...", ios: "...", web: "..." }  ← web token added
  └── premium: { active: bool, expiresAt: Timestamp }

matches/{matchId}
  ├── userIds: [uid1, uid2]
  ├── createdAt: Timestamp
  └── lastActivity: Timestamp

conversations/{conversationId}
  ├── matchId
  ├── participants: [uid1, uid2]
  ├── lastMessage: { text, senderId, timestamp }
  └── unreadCounts: { uid1: int, uid2: int }

conversations/{conversationId}/messages/{messageId}
  ├── senderId, text, imageUrl
  ├── timestamp: Timestamp
  └── readBy: [uid1, uid2]

swipes/{userId}/likes/{targetUserId}
  └── timestamp: Timestamp

swipes/{userId}/dislikes/{targetUserId}
  └── timestamp: Timestamp
```

**Web-only addition:** The `users/{userId}.fcmTokens.web` field stores the FCM web
registration token (deferred to v2 for push notifications, but the field write is wired
in v1 so token collection is ready).

### Data Flow

```
User action (swipe / message)
        │
        ▼
Flutter UI widget
        │
        ▼
Repository / Service layer (existing Dart code)
        │
        ▼
Firebase SDK (firestore / storage)
        │  (real-time listener or one-shot write)
        ▼
Cloud Firestore / Firebase Storage
        │
        ▼
Real-time listener on other client (mobile or web)
        │
        ▼
UI update (StreamBuilder / Riverpod / BLoC stream)
```

No intermediary API server exists. All reads and writes are direct Firebase SDK calls,
protected by Firestore Security Rules server-side.

### Storage Strategy

- **Primary Database**: Cloud Firestore — real-time, offline-capable (on mobile; on web
  Firestore uses IndexedDB for persistence automatically when enabled).
- **File Storage**: Firebase Storage — profile photos, chat image attachments. Accessed
  directly from the client via the Firebase Storage SDK.
- **Browser-side Caching**:
  - **App shell** (HTML, JS, fonts, icons) — Cached by the Flutter service worker using
    the `offline-first` strategy.
  - **Firestore data** — Firestore web SDK uses IndexedDB for local persistence; enable
    with `db.enablePersistence()` to allow previously loaded matches/chats to display
    offline.
  - **Images** — Served from Firebase Storage URLs; browser HTTP cache handles image
    caching via `Cache-Control` headers on Storage objects.

---

## API Design

### API Style

**No custom REST or GraphQL API.** All client-server communication goes through Firebase
SDK calls:
- **Firebase Auth** — sign-up, sign-in, OAuth (Google), password reset, phone/OTP.
- **Firestore SDK** — real-time listeners (`snapshots()`) and one-shot reads/writes.
- **Firebase Storage SDK** — `putData()` / `getDownloadURL()` for photo uploads.
- **Firebase Analytics** — `logEvent()` calls for funnel tracking.
- **Firebase App Check** — token attached automatically by the SDK to all Firebase API calls.

This means there are no new endpoints to design, document, or secure for v1. The existing
Firebase Security Rules are the API contract.

### Key Firebase Security Rules (Verify Before Launch)

| Collection | Rule | Notes |
|------------|------|-------|
| `users/{userId}` | Read: authenticated; Write: `request.auth.uid == userId` | Verify no platform check that would block web |
| `conversations/{id}/messages` | Read/Write: participant only | Check `resource.data.participants` includes `request.auth.uid` |
| `swipes/{userId}/**` | Write: `request.auth.uid == userId` | No change needed |
| Firebase Storage | Read: authenticated; Write: own folder only | Verify `request.auth != null` (not platform-gated) |

**Action item:** Audit existing Security Rules for any `request.resource.data` or
`request.headers` checks that inadvertently assume a mobile client — these would need to be
made platform-agnostic.

### Browser Geolocation (replaces native location package)

On web, location is obtained via the browser Geolocation API:

```dart
// web_geolocation_stub.dart
import 'dart:html' as html;

Future<Position> getCurrentPosition() async {
  final geo = html.window.navigator.geolocation;
  final pos = await geo.getCurrentPosition();
  return Position(
    latitude: pos.coords!.latitude!.toDouble(),
    longitude: pos.coords!.longitude!.toDouble(),
  );
}
```

The browser prompts the user for location permission natively (no `permission_handler`
needed on web). The resulting `Position` object matches the shape expected by the existing
discover/matching logic.

---

## Technology Stack

### Recommended Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **UI Framework** | Flutter 3.x (Web target) | Existing codebase; ~95% code reuse; single Dart codebase for Android, iOS, Web |
| **Web Renderer** | Auto (HTML on mobile, CanvasKit on desktop) | Balances bundle size vs. visual fidelity based on device; no manual override needed |
| **Build strategy** | `--pwa-strategy=offline-first` | Caches app shell for offline load; required for Lighthouse PWA >= 90 |
| **Auth** | Firebase Authentication | Already used on mobile; Google Sign-In, Email/Password, Phone/OTP all have web SDK support |
| **Database** | Cloud Firestore | Already used; real-time listeners work identically on web; IndexedDB persistence for offline data |
| **File Storage** | Firebase Storage | Already used; web SDK supports `putData()` from `dart:html` File objects |
| **Analytics** | Firebase Analytics | Already instrumented; `logEvent()` works on web; no changes needed |
| **Security** | Firebase App Check (reCAPTCHA v3) | v1 inclusion as decided; protects Firestore/Storage from scraped-key abuse on the web surface |
| **Hosting / CDN** | Firebase Hosting | HTTPS, CDN, URL rewrites for SPA routing, free on Spark tier |
| **Deployment** | Manual (`flutter build web` + `firebase deploy`) | Chosen approach; no CI pipeline in v1 |
| **Image Capture (web)** | `image_picker_for_web` + `getUserMedia` | Browser-native; replaces `camera` plugin on web |
| **Push Notifications** | Deferred to v2 (FCM VAPID) | In-app Firestore-driven badges sufficient for v1 |
| **Video Calls** | Deferred to v2 (Agora Web SDK) | Stubbed with "Coming Soon" banner in v1 |
| **Payments** | Deferred to v2 (Razorpay Web JS) | Hidden on web in v1 |

### Flutter Package Changes Summary

| Package | Mobile | Web (v1) |
|---------|--------|----------|
| `firebase_core` | ✓ | ✓ (fix `initializeApp` call) |
| `firebase_auth` | ✓ | ✓ (web SDK included) |
| `cloud_firestore` | ✓ | ✓ (web SDK included) |
| `firebase_storage` | ✓ | ✓ (web SDK included) |
| `firebase_analytics` | ✓ | ✓ (web SDK included) |
| `firebase_app_check` | ✓ | ✓ (reCAPTCHA v3 provider) |
| `permission_handler` | ✓ | Stub (no-op, returns granted) |
| `flutter_local_notifications` | ✓ | Stub (no-op) |
| `agora_rtc_engine` | ✓ | Guarded (`kIsWeb` → banner) |
| `razorpay_flutter` | ✓ | Guarded (`kIsWeb` → hidden) |
| `camera` | ✓ | `image_picker_for_web` |
| `geolocator` | ✓ | `dart:html` geolocation stub |

---

## Security Considerations

### Authentication

- **Firebase Authentication** handles all identity. All Firestore and Storage operations
  require `request.auth != null` via Security Rules — enforced server-side regardless of
  client platform.
- **Google Sign-In on web** uses the Firebase Auth `signInWithPopup` or
  `signInWithRedirect` flow (no native Google SDK; handled by `firebase_auth` web plugin).
- **Phone/OTP on web** uses Firebase Phone Auth with the reCAPTCHA verifier (rendered as
  an invisible reCAPTCHA by the Firebase SDK automatically).
- **Session persistence**: Firebase Auth `LOCAL` persistence is the default on web —
  the user stays signed in across browser refreshes until explicit sign-out.

### Authorization

- **Firestore Security Rules** remain the authoritative access control layer. No changes
  are made to relax rules for web clients.
- **Firebase Storage Rules** enforce that users can only write to their own folder
  (`/users/{userId}/...`).
- **App Check (reCAPTCHA v3)**: Activated in v1 for the web platform. Every Firebase SDK
  request from the browser will carry an App Check token. Enforcement mode should be set
  to **monitoring only** during QA, then switched to **enforced** before public launch to
  avoid blocking legitimate users during testing.

### API Key Exposure

- Firebase web config (apiKey, authDomain, etc.) is necessarily visible in client-side JS.
  This is expected and safe when Security Rules + App Check are in place — the apiKey
  alone cannot bypass auth or security rules.
- No service account credentials or private keys are included in the web build.

### HTTPS

- Firebase Hosting enforces HTTPS automatically. HTTP requests are redirected to HTTPS.
  The service worker requires HTTPS (or localhost) — Firebase Hosting satisfies this.

---

## PWA Architecture

### Service Worker Strategy

Flutter's `flutter build web --pwa-strategy=offline-first` generates
`flutter_service_worker.js` automatically. It implements a **cache-first** strategy for
all app shell assets:

```
First visit:
  Browser → Network → Cache (store) → App renders

Subsequent visits (online):
  Browser → Cache (serve immediately) → Background fetch (update cache)

Offline:
  Browser → Cache (serve) → Offline banner shown for live data features
```

Assets cached: `index.html`, `main.dart.js`, `flutter.js`, fonts, `manifest.json`, icons.

### manifest.json

```json
{
  "name": "GoMeet — Dating Without the Download",
  "short_name": "GoMeet",
  "description": "Swipe, match, and chat — no app install needed.",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#0F0F1A",
  "theme_color": "#FF4458",
  "orientation": "portrait-primary",
  "icons": [
    { "src": "icons/Icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "icons/Icon-512.png", "sizes": "512x512", "type": "image/png" },
    { "src": "icons/Icon-maskable-192.png", "sizes": "192x192", "type": "image/png", "purpose": "maskable" },
    { "src": "icons/Icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ]
}
```

### PWA Install Prompt (In-App CTA)

```dart
// web_install_prompt.dart (web only, guarded by kIsWeb)
import 'dart:js' as js;

void listenForInstallPrompt() {
  js.context['onbeforeinstallprompt'] = (event) {
    // Save the event, show custom install banner
    _deferredPrompt = event;
    _showInstallBanner();
    FirebaseAnalytics.instance.logEvent(name: 'pwa_install_prompt_shown');
  };
}
```

---

## Scalability Considerations

### Current Scale (v1)

GoMeet is an existing product with an established mobile user base being extended to web.
The architecture does not introduce any new backend infrastructure — Firebase scales
horizontally and automatically. v1 web traffic is expected to be modest (existing user
base + organic browser discovery) and well within Firebase's free/Blaze tier limits.

### Firestore Read/Write Patterns

- **Discover screen**: Queries `users` collection with compound filters (location radius,
  gender preference, age range, already-swiped exclusions). These queries must be backed
  by existing Firestore composite indexes — verify the indexes cover the web query patterns
  (they should, as the query logic is shared with mobile).
- **Chat**: Firestore real-time listeners on `conversations/{id}/messages` — efficient
  at current scale; no caching layer needed for v1.
- **Match detection**: Triggered by Cloud Functions on swipe writes — unchanged from mobile.

### Growth Path

If the PWA drives significant user growth, the following scaling levers are available
without architectural changes:

- **Firebase Blaze tier** — Auto-scaling Firestore reads/writes; Firebase Storage egress
  scales with CDN caching.
- **Flutter deferred loading** — Lazy-load non-critical screens (settings, premium, video
  call stub) using Dart's `deferred as` imports to reduce initial JS bundle size and
  improve Time-to-Interactive as the codebase grows.
- **CanvasKit deferred loading** — When using Auto renderer, CanvasKit WASM is only
  fetched on desktop; consider deferring it further with a loading splash for very large
  viewports.
- **Firebase CDN** — Static assets (JS, fonts, icons) are globally distributed by Firebase
  Hosting's CDN automatically — no additional CDN configuration needed.

### Bundle Size Budget

| Asset | Target (gzipped) |
|-------|-----------------|
| `main.dart.js` (HTML renderer, mobile) | <= 2.5 MB |
| `main.dart.js` (CanvasKit, desktop) | <= 3.5 MB |
| CanvasKit WASM (`canvaskit.wasm`) | ~1.5 MB (desktop only, deferred) |
| Total initial transfer (mobile) | <= 3.5 MB |
| Total initial transfer (desktop) | <= 5 MB |

Use `dart compile js --minify` flags (applied automatically in `--release` mode) and
audit with `flutter build web --analyze-size` after the first working build.

---

## Implementation Sequence

The following sequence de-risks the migration by unblocking the build first, then layering
PWA features:

### Phase 1 — Build Unblocked (P0)
1. Fix `Firebase.initializeApp()` in `main.dart` (remove `if (!kIsWeb)` guard).
2. Populate `firebase_options.dart` with the web config values.
3. Add conditional import stubs for all blocking packages (`permission_handler`,
   `flutter_local_notifications`, `agora_rtc_engine`, `razorpay_flutter`, `camera`,
   `geolocator`).
4. Run `flutter build web --pwa-strategy=offline-first` — achieve zero compilation errors.
5. Run `flutter run -d chrome` — achieve a running app shell.

### Phase 2 — Core Flows (P0)
6. Wire `CorePwaHomeScreen` to the router as the web entry route.
7. Verify all primary routes are reachable; add 404 screen.
8. Test Email + Google Sign-In on web; verify Firebase Auth tokens are issued.
9. Test profile creation with `image_picker_for_web` for photo upload.
10. Test Discover swipe gestures (mouse drag) and Firestore writes.
11. Test real-time Chat (Firestore listeners); verify message delivery.
12. Initialise Firebase App Check (reCAPTCHA v3); test in monitoring mode.

### Phase 3 — PWA Shell (P0 / P1)
13. Configure `web/manifest.json` with correct icons, theme colour, `start_url`.
14. Add `apple-touch-icon` meta tags to `index.html` for iOS Safari.
15. Verify service worker registration and offline shell behaviour.
16. Run Lighthouse PWA audit; target score >= 90.

### Phase 4 — Responsive Layouts (P1)
17. Add tablet breakpoint to Discover screen (>= 600 px card centring + sidebar buttons).
18. Add two-panel layout to Chat screen (>= 768 px master-detail).
19. Add keyboard arrow-key handlers to Discover screen.
20. Test all screens at 375 px, 768 px, 1024 px.

### Phase 5 — Polish & Deploy (P1)
21. Switch App Check to enforced mode.
22. Wire `beforeinstallprompt` CTA and Analytics events.
23. Configure `firebase.json` (cache headers, URL rewrite catch-all).
24. Run final Lighthouse audit; verify Performance >= 80, PWA >= 90.
25. Manual deploy: `flutter build web --release && firebase deploy --only hosting`.

---

## Open Technical Questions

> These should be resolved before or during implementation.

| # | Question | Impact | Owner |
|---|----------|--------|-------|
| 1 | What are the Firebase web config values (apiKey, authDomain, appId, measurementId)? | Blocks Phase 1 (Step 2) | Dev Lead |
| 2 | What is the reCAPTCHA v3 site key for the GoMeet web domain? | Blocks App Check init (Phase 2, Step 12) | Dev Lead |
| 3 | Do existing Firestore Security Rules contain any platform-specific checks that would block web clients? | Could block all Firestore reads/writes on web | Dev Lead |
| 4 | What custom domain (if any) will the PWA be served from? Required before generating reCAPTCHA v3 key and HTTPS config. | Affects manifest `start_url`, reCAPTCHA domain allowlist | Product |
| 5 | Which state management solution does the existing app use (Riverpod, BLoC, Provider)? | Determines how platform-split service stubs are injected at startup | Any developer |
| 6 | Does the existing router support hash-based vs. path-based URLs? (`/chat/123` vs `/#/chat/123`) — Firebase Hosting rewrites require path-based. | Affects `firebase.json` rewrite rules and deep-link behaviour | Dev Lead |
| 7 | Are there any Cloud Functions triggered by mobile-specific headers or platforms that would behave differently for web requests? | Could cause silent failures in matching or notification logic | Dev Lead |
