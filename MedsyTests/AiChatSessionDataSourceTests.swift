import XCTest
@testable import Medsy

@MainActor
final class AiChatSessionDataSourceTests: XCTestCase {

    func test_appendOptimisticUserMessage_addsMessage() {
        let sut = AIChatSessionDataSource()
        let id = sut.appendOptimisticUserMessage(text: "Hello")
        XCTAssertEqual(sut.messages.count, 1)
        XCTAssertEqual(sut.messages[0].text, "Hello")
        XCTAssertEqual(sut.messages[0].role, .user)
        XCTAssertTrue(id < 0)  // local negative ID
    }

    func test_appendTypingIndicator_addsTypingMessage() {
        let sut = AIChatSessionDataSource()
        _ = sut.appendTypingIndicator()
        XCTAssertEqual(sut.messages.count, 1)
        XCTAssertTrue(sut.messages[0].isTyping)
    }

    func test_resolveResponse_replacesTypingWithRealMessage() {
        let sut = AIChatSessionDataSource()
        let typingID = sut.appendTypingIndicator()
        let response = makeResponse(text: "AI reply")
        sut.resolveResponse(response, typingID: typingID, sentGeneration: sut.generation)
        XCTAssertEqual(sut.messages.count, 1)
        XCTAssertFalse(sut.messages[0].isTyping)
        XCTAssertEqual(sut.messages[0].text, "AI reply")
    }

    func test_resolveResponse_droppedWhenGenerationChanged() {
        let sut = AIChatSessionDataSource()
        let sentGen = sut.generation
        let typingID = sut.appendTypingIndicator()
        sut.reset()  // increments generation
        let response = makeResponse(text: "stale")
        sut.resolveResponse(response, typingID: typingID, sentGeneration: sentGen)
        XCTAssertTrue(sut.messages.isEmpty)  // stale response discarded
    }

    func test_markRetryable_setsFlag() {
        let sut = AIChatSessionDataSource()
        let userID = sut.appendOptimisticUserMessage(text: "test")
        sut.markRetryable(userMessageID: userID)
        XCTAssertTrue(sut.messages[0].isRetryable)
    }

    func test_beginRetry_clearRetryableFlag() {
        let sut = AIChatSessionDataSource()
        let userID = sut.appendOptimisticUserMessage(text: "test")
        sut.markRetryable(userMessageID: userID)
        sut.beginRetry(userMessageID: userID)
        XCTAssertFalse(sut.messages[0].isRetryable)
    }

    func test_reset_clearsMessagesAndIncrementsGeneration() {
        let sut = AIChatSessionDataSource()
        _ = sut.appendOptimisticUserMessage(text: "test")
        let genBefore = sut.generation
        sut.reset()
        XCTAssertTrue(sut.messages.isEmpty)
        XCTAssertEqual(sut.generation, genBefore + 1)
        XCTAssertFalse(sut.isHistoryLoaded)
    }

    func test_hydrateHistory_calledOnce() {
        let sut = AIChatSessionDataSource()
        let history = makeHistory(messageCount: 3)
        sut.hydrateHistory(history)
        let countAfterFirst = sut.messages.count
        sut.hydrateHistory(makeHistory(messageCount: 10))  // should be ignored
        XCTAssertEqual(sut.messages.count, countAfterFirst, "Second hydrate should be a no-op")
    }

    // MARK: - Helpers

    private func makeResponse(text: String) -> AIChatAssistantResponse {
        AIChatAssistantResponse(
            conversationID: nil, messageID: nil, intent: .other,
            answer: text, products: [], alternatives: [],
            doctorSpecializations: [], emergencyNumbers: [],
            categories: [], pharmacistRankings: [],
            disclaimer: nil, action: nil
        )
    }

    private func makeHistory(messageCount: Int) -> AIChatHistory {
        let messages = (0..<messageCount).map { i in
            AIChatHistoryMessage(
                id: i, role: .user, content: "Message \(i)",
                intent: nil, products: [], alternatives: [],
                doctorSpecializations: [], emergencyNumbers: [],
                categories: [], pharmacistRankings: [], createdAt: nil
            )
        }
        return AIChatHistory(conversationID: 1, messages: messages)
    }
}
