import Foundation

public enum HairColour: String, CaseIterable, Sendable {
    case black, brown, blond, red, grey, none
    public var label: String { self == .none ? "no hair" : "\(rawValue) hair" }
}

public enum Hat: String, CaseIterable, Sendable {
    case none, cap, beanie, brimmed
    public var label: String {
        switch self {
        case .none: return "no hat"
        case .cap: return "a cap"
        case .beanie: return "a beanie"
        case .brimmed: return "a brimmed hat"
        }
    }
}

public enum FacialHair: String, CaseIterable, Sendable {
    case none, moustache, beard
    public var label: String { self == .none ? "no facial hair" : "a \(rawValue)" }
}

/// All deduction traits are explicit. Avatar decoration never changes an answer.
public struct Character: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let hair: HairColour
    public let glasses: Bool
    public let hat: Hat
    public let facialHair: FacialHair
    public let paletteIndex: Int

    public var attributeDescription: String {
        "\(hair.label), \(glasses ? "glasses" : "no glasses"), \(hat.label), \(facialHair.label)"
    }
}
