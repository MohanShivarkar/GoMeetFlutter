# Product Requirements Document: GoMeet PWA — v1 Web Launch

**Phase:** Definition
**Date:** 2026-08-22
**Status:** Draft — awaiting confirmation
**Preceding Document:** `01-vision-brief.md`

---

## Overview

GoMeet is a fully developed Flutter dating app (swipe-based matching, real-time chat, video
calls, premium subscriptions, location-based discovery) that today ships only on Android and
iOS. This PRD defines the requirements to transform the existing codebase into a **fully
functional Progressive Web App (PWA)** with ~95% code reuse, targeting v1 launch on Firebase
Hosting.

The v1 web release covers: Firebase web initialisation, web-compatible package resolution,
the complete core user journey (sign-up → profile → discover → match → chat), installability
from the browser, and responsive layouts for **mobile and tablet viewports**. Video calls,
premium purchases, and web push notifications are explicitly scoped to v2.

---

## User Personas

### Persona 1 — The Browser Discoverer
- **Who**: Someone who receives a GoMeet link (social media share, referral, or ad) and
  opens it in a browser on their phone or tablet without wanting to install a native app.
- **Goals**: Try the app immediately, create a profile, and start swiping — zero friction.
- **Pain Points**: Being redirected to an app store install page and abandoning the funnel;
  lack of web fallback.

### Persona 2 — The Desktop / Laptop User
- **Who**: A Windows, macOS, or Linux user who wants to use GoMeet from their computer
  where no native app exists.
- **Goals**: Use GoMeet during work breaks or from home on a larger screen; install the PWA
  to their desktop for quick access.
- **Pain Points**: Completely excluded today — no native desktop app exists.

### Persona 3 — The Tablet User
- **Who**: Uses an iPad or Android tablet; may have the mobile app but prefers browser-based
  access, or may not want to install another native app.
- **Goals**: Full GoMeet experience with a layout that takes advantage of the larger screen
  (e.g. wider chat view, bigger swipe cards).
- **Pain Points**: Mobile app renders in a small window or letterbox on tablets; web
  version is non-functional today.

### Persona 4 — The Development Team (Internal)
- **Who**: Flutter engineers maintaining GoMeet across platforms.
- **Goals**: A single Dart/Flutter codebase that builds and ships to Android, iOS, and Web
  without diverging codebases or separate web rewrites.
- **Pain Points**: Current `kIsWeb` guards are incomplete; mobile-only packages block the
  web build; `Firebase.initializeApp` is skipped on web causing runtime failures.

---

## User Stories

### Epic 1: Core App Shell & Firebase Web Initialisation

#### Story 1.1 — Firebase Web Init
**As a** browser discoverer, **I want** the app to connect to Firebase when I open it in
a browser, **so that** authentication, Firestore, and all real-time features work without
errors.

**Acceptance Criteria:**
- [ ] `main.dart` calls `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` on web (the current web skip is removed).
- [ ] `firebase_options.dart` includes valid web configuration (apiKey, authDomain, projectId, storageBucket, messagingSenderId, appId).
- [ ] `flutter run -d chrome` launches to the home screen with no Firebase-related console errors.
- [ ] Firebase Auth, Firestore, and Firebase Storage are all reachable in the browser.

#### Story 1.2 — PWA Shell & Route Completeness
**As a** browser discoverer, **I want** all app routes to be reachable from the browser
URL bar, **so that** I can navigate directly to any screen and the back button works correctly.

**Acceptance Criteria:**
- [ ] `CorePwaHomeScreen` is wired as the web entry route in the router.
- [ ] All primary routes (sign-in, sign-up, profile creation, discover, chat list, chat thread, profile view, settings) are reachable on web.
- [ ] Deep linking works: navigating to `/chat/:conversationId` opens the correct thread.
- [ ] Browser back / forward navigation behaves correctly (no double-pop or infinite redirect loops).
- [ ] 404 / unknown routes show a graceful error screen with a link back to home.

#### Story 1.3 — Web-Compatible Package Resolution
**As a** developer, **I want** the Flutter web build to compile and run without package
incompatibility errors, **so that** we can deploy to production.

**Acceptance Criteria:**
- [ ] `permission_handler` is stubbed on web via conditional import (web stub returns `PermissionStatus.granted` or a no-op).
- [ ] `flutter_local_notifications` is stubbed on web (no-op implementation; in-app notifications still work via Firestore listeners).
- [ ] `agora_rtc_engine` imports are guarded by `kIsWeb`; the video call screen shows a "Coming Soon on Web" banner instead of attempting to load the engine.
- [ ] `razorpay_flutter` imports are guarded by `kIsWeb`; the premium upgrade screen is hidden on web (replaced by a "Premium available on the mobile app" notice).
- [ ] `camera` plugin is replaced / conditionally swapped with `getUserMedia` (browser MediaDevices API) for profile photo capture on web.
- [ ] `flutter build web --pwa-strategy=offline-first` completes with zero compilation errors.

