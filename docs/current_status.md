# Current Status

## Project State

This workspace contains the current GoMeet Flutter web/PWA migration state with the latest route and startup adjustments applied in the active development copy.

## Latest Applied Changes

- Restored `web/flutter_bootstrap.js` to a standard Flutter loader path.
- Updated `scripts/web_dev.ps1` so `build/flutter_assets` is copied into `build/web/assets` after web builds.
- Changed the route generator so `/`, `/corePwaHome`, and `/homeScreen` target the legacy `HomeScreen`.
- Adjusted splash/session routing to favor `HomeScreen` instead of the earlier Core PWA landing path during local testing.

## Current Runtime Notes

- The static built bundle can render the onboarding/auth flow after asset sync.
- The current source configuration is aimed at opening the legacy `HomeScreen`.
- Final browser verification of direct `HomeScreen` startup is still inconsistent in the IDE runtime because local `flutter run -d web-server` sessions are intermittently exiting or refusing connections.

## Important References

- Primary route generator: `lib/core/routes.dart`
- Splash/session navigation logic: `lib/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart`
- Legacy home screen: `lib/presentation/screens/BottomNavBar/home_screen.dart`
- Local web build helper: `scripts/web_dev.ps1`
- Backup reference project: `E:\Works\Mandroid\Dating app\GoMeet Flutter code v1.5`

## Push Intent

This file was added as the requested current status summary for the next repository push.
