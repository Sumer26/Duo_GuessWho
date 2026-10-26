import SwiftUI
import FaceOffCore

struct ResultView: View {
    let outcome: Outcome
    let nextStarter: Player
    let rematch: () -> Void
    let newGame: () -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Image(systemName: "trophy.fill").font(.system(size: 54)).foregroundStyle(Theme.accent)
                Eyebrow(text: outcome.correct ? "A face well found" : "A bold guess")
                Text("\(outcome.winner.name) wins!")
                    .font(.system(.largeTitle, design: .rounded, weight: .heavy)).multilineTextAlignment(.center)
                Text(outcome.correct
                     ? "\(outcome.guesser.name) found \(name(outcome.targetID)). Mystery solved."
                     : "\(outcome.guesser.name) guessed \(name(outcome.guessedID)). The secret was \(name(outcome.targetID)).")
                    .foregroundStyle(.secondary).multilineTextAlignment(.center)
                if let target = Roster.character(id: outcome.targetID) {
                    AvatarView(character: target).frame(maxWidth: 180)
                    Text(target.name).font(.title2.bold())
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Both secrets, revealed").font(.headline)
                    reveal(player: .one, id: outcome.playerOneSecretID)
                    reveal(player: .two, id: outcome.playerTwoSecretID)
                }
                .padding(20).frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 20))
                VStack(spacing: 10) {
                    Button("Rematch · \(nextStarter.name) starts", action: rematch).buttonStyle(PrimaryButton())
                    Button("New game · Player 1 starts", action: newGame).frame(minHeight: 44).font(.headline)
                }
            }
            .padding(24).frame(maxWidth: 520).frame(maxWidth: .infinity)
        }
        .navigationTitle("Game over").navigationBarTitleDisplayMode(.inline)
    }
    private func name(_ id: String) -> String { Roster.character(id: id)?.name ?? id }
    private func reveal(player: Player, id: String) -> some View {
        HStack {
            Text(player.name).foregroundStyle(.secondary)
            Spacer()
            Text(name(id)).fontWeight(.semibold)
        }.accessibilityElement(children: .combine)
    }
}
