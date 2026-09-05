# GoMeet PWA — Implementation Plan

**Goal:** Transform the existing GoMeet Flutter mobile app into a fully functional,
installable Progressive Web App deployable to Firebase Hosting with ~95% code reuse.

**Architecture:** The change is purely additive — the Firebase backend, Firestore schema,
and all business logic remain untouched. Work is confined to four bounded areas: the
platform entry point (Firebase init fix), a package compatibility layer (conditional-import
stubs for mobile-only plugins), the PWA shell (manifest, service worker, icons), and
responsive layout additions for tablet viewports (Discover + Chat screens).

**Tech Stack:** Flutter 3.x (Web target, Auto renderer), Firebase Auth / Firestore /
Storage / Analytics / App Check, Firebase Hosting, `image_picker_for_web`,
`dart:html` geolocation, `dart:js` install-prompt interop.

---

## File Structure

Map of every file that will be created or modified, organised by responsibility area.
Each file has one clear job. Files that change together live together.

---

### Platform Entry Point

- Modify: `lib/main.dart`
  — Remove `if (!kIsWeb)` guard around `Firebase.initializeApp()`; add
  `FirebaseAppCheck` activation block for web (reCAPTCHA v3).
- Modify: `lib/firebase_options.dart`
  — Add the `web` case to `DefaultFirebaseOptions.currentPlatform` with all required
  Firebase web config values (apiKey, authDomain, projectId, storageBucket,
  messagingSenderId, appId, measurementId).

---

### Package Compatibility Layer

One file per stubbed package; each file is a conditional-import facade.

- Create: `lib/core/platform/permission/permission_service.dart`
  — Public facade; conditional import selects mobile or web implementation.
- Create: `lib/core/platform/permission/permission_service_mobile.dart`
  — Delegates to `permission_handler` (unchanged mobile behaviour).
- Create: `lib/core/platform/permission/permission_service_web.dart`
  — No-op stub; all permission checks return `granted` immediately.

- Create: `lib/core/platform/notifications/notification_service.dart`
  — Public facade; conditional import selects mobile or web implementation.
- Create: `lib/core/platform/notifications/notification_service_mobile.dart`
  — Delegates to `flutter_local_notifications` (unchanged mobile behaviour).
- Create: `lib/core/platform/notifications/notification_service_web.dart`
  — No-op stub; all schedule/show calls are silent on web.

- Create: `lib/core/platform/geolocation/geolocation_service.dart`
  — Public facade with a shared `Position` model; conditional import selects platform impl.
- Create: `lib/core/platform/geolocation/geolocation_service_mobile.dart`
  — Delegates to `geolocator` package (unchanged mobile behaviour).
- Create: `lib/core/platform/geolocation/geolocation_service_web.dart`
  — Calls `window.navigator.geolocation.getCurrentPosition()` via `dart:html`; maps
  result to the shared `Position` model.

- Create: `lib/core/platform/camera/camera_service.dart`
  — Public facade for photo capture/pick; conditional import selects platform impl.
- Create: `lib/core/platform/camera/camera_service_mobile.dart`
  — Delegates to `camera` + `image_picker` packages (unchanged mobile behaviour).
- Create: `lib/core/platform/camera/camera_service_web.dart`
  — Delegates to `image_picker_for_web`; exposes file-picker and `getUserMedia` capture.

---

### Feature Guards (kIsWeb inline guards — modify existing screens)

- Modify: `lib/features/video_call/screens/video_call_screen.dart`
  — Wrap Agora engine init and all Agora imports behind `kIsWeb`; render a
  "Video calls coming soon on web" banner when `kIsWeb == true`.
- Modify: `lib/features/premium/screens/premium_screen.dart`
  — Wrap Razorpay import and payment trigger behind `kIsWeb`; render a
  "Subscribe via the GoMeet mobile app" notice when `kIsWeb == true`.

---

### Router & Shell

- Modify: `lib/core/router/app_router.dart`
  — Wire `CorePwaHomeScreen` as the web entry route; add the 404 fallback route;
  verify all primary routes are declared (sign-in, sign-up, profile creation,
  discover, chat list, chat thread, profile view, settings).
- Modify: `lib/features/shell/screens/core_pwa_home_screen.dart`
  — Complete any placeholder sections; ensure bottom navigation bar is always visible
  and correctly spaced 375–1024 px.
