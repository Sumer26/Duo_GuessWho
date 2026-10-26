# iOS acceptance checklist

These checks require Xcode Simulator or a physical device. They have not been executed in the Linux authoring environment. Run them before shipping or distributing a build.

## Build and first launch

- Open `FaceOff.xcodeproj`, select FaceOff and an installed iPhone simulator, and build/run.
- Confirm the app icon appears and the welcome screen has readable text, two character portraits, Play, and How to Play.
- Open How to Play, scroll all rules, close, and start a game.
- Run `⌘U`; all 21 FaceOffTests should pass.
- Enable airplane mode on a device; play a complete match without internet access.

## Private setup

- Initial handoff names Player 1 and shows no selection or board.
- Continue; verify all 24 cards and their complete traits can be read.
- Confirm button is disabled before selecting. Select Arden, then Cleo; only Cleo remains marked. Confirm Cleo.
- Verify Player 2’s handoff appears immediately with no previous name or portrait.
- Player 2 selects Brio. Verify a separate Player 1 turn handoff appears.
- Continue as Player 1. Verify the own-secret reminder shows Cleo, then close it.
- Repeat setup using the same face for both players; both selections are permitted.

## Turn and board behavior

- On Player 1’s first turn, ask “Do they wear glasses?” against Brio. The answer is **No**.
- Verify the answer appears on the board, no cards auto-eliminate, and Final guess is unavailable for the rest of the turn.
- Eliminate and restore several cards. Verify the face switches at the flip midpoint and back labels read normally.
- Pass the phone. No board, clues, or secrets appear until Player 2 confirms readiness.
- Verify Player 2 has a fresh 24-card board and can ask the glasses question independently. Against Cleo it answers **Yes**.
- Eliminate different cards on Player 2’s board, pass, and verify Player 1’s prior eliminations and clues are preserved.
- Verify Player 1’s already-asked question is disabled and displays its prior answer in the picker.
- Eliminate all cards. Verify the recovery message and that tapping restores cards.
- Check a hat/no-hair combination (for example Vesper): cap **Yes**, no hair **Yes**, black hair **No**. Hats never imply a hair colour.

## Final guess and replay

- Start a fresh turn without asking. Open Final guess, select a face, then cancel the confirmation. The game and turn stay active.
- Confirm the correct target. Verify the guesser wins and both secret names are revealed correctly.
- In another match, confirm a wrong target. Verify the opponent wins and the actual target is shown.
- Test both paths for Player 2 as well as Player 1.
- Guess a previously eliminated card; the final-guess grid still offers all 24.
- Rematch: verify Player 2 selects and starts, boards and histories are empty, and both players must select again.
- Finish that match and rematch again: verify Player 1 starts.
- New game always resets to Player 1. The home button’s Cancel preserves the match; confirmed New game or Return to welcome clears it.

## Privacy interruptions

- During secret selection, while the reminder sheet is open, and while a final-guess confirmation is open, background the app. Inspect the app-switcher snapshot and return.
- Confirm the privacy cover is visible, the sheet is dismissed, and resuming requires a deliberate button press.
- Open Control Center and return; the cover should require resume. Check the underlying turn/selection is preserved.
- Check VoiceOver cannot focus content beneath the cover or a dismissed sheet.
- Confirm neutral handoffs never animate the outgoing secret into view. This app does not prevent screenshots or intentional peeking.

## Layout and accessibility matrix

Use available simulators rather than relying on a specific unverified device model.

| Configuration | Check |
| --- | --- |
| Small iPhone, roughly 320–375 pt wide | No clipped names/traits; two columns where needed; buttons reachable |
| Standard iPhone, roughly 390 pt wide | Comfortable grid, readable clues, safe-area-aware bottom actions |
| Large iPhone and landscape | Grid gains columns; all content remains scrollable |
| iPad narrow/wide windows and rotation | Grid responds to available width, content stays within reading limits |
| Light and dark appearance | Surfaces, labels, selection borders, answers, and controls remain legible |
| Largest Dynamic Type accessibility sizes | Grid widens cards, text wraps, all actions remain accessible through scrolling |
| VoiceOver | Cards announce name, all traits, and state; buttons announce purpose; reading order follows the visible screen |
| Reduce Motion | Eliminations change immediately without 3D rotation |
| Increase Contrast / Differentiate Without Color | Text labels and checkmarks carry all game state; verify legibility |

For a future foldable or resized window, test only documented OS behavior once supported tooling exists. The current app uses available size, not hardware identity.
