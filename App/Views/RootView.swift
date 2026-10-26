import SwiftUI
import FaceOffCore

enum GameSheet: String, Identifiable {
    case help, questions, guess, secret
    var id: String { rawValue }
}

@MainActor
struct RootView: View {
    @StateObject private var store = GameStore()
    @Environment(\.scenePhase) private var scenePhase
    @State private var sheet: GameSheet?
    @State private var privacyLocked = false
    @State private var confirmExit = false

    var body: some View {
        ZStack {
            NavigationStack {
                phaseView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.background.ignoresSafeArea())
                    .toolbar {
                        if store.game.phase != .welcome {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button { confirmExit = true } label: {
                                    Image(systemName: "house")
                                }.accessibilityLabel("Return to welcome")
                            }
                        }
                    }
                    .confirmationDialog("Leave this game?", isPresented: $confirmExit, titleVisibility: .visible) {
                        Button("New game", role: .destructive) { store.perform { $0.startNewGame() } }
                        Button("Return to welcome", role: .destructive) { store.perform { $0.returnToWelcome() } }
                    } message: { Text("The current game will be cleared.") }
            }
            .accessibilityHidden(privacyLocked || scenePhase != .active)

            if privacyLocked || scenePhase != .active {
                PrivacyCover {
                    privacyLocked = false
                }
                .zIndex(10)
            }
        }
        .tint(Theme.accent)
        .sheet(item: $sheet) { item in
            NavigationStack {
                Group {
                    switch item {
                    case .help: HowToPlayView()
                    case .questions: QuestionPickerView(store: store)
                    case .guess: GuessView(store: store)
                    case .secret: SecretReminderView(character: store.game.ownSecret)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) { Button("Done") { sheet = nil } }
                }
            }
            .tint(Theme.accent)
            .accessibilityHidden(privacyLocked || scenePhase != .active)
            .overlay {
                if privacyLocked || scenePhase != .active {
                    Theme.background.ignoresSafeArea()
                }
            }
        }
        .alert("Unable to continue", isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } }
        )) { Button("OK") { store.errorMessage = nil } }
        message: { Text(store.errorMessage ?? "") }
        .onChange(of: scenePhase) { phase in
            if phase != .active {
                privacyLocked = true
                sheet = nil
                confirmExit = false
            }
        }
    }

    @ViewBuilder private var phaseView: some View {
        switch store.game.phase {
        case .welcome:
            WelcomeView(play: { store.perform { $0.startNewGame() } }, help: { sheet = .help })
        case .handoff(let player, let purpose):
            HandoffView(player: player, purpose: purpose) {
                store.perform { try $0.acknowledgeHandoff() }
            }
        case .selecting(let player):
            SelectionView(player: player) { id in store.perform { try $0.selectSecret(id) } }
                .id(player)
        case .turn(let player):
            BoardView(store: store, player: player, showSheet: { sheet = $0 })
                .id(player)
        case .finished(let outcome):
            ResultView(outcome: outcome, nextStarter: store.game.startingPlayer.opponent,
                       rematch: { store.perform { try $0.rematch() } },
                       newGame: { store.perform { $0.startNewGame() } })
        }
    }
}

struct PrivacyCover: View {
    let resume: () -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill").font(.system(size: 64)).foregroundStyle(Theme.accent)
                Text("Secrets stay secret.").font(.largeTitle.bold()).multilineTextAlignment(.center)
                Text("Make sure the current player has the phone before continuing.")
                    .foregroundStyle(.secondary).multilineTextAlignment(.center)
                Button("Resume game", action: resume).buttonStyle(PrimaryButton())
            }
            .padding(28).frame(maxWidth: 520).frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
        .accessibilityElement(children: .contain)
    }
}