- Create: `lib/features/shell/screens/not_found_screen.dart`
  — Graceful 404 page with a "Go to home" link; constrained to max 500 px, centred.
- Create: `lib/features/shell/widgets/offline_banner.dart`
  — Slim top/bottom banner widget shown when `Connectivity` detects no network;
  displays "You're offline — connect to continue."

---

### PWA Install Prompt

- Create: `lib/features/pwa/web_install_manager.dart`
  — `dart:js` interop; listens for `beforeinstallprompt` event, stores the deferred
  prompt, exposes `showInstallPrompt()` and a `ValueNotifier<bool>` for banner
  visibility. Logs `pwa_install_prompt_shown` and `pwa_installed` Analytics events.
  File is web-only; guarded by `kIsWeb` at call site.
- Create: `lib/features/pwa/widgets/install_banner.dart`
  — Dismissable bottom banner widget that calls `WebInstallManager.showInstallPrompt()`.
  Shown on Discover screen after first swipe (install funnel touchpoint).

---

### Responsive Layouts

- Modify: `lib/features/discover/screens/discover_screen.dart`
  — Wrap existing single-column layout in a `LayoutBuilder`; at >= 600 px, centre card
  stack (max width 500 px) and move action buttons to a right sidebar. Add
  `RawKeyboardListener` (or `Focus` + `KeyEvent`) for left/right/up arrow-key swipe
  triggers.
- Modify: `lib/features/chat/screens/chat_list_screen.dart`
  — At >= 768 px, render two-panel master-detail layout (conversation list 290 px left,
  active thread fills remaining width). Below 768 px retains single-panel push nav.
- Modify: `lib/features/chat/screens/chat_thread_screen.dart`
  — Accept an optional `embedded: bool` parameter so the two-panel layout can render
  the thread inline (no `Scaffold` app bar duplication).
- Modify: `lib/shared/widgets/app_dialog.dart` (or equivalent dialog utility)
  — Constrain all dialogs and modals to `maxWidth: 500`, centred with `Align` +
  `ConstrainedBox` on wider screens.

---

### PWA Shell (web/ directory)

- Modify: `web/manifest.json`
  — Set `name`, `short_name`, `description`, `start_url: "/"`, `display: standalone`,
  `theme_color: "#FF4458"`, `background_color: "#0F0F1A"`, `orientation: portrait-primary`,
  full icon array (192, 512, maskable-192, maskable-512).
- Modify: `web/index.html`
  — Add `<meta name="theme-color">`, `<link rel="apple-touch-icon">` tags for iOS Safari
  "Add to Home Screen", and verify the Flutter bootstrap script reference is correct.
- Create: `web/icons/Icon-192.png` — GoMeet brand icon 192×192 px.
- Create: `web/icons/Icon-512.png` — GoMeet brand icon 512×512 px.
- Create: `web/icons/Icon-maskable-192.png` — Maskable variant with safe-zone padding.
- Create: `web/icons/Icon-maskable-512.png` — Maskable variant 512×512 px.

  > Note: `flutter_service_worker.js` is auto-generated by
  > `flutter build web --pwa-strategy=offline-first`; it is not hand-edited.

---

### Firebase Hosting & Deployment

- Modify: `firebase.json`
  — Set `hosting.public` to `"build/web"`, add cache-control headers
  (`no-cache` for `index.html`; `immutable, max-age=31536000` for hashed JS/CSS/WASM),
  and add the catch-all URL rewrite (`"**"` → `"/index.html"`) for Flutter's
  client-side router.

---

### Tests

- Test: `test/core/platform/permission_service_test.dart`
  — Verifies web stub returns `granted` without throwing.
- Test: `test/core/platform/geolocation_service_test.dart`
  — Verifies mobile impl delegates correctly; web impl mocked via `dart:html` mock.
- Test: `test/features/discover/discover_screen_responsive_test.dart`
  — Widget test at 375 px, 600 px, 1024 px viewport widths; asserts sidebar visibility
  and no overflow.
- Test: `test/features/chat/chat_layout_responsive_test.dart`
  — Widget test at 375 px and 800 px; asserts single-panel vs two-panel rendering.
- Test: `test/features/shell/not_found_screen_test.dart`
  — Verifies 404 screen renders and home link navigates correctly.

