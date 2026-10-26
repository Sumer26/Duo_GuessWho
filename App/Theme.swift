import SwiftUI

enum Theme {
    static let ink = Color.primary
    static let accent = Color("AccentColor")
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    static let background = Color(uiColor: .systemGroupedBackground)
    static let coral = Color(red: 0.91, green: 0.35, blue: 0.27)
}

struct PrimaryButton: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 30)
            .padding(14)
            .foregroundStyle(.white)
            .background(Theme.accent, in: RoundedRectangle(cornerRadius: 18))
            .opacity(enabled ? (configuration.isPressed ? 0.8 : 1) : 0.45)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct Eyebrow: View {
    let text: String
    var body: some View {
        Text(text.uppercased()).font(.caption.weight(.bold)).tracking(2).foregroundStyle(Theme.accent)
    }
}

struct GameGrid<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: typeSize.isAccessibilitySize ? 200 : 104), spacing: 10)], spacing: 12) {
            content
        }
    }
}
