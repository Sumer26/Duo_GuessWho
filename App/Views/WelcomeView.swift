import SwiftUI
import FaceOffCore

struct WelcomeView: View {
    let play: () -> Void
    let help: () -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                HStack {
                    Label("THE OFFLINE FACE GAME", systemImage: "sparkle")
                        .font(.caption2.weight(.bold)).tracking(1.5)
                    Spacer()
                    Image(systemName: "circle.grid.2x2.fill").foregroundStyle(Theme.accent)
                }
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Many faces.\nOne secret.")
                        .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Meet FaceOff.").font(.title3.weight(.medium)).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    heroCard(Roster.all[2], rotation: -8)
                    heroCard(Roster.all[13], rotation: 8)
                }
                .padding(.vertical, 16)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 12) {
                    Text("FaceOff").font(.system(.largeTitle, design: .rounded, weight: .black))
                    Text("A little curiosity. A clever question.\nCan you find their face first?")
                        .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 16) {
                        Label("2 players", systemImage: "person.2")
                        Label("1 phone", systemImage: "iphone")
                    }.font(.subheadline.weight(.medium)).padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 12) {
                    Button(action: play) { Label("Let’s play", systemImage: "arrow.right") }
                        .buttonStyle(PrimaryButton()).accessibilityIdentifier("welcome.play")
                    Button("How to play", action: help).font(.headline).frame(minHeight: 44)
                    Text("24 original characters · Entirely offline")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24).padding(.bottom, 24).frame(maxWidth: 540)
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
    }

    private func heroCard(_ character: FaceOffCore.Character, rotation: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AvatarView(character: character)
            Text(character.name).font(.headline)
            Text("A face to remember").font(.caption2).foregroundStyle(.secondary)
        }
        .padding(12).background(Theme.surface, in: RoundedRectangle(cornerRadius: 24))
        .rotationEffect(.degrees(rotation))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 8)
    }
}

struct HowToPlayView: View {
    private let rules: [(String, String, String)] = [
        ("1", "Pick in private", "Each player chooses a secret character. You may both choose the same face. Pass the phone only when the handoff screen appears."),
        ("2", "Ask one question", "On your turn, choose one yes/no question. FaceOff answers using your opponent’s secret character. Hats do not change hair colour."),
        ("3", "Narrow the field", "Tap characters to flip them over. Tap again to restore a face. Elimination is manual, and your board stays separate from your opponent’s."),
        ("4", "Pass or make your move", "After asking, finish flipping cards and pass the phone. Instead of asking, you may make one final guess at the start of your turn."),
        ("5", "Find the face", "A correct guess wins. A wrong guess means your opponent wins immediately. Even eliminated characters can be guessed."),
        ("6", "Play again", "A rematch clears both secrets and boards and alternates who starts. A new game always starts with Player 1.")
    ]
    var body: some View {
        List {
            Section {
                ForEach(rules, id: \.0) { rule in
                    HStack(alignment: .top, spacing: 14) {
                        Text(rule.0).font(.headline).foregroundStyle(Theme.accent).frame(width: 24)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(rule.1).font(.headline)
                            Text(rule.2).foregroundStyle(.secondary)
                        }.padding(.vertical, 8)
                    }
                }
            }
            Section("Good to know") {
                Text("You cannot repeat your own questions. If all questions are used, you can pass or make a final guess. You can restore cards at any time on your turn.")
                Text("Use the same trait descriptions shown on the cards. The portraits are original placeholders. No timers, internet, or accounts are needed.")
                Text("The game stays in memory for this session. Closing the app ends the game. Keep the screen private: the handoff screens rely on both players taking turns fairly.")
            }
        }
        .navigationTitle("How to play").navigationBarTitleDisplayMode(.inline)
    }
}
