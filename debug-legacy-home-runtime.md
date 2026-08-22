# Debug Session: legacy-home-runtime

- Status: OPEN
- Goal: identify and eliminate command prompt/runtime errors preventing the full application from launching and rendering the legacy home flow correctly
- Scope:
  - command prompt execution failures
  - stale/incomplete web build output
  - runtime blank-screen behavior after launch
  - authenticated landing path to legacy home experience

## Hypotheses

1. The IDE terminal wrapper exits before Flutter child compiler processes finish, leaving `build/web` partially stale.
2. The app reaches the current-source dev server, but runtime initialization fails before the first frame is painted.
3. A stale compiled route table or stale served bundle still targets the old placeholder screen instead of the current route map.
4. The legacy home flow still triggers an unresolved runtime dependency or async initialization blocker after routing succeeds.
5. Browser-side service worker or local caching is serving mismatched web artifacts across ports/build modes.

## Evidence Log

- Pre-fix runtime trace from `.dbg/trae-debug-log-legacy-home-runtime.ndjson`:
  - `index.html loaded` at `http://localhost:3008/`
  - `bootstrap load invoked` with `chosenRenderer=canvaskit`
  - no subsequent `entrypoint loaded`, `engine initialized`, or `runApp completed` events captured
- Browser reproduction on `http://localhost:3008/`:
  - page title `GoMeet`
  - visible result remained a black screen for 25 seconds
- Command-prompt compile blockers confirmed earlier from Flutter stderr:
  - invalid type/constructor: `FirebaseAccesstoken` in `lib/presentation/screens/BottomNavBar/home_screen.dart`
  - mismatched imports for `relationgoalmodel.dart` vs `relationGoalModel.dart`
- Release bundle audit:
  - `build/web/main.dart.js` still contains stale placeholder strings `Core PWA Environment Ready` and `GoMeet PWA`
  - compiled route table in `build/web/main.dart.js` does not match current `lib/core/routes.dart`
  - `build/web/main.dart.js` timestamp remained stale while wrapper-reported builds exited successfully
- Debug-server host limitation:
  - server could be started and reached initially on `127.0.0.1:7777`
  - process did not remain reliably alive across subsequent IDE-hosted reproductions

## Hypothesis Status

- A: early browser/bootstrap exception before mount -> INCONCLUSIVE
- B: Flutter bootstrap stalls before entrypoint/engine init -> CONFIRMED by missing post-bootstrap events
- C: served artifact/route table is stale relative to source -> CONFIRMED for `build/web`
- D: legacy home still has runtime dependency/init blocker -> PARTIALLY CONFIRMED from prior compile failures; remaining runtime blocker still not isolated to a single Dart file
- E: browser/service-worker/cache or host serving mismatch -> CONFIRMED in part by stale `build/web` output and wrapper process instability

## Fix Log

- Fixed compile blocker by removing invalid `FirebaseAccesstoken` bootstrap reference from `lib/presentation/screens/BottomNavBar/home_screen.dart`
- Fixed model-type mismatch by standardizing relation-goal imports to `relationgoalmodel.dart`
- Added route/auth instrumentation and bootstrap instrumentation for runtime tracing
- Updated `web/flutter_bootstrap.js` to stop forcing desktop `canvaskit` selection and let Flutter choose the default renderer unless explicitly requested

## Verification Log

- `flutter run -d web-server` launches without the previous command-prompt compile errors
- current-source app still renders as a black screen in IDE-hosted browser validation
- stable, fresh `build/web` regeneration has not yet been proven in this terminal host