---

### Epic 2: Authentication & Onboarding

#### Story 2.1 — Sign Up on Web
**As a** browser discoverer, **I want** to create a GoMeet account directly in the browser,
**so that** I do not need to install the mobile app first.

**Acceptance Criteria:**
- [ ] Email + password sign-up works via Firebase Auth on web.
- [ ] Google Sign-In OAuth works via `firebase_auth` web provider (no native Google SDK needed).
- [ ] Phone/OTP sign-up works on web (Firebase Phone Auth with reCAPTCHA verifier).
- [ ] On successful sign-up the user is directed to the profile creation flow.
- [ ] Auth state is persisted across browser refreshes (Firebase `LOCAL` persistence).

#### Story 2.2 — Sign In on Web
**As a** returning user, **I want** to sign in to my existing GoMeet account from a browser,
**so that** my matches and conversations are available immediately.

**Acceptance Criteria:**
- [ ] Email + password and Google Sign-In work on web.
- [ ] "Remember me" session persists until explicit sign-out.
- [ ] Password reset email flow works on web.
- [ ] Incorrect credentials show a clear inline error (not a native alert dialog).

#### Story 2.3 — Profile Creation on Web
**As a** new browser discoverer, **I want** to complete my GoMeet profile in the browser,
**so that** I can start discovering matches.

**Acceptance Criteria:**
- [ ] All profile fields (name, age, bio, gender, preference, photos) are editable on web.
- [ ] Photo upload uses `getUserMedia` (camera capture) or file picker (`<input type="file">`) — no native `camera` plugin dependency.
- [ ] Photos are uploaded to Firebase Storage and thumbnails rendered correctly in the browser.
- [ ] Location is obtained via the browser Geolocation API (`window.navigator.geolocation`) as a fallback to the native location package.
- [ ] Profile creation stepper is usable on both mobile-width and tablet-width viewports.

---

### Epic 3: Core Features — Discover, Match & Chat

#### Story 3.1 — Swipe / Discover on Web
**As a** user, **I want** to swipe through profiles in the browser just as I do on mobile,
**so that** I can find matches without the native app.

**Acceptance Criteria:**
- [ ] Swipe cards render correctly on web (drag gesture works via mouse and touch).
- [ ] Like / Dislike / Super-Like actions fire correctly and write to Firestore.
- [ ] Match popup appears immediately when a mutual like is detected.
- [ ] Profile cards display photos, name, age, distance, and bio on web.
- [ ] Keyboard left/right arrow keys trigger dislike/like for accessibility.

#### Story 3.2 — Real-Time Chat on Web
**As a** matched user, **I want** to send and receive messages in real time via the browser,
**so that** I can chat with my matches without switching to the mobile app.

**Acceptance Criteria:**
- [ ] Chat thread opens and displays message history from Firestore.
- [ ] Sending a text message writes to Firestore and appears in real-time for both users.
- [ ] Message timestamps, read receipts, and sender avatars render correctly.
- [ ] Image sharing works via file picker upload to Firebase Storage.
- [ ] New messages trigger an in-app notification badge on the Chat tab while the app is open (no background push required for v1).
- [ ] Chat list shows unread counts and latest message previews.

#### Story 3.3 — Profile View & Settings
**As a** user, **I want** to view and edit my profile and settings from the browser,
**so that** I can keep my information up to date without the mobile app.

**Acceptance Criteria:**
- [ ] My Profile screen is fully editable on web (photos, bio, preferences).
- [ ] Settings screen (notifications, privacy, account) is reachable and functional.
- [ ] Sign-out from settings clears auth state and redirects to the sign-in screen.
- [ ] Account deletion flow works on web.

---

### Epic 4: PWA Installability & Offline Shell

#### Story 4.1 — Installable PWA
**As a** desktop or tablet user, **I want** to install GoMeet to my home screen or desktop
from the browser, **so that** I can open it like a native app without a browser address bar.

