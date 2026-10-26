import SwiftUI
import FaceOffCore

struct CharacterCard: View {
    let character: FaceOffCore.Character
    var eliminated = false
    var selected = false
    var actionHint = "Double tap to eliminate"
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            Group {
                if reduceMotion {
                    ZStack {
                        face.opacity(eliminated ? 0 : 1)
                        back.opacity(eliminated ? 1 : 0)
                    }
                } else {
                    face.modifier(CardFlip(angle: eliminated ? 180 : 0, back: back))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(selected ? Theme.accent : Color.primary.opacity(0.08), lineWidth: selected ? 3 : 1)
            }
            .overlay(alignment: .topTrailing) {
                if selected {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.white, Theme.accent).padding(8)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: eliminated)
        .accessibilityLabel("\(character.name), \(character.attributeDescription)")
        .accessibilityValue(eliminated ? "Eliminated" : selected ? "Selected" : "Available")
        .accessibilityHint(eliminated ? "Double tap to restore" : actionHint)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    private var back: some View {
        VStack(spacing: 8) {
            Image(systemName: "xmark").font(.largeTitle.weight(.light))
            Text(character.name).font(.subheadline.weight(.semibold))
            Text("Eliminated").font(.caption2)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 20))
    }

    private var face: some View {
        VStack(alignment: .leading, spacing: 6) {
            AvatarView(character: character)
            Text(character.name).font(.subheadline.weight(.bold)).foregroundStyle(Theme.ink)
            Text(character.attributeDescription)
                .font(.caption2).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
        .padding(9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 20))
    }
}

/// Swap visible faces at the midpoint so labels never appear mirrored.
private struct CardFlip<Back: View>: AnimatableModifier {
    var angle: Double
    let back: Back
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }
    func body(content: Content) -> some View {
        ZStack {
            content.opacity(angle < 90 ? 1 : 0)
            back
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(angle >= 90 ? 1 : 0)
        }
        .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
    }
}
