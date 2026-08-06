import Foundation

protocol LoadAiChatHistoryUseCaseProtocol: Sendable {
    func execute() async throws -> AIChatHistory
}

final class LoadAiChatHistoryUseCase: LoadAiChatHistoryUseCaseProtocol, @unchecked Sendable {
    private let repository: AIChatRepositoryProtocol

    init(repository: AIChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> AIChatHistory {
        return try await repository.loadHistory()
    }
}
