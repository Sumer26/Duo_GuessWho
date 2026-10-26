import XCTest
import FaceOffCore

final class GameStateTests: XCTestCase {
    private func readyGame(first: String = "arden", second: String = "brio") throws -> GameState {
        var game = GameState()
        game.startNewGame()
        try game.acknowledgeHandoff()
        try game.selectSecret(first)
        try game.acknowledgeHandoff()
        try game.selectSecret(second)
        try game.acknowledgeHandoff()
        return game
    }

    private func assertError(_ expected: GameError, file: StaticString = #filePath, line: UInt = #line,
                             _ action: () throws -> Void) {
        XCTAssertThrowsError(try action(), file: file, line: line) { error in
            XCTAssertEqual(error as? GameError, expected, file: file, line: line)
        }
    }

    func testRosterHas24StableUniqueCharactersAndQuestionSignatures() {
        XCTAssertEqual(Roster.all.count, 24)
        XCTAssertEqual(Set(Roster.all.map(\.id)).count, 24)
        XCTAssertEqual(Set(Roster.all.map(\.name)).count, 24)
        let signatures = Roster.all.map { character in
            Question.allCases.map { $0.answer(for: character) ? "1" : "0" }.joined()
        }
        XCTAssertEqual(Set(signatures).count, 24, "Every face must be distinguishable")
        for question in Question.allCases {
            XCTAssertTrue(Roster.all.contains { question.answer(for: $0) })
            XCTAssertTrue(Roster.all.contains { !question.answer(for: $0) })
        }
    }

    func testQuestionTruthTableForEntireRoster() {
        // Independent expected sets catch incorrect predicate-to-attribute mappings.
        let expected: [Question: Set<String>] = [
            .glasses: ["arden", "cleo", "fable", "hollis", "indi", "kit", "nessa", "pippa", "quill", "sol", "vesper", "zeri"],
            .cap: ["brio", "fable", "joss", "nessa", "rue", "vesper"],
            .beanie: ["cleo", "greer", "kit", "orin", "sol", "wynn"],
            .brimmedHat: ["dax", "hollis", "lumi", "pippa", "tavi", "zeri"],
            .anyHat: Set(Roster.all.map(\.id)).subtracting(["arden", "elio", "indi", "marlow", "quill", "uma"]),
            .beard: ["dax", "greer", "indi", "pippa", "rue", "wynn"],
            .moustache: ["brio", "hollis", "kit", "marlow", "quill", "vesper"],
            .anyFacialHair: ["dax", "greer", "indi", "pippa", "rue", "wynn", "brio", "hollis", "kit", "marlow", "quill", "vesper"],
            .blackHair: ["arden", "brio", "cleo", "dax"],
            .brownHair: ["elio", "fable", "greer", "hollis"],
            .blondHair: ["indi", "joss", "kit", "lumi"],
            .redHair: ["marlow", "nessa", "orin", "pippa"],
            .greyHair: ["quill", "rue", "sol", "tavi"],
            .noHair: ["uma", "vesper", "wynn", "zeri"]
        ]
        XCTAssertEqual(expected.count, Question.allCases.count)
        for question in Question.allCases {
            for character in Roster.all {
                XCTAssertEqual(question.answer(for: character), expected[question]?.contains(character.id),
                               "\(question): \(character.id)")
            }
        }
    }

    func testSetupRequiresBothPrivateHandoffs() throws {
        var game = GameState()
        XCTAssertEqual(game.phase, .welcome)
        game.startNewGame()
        XCTAssertEqual(game.phase, .handoff(.one, .selection))
        assertError(.invalidPhase) { try game.selectSecret("arden") }
        try game.acknowledgeHandoff()
        XCTAssertEqual(game.phase, .selecting(.one))
        try game.selectSecret("arden")
        XCTAssertEqual(game.phase, .handoff(.two, .selection))
        XCTAssertNil(game.ownSecret)
        try game.acknowledgeHandoff()
        try game.selectSecret("brio")
        XCTAssertEqual(game.phase, .handoff(.one, .turn))
        XCTAssertNil(game.ownSecret)
        XCTAssertNil(game.currentBoard)
        try game.acknowledgeHandoff()
        XCTAssertEqual(game.phase, .turn(.one))
        XCTAssertEqual(game.ownSecret?.id, "arden")
        XCTAssertEqual(game.turnNumber, 1)
    }

    func testSameSecretForBothPlayersIsAllowed() throws {
        var game = try readyGame(first: "cleo", second: "cleo")
        try game.guess("cleo")
        guard case .finished(let result) = game.phase else { return XCTFail("No result") }
        XCTAssertEqual(result.winner, .one)
        XCTAssertTrue(result.correct)
    }

