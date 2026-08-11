protocol GetCartInteractionsUseCaseProtocol {
    func execute(language: String) async throws -> [CartInteractionWarning]
}

final class GetCartInteractionsUseCase: GetCartInteractionsUseCaseProtocol {
    private let repository: CartRepositoryProtocol

    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }

    func execute(language: String) async throws -> [CartInteractionWarning] {
        try await repository.fetchInteractions(language: language)
    }
}
