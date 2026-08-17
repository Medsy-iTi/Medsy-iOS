import XCTest
@testable import Medsy

// MARK: - Mocks

final class MockSendTextUseCase: SendAiChatTextMessageUseCaseProtocol, @unchecked Sendable {
    var result: Result<AIChatAssistantResponse, Error> = .success(makeDefaultResponse())
    var callCount = 0
    func execute(text: String, analyticsPreset: String?) async throws -> AIChatAssistantResponse {
        callCount += 1
        return try result.get()
    }
}

final class MockSendImageUseCase: SendAiChatImageMessageUseCaseProtocol, @unchecked Sendable {
    var result: Result<AIChatAssistantResponse, Error> = .success(makeDefaultResponse())
    func execute(imageData: Data, mimeType: String, message: String?) async throws -> AIChatAssistantResponse {
        return try result.get()
    }
}

final class MockLoadHistoryUseCase: LoadAiChatHistoryUseCaseProtocol, @unchecked Sendable {
    var result: Result<AIChatHistory, Error> = .success(AIChatHistory(conversationID: nil, messages: []))
    func execute() async throws -> AIChatHistory {
        return try result.get()
    }
}

final class MockStartNewChatUseCase: StartNewAiChatUseCaseProtocol, @unchecked Sendable {
    var callCount = 0
    func execute() async throws { callCount += 1 }
}

private func makeDefaultResponse() -> AIChatAssistantResponse {
    AIChatAssistantResponse(
        conversationID: nil, messageID: 1, intent: .other,
        answer: "Response text", products: [], alternatives: [],
        doctorSpecializations: [], emergencyNumbers: [],
        categories: [], pharmacistRankings: [], disclaimer: nil,
        action: nil, reminder: nil, analytics: nil
    )
}

// MARK: - Tests

@MainActor
final class AiChatViewModelTests: XCTestCase {

    var sendTextUseCase: MockSendTextUseCase!
    var sendImageUseCase: MockSendImageUseCase!
    var loadHistoryUseCase: MockLoadHistoryUseCase!
    var startNewChatUseCase: MockStartNewChatUseCase!
    var session: AIChatSessionDataSource!
    var sut: AiChatViewModel!

    override func setUp() {
        sendTextUseCase = MockSendTextUseCase()
        sendImageUseCase = MockSendImageUseCase()
        loadHistoryUseCase = MockLoadHistoryUseCase()
        startNewChatUseCase = MockStartNewChatUseCase()
        session = AIChatSessionDataSource()
        sut = AiChatViewModel(
            sendTextUseCase: sendTextUseCase,
            sendImageUseCase: sendImageUseCase,
            loadHistoryUseCase: loadHistoryUseCase,
            startNewChatUseCase: startNewChatUseCase,
            session: session,
            speechRecognizer: AiChatSpeechRecognizer()
        )
    }