    func testInvalidSelectionDoesNotMutateState() throws {
        var game = GameState()
        game.startNewGame()
        try game.acknowledgeHandoff()
        let before = game
        assertError(.unknownCharacter) { try game.selectSecret("missing") }
        XCTAssertEqual(game, before)
    }

    func testAnswerUsesOpponentsSecretRatherThanOwn() throws {
        var game = try readyGame(first: "arden", second: "brio")
        let answer = try game.ask(.glasses)
        XCTAssertFalse(answer.answer)
        XCTAssertEqual(answer.turn, 1)
        XCTAssertEqual(game.currentBoard?.history, [answer])
        XCTAssertEqual(game.currentBoard?.remainingCount, 24, "Questions never auto-eliminate cards")
        XCTAssertTrue(game.canEndTurn)
        XCTAssertFalse(game.canAsk)
        XCTAssertFalse(game.canGuess)
    }

    func testOnlyOneQuestionAndNoGuessAfterAsking() throws {
        var game = try readyGame()
        try game.ask(.glasses)
        let before = game
        assertError(.actionUsed) { _ = try game.ask(.anyHat) }
        assertError(.actionUsed) { try game.guess("brio") }
        XCTAssertEqual(game, before)
    }

    func testCannotEndAnUnusedTurn() throws {
        var game = try readyGame()
        assertError(.questionRequired) { try game.endTurn() }
        XCTAssertEqual(game.phase, .turn(.one))
    }

    func testHandoffBlocksBoardAnswersAndSecretAccess() throws {
        var game = try readyGame()
        try game.ask(.glasses)
        try game.endTurn()
        XCTAssertEqual(game.phase, .handoff(.two, .turn))
        XCTAssertNil(game.activePlayer)
        XCTAssertNil(game.ownSecret)
        XCTAssertNil(game.currentBoard)
        XCTAssertTrue(game.availableQuestions.isEmpty)
        XCTAssertFalse(game.canAsk)
        XCTAssertFalse(game.canGuess)
        XCTAssertFalse(game.canEndTurn)
        let before = game
        assertError(.invalidPhase) { _ = try game.ask(.anyHat) }
        assertError(.invalidPhase) { try game.toggleElimination("arden") }
        assertError(.invalidPhase) { try game.guess("arden") }
        XCTAssertEqual(game, before)
        try game.acknowledgeHandoff()
        XCTAssertEqual(game.phase, .turn(.two))
        XCTAssertEqual(game.ownSecret?.id, "brio")
        XCTAssertNil(game.answerThisTurn)
        XCTAssertEqual(game.turnNumber, 2)
    }

    func testBoardsAndQuestionHistoryStayIndependent() throws {
        var game = try readyGame()
        try game.toggleElimination("cleo")
        try game.ask(.glasses)
        try game.endTurn()
        try game.acknowledgeHandoff()
        XCTAssertEqual(game.currentBoard?.remainingCount, 24)
        XCTAssertEqual(game.currentBoard?.history.count, 0)
        XCTAssertTrue(game.availableQuestions.contains(.glasses))
        try game.toggleElimination("dax")
        let secondAnswer = try game.ask(.glasses)
        XCTAssertTrue(secondAnswer.answer)
        try game.endTurn()
        try game.acknowledgeHandoff()
        XCTAssertEqual(game.currentBoard?.eliminated, ["cleo"])
        XCTAssertEqual(game.currentBoard?.history.count, 1)
        XCTAssertFalse(game.availableQuestions.contains(.glasses))
        assertError(.alreadyAsked) { _ = try game.ask(.glasses) }
    }

    func testCardCanBeRestoredBeforeAndAfterQuestion() throws {
        var game = try readyGame()
        try game.toggleElimination("arden")
        XCTAssertEqual(game.currentBoard?.remainingCount, 23)
        try game.ask(.anyHat)
        try game.toggleElimination("arden")
        XCTAssertEqual(game.currentBoard?.remainingCount, 24)
    }

    func testAllCardsCanBeEliminatedAndStillGuessed() throws {
        var game = try readyGame()
        for character in Roster.all { try game.toggleElimination(character.id) }
        XCTAssertEqual(game.currentBoard?.remainingCount, 0)
        try game.guess("brio")
        guard case .finished(let result) = game.phase else { return XCTFail("No result") }
        XCTAssertTrue(result.correct)
    }

    func testUnknownCardAndGuessLeaveStateIntact() throws {
        var game = try readyGame()
        let before = game
        assertError(.unknownCharacter) { try game.toggleElimination("unknown") }
        assertError(.unknownCharacter) { try game.guess("unknown") }
        XCTAssertEqual(game, before)
    }