---

## Phases

### Phase 1: Build Unblocked
**Goal:** Achieve a zero-error `flutter build web --pwa-strategy=offline-first` and a
running `flutter run -d chrome` app shell. Nothing else can be tested until the build
compiles cleanly.

**Milestone:** `flutter build web` exits with code 0; Chrome opens GoMeet without a
red-screen crash or Firebase console errors.

**Files involved:**
- Modify: `lib/main.dart`
- Modify: `lib/firebase_options.dart`
- Create: `lib/core/platform/permission/permission_service.dart`
- Create: `lib/core/platform/permission/permission_service_mobile.dart`
- Create: `lib/core/platform/permission/permission_service_web.dart`
- Create: `lib/core/platform/notifications/notification_service.dart`
- Create: `lib/core/platform/notifications/notification_service_mobile.dart`
- Create: `lib/core/platform/notifications/notification_service_web.dart`
- Create: `lib/core/platform/geolocation/geolocation_service.dart`
- Create: `lib/core/platform/geolocation/geolocation_service_mobile.dart`
- Create: `lib/core/platform/geolocation/geolocation_service_web.dart`
- Create: `lib/core/platform/camera/camera_service.dart`
- Create: `lib/core/platform/camera/camera_service_mobile.dart`
- Create: `lib/core/platform/camera/camera_service_web.dart`
- Modify: `lib/features/video_call/screens/video_call_screen.dart`
- Modify: `lib/features/premium/screens/premium_screen.dart`
- Test: `test/core/platform/permission_service_test.dart`
- Test: `test/core/platform/geolocation_service_test.dart`

**Tasks (high-level):**
- [ ] Remove `if (!kIsWeb)` guard around `Firebase.initializeApp()` in `main.dart`;
      add `FirebaseAppCheck` web activation block (monitoring mode, reCAPTCHA v3 key TBD).
