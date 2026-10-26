import Foundation

public enum Player: Int, CaseIterable, Sendable {
    case one = 1, two = 2
    public var name: String { "Player \(rawValue)" }
    public var opponent: Player { self == .one ? .two : .one }
}

public enum HandoffPurpose: Equatable, Sendable { case selection, turn }
public enum GamePhase: Equatable, Sendable {
    case welcome
    case handoff(Player, HandoffPurpose)
    case selecting(Player)
    case turn(Player)
    case finished(Outcome)
}

public struct AnswerRecord: Equatable, Identifiable, Sendable {
    public let question: Question
    public let answer: Bool
    public let turn: Int
    public var id: String { question.id }
}

public struct PlayerBoard: Equatable, Sendable {
    public internal(set) var eliminated: Set<String> = []
    public internal(set) var history: [AnswerRecord] = []
    public var remainingCount: Int { Roster.all.count - eliminated.count }
}

public struct Outcome: Equatable, Sendable {
    public let winner: Player
    public let guesser: Player
    public let guessedID: String
    public let targetID: String
    public let playerOneSecretID: String
    public let playerTwoSecretID: String
    public var correct: Bool { guessedID == targetID }
}

public enum GameError: String, Error, LocalizedError {
    case invalidPhase = "That action is unavailable right now."
    case unknownCharacter = "Choose a character from the roster."
    case alreadyAsked = "You already asked that question."
    case actionUsed = "You have already asked a question this turn. Pass the phone next."
    case questionRequired = "Ask a question or make a final guess first."
    public var errorDescription: String? { rawValue }
}

/// Pure value-type state machine; no UI, storage, clocks, or network dependencies.
/// Secrets are private and only exposed for the active player's optional reminder,
/// or as part of the public end-of-game result.
public struct GameState: Equatable, Sendable {
    public private(set) var phase: GamePhase = .welcome
    public private(set) var startingPlayer: Player = .one
    public private(set) var turnNumber = 0
    public private(set) var answerThisTurn: AnswerRecord?
    private var secrets: [Player: String] = [:]
    private var boards: [Player: PlayerBoard] = [.one: .init(), .two: .init()]

    public init() {}
    public var activePlayer: Player? {
        switch phase {
        case .turn(let player), .selecting(let player): return player
        default: return nil
        }
    }
    public var ownSecret: Character? {
        guard case .turn(let player) = phase, let id = secrets[player] else { return nil }
        return Roster.character(id: id)
    }
    public var currentBoard: PlayerBoard? {
        guard case .turn(let player) = phase else { return nil }
        return boards[player]
    }
    public var availableQuestions: [Question] {
        guard let board = currentBoard else { return [] }
        return Question.allCases.filter { question in !board.history.contains { $0.question == question } }
    }
    public var canAsk: Bool { currentBoard != nil && answerThisTurn == nil && !availableQuestions.isEmpty }
    public var canGuess: Bool { currentBoard != nil && answerThisTurn == nil }
    public var canEndTurn: Bool { currentBoard != nil && (answerThisTurn != nil || availableQuestions.isEmpty) }

    public mutating func startNewGame() {
        self = GameState()
        phase = .handoff(.one, .selection)
    }

    public mutating func returnToWelcome() { self = GameState() }

    public mutating func acknowledgeHandoff() throws {
        guard case .handoff(let player, let purpose) = phase else { throw GameError.invalidPhase }
        phase = purpose == .selection ? .selecting(player) : .turn(player)
    }

    public mutating func selectSecret(_ id: String) throws {
        guard case .selecting(let player) = phase else { throw GameError.invalidPhase }
        guard Roster.character(id: id) != nil else { throw GameError.unknownCharacter }
        secrets[player] = id
        if secrets[player.opponent] == nil {
            phase = .handoff(player.opponent, .selection)
        } else {
            turnNumber = 1
            phase = .handoff(startingPlayer, .turn)
        }
    }

    @discardableResult public mutating func ask(_ question: Question) throws -> AnswerRecord {
        guard case .turn(let player) = phase, let targetID = secrets[player.opponent],
              let target = Roster.character(id: targetID) else { throw GameError.invalidPhase }
        guard answerThisTurn == nil else { throw GameError.actionUsed }
        guard availableQuestions.contains(question) else { throw GameError.alreadyAsked }
        let record = AnswerRecord(question: question, answer: question.answer(for: target), turn: turnNumber)
        boards[player, default: .init()].history.append(record)
        answerThisTurn = record
        return record
    }

    public mutating func toggleElimination(_ id: String) throws {
        guard case .turn(let player) = phase else { throw GameError.invalidPhase }
        guard Roster.character(id: id) != nil else { throw GameError.unknownCharacter }
        if boards[player, default: .init()].eliminated.contains(id) {
            boards[player, default: .init()].eliminated.remove(id)
        } else {
            boards[player, default: .init()].eliminated.insert(id)
        }
    }

    public mutating func endTurn() throws {
        guard case .turn(let player) = phase else { throw GameError.invalidPhase }
        guard canEndTurn else { throw GameError.questionRequired }
        answerThisTurn = nil
        turnNumber += 1
        phase = .handoff(player.opponent, .turn)
    }

    public mutating func guess(_ id: String) throws {
        guard case .turn(let player) = phase,
              let target = secrets[player.opponent],
              let first = secrets[.one], let second = secrets[.two] else { throw GameError.invalidPhase }
        guard answerThisTurn == nil else { throw GameError.actionUsed }
        guard Roster.character(id: id) != nil else { throw GameError.unknownCharacter }
        phase = .finished(.init(winner: id == target ? player : player.opponent,
                                guesser: player, guessedID: id, targetID: target,
                                playerOneSecretID: first, playerTwoSecretID: second))
    }

    public mutating func rematch() throws {
        guard case .finished = phase else { throw GameError.invalidPhase }
        let nextStarter = startingPlayer.opponent
        self = GameState()
        startingPlayer = nextStarter
        phase = .handoff(nextStarter, .selection)
    }
}
