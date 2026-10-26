# FaceOff

A native SwiftUI character deduction game for two people sharing one iPhone. FaceOff is a working title, with an original cast, original placeholder artwork, and no third-party branding or character assets.

## Open and run

Requires macOS with **Xcode 15 or later** (Swift 5.9+), and an **iOS 16 or later** simulator or device. Xcode 16+ is recommended. No project generator, paid dependency, backend, account, API key, or network connection is required by the game. Its local Swift package has no external dependencies.

1. Open **`FaceOff.xcodeproj`** in Xcode. Open the project rather than `Package.swift` to run the iOS app.
2. Select the shared **FaceOff** scheme.
3. Select an installed iPhone simulator and press **Run** (`⌘R`).
4. For a physical device, select your development team under the FaceOff target’s Signing & Capabilities and change `com.example.faceoff` to a unique bundle identifier. A simulator needs no development team.
5. Choose **Let’s play**. Give Player 1 the phone at the handoff screen and follow the private selections.

The project contains app and hosted XCTest targets. The local **FaceOffCore** package supplies the rules to both. Xcode builds it directly; there is no generation step or remote package resolution.

Command-line builds on a Mac:

```sh
# Show simulator destinations installed on this Mac.
xcodebuild -showdestinations -project FaceOff.xcodeproj -scheme FaceOff

# Substitute a simulator UUID from the output above.
xcodebuild -project FaceOff.xcodeproj -scheme FaceOff \
  -destination 'platform=iOS Simulator,id=SIMULATOR_UUID' build

xcodebuild -project FaceOff.xcodeproj -scheme FaceOff \
  -destination 'platform=iOS Simulator,id=SIMULATOR_UUID' test
```

## How a match works

- Both players choose one secret privately, with a neutral handoff before each selection and each turn. Both may choose the same character.
- Player 1 starts a new game. Each turn allows **one question or one final guess**.
- Questions have predefined yes/no predicates. The app answers using the opponent’s secret, records the clue, and leaves elimination to the player.
- Tap cards to eliminate them; tap again to restore them. Each player’s board and question history are independent. Elimination never changes the secret or the answers.
- After a question, flip any cards you want and choose **Pass to Player …**. You cannot guess after asking on that turn.
- A correct final guess wins. A wrong final guess immediately awards the opponent the win. Guesses require confirmation, and all 24 characters remain available to guess.
- Questions cannot be repeated by the same player. After all 14 are used, passing remains available so a match cannot get stuck.
- **Rematch** clears both secrets, histories, and boards and alternates the starting player. **New game** resets everything and starts with Player 1.
- The home button offers a confirmed reset or return to the welcome screen.

The app is session-only. It does not save an unfinished match across app termination. There are no timers, analytics, advertisements, accounts, purchases, network calls, or permissions.

## Project structure

```text
FaceOff.xcodeproj/               Ready-to-open project and shared scheme
App/
  FaceOffApp.swift               App entry point
  GameStore.swift               Main-actor observable adapter for the rules
  Theme.swift                   Semantic surfaces, accent, buttons, adaptive grid
  Components/
    AvatarView.swift            Original, on-device vector placeholders
    CharacterCard.swift         Accessible card and two-sided flip animation
  Views/                        Welcome, rules, handoff, selection, board,
                                questions, guess, reminder, and result screens
  Assets.xcassets/              Light/dark accent and original placeholder icon
Sources/FaceOffCore/
  Character.swift              Typed character attributes
  Roster.swift                 24 stable IDs and structured character records
  Question.swift               14 explicit, deterministic predicates
  GameState.swift              Value-type rules and guarded phase transitions
Tests/FaceOffCoreTests/         Shared XCTest suite (package and iOS target)
Docs/Manual-Test-Plan.md        Simulator/device acceptance checks
Docs/Validation.md             Verification performed and limitations
Package.swift                  Portable, dependency-free rules package
```

`GameState` has no SwiftUI dependency. Every rule mutation goes through a guarded method. Its secret dictionary is private: the UI can only read the active player’s own reminder during a turn, or both secrets after a match finishes. Neutral handoff phases expose no current board, answers, active player, or secret. Views never calculate an answer or decide a winner. `GameStore` publishes changes and translates errors for presentation.

To replace the placeholders, keep roster IDs and typed attributes stable, then replace `AvatarView` with bundled artwork keyed by those IDs. Traits on the cards, VoiceOver descriptions, and question answers all use the same data. Every character has a unique answer signature across the question set.

## Layout, accessibility, and privacy

The app uses standard `NavigationStack`, sheets, lists, `safeAreaInset`, and an adaptive `LazyVGrid`. iPhone layouts usually show two or three columns depending on available width; larger text increases minimum card width. Scrollable content and a capped reading width allow landscape, iPad, and future window sizes without device-model checks or speculative foldable APIs. Controls use safe areas rather than screen bounds.

System surfaces and labels follow light/dark mode. Accent colors have light/dark variants. Character buttons describe all traits and expose selected/eliminated states to VoiceOver. Cards use text as well as visual markers. Dynamic Type uses semantic fonts. Reduce Motion replaces the 3D flip with an immediate state change.

Selections are confirmed into a neutral handoff without a crossfade. Optional secret reminders live in a dismissible sheet. Leaving the active scene dismisses sheets and covers the interface; returning requires a privacy resume action. This is a courtesy privacy flow for a shared phone, not authentication or screenshot prevention. Players still need to look away and pass the phone fairly. Verify app-switcher behavior on a real device using the manual checklist.

## Tests

In Xcode, choose **Product → Test** (`⌘U`) with an iPhone simulator selected. For the portable rules only, use a Swift 5.9+ toolchain on macOS or Linux:

```sh
swift test
```

The 21 tests cover all question answers, 24 unique deduction signatures, all 576 secret pairs, private setup and handoffs, per-player histories and eliminations, restoration, invalid actions, turn limits, exhausted questions, wins/losses for both players, reset, and alternating rematches. See `Docs/Validation.md` for what was actually executed here.
