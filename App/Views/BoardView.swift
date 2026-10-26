import SwiftUI
import FaceOffCore

struct BoardView: View {
    @ObservedObject var store: GameStore
    let player: Player
    let showSheet: (GameSheet) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Eyebrow(text: "Turn \(store.game.turnNumber) · \(player.name)")
                        Text("Find their face.").font(.largeTitle.bold())
                    }
                    Spacer(minLength: 8)
                    VStack(spacing: 2) {
                        Text("\(store.game.currentBoard?.remainingCount ?? 24)").font(.title.bold())
                        Text("remaining").font(.caption2).foregroundStyle(.secondary)
                    }
                    .padding(12).background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
                    .accessibilityElement(children: .combine)
                }
                if let answer = store.game.answerThisTurn {
                    AnswerBanner(record: answer)
                    Text("Tap faces to eliminate or restore them, then pass the phone.")
                        .font(.subheadline).foregroundStyle(.secondary)
                } else {
                    Text(store.game.availableQuestions.isEmpty
                         ? "All questions used. Make a final guess or pass your turn."
                         : "Ask a question, or take a chance with a final guess. Tap cards to flip them.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                if store.game.currentBoard?.remainingCount == 0 {
                    Label("No faces left? Tap a card to restore it. All faces are available in Final guess.", systemImage: "arrow.uturn.backward")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                GameGrid {
                    ForEach(Roster.all) { character in
                        CharacterCard(character: character,
                                      eliminated: store.game.currentBoard?.eliminated.contains(character.id) ?? false) {
                            store.perform { try $0.toggleElimination(character.id) }
                        }
                    }
                }
                if let history = store.game.currentBoard?.history, !history.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your clues").font(.title3.bold())
                        ForEach(history.reversed()) { record in
                            HStack(alignment: .top) {
                                Text(record.question.text).font(.subheadline)
                                Spacer()
                                Text(record.answer ? "YES" : "NO").font(.caption.bold()).foregroundStyle(Theme.accent)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .padding(18).background(Theme.surface, in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(20).frame(maxWidth: 900).frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 6) {
                if store.game.canEndTurn {
                    Button { store.perform { try $0.endTurn() } } label: {
                        Label("Pass to \(player.opponent.name)", systemImage: "arrow.right")
                    }.buttonStyle(PrimaryButton())
                } else {
                    Button { showSheet(.questions) } label: {
                        Label("Ask a question", systemImage: "text.bubble")
                    }.buttonStyle(PrimaryButton()).disabled(!store.game.canAsk)
                }
                Button("Make a final guess") { showSheet(.guess) }
                    .font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity, minHeight: 44)
                    .disabled(!store.game.canGuess)
                    .accessibilityHint("A wrong guess ends the game and your opponent wins")
            }
            .padding(.horizontal, 20).padding(.top, 10).background(.regularMaterial)
        }
        .navigationTitle(player.name).navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button { showSheet(.help) } label: { Image(systemName: "questionmark.circle") }
                    .accessibilityLabel("How to play")
                Button { showSheet(.secret) } label: { Image(systemName: "person.crop.square") }
                    .accessibilityLabel("Privately remind me of my secret character")
            }
        }
    }
}

struct AnswerBanner: View {
    let record: AnswerRecord
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(record.answer ? "YES" : "NO")
                .font(.title2.weight(.black)).foregroundStyle(Theme.accent)
            VStack(alignment: .leading, spacing: 4) {
                Text(record.question.text).font(.headline)
                Text("Your opponent’s character \(record.answer ? "matches" : "doesn’t match").")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }
}
