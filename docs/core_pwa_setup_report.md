# Core PWA Setup Report

## Scope
This report documents the completed core Progressive Web App setup for the GoMeet Flutter project, focused on the initial browser-safe experience:

- Splash screen
- Onboarding flow
- Authentication entry flow
- Registration entry flow
- Browser-safe post-auth landing screen
- PWA shell configuration in `web/`

Google Ads and Push Notifications were intentionally excluded from the runtime scope for this phase, per task direction.

## Completed Infrastructure Work

### 1. Core startup isolation
Updated the application bootstrap so the core PWA path no longer depends on mobile-only startup services.

- `lib/main.dart`
  - Reduced startup providers and blocs to the core set required for splash, onboarding, and auth.
  - Enabled clean web URLs with `usePathUrlStrategy()`.
  - Stopped eager mobile-only startup initialization for the PWA path.
  - Kept Firebase initialization limited to non-web startup in this phase.

### 2. Session persistence fix
Corrected the persisted login key mismatch that previously broke splash-to-auth restoration.

- `lib/data/localdatabase.dart`
  - Standardized the saved key to `UserLogin`.
  - Added backward-compatible fallback support for legacy `UserLogn`.

### 3. Splash flow hardening
Stabilized splash behavior for web and API failure cases.

- `lib/presentation/screens/splash_bording/splash_screen.dart`
  - Added safe defaults for maintenance and OTP flags when the SMS config API fails.
  - Preserved splash transition behavior without blocking on non-core services.

### 4. Browser-safe onboarding provider
Updated onboarding state to support browser execution.

- `lib/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart`
  - Added in-memory image bytes for selected signup images.
  - Removed browser geolocation permission forcing during splash.
  - Redirected restored sessions into the core PWA shell for this phase.

### 5. Authentication page cleanup
Removed camera dependency from the authentication entry page.

- `lib/presentation/screens/splash_bording/auth_screen.dart`
  - Removed eager camera permission request.
  - Redirected successful auth into the core PWA shell.

### 6. Onboarding screen cleanup
Removed dependency on notification permission code imported from unrelated chat features.

- `lib/presentation/screens/splash_bording/onbording_screens.dart`
  - Removed `requestPermission()` call and non-core imports.

### 7. Web-safe registration upload handling
Made the registration flow compatible with browser file uploads.

- `lib/Logic/cubits/onBording_cubit/onbording_cubit.dart`
  - Added browser-safe multipart upload using `MultipartFile.fromBytes(...)`.
  - Kept mobile upload behavior through `MultipartFile.fromFile(...)`.
  - Skipped OneSignal and Firebase chat bootstrap on web in this phase.

### 8. Firebase chat bootstrap safety
Prevented browser path failures when Firebase runtime services are not initialized for this phase.

- `lib/presentation/firebase/auth_firebase.dart`
  - Added early return on web or missing Firebase app initialization.

### 9. Push notification guard
Prevented push initialization from running in browser mode during this phase.

- `lib/core/push_notification_function.dart`
  - Added a web no-op guard.

### 10. Core route isolation
Scoped route generation to the PWA core flow so mobile-only screens are not pulled into the current browser slice.

- `lib/core/routes.dart`
  - Reduced routes to splash, onboarding, auth, password recovery, create steps, login, and core PWA home.

### 11. Browser-safe auth completion target
Replaced full-app navigation with a core web landing page for validated auth completion.

- `lib/presentation/screens/auth/login_screen.dart`
- `lib/presentation/screens/splash_bording/creat_steps.dart`
- `lib/presentation/screens/pwa/core_pwa_home_screen.dart`

The new PWA landing screen confirms the post-auth shell is functional and supports logout/session reset.

### 12. Browser-safe image preview
Removed `dart:io` dependency from the registration screen image preview path.

- `lib/presentation/screens/splash_bording/creat_steps.dart`
  - Replaced `FileImage` previews with `MemoryImage` previews sourced from onboarding provider state.

## PWA Web Configuration

### Updated files
- `web/index.html`
- `web/manifest.json`

### Changes applied
- Branded the app as `GoMeet`
- Updated theme and background colors for installable PWA presentation
- Added viewport and theme-color metadata
- Configured dynamic renderer preference:
  - desktop defaults toward `canvaskit`
  - smaller screens default toward `auto`
- Retained Flutter service worker registration flow

## Dependency Integration Notes

### Existing dependencies reused
No new package dependencies were required for this phase.