**Acceptance Criteria:**
- [ ] `web/manifest.json` is present and complete: `name`, `short_name`, `start_url`, `display: standalone`, `theme_color`, `background_color`, and icon set (192×192, 512×512, maskable variant).
- [ ] Chrome on Android shows the "Add to Home Screen" install prompt.
- [ ] Chrome on desktop shows the install icon in the address bar.
- [ ] Safari on iOS shows a "Add to Home Screen" option in the share sheet (requires `apple-touch-icon` meta tags).
- [ ] Installed PWA opens in standalone mode with no browser chrome.
- [ ] Lighthouse PWA audit score >= 90.

#### Story 4.2 — Offline App Shell
**As a** user with an unreliable connection, **I want** the app shell to load even without
network access, **so that** I see GoMeet instead of a browser error page.

**Acceptance Criteria:**
- [ ] Service worker is registered via `flutter_service_worker.js` using the `offline-first` strategy.
- [ ] The app shell (HTML, CSS, core Dart JS) is cached on first load.
- [ ] Navigating to the app while offline shows the shell with a friendly "You're offline — connect to continue" banner rather than a browser error page.
- [ ] Cache is updated in the background when the user is online (stale-while-revalidate for static assets).

---

### Epic 5: Responsive Layouts (Mobile + Tablet)

#### Story 5.1 — Tablet-Adaptive Discover Screen
**As a** tablet user, **I want** the Discover / swipe screen to take advantage of the
tablet's larger screen, **so that** profile cards are not tiny or awkwardly scaled.

**Acceptance Criteria:**
- [ ] At viewport widths >= 600 px, swipe cards scale up proportionally (max card width ~500 px, centred).
- [ ] Action buttons (Like, Dislike, Super-Like) reposition below the card and are sized for finger tapping on a tablet.
- [ ] No content overflow or horizontal scroll on any viewport from 320 px to 1024 px.

#### Story 5.2 — Tablet-Adaptive Chat Layout
**As a** tablet user, **I want** the chat experience to use the available screen width,
**so that** I can see my conversations list and the active chat thread side by side.

**Acceptance Criteria:**
- [ ] At viewport widths >= 768 px, the Chat screen renders in a two-panel layout: conversation list (left, ~280 px) + active thread (right, remaining width).
- [ ] On mobile-width viewports (<768 px), the layout remains single-panel (list → thread navigation as normal).
- [ ] Selecting a conversation on the left panel opens it in the right panel without a full-screen navigation push.

#### Story 5.3 — General Responsive Polish
**As any user**, **I want** all screens to render correctly across mobile and tablet
viewport widths, **so that** nothing is cut off or inaccessible.

**Acceptance Criteria:**
- [ ] All screens pass manual viewport testing at 375 px (mobile), 768 px (tablet portrait), and 1024 px (tablet landscape / desktop).
- [ ] No text overflow, no widget clipping, no horizontal scroll on any screen.
- [ ] Bottom navigation bar is always visible and correctly spaced at all widths.
- [ ] Dialogs and modals are constrained to a max width of 500 px and centred on wider screens.

---

## Feature Priority

| Feature | Priority | Scope | Notes |
|---|---|---|---|
| Firebase web initialisation fix | P0 | v1 | Blocker for everything |
| Web-compatible package stubs | P0 | v1 | Required for `flutter build web` |
| Full Flutter web build (zero errors) | P0 | v1 | Core deliverable |
| Service worker + manifest.json | P0 | v1 | PWA compliance requirement |
| Email + Google Sign-In on web | P0 | v1 | Core user entry |
| Profile creation on web | P0 | v1 | Required before discover |
| Discover / Swipe on web | P0 | v1 | Core product value |
| Real-time Chat on web | P0 | v1 | Core product value |
| PWA installability (home screen) | P0 | v1 | Success criterion |
| All routes reachable on web | P0 | v1 | Shell completeness |
| Offline app shell (service worker) | P1 | v1 | Lighthouse score + UX |
| Tablet responsive layouts | P1 | v1 | Tablet persona (user decision) |
| Camera / file picker on web | P1 | v1 | Needed for profile photos |
| Browser Geolocation API | P1 | v1 | Replaces native location package |
| Phone/OTP auth on web | P1 | v1 | Sign-up parity |
| In-app notification badges (Firestore) | P1 | v1 | Basic notification UX |
| Video Calls (Agora Web SDK) | P2 | v2 | Deferred — stub with "Coming Soon" |
| Premium purchases (Razorpay Web JS) | P2 | v2 | Deferred — hidden on web in v1 |
| Web Push Notifications (FCM VAPID) | P2 | v2 | Deferred — no background push in v1 |
| Full desktop-optimised layouts (>1024 px) | P2 | v2 | Out of scope per user decision |

---

## Non-Functional Requirements

