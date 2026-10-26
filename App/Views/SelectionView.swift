import SwiftUI
import FaceOffCore

struct HandoffView: View {
    let player: Player
    let purpose: HandoffPurpose
    let ready: () -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                Image(systemName: "iphone").font(.system(size: 68)).foregroundStyle(Theme.accent)
                Eyebrow(text: "A little privacy, please")
                Text("Pass to\n\(player.name)")
                    .font(.system(.largeTitle, design: .rounded, weight: .heavy)).multilineTextAlignment(.center)
                Text(purpose == .selection ? "Your secret is yours to choose.\nThe other player should look away." : "Your board is waiting.\nOnly continue when the phone is yours.")
                    .foregroundStyle(.secondary).multilineTextAlignment(.center)
                Button("I’m \(player.name) — ready", action: ready).buttonStyle(PrimaryButton())
                Label("No secrets on this screen", systemImage: "lock.fill")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(28).frame(maxWidth: 520).frame(maxWidth: .infinity)
        }
        .navigationTitle("Handoff").navigationBarTitleDisplayMode(.inline)
    }
}

struct SelectionView: View {
    let player: Player
    let select: (String) -> Void
    @State private var selectedID: String?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Eyebrow(text: "\(player.name) · Private selection")
                Text("Who’s your secret?").font(.largeTitle.bold())
                Text("Choose a face for your opponent to find. Confirm when you’re ready to hide your choice.")
                    .foregroundStyle(.secondary)
                GameGrid {
                    ForEach(Roster.all) { character in
                        CharacterCard(character: character, selected: selectedID == character.id,
                                      actionHint: "Double tap to choose as your secret") {
                            selectedID = character.id
                        }
                    }
                }
            }
            .padding(20).frame(maxWidth: 900).frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                if let id = selectedID { selectedID = nil; select(id) }
            } label: {
                Text(selectedID.flatMap { Roster.character(id: $0)?.name }.map { "Choose \($0) & hide" } ?? "Choose a character")
            }
            .buttonStyle(PrimaryButton()).disabled(selectedID == nil)
            .padding().background(.regularMaterial)
        }
        .navigationTitle(player.name).navigationBarTitleDisplayMode(.inline)
    }
}
