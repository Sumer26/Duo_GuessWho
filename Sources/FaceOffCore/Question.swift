public enum Question: String, CaseIterable, Identifiable, Sendable {
    case glasses, anyHat, cap, beanie, brimmedHat, anyFacialHair, beard, moustache
    case blackHair, brownHair, blondHair, redHair, greyHair, noHair

    public var id: String { rawValue }
    public var category: String {
        switch self {
        case .glasses: return "Accessories"
        case .anyHat, .cap, .beanie, .brimmedHat: return "Hats"
        case .anyFacialHair, .beard, .moustache: return "Facial hair"
        default: return "Hair"
        }
    }
    public var text: String {
        switch self {
        case .glasses: return "Do they wear glasses?"
        case .anyHat: return "Do they wear a hat?"
        case .cap: return "Do they wear a cap?"
        case .beanie: return "Do they wear a beanie?"
        case .brimmedHat: return "Do they wear a brimmed hat?"
        case .anyFacialHair: return "Do they have facial hair?"
        case .beard: return "Do they have a beard?"
        case .moustache: return "Do they have a moustache?"
        case .blackHair: return "Do they have black hair?"
        case .brownHair: return "Do they have brown hair?"
        case .blondHair: return "Do they have blond hair?"
        case .redHair: return "Do they have red hair?"
        case .greyHair: return "Do they have grey hair?"
        case .noHair: return "Do they have no hair?"
        }
    }

    public func answer(for character: Character) -> Bool {
        switch self {
        case .glasses: return character.glasses
        case .anyHat: return character.hat != .none
        case .cap: return character.hat == .cap
        case .beanie: return character.hat == .beanie
        case .brimmedHat: return character.hat == .brimmed
        case .anyFacialHair: return character.facialHair != .none
        case .beard: return character.facialHair == .beard
        case .moustache: return character.facialHair == .moustache
        case .blackHair: return character.hair == .black
        case .brownHair: return character.hair == .brown
        case .blondHair: return character.hair == .blond
        case .redHair: return character.hair == .red
        case .greyHair: return character.hair == .grey
        case .noHair: return character.hair == .none
        }
    }
}