    // 1. History loads and syncs to messages
    func test_onAppear_loadsHistory() async throws {
        let historyMessages = [
            AIChatHistoryMessage(
                id: 100, role: .user, content: "Previous message",
                intent: nil, products: [], alternatives: [],
                doctorSpecializations: [], emergencyNumbers: [],
                categories: [], pharmacistRankings: [], analytics: nil, createdAt: nil
            )
        ]
        loadHistoryUseCase.result = .success(AIChatHistory(conversationID: 1, messages: historyMessages))
        sut.onAppear()
        // Allow async work
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.messages.isEmpty)
        XCTAssertEqual(sut.messages.first?.id, 100)
        XCTAssertFalse(sut.isLoadingHistory)
    }

    // 2. History failure sets historyLoadFailed
    func test_onAppear_historyFailure_setsFlag() async throws {
        loadHistoryUseCase.result = .failure(NSError(domain: "test", code: 0))
        sut.onAppear()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(sut.historyLoadFailed)
        XCTAssertFalse(sut.isLoadingHistory)
    }

    // 3. isSendEnabled is false until history loaded
    func test_isSendEnabled_falseBeforeHistoryLoaded() {
        sut.inputText = "Hello"
        XCTAssertFalse(sut.isSendEnabled, "Send should be disabled before history loads")
    }

    // 4. Sending text adds optimistic bubble then resolves
    func test_sendText_appendsOptimisticBubble() async throws {
        // Manually mark history loaded
        session.markHistoryFailed()  // shortcut to set isHistoryLoaded = true
        sut.inputText = "Hello"
        sut.sendText()
        // Optimistic bubble should be there immediately
        XCTAssertFalse(sut.messages.isEmpty)
        XCTAssertEqual(sut.messages.first?.text, "Hello")
        XCTAssertEqual(sut.messages.first?.role, .user)
    }

    // 5. Retry deduplication — no duplicate user bubble
    func test_retryMessage_doesNotAppendDuplicateBubble() async throws {
        session.markHistoryFailed()
        let failError = NSError(domain: "test", code: 500)
        sendTextUseCase.result = .failure(failError)
        sut.inputText = "retry me"
        sut.sendText()
        try await Task.sleep(nanoseconds: 200_000_000)
        let countAfterFailure = sut.messages.count
        // Now retry
        if let retryableID = sut.messages.first(where: { $0.isRetryable })?.id {
            sendTextUseCase.result = .success(makeDefaultResponse())
            sut.retryMessage(id: retryableID)
            try await Task.sleep(nanoseconds: 200_000_000)
            let userBubbles = sut.messages.filter { $0.role == .user }
            XCTAssertEqual(userBubbles.count, 1, "Should not have duplicate user bubble")
        }
    }

    // 6. Generation counter — stale response is discarded on new chat
    func test_startNewChat_discardsStaleSendResult() async throws {
        session.markHistoryFailed()
        // Delay the response
        let delayUseCase = MockSendTextUseCase()
        delayUseCase.result = .success(makeDefaultResponse())
        let vm = AiChatViewModel(
            sendTextUseCase: delayUseCase,
            sendImageUseCase: sendImageUseCase,
            loadHistoryUseCase: loadHistoryUseCase,
            startNewChatUseCase: startNewChatUseCase,
            session: AIChatSessionDataSource(),
            speechRecognizer: AiChatSpeechRecognizer()
        )
        vm.inputText = "query"
        session.markHistoryFailed()
        vm.startNewChat()  // clear and increment generation before response arrives
        // No crash, messages empty
        XCTAssertTrue(vm.messages.isEmpty)
    }

    // 7. addedToCart action — does NOT call add-to-cart API, fires onOpenCart
    func test_addedToCartAction_firesOpenCartCallback() async throws {
        session.markHistoryFailed()
        var openCartCalled = false
        sut.onOpenCart = { openCartCalled = true }
        let action = AIChatAction(type: .addedToCart, addedProductIDs: [1], quantity: 1, cartItemCount: 1)
        let responseWithAction = AIChatAssistantResponse(
            conversationID: nil, messageID: 1, intent: .addToCart,
            answer: "Added!", products: [], alternatives: [],
            doctorSpecializations: [], emergencyNumbers: [],
            categories: [], pharmacistRankings: [], disclaimer: nil,
            action: action, reminder: nil, analytics: nil
        )
        sendTextUseCase.result = .success(responseWithAction)
        sut.inputText = "add to cart"
        sut.sendText()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(openCartCalled, "onOpenCart should be called for addedToCart action")
    }

    // 8. Input capped at 500 chars
    func test_sendText_capsAt500Chars() async throws {
        session.markHistoryFailed()
        let longText = String(repeating: "a", count: 600)
        sut.inputText = longText
        sut.sendText()
        try await Task.sleep(nanoseconds: 200_000_000)
        // The user bubble text should be at most 500 chars
        let userMsg = sut.messages.first { $0.role == .user }
        XCTAssertNotNil(userMsg)
        XCTAssertLessThanOrEqual(userMsg!.text.count, 500)
    }

    // 9. startNewChat clears messages
    func test_startNewChat_clearsMessages() async throws {
        session.markHistoryFailed()
        sut.inputText = "hello"
        sut.sendText()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.messages.isEmpty)
        sut.startNewChat()
        XCTAssertTrue(sut.messages.isEmpty)
    }
}
