import SwiftUI
import FaceOffCore

@MainActor
final class GameStore: ObservableObject {
    @Published private(set) var game = GameState()
    @Published var errorMessage: String?

    func perform(_ action: (inout GameState) throws -> Void) {
        do { try action(&game) }
        catch { errorMessage = error.localizedDescription }
    }
}
