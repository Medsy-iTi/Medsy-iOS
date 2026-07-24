//
//  FetchChatHistoryUseCase.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//
protocol FetchChatHistoryUseCaseProtocol: Sendable {
    func execute() async throws -> [ChatMessage]
}

final class FetchChatHistoryUseCase: FetchChatHistoryUseCaseProtocol {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [ChatMessage] {
        try await repository.fetchChatHistory()
    }
}