- [ ] Populate `firebase_options.dart` with the web config values from the Firebase Console
      (requires open question #1 to be resolved: web apiKey, authDomain, appId, etc.).
- [ ] Create conditional-import facades for `permission_handler` (web stub: all granted),
      `flutter_local_notifications` (web stub: no-op), `geolocator` (web: `dart:html`
      geolocation), and `camera` / `image_picker` (web: `image_picker_for_web`).
- [ ] Add `kIsWeb` guards to the video call screen (Agora) and premium screen (Razorpay);
      render placeholder banners.
- [ ] Run `flutter build web --pwa-strategy=offline-first`; fix any remaining compilation
      errors iteratively until exit code 0.
- [ ] Run `flutter run -d chrome`; verify no red screen, no Firebase console errors,
      Firebase Auth reachable.

**Dependencies:** None — this is the project's critical-path start.

**Blockers to resolve first:**
- Firebase web config values (apiKey, authDomain, projectId, storageBucket,
  messagingSenderId, appId, measurementId) — open question #1.
- Confirm which state management solution the app uses (Riverpod / BLoC / Provider)
  so stubs are injected consistently — open question #5.

---

### Phase 2: Core User Flows
**Goal:** All P0 user journeys work end-to-end in Chrome: sign-up → profile creation →
discover → match → chat. Firebase App Check active in monitoring mode.

**Milestone:** A test user can complete the full sign-up → swipe → match → chat flow
in Chrome without errors. All primary routes are reachable via the browser URL bar.

**Files involved:**
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/shell/screens/core_pwa_home_screen.dart`
- Create: `lib/features/shell/screens/not_found_screen.dart`
- Test: `test/features/shell/not_found_screen_test.dart`

**Tasks (high-level):**
- [ ] Wire `CorePwaHomeScreen` as the web entry route in the app router; confirm all
      primary routes (sign-in, sign-up, profile creation steps, discover, chat list,
      chat thread, profile view, settings) are declared and reachable.
- [ ] Add the 404 fallback route pointing to `NotFoundScreen`; verify browser back/forward
      navigation does not double-pop or infinite-redirect.
- [ ] Verify deep-link routing: navigate to `/chat/:conversationId` directly — confirm the
      correct thread opens (requires `firebase.json` catch-all rewrite in place, even if
      deployed locally with `firebase serve`).
- [ ] Test Email + password sign-up and Google Sign-In (`signInWithPopup`) on web;
      verify Firebase Auth tokens are issued and `LOCAL` persistence works across refresh.
- [ ] Test Phone/OTP sign-up on web (Firebase reCAPTCHA verifier auto-injected by SDK).
- [ ] Test profile creation: photo upload via `image_picker_for_web` file picker and
      camera capture; verify Firebase Storage upload and thumbnail render.
- [ ] Test browser Geolocation API prompt and confirm location writes to Firestore.
- [ ] Test Discover screen: mouse-drag swipe cards fire Firestore like/dislike writes;
      match popup triggers on mutual like.
- [ ] Test Chat: Firestore real-time listener delivers messages; image share via file
      picker uploads to Storage; unread badges update.
- [ ] Verify `firebase_analytics` `logEvent` calls fire on web (check no mobile-only guards
      wrap analytics calls).
- [ ] Confirm Firebase App Check monitoring mode is active; check Firebase Console for
      request attestation data.

**Dependencies:** Phase 1 complete (build must be green before flows can be tested).

---

### Phase 3: PWA Shell & Installability
**Goal:** The app passes a Lighthouse PWA audit >= 90; it can be installed to Android
home screen and macOS desktop from Chrome; the offline shell loads without a network
connection.

**Milestone:** Lighthouse PWA score >= 90 in Chrome DevTools. Chrome shows the install
icon in the address bar. Opening the app offline shows the GoMeet shell (not a browser
error page).

**Files involved:**
- Modify: `web/manifest.json`
- Modify: `web/index.html`
- Create: `web/icons/Icon-192.png`
- Create: `web/icons/Icon-512.png`
- Create: `web/icons/Icon-maskable-192.png`
- Create: `web/icons/Icon-maskable-512.png`
- Create: `lib/features/shell/widgets/offline_banner.dart`

**Tasks (high-level):**
- [ ] Export GoMeet brand icon at 192×192, 512×512, and maskable variants (safe-zone
      padding ~10% on each side); place in `web/icons/`.
- [ ] Configure `web/manifest.json`: `name`, `short_name`, `start_url: "/"`,
      `display: standalone`, `theme_color: "#FF4458"`, `background_color: "#0F0F1A"`,
      `orientation: portrait-primary`, full icon array including maskable purpose.
- [ ] Update `web/index.html`: add `<meta name="theme-color" content="#FF4458">`,
      `<link rel="apple-touch-icon" href="icons/Icon-192.png">` (and 512 variant) for
      iOS Safari "Add to Home Screen".
- [ ] Build with `flutter build web --pwa-strategy=offline-first`; verify
      `flutter_service_worker.js` is emitted and references the correct asset manifest.
- [ ] Smoke-test service worker: load the app once in Chrome, disconnect network in DevTools,
      reload — confirm shell loads and `OfflineBanner` widget appears instead of a browser
      error page.
- [ ] Run Lighthouse PWA audit in Chrome DevTools on the production build (use
      `firebase serve` locally or deploy to a staging channel); iterate on any failing
      criteria until score >= 90.
- [ ] Test "Add to Home Screen" on Android Chrome; test install icon in desktop Chrome
      address bar; test "Add to Home Screen" via iOS Safari share sheet.

**Dependencies:** Phase 2 complete (all routes must be reachable for full Lighthouse audit
to pass; a broken route causes a PWA audit failure on navigability).

---

### Phase 4: Responsive Layouts
**Goal:** Discover and Chat screens adapt to tablet viewports; all screens pass manual
overflow/clipping checks at 375 px, 768 px, and 1024 px.

**Milestone:** Manual QA sign-off at all three breakpoints for every primary screen.
Two-panel Chat and sidebar-button Discover are visually verified on an 820 px viewport.

**Files involved:**
- Modify: `lib/features/discover/screens/discover_screen.dart`
- Modify: `lib/features/chat/screens/chat_list_screen.dart`
- Modify: `lib/features/chat/screens/chat_thread_screen.dart`
- Modify: `lib/shared/widgets/app_dialog.dart` (or equivalent dialog utility)
- Test: `test/features/discover/discover_screen_responsive_test.dart`
- Test: `test/features/chat/chat_layout_responsive_test.dart`

**Tasks (high-level):**
- [ ] Wrap the Discover screen body in a `LayoutBuilder`; at >= 600 px render card stack
      centred (max width 500 px) + action buttons in a right `Column` sidebar; below
      600 px retain the existing mobile layout unchanged.
- [ ] Add a `RawKeyboardListener` (or `Focus` + `onKeyEvent`) to the Discover screen;
      map left-arrow → dislike, right-arrow → like, up-arrow → super-like for
      accessibility and desktop UX.
- [ ] Wrap the Chat root in a `LayoutBuilder`; at >= 768 px render a `Row` with a fixed
      290 px conversation list (left) and an expanded thread panel (right) — selecting a
      conversation replaces the right panel without a navigation push. Below 768 px retain
      single-panel push navigation.
- [ ] Add an `embedded: bool` parameter to `ChatThreadScreen` so it can suppress its own
      `Scaffold` app bar when rendered inside the two-panel layout.
- [ ] Audit every dialog/modal widget: wrap content in `ConstrainedBox(maxWidth: 500)` +
      `Align(alignment: Alignment.center)` so modals are centred on wider screens.
- [ ] Manual QA pass at 375 px, 768 px, 1024 px using Chrome DevTools device toolbar:
      check for text overflow, horizontal scroll, widget clipping, and bottom nav visibility
      on every primary screen.
- [ ] Write widget tests for Discover responsive layout (sidebar visible at 1024 px,
      hidden at 375 px) and Chat two-panel layout (two columns at 800 px, one at 375 px).

**Dependencies:** Phase 2 complete (screens must be routable and functional before
responsive changes are layered on).

---

### Phase 5: Polish, Install CTA & Deploy
**Goal:** App Check is switched to enforced mode; the PWA install CTA is wired and
instrumented; `firebase.json` is finalised; Lighthouse Performance >= 80; the app is
deployed to Firebase Hosting.

**Milestone:** Live URL on Firebase Hosting serves GoMeet PWA. Lighthouse PWA >= 90,
Performance >= 80. Manual end-to-end QA in Chrome, Firefox, and Safari passes all P0
flows. Project is declared launch-ready.

**Files involved:**
- Create: `lib/features/pwa/web_install_manager.dart`
- Create: `lib/features/pwa/widgets/install_banner.dart`
- Modify: `lib/features/discover/screens/discover_screen.dart` (wire install banner)
- Modify: `firebase.json`

**Tasks (high-level):**
- [ ] Implement `WebInstallManager` using `dart:js` interop: listen for
      `beforeinstallprompt`, store the deferred event, expose `showInstallPrompt()` and a
      `ValueNotifier<bool>` for banner state. Log `pwa_install_prompt_shown` and
      `pwa_installed` as Firebase Analytics events.
- [ ] Build `InstallBanner` widget (dismissable bottom sheet); show it on the Discover
      screen after the user's first swipe (converting the discovery session into an install
      funnel touchpoint, per market analysis recommendation).
- [ ] Finalise `firebase.json`: set `hosting.public: "build/web"`, add cache-control header
      rules (`no-cache` for `index.html`; `immutable, max-age=31536000` for hashed
      `.js`, `.css`, `.wasm` assets), add catch-all rewrite `"**" → "/index.html"`.
- [ ] Switch Firebase App Check from monitoring mode to enforced mode for the web platform
      in the Firebase Console (after confirming QA traffic is attested cleanly in
      monitoring logs).
- [ ] Run `flutter build web --pwa-strategy=offline-first --release`; verify total
      gzipped transfer <= 3.5 MB (mobile) / <= 5 MB (desktop) using `flutter build web
      --analyze-size` output and Chrome DevTools Network tab.
- [ ] Run final Lighthouse audit: Performance >= 80, PWA >= 90. Iterate if scores fall
      short (common levers: deferred Dart loading for non-critical screens, verify
      CanvasKit WASM is only fetched on desktop via Auto renderer).
- [ ] Cross-browser end-to-end QA: sign-up → profile creation → discover → match → chat
      in Chrome, Firefox, and Safari (desktop); verify on Android Chrome (mobile) and
      iOS Safari.
- [ ] Manual deploy: `flutter build web --pwa-strategy=offline-first --release &&
      firebase deploy --only hosting`.
- [ ] Verify live URL: PWA install prompt appears in Chrome; standalone mode opens
      correctly after install; offline shell loads when network is disabled.

**Dependencies:** Phases 1–4 complete. Open questions #1 (Firebase web config) and #2
(reCAPTCHA v3 site key) must be resolved before this phase begins. Custom domain (open
question #4) should be confirmed before deploy — affects `manifest.json` `start_url`
and the reCAPTCHA domain allowlist.

---

## Timeline Overview

| Phase | Name | Milestone | Dependencies |
|-------|------|-----------|--------------|
| 1 | Build Unblocked | `flutter build web` exits 0; Chrome opens app shell | None |
| 2 | Core User Flows | Full sign-up → swipe → chat flow works in Chrome | Phase 1 |
| 3 | PWA Shell & Installability | Lighthouse PWA >= 90; app installs from browser | Phase 2 |
| 4 | Responsive Layouts | Manual QA pass at 375/768/1024 px; tablet layouts verified | Phase 2 |
| 5 | Polish & Deploy | Live on Firebase Hosting; all P0 flows pass cross-browser QA | Phases 1–4 |

> Phases 3 and 4 can run in parallel once Phase 2 is complete — they touch separate
> files and have no shared dependencies between them.

---

## Open Questions — Resolution Blockers

The following open questions from the design docs must be resolved before the phases they
block can begin. Engineering should not wait — raise these with the named owners immediately.

| # | Question | Blocks | Owner |
|---|----------|--------|-------|
| 1 | Firebase web config values (apiKey, authDomain, projectId, storageBucket, messagingSenderId, appId, measurementId) | Phase 1, Step 2 | Dev Lead |
| 2 | reCAPTCHA v3 site key for the GoMeet web domain | Phase 2, App Check activation | Dev Lead |
| 3 | Do existing Firestore Security Rules contain any platform-specific checks that would block web clients? | Phase 2, all Firestore reads/writes | Dev Lead |
| 4 | Custom domain for the PWA (affects `manifest.json` `start_url`, reCAPTCHA allowlist, HTTPS config) | Phase 5, deploy | Product |
| 5 | State management solution in use (Riverpod / BLoC / Provider) — determines stub injection pattern | Phase 1, stub wiring | Any developer |
| 6 | Does the existing router use hash-based (`/#/path`) or path-based (`/path`) URLs? Firebase Hosting rewrites require path-based. | Phase 2, deep-link routing | Dev Lead |
| 7 | HTML vs. CanvasKit renderer preference (HTML = smaller bundle / some visual diff; CanvasKit = pixel-perfect / larger) — Auto renderer covers both but confirm team is comfortable with Auto | Phase 1, build config | Tech Lead |

---

## Risk Mitigation

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Firebase web config not available at Phase 1 start | Medium | Request config from Firebase Console immediately; use a `.env`-style local override during dev so the build is not blocked on Product decisions |
| Existing Firestore Security Rules gate on mobile platform headers — all web reads fail | Medium | Audit rules in Phase 1 alongside the build fix; add a dedicated "rules audit" task at the start of Phase 2 |
| Lighthouse Performance score stays below 80 due to large CanvasKit bundle | Medium | Auto renderer mitigates this (HTML on mobile); if desktop score is low, implement deferred Dart loading for settings/premium/video screens using `deferred as` imports |
| iOS Safari "Add to Home Screen" relies on manual user action (no install prompt) | Low-Medium | Document this in release notes; ensure `apple-touch-icon` meta tags are correct so the icon displays properly in the share sheet |
| `flutter run -d chrome` reveals additional mobile-only package imports not covered by the four stubs | Medium | Run a full `flutter build web` dry-run in Phase 1 and triage all compilation errors before stub count is declared final |
| Firebase App Check enforced mode blocks legitimate users during Phase 5 QA | Low | Keep App Check in monitoring mode throughout Phases 1–4; switch to enforced only after verifying attestation success rate >= 99% in the Firebase Console monitoring dashboard |
| Two-panel Chat layout conflicts with existing navigator state management | Low | Implement `embedded: bool` parameter as a pure presentation flag; keep all navigation logic in the existing router — the panel swap is a widget-level `setState`, not a route push |
| Phase 3 and Phase 4 running in parallel causes merge conflicts on shared screen files | Low | Assign Discover screen to one developer (responsive layout) and a separate developer to PWA shell work (web/ directory only); conflict surface is zero |

---

## Environment Setup

### Local Development
- **Prerequisites**:
  - Flutter 3.x with web target enabled (`flutter config --enable-web`)
  - Node.js 18+ and npm for Firebase CLI
  - Chrome browser (for testing web builds)
  - Firebase CLI (`npm install -g firebase-tools`)
- **Setup Steps**:
  1. Clone the repository and run `flutter pub get`
  2. Ensure `lib/firebase_options.dart` contains valid Firebase web config (from Firebase Console)
  3. Run `flutter run -d chrome` to launch the app in development mode
  4. Alternatively, build with `flutter build web --pwa-strategy=offline-first` and serve locally with `firebase serve`
- **Environment Variables**:
  - No `.env` file required; Firebase config is committed in `lib/firebase_options.dart`
  - Local testing: use the development Firebase project (configured in firebase.json)

### CI/CD Pipeline
- **Platform**: GitHub Actions (configured in `.github/workflows/`)
- **Stages**:
  1. **Lint & Test**: Run `flutter test` and `dart analyze` on every PR
  2. **Build Web**: Run `flutter build web --pwa-strategy=offline-first --release` to verify build integrity
  3. **Deploy to Staging**: Push built artifacts to a Firebase Hosting preview channel for QA
  4. **Deploy to Production**: On merge to `main`, deploy to the live Firebase Hosting channel
- **Triggers**:
  - PRs: run lint, test, and build stages (no deploy)
  - Merge to `main`: run all stages including production deploy

### Infrastructure
- **Hosting**: Firebase Hosting (gomeet.web.app and custom domain if configured)
- **Database**: Firestore (Google Cloud managed service)
- **Storage**: Firebase Storage (for profile photos, chat images)
- **Authentication**: Firebase Auth with email/password, Google Sign-In, and Phone/OTP
- **Analytics**: Firebase Analytics (pwa_install_prompt_shown, pwa_installed, custom events)
- **App Check**: Firebase App Check with reCAPTCHA v3 (enforced mode post-QA)
- **Secrets Management**:
  - Firebase config (apiKey, projectId, etc.) is committed in `lib/firebase_options.dart` (public values only)
  - Firebase project secrets (service account keys for backend) are stored in GitHub Secrets
  - reCAPTCHA site key is configured in Firebase Console and applied globally (no local storage needed)

### Deployment Strategy
- **Staging**:
  - Deploy to Firebase Hosting preview channels with `firebase hosting:channel:deploy <branch-name> --expires 7d`
  - Used for cross-browser QA, Lighthouse audits, and pre-production testing
  - Preview URLs are ephemeral and expire after 7 days
- **Production**:
  - Deploy to the live Firebase Hosting channel: `firebase deploy --only hosting`
  - Triggered automatically by CI/CD merge to `main`, or manually by DevOps via Firebase Console
  - Live URL: https://gomeet.web.app (and custom domain, if configured)
- **Rollback**:
  - Firebase Hosting automatically tracks release history in the Console
  - To rollback: Firebase Console → Hosting → Release history → click "Rollback" on a previous release
  - Rollback is instant (no rebuild required); the previous build artifacts are served immediately

---

## Out of Scope (v1 — deferred to v2)

The following are explicitly excluded from this plan. Stubs and banners handle them
gracefully in v1 without blocking launch.

| Feature | v1 Treatment | v2 Work |
|---------|-------------|---------|
| Video Calls (Agora Web SDK) | "Coming Soon on Web" banner on video call screen | Full Agora Web SDK integration, WebRTC permissions, browser compat testing |
| Premium Purchases (Razorpay Web JS) | "Subscribe via the GoMeet mobile app" notice | Razorpay Web JS interop, payment flow on web |
| Web Push Notifications (FCM VAPID) | In-app Firestore badges only; FCM token field written to Firestore for readiness | VAPID key setup, `firebase-messaging-sw.js`, background push |
| Full desktop layouts (> 1024 px) | Tablet layout (capped width, centred) shown above 1024 px | Custom desktop-optimised screen designs |
| Apple Sign-In on web | Not shown on web (requires separate web service ID) | Apple web OAuth configuration |
| CI/CD pipeline | Manual deploy (`flutter build web` + `firebase deploy`) | GitHub Actions: build → test → deploy on merge to `main` |
