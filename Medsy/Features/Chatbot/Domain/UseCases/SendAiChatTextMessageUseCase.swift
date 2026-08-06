import Foundation

protocol SendAiChatTextMessageUseCaseProtocol: Sendable {
    func execute(text: String) async throws -> AIChatAssistantResponse
}

final class SendAiChatTextMessageUseCase: SendAiChatTextMessageUseCaseProtocol, @unchecked Sendable {
    private let repository: AIChatRepositoryProtocol

    init(repository: AIChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(text: String) async throws -> AIChatAssistantResponse {
        return try await repository.sendTextMessage(text)
    }
}