The current implementation uses already-declared packages and SDK libraries:

- `firebase_core`
- `firebase_auth`
- `provider`
- `flutter_bloc`
- `shared_preferences`
- `image_picker`
- `dio`
- `flutter_web_plugins`

### Deferred runtime integrations
The following packages remain intentionally excluded from the active browser runtime for this phase:

- `google_mobile_ads`
- `onesignal_flutter`
- `flutter_local_notifications`
- broader chat/video/profile modules that still include mobile-specific behavior

## Files Changed

- `lib/main.dart`
- `lib/data/localdatabase.dart`
- `lib/presentation/screens/splash_bording/splash_screen.dart`
- `lib/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart`
- `lib/presentation/screens/splash_bording/auth_screen.dart`
- `lib/presentation/screens/splash_bording/onbording_screens.dart`
- `lib/Logic/cubits/onBording_cubit/onbording_cubit.dart`
- `lib/presentation/firebase/auth_firebase.dart`
- `lib/core/push_notification_function.dart`
- `lib/core/routes.dart`
- `lib/presentation/screens/auth/login_screen.dart`
- `lib/presentation/screens/splash_bording/creat_steps.dart`
- `lib/presentation/screens/pwa/core_pwa_home_screen.dart`
- `web/index.html`
- `web/manifest.json`

## Validation Status

### Analyzer status
`flutter analyze` now completes successfully in the current local environment.

- result: command exits successfully
- current state: analyzer reports warnings and informational lints, but no blocking execution failure
- implication: analysis does not prevent local web run/build commands from executing

### Local launch status
The local environment is now able to resolve the Flutter SDK from `android/local.properties`:

- `flutter.sdk=E:\\Software\\flutter`
- verified Flutter version: `3.44.6`
- verified Python version: `3.12.10`
- verified web build command: `flutter build web --release`
- verified Chrome device availability through `flutter doctor -v`
- verified debug startup output for `flutter run -d chrome`

## Terminal Command Investigation

### Root causes identified

1. Earlier command guidance was outdated for the installed Flutter toolchain.
   - obsolete examples used `--web-renderer`
   - obsolete examples suggested `flutter create . --platforms web` even though `web/` already exists

2. Flutter availability was environment-dependent.
   - `flutter` may not be available on `PATH`
   - the reliable SDK source for this workspace is `android/local.properties`

3. Relative command execution was fragile in reused IDE terminals.
   - some reused terminals remained inside `build\web`
   - relative paths such as `.\scripts\web_dev.ps1` failed from that location

4. Long-running commands were affected by the IDE terminal wrapper.
   - `flutter run -d chrome` and `python -m http.server 8000` can appear to stop or return incomplete console output inside the wrapper
   - direct child-process validation confirmed the commands do start correctly outside that wrapper behavior

### Fixes implemented

- Updated the report commands to match Flutter `3.44.6`
- Added `scripts/web_dev.ps1` to resolve Flutter automatically from either:
  - `PATH`
  - `android/local.properties`
- Standardized the documented commands to use absolute script paths so they work even if the terminal is not currently at the repo root
- Revalidated dependency restore, analysis, web build, Chrome debug startup, and static local serving

## Current Readiness

- [x] Splash flow adapted for browser-safe startup
- [x] Onboarding flow adapted for browser-safe startup
- [x] Authentication entry flow adapted for browser-safe startup
- [x] Registration entry flow adapted for browser-safe image selection/upload
- [x] Session restore logic fixed
- [x] PWA metadata updated
- [x] Core route shell added
- [x] Local browser build command executed in this IDE session
- [x] Chrome debug startup validated in this IDE session
- [x] Static local server startup validated in this IDE session

## Fully Tested Commands

### Preferred command wrapper

Use the helper script added in this task:

- script path: `scripts/web_dev.ps1`
- purpose: resolves the Flutter executable automatically and runs commands from the correct project root

### Prerequisites

Before running any of the commands below, ensure:

- Flutter SDK exists at `E:\Software\flutter` or is available on `PATH`
- Google Chrome is installed
- Python 3 is installed for local static serving
- terminal has permission to execute PowerShell scripts

### Step 1: Verify the environment

Run:

```powershell
powershell -ExecutionPolicy Bypass -File "e:\Works\Mandroid\Dating app\Development\GoMeetFlutter\scripts\web_dev.ps1" doctor
```

Expected output:

- Flutter version information
- Chrome listed as an available web device
- Android toolchain warnings may appear, but they do not block web development

### Step 2: Restore dependencies

Run:

```powershell
powershell -ExecutionPolicy Bypass -File "e:\Works\Mandroid\Dating app\Development\GoMeetFlutter\scripts\web_dev.ps1" pub-get
```

Expected output:

- `Resolving dependencies...`
- `Downloading packages...`
- `Got dependencies!`

### Step 3: Run static analysis

Run:

```powershell
powershell -ExecutionPolicy Bypass -File "e:\Works\Mandroid\Dating app\Development\GoMeetFlutter\scripts\web_dev.ps1" analyze
```

Expected output:

- `Analyzing GoMeetFlutter...`
- warnings and infos may be listed
- command still exits successfully unless new blocking issues are introduced

### Step 4: Launch the application in Chrome

Run:

```powershell
powershell -ExecutionPolicy Bypass -File "e:\Works\Mandroid\Dating app\Development\GoMeetFlutter\scripts\web_dev.ps1" run
```

Expected output:

- `Launching lib\main.dart on Chrome in debug mode...`
- `Waiting for connection from debug service on Chrome...`
- after startup completes, Chrome opens the app

### Step 5: Build the production web bundle

Run:

```powershell
powershell -ExecutionPolicy Bypass -File "e:\Works\Mandroid\Dating app\Development\GoMeetFlutter\scripts\web_dev.ps1" build
```

Expected output:

- Flutter web build runs successfully
- `build\web` is generated or refreshed

### Step 6: Serve the built web app locally

Run:

```powershell
powershell -ExecutionPolicy Bypass -File "e:\Works\Mandroid\Dating app\Development\GoMeetFlutter\scripts\web_dev.ps1" serve -Port 8000
```

Then open:

```text
http://localhost:8000
```

Expected output:

- Python starts a local HTTP server
- the built application is reachable at `http://localhost:8000`

## Direct Flutter Commands

Use these if you prefer not to use the helper script.

### Development run

```powershell
cd "e:\Works\Mandroid\Dating app\Development\GoMeetFlutter"
& "E:\Software\flutter\bin\flutter.bat" --version
& "E:\Software\flutter\bin\flutter.bat" pub get
& "E:\Software\flutter\bin\flutter.bat" analyze
& "E:\Software\flutter\bin\flutter.bat" run -d chrome
```

### Production build and static serve

```powershell
cd "e:\Works\Mandroid\Dating app\Development\GoMeetFlutter"
& "E:\Software\flutter\bin\flutter.bat" build web --release
cd "e:\Works\Mandroid\Dating app\Development\GoMeetFlutter\build\web"
python -m http.server 8000
```

## Notes

- Do not run `flutter create . --platforms web` unless the `web/` folder is missing and needs to be regenerated.
- Do not use `--web-renderer canvakit` with the current Flutter `3.44.6` command examples in this report; the project already selects the renderer through `web/flutter_bootstrap.js`.
- `flutter run -d chrome` is the primary command to launch the application in local development.
- The helper script is safer than relative manual commands because it always resolves the project root before running Flutter.

## Troubleshooting Notes

### `flutter` is not recognized

Use the helper script or the explicit SDK path:

```powershell
& "E:\Software\flutter\bin\flutter.bat" --version
```

### `.\scripts\web_dev.ps1` cannot be found

This usually means the terminal is not at the repo root. Use the absolute script path documented above instead of a relative path.

### `flutter doctor -v` shows Android or Visual Studio issues

- Android cmdline-tools and license warnings do not block web execution
- Visual Studio warnings do not block Chrome/web execution

### `flutter run -d chrome` seems to stop inside the IDE terminal

This can be caused by the IDE terminal wrapper for long-running processes. The command itself was validated to reach Chrome debug startup successfully. If needed, rerun it in a fresh PowerShell terminal outside the IDE-integrated wrapper.

### `python -m http.server 8000` fails

- confirm `build\web` exists first
- run the build command before serve
- ensure Python 3 is installed and available on `PATH`
- try another port, for example `-Port 8080` in the helper script or `python -m http.server 8080`

## Recommended Validation Steps

After launching with `flutter run -d chrome` or serving the release build, validate:

- splash loads without permission prompts
- onboarding advances correctly
- login completes and opens the core PWA shell
- registration image selection previews correctly in browser
- refresh restores authenticated session into the core PWA shell