    func testCorrectFinalGuessRevealsBothSecretsAndLocksGame() throws {
        var game = try readyGame()
        try game.guess("brio")
        guard case .finished(let result) = game.phase else { return XCTFail("No result") }
        XCTAssertEqual(result.winner, .one)
        XCTAssertEqual(result.guesser, .one)
        XCTAssertEqual(result.playerOneSecretID, "arden")
        XCTAssertEqual(result.playerTwoSecretID, "brio")
        XCTAssertTrue(result.correct)
        XCTAssertNil(game.ownSecret)
        XCTAssertNil(game.currentBoard)
        let before = game
        assertError(.invalidPhase) { _ = try game.ask(.anyHat) }
        assertError(.invalidPhase) { try game.guess("arden") }
        assertError(.invalidPhase) { try game.endTurn() }
        XCTAssertEqual(game, before)
    }

    func testWrongFinalGuessAwardsOpponentWin() throws {
        var game = try readyGame()
        try game.guess("cleo")
        guard case .finished(let result) = game.phase else { return XCTFail("No result") }
        XCTAssertFalse(result.correct)
        XCTAssertEqual(result.winner, .two)
        XCTAssertEqual(result.targetID, "brio")
        XCTAssertEqual(result.guessedID, "cleo")
    }

    func testPlayerTwoCanWin() throws {
        var game = try readyGame()
        try game.ask(.anyHat)
        try game.endTurn()
        try game.acknowledgeHandoff()
        try game.guess("arden")
        guard case .finished(let result) = game.phase else { return XCTFail("No result") }
        XCTAssertEqual(result.winner, .two)
        XCTAssertEqual(result.guesser, .two)
    }

    func testRematchClearsSecretsBoardsHistoryAndAlternatesStarter() throws {
        var game = try readyGame()
        try game.toggleElimination("dax")
        try game.guess("brio")
        try game.rematch()
        XCTAssertEqual(game.startingPlayer, .two)
        XCTAssertEqual(game.phase, .handoff(.two, .selection))
        XCTAssertNil(game.ownSecret)
        XCTAssertEqual(game.turnNumber, 0)
        try game.acknowledgeHandoff()
        try game.selectSecret("zeri")
        XCTAssertEqual(game.phase, .handoff(.one, .selection), "Both players must pick again")
        try game.acknowledgeHandoff()
        try game.selectSecret("uma")
        XCTAssertEqual(game.phase, .handoff(.two, .turn))
        try game.acknowledgeHandoff()
        XCTAssertEqual(game.currentBoard?.remainingCount, 24)
        XCTAssertEqual(game.currentBoard?.history.count, 0)
        XCTAssertNil(game.answerThisTurn)
        XCTAssertEqual(game.ownSecret?.id, "zeri")
        try game.guess("uma")
        try game.rematch()
        XCTAssertEqual(game.startingPlayer, .one)
        XCTAssertEqual(game.phase, .handoff(.one, .selection))
    }

    func testRematchOnlyAllowedAfterGameEnds() throws {
        var game = try readyGame()
        assertError(.invalidPhase) { try game.rematch() }
    }

    func testExhaustedQuestionsAllowPassingWithoutDeadlock() throws {
        var game = try readyGame()
        for question in Question.allCases {
            for _ in Player.allCases {
                try game.ask(question)
                try game.endTurn()
                try game.acknowledgeHandoff()
            }
        }
        XCTAssertTrue(game.availableQuestions.isEmpty)
        XCTAssertTrue(game.canEndTurn)
        XCTAssertTrue(game.canGuess)
        XCTAssertFalse(game.canAsk)
        try game.endTurn()
        try game.acknowledgeHandoff()
        XCTAssertTrue(game.canEndTurn)
        try game.guess("arden")
    }

    func testNewGameAndWelcomeResetAllState() throws {
        var game = try readyGame()
        try game.ask(.glasses)
        try game.toggleElimination("brio")
        game.startNewGame()
        XCTAssertEqual(game.phase, .handoff(.one, .selection))
        XCTAssertEqual(game.startingPlayer, .one)
        XCTAssertEqual(game.turnNumber, 0)
        XCTAssertNil(game.answerThisTurn)
        game.returnToWelcome()
        XCTAssertEqual(game, GameState())
    }

    func testAllSecretPairsAnswerAndResolveCorrectly() throws {
        for first in Roster.all {
            for second in Roster.all {
                var game = try readyGame(first: first.id, second: second.id)
                let answer = try game.ask(.glasses)
                XCTAssertEqual(answer.answer, second.glasses)
                try game.endTurn()
                try game.acknowledgeHandoff()
                try game.guess(first.id)
                guard case .finished(let result) = game.phase else { return XCTFail("No result") }
                XCTAssertEqual(result.winner, .two)
                XCTAssertEqual(result.targetID, first.id)
            }
        }
    }
}
