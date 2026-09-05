# Vision Brief: GoMeet PWA

## The Problem

GoMeet is a fully developed Flutter dating app (swipe-based matching, real-time chat, video
calls, premium subscriptions, location-based discovery) that currently runs only on Android
and iOS. Users on desktop browsers or devices that cannot install native apps are completely
excluded. The app already has early web scaffolding (`kIsWeb` guards, `CorePwaHomeScreen`,
`flutter_web_plugins`) but is not yet deployable as a Progressive Web App.

## The Vision

Transform the existing GoMeet Flutter codebase into a fully functional Progressive Web App
that runs in any modern browser, can be installed to a home screen or desktop, and delivers
a near-native experience — without abandoning the existing Dart/Flutter code or rewriting
the product from scratch.

## Target Users

- **End users** who discover GoMeet via a browser link and want to use it without installing
  a native app.
- **End users on desktop/laptop** (Windows, macOS, Linux) where no native app exists.
- **Development team** who need a single codebase to maintain across mobile and web.

## Core Value Proposition

Flutter Web lets the team ship to web with ~95% code reuse. By adding proper PWA
configuration (web manifest, service worker, HTTPS), resolving the handful of
mobile-only package incompatibilities, and completing the partially started web screens,
GoMeet becomes available to any user with a browser — faster than any alternative approach.

## Key Capabilities

1. **Full Flutter Web build** — `flutter build web --pwa-strategy=offline-first` producing
   a deployable PWA with manifest and service worker.
2. **Web-compatible package resolution** — Replace or conditionally stub packages that do
   not support web: `permission_handler`, `flutter_local_notifications`, `agora_rtc_engine`
   (web SDK), `razorpay_flutter` (Razorpay web JS), `camera` (browser `getUserMedia`).
3. **Firebase fully enabled on web** — `firebase_core` web initialisation (the current
   `main.dart` skips `Firebase.initializeApp` on web — this must be fixed).
4. **PWA shell complete** — `CorePwaHomeScreen` wired up, all routes reachable on web,
   responsive layouts where needed.
5. **Installable & offline-ready** — `manifest.json` with correct icons/theme colour,
   service worker caching strategy so the app shell loads without network.

## Success Criteria

- `flutter run -d chrome` launches the app without runtime errors.
- `flutter build web` produces a valid PWA (Lighthouse PWA score >= 90).
- All core user flows work in Chrome/Firefox/Safari: sign-up, profile creation, swipe/match,
  chat, notifications (web push), premium purchase.
- Firebase Auth, Firestore, and Firebase Messaging are fully operational on web.
- The app can be installed to the desktop/home screen and opens without a browser chrome.

## Open Questions

1. **Video calls on web** — `agora_rtc_engine` has a web SDK but requires separate
   initialisation. Should video calling be deferred for a later web phase, or included in
   v1?
2. **Payment gateway** — Razorpay has a web JS SDK. Do we integrate it directly or
   temporarily disable premium purchases on web?
3. **Responsive design** — Are any screens expected to adapt to wider desktop viewports,
   or is a fixed mobile-width shell sufficient?
4. **Hosting target** — Where will the PWA be deployed? (Firebase Hosting, Vercel, custom
   server?) This affects service worker and HTTPS setup.
5. **Notifications on web** — Web push via Firebase Messaging requires a VAPID key and
   `firebase-messaging-sw.js`. Is this in scope for v1?
