import SwiftUI
import FaceOffCore

/// Lightweight original vector placeholders, drawn entirely on device.
/// Hair remains visible under every hat; textual traits are the source of truth.
struct AvatarView: View {
    let character: FaceOffCore.Character

    private let skins: [Color] = [
        Color(red: 0.70, green: 0.43, blue: 0.29), Color(red: 0.96, green: 0.73, blue: 0.54),
        Color(red: 0.43, green: 0.27, blue: 0.21), Color(red: 0.85, green: 0.58, blue: 0.40),
        Color(red: 0.98, green: 0.82, blue: 0.67), Color(red: 0.57, green: 0.36, blue: 0.26)
    ]
    private let backdrops: [Color] = [.orange, .mint, .purple, .pink, .teal, .yellow]
    private var hair: Color {
        switch character.hair {
        case .black: return Color(red: 0.14, green: 0.15, blue: 0.19)
        case .brown: return Color(red: 0.34, green: 0.20, blue: 0.13)
        case .blond: return Color(red: 0.92, green: 0.70, blue: 0.24)
        case .red: return Color(red: 0.72, green: 0.25, blue: 0.13)
        case .grey: return Color(red: 0.64, green: 0.66, blue: 0.70)
        case .none: return .clear
        }
    }

    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 100, y: size.height / 100)
            let skin = skins[character.paletteIndex % skins.count]
            let dark = Color(red: 0.12, green: 0.12, blue: 0.20)
            func ellipse(_ rect: CGRect, _ colour: Color) {
                context.fill(Path(ellipseIn: rect), with: .color(colour))
            }
            func round(_ rect: CGRect, _ radius: CGFloat, _ colour: Color) {
                context.fill(Path(roundedRect: rect, cornerRadius: radius), with: .color(colour))
            }
            ellipse(CGRect(x: 13, y: 77, width: 74, height: 60), Theme.accent)
            round(CGRect(x: 42, y: 65, width: 16, height: 20), 5, skin)
            ellipse(CGRect(x: 25, y: 43, width: 50, height: 19), skin)
            ellipse(CGRect(x: 29, y: 18, width: 42, height: 58), skin)
            if character.hair != .none {
                round(CGRect(x: 28, y: 21, width: 44, height: 20), 9, hair)
                round(CGRect(x: 28, y: 31, width: 6, height: 19), 3, hair)
                round(CGRect(x: 66, y: 31, width: 6, height: 19), 3, hair)
            }
            ellipse(CGRect(x: 38, y: 46, width: 4, height: 5), dark)
            ellipse(CGRect(x: 58, y: 46, width: 4, height: 5), dark)
            var smile = Path()
            smile.move(to: CGPoint(x: 43, y: 63))
            smile.addQuadCurve(to: CGPoint(x: 57, y: 63), control: CGPoint(x: 50, y: 69))
            context.stroke(smile, with: .color(dark), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            if character.facialHair == .beard {
                var beard = Path()
                beard.move(to: CGPoint(x: 32, y: 58))
                beard.addQuadCurve(to: CGPoint(x: 68, y: 58), control: CGPoint(x: 50, y: 91))
                beard.addLine(to: CGPoint(x: 63, y: 64))
                beard.addQuadCurve(to: CGPoint(x: 37, y: 64), control: CGPoint(x: 50, y: 76))
                beard.closeSubpath()
                context.fill(beard, with: .color(character.hair == .none ? dark : hair))
            }
            if character.facialHair == .moustache {
                ellipse(CGRect(x: 39, y: 57, width: 13, height: 6), character.hair == .none ? dark : hair)
                ellipse(CGRect(x: 48, y: 57, width: 13, height: 6), character.hair == .none ? dark : hair)
            }
            if character.glasses {
                for x in [CGFloat(33), CGFloat(54)] {
                    context.stroke(Path(roundedRect: CGRect(x: x, y: 42, width: 15, height: 13), cornerRadius: 5), with: .color(dark), lineWidth: 2)
                }
                var bridge = Path()
                bridge.move(to: CGPoint(x: 48, y: 47)); bridge.addLine(to: CGPoint(x: 54, y: 47))
                context.stroke(bridge, with: .color(dark), lineWidth: 2)
            }
            switch character.hat {
            case .none: break
            case .cap:
                round(CGRect(x: 26, y: 13, width: 48, height: 17), 9, Theme.coral)
                round(CGRect(x: 28, y: 26, width: 58, height: 5), 2, Theme.coral)
            case .beanie:
                round(CGRect(x: 27, y: 10, width: 46, height: 21), 13, Color.teal)
                round(CGRect(x: 25, y: 25, width: 50, height: 8), 3, Color.teal)
                ellipse(CGRect(x: 45, y: 3, width: 10, height: 10), Color.teal)
            case .brimmed:
                round(CGRect(x: 33, y: 8, width: 34, height: 21), 5, dark)
                round(CGRect(x: 20, y: 26, width: 60, height: 6), 3, dark)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .background(backdrops[character.paletteIndex % backdrops.count].opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityHidden(true)
    }
}
