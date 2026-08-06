import Foundation

protocol SendAiChatImageMessageUseCaseProtocol: Sendable {
    func execute(imageData: Data, mimeType: String, message: String?) async throws -> AIChatAssistantResponse
}

final class SendAiChatImageMessageUseCase: SendAiChatImageMessageUseCaseProtocol, @unchecked Sendable {
    private let repository: AIChatRepositoryProtocol

    init(repository: AIChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(imageData: Data, mimeType: String, message: String?) async throws -> AIChatAssistantResponse {
        return try await repository.sendImageMessage(imageData: imageData, mimeType: mimeType, message: message)
    }
}