- **Performance**: Lighthouse Performance score >= 80; app shell first contentful paint < 3 s
  on a simulated 4G connection. Flutter web canvaskit renderer for visual fidelity;
  consider html renderer as fallback if bundle size is a concern.
- **Security**: HTTPS enforced via Firebase Hosting. Firebase Security Rules remain
  unchanged from mobile (no web-specific relaxation). No API keys exposed in client-side
  JS beyond what Firebase requires (use Firebase App Check if bot abuse is a concern post-launch).
- **Accessibility**: Flutter's built-in semantics tree must be enabled (`SemanticsDebugger`
  verified). Keyboard navigation must be possible for sign-in, sign-up, and chat. Colour
  contrast ratios >= 4.5:1 for all text.
- **Browser Support**: Latest 2 versions of Chrome, Firefox, Safari, and Edge. IE is not
  supported. Minimum mobile Safari iOS 14.
- **Bundle Size**: Total transfer size of the initial load should be <= 5 MB (gzipped).
  Defer non-critical Dart code with deferred loading where possible.
- **Analytics**: Existing Firebase Analytics events must fire on web (verify `logEvent`
  calls are not behind mobile-only guards).

---

## Hosting & Deployment

- **Platform**: Firebase Hosting (free Spark/Blaze tier).
- **Build command**: `flutter build web --pwa-strategy=offline-first --release`
- **Deploy command**: `firebase deploy --only hosting`
- **HTTPS**: Automatic via Firebase Hosting (custom domain support available).
- **URL rewrite**: `firebase.json` must include a catch-all rewrite to `index.html` for
  Flutter's client-side router to handle deep links correctly.
- **CI/CD**: GitHub Actions workflow recommended: `flutter build web` → `firebase deploy`
  on merge to `main`.

---

## Out of Scope (v1)

The following are explicitly **not** included in the v1 web release:

1. **Video Calls (Agora Web SDK)** — The video call screen will show a "Coming Soon on Web"
   banner. Full Agora web integration (WebRTC permissions, separate SDK init, browser
   compatibility testing) is scheduled for v2.
2. **Premium Purchases (Razorpay Web JS)** — The premium upgrade flow is hidden on web.
   A notice "Subscribe via the GoMeet mobile app" is shown instead. Razorpay web JS interop
   is scheduled for v2.
3. **Web Push Notifications (FCM VAPID)** — Background notifications require VAPID key
   setup and `firebase-messaging-sw.js`. Deferred to v2; in-app badges via Firestore
   listeners are sufficient for v1.
4. **Full Desktop-Optimised Layouts** — Viewport widths > 1024 px will show the tablet
   layout (capped width, centred). No custom desktop-only screen designs are in scope.
5. **Server-Side Rendering (SSR)** — Flutter web does not support SSR; this is a known
   limitation and not in scope for any phase.
6. **Apple Sign-In on web** — Apple's web OAuth requires a separate web service ID
   configuration; deferred unless prioritised by the team.

---

## Open Questions

> Questions that should be resolved before or during implementation.

| # | Question | Owner | Status |
|---|---|---|---|
| 1 | What is the Firebase project ID and web app config for `DefaultFirebaseOptions`? | Dev Lead | Open |
| 2 | Which custom domain (if any) will the PWA be served on? | Product | Open |
| 3 | Should the `html` or `canvaskit` renderer be used? (canvaskit = better fidelity, larger download; html = smaller, some visual differences) | Tech Lead | Open |
| 4 | Does the existing Firestore Security Rules allow web clients (check `request.auth` vs platform checks)? | Dev Lead | Open |
| 5 | Is Firebase App Check needed for the web client to prevent API abuse? | Product / Security | Open |
| 6 | What is the target launch date for v1 web? | Product | Open |

---

## Success Criteria (Definition of Done)

- [ ] `flutter run -d chrome` launches GoMeet without runtime errors or red-screen crashes.
- [ ] `flutter build web --pwa-strategy=offline-first` completes with zero errors.
- [ ] Lighthouse PWA score >= 90 in Chrome DevTools.
- [ ] All P0 user flows verified end-to-end in Chrome, Firefox, and Safari: sign-up → profile creation → discover → match → chat.
- [ ] App installs to Android home screen (Chrome) and macOS desktop (Chrome) and opens in standalone mode.
- [ ] Firebase Auth, Firestore, and Firebase Storage are fully operational on web.
- [ ] Tablet layout (768 px) passes manual QA for Discover and Chat screens.
- [ ] No horizontal scroll or content clipping at 375 px, 768 px, or 1024 px viewport widths.
- [ ] App shell loads (from service worker cache) when the device is offline.
