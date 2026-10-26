import SwiftUI
import FaceOffCore

struct GuessView: View {
    @ObservedObject var store: GameStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedID: String?
    @State private var confirmGuess = false

    private var selectedName: String { selectedID.flatMap { Roster.character(id: $0)?.name } ?? "this character" }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("One face. One chance.").font(.title.bold())
                Text("Choose your opponent’s secret. A correct guess wins. A wrong guess gives your opponent the win.")
                    .foregroundStyle(.secondary)
                Text("All 24 faces are available, including eliminated cards.").font(.caption).foregroundStyle(.secondary)
                GameGrid {
                    ForEach(Roster.all) { character in
                        CharacterCard(character: character, selected: selectedID == character.id,
                                      actionHint: "Double tap to select your final guess") {
                            selectedID = character.id
                        }
                    }
                }
            }
            .padding(20).frame(maxWidth: 900).frame(maxWidth: .infinity)
        }
        .background(Theme.background)
        .safeAreaInset(edge: .bottom) {
            Button(selectedID == nil ? "Choose your guess" : "Guess \(selectedName)") { confirmGuess = true }
                .buttonStyle(PrimaryButton()).disabled(selectedID == nil || !store.game.canGuess)
                .padding().background(.regularMaterial)
        }
        .alert("Is it \(selectedName)?", isPresented: $confirmGuess) {
            Button("Cancel", role: .cancel) {}
            Button("Make final guess", role: .destructive) {
                guard let id = selectedID else { return }
                store.perform { try $0.guess(id) }
                dismiss()
            }
        } message: { Text("This ends the game. If you’re wrong, your opponent wins.") }
        .navigationTitle("Final guess").navigationBarTitleDisplayMode(.inline)
    }
}

struct SecretReminderView: View {
    let character: FaceOffCore.Character?
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Eyebrow(text: "Only for your eyes")
                if let character {
                    AvatarView(character: character).frame(maxWidth: 220)
                    Text(character.name).font(.largeTitle.bold())
                    Text(character.attributeDescription).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
                Label("Close this before passing the phone.", systemImage: "lock.fill")
                    .font(.subheadline).multilineTextAlignment(.center)
            }
            .padding(28).frame(maxWidth: .infinity)
        }
        .navigationTitle("Your secret").navigationBarTitleDisplayMode(.inline)
    }
}
