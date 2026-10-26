public enum Roster {
    /// Original placeholder cast. IDs stay stable when portraits are replaced.
    public static let all: [Character] = [
        .init(id: "arden", name: "Arden", hair: .black, glasses: true, hat: .none, facialHair: .none, paletteIndex: 0),
        .init(id: "brio", name: "Brio", hair: .black, glasses: false, hat: .cap, facialHair: .moustache, paletteIndex: 1),
        .init(id: "cleo", name: "Cleo", hair: .black, glasses: true, hat: .beanie, facialHair: .none, paletteIndex: 2),
        .init(id: "dax", name: "Dax", hair: .black, glasses: false, hat: .brimmed, facialHair: .beard, paletteIndex: 3),
        .init(id: "elio", name: "Elio", hair: .brown, glasses: false, hat: .none, facialHair: .none, paletteIndex: 4),
        .init(id: "fable", name: "Fable", hair: .brown, glasses: true, hat: .cap, facialHair: .none, paletteIndex: 5),
        .init(id: "greer", name: "Greer", hair: .brown, glasses: false, hat: .beanie, facialHair: .beard, paletteIndex: 0),
        .init(id: "hollis", name: "Hollis", hair: .brown, glasses: true, hat: .brimmed, facialHair: .moustache, paletteIndex: 1),
        .init(id: "indi", name: "Indi", hair: .blond, glasses: true, hat: .none, facialHair: .beard, paletteIndex: 2),
        .init(id: "joss", name: "Joss", hair: .blond, glasses: false, hat: .cap, facialHair: .none, paletteIndex: 3),
        .init(id: "kit", name: "Kit", hair: .blond, glasses: true, hat: .beanie, facialHair: .moustache, paletteIndex: 4),
        .init(id: "lumi", name: "Lumi", hair: .blond, glasses: false, hat: .brimmed, facialHair: .none, paletteIndex: 5),
        .init(id: "marlow", name: "Marlow", hair: .red, glasses: false, hat: .none, facialHair: .moustache, paletteIndex: 0),
        .init(id: "nessa", name: "Nessa", hair: .red, glasses: true, hat: .cap, facialHair: .none, paletteIndex: 1),
        .init(id: "orin", name: "Orin", hair: .red, glasses: false, hat: .beanie, facialHair: .none, paletteIndex: 2),
        .init(id: "pippa", name: "Pippa", hair: .red, glasses: true, hat: .brimmed, facialHair: .beard, paletteIndex: 3),
        .init(id: "quill", name: "Quill", hair: .grey, glasses: true, hat: .none, facialHair: .moustache, paletteIndex: 4),
        .init(id: "rue", name: "Rue", hair: .grey, glasses: false, hat: .cap, facialHair: .beard, paletteIndex: 5),
        .init(id: "sol", name: "Sol", hair: .grey, glasses: true, hat: .beanie, facialHair: .none, paletteIndex: 0),
        .init(id: "tavi", name: "Tavi", hair: .grey, glasses: false, hat: .brimmed, facialHair: .none, paletteIndex: 1),
        .init(id: "uma", name: "Uma", hair: .none, glasses: false, hat: .none, facialHair: .none, paletteIndex: 2),
        .init(id: "vesper", name: "Vesper", hair: .none, glasses: true, hat: .cap, facialHair: .moustache, paletteIndex: 3),
        .init(id: "wynn", name: "Wynn", hair: .none, glasses: false, hat: .beanie, facialHair: .beard, paletteIndex: 4),
        .init(id: "zeri", name: "Zeri", hair: .none, glasses: true, hat: .brimmed, facialHair: .none, paletteIndex: 5)
    ]

    public static func character(id: String) -> Character? { all.first { $0.id == id } }
}
