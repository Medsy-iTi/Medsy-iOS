import Foundation

protocol StartNewAiChatUseCaseProtocol: Sendable {
    func execute() async throws
}

final class StartNewAiChatUseCase: StartNewAiChatUseCaseProtocol, @unchecked Sendable {
    private let repository: AIChatRepositoryProtocol

    init(repository: AIChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.deleteHistory()
    }
}
