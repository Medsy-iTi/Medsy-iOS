//
//  SendMessageUseCaseProtocol.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


protocol SendMessageUseCaseProtocol {
    func execute(text: String) async throws -> ChatMessage
}
final class SendMessageUseCase: SendMessageUseCaseProtocol {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(text: String) async throws -> ChatMessage {
        try await repository.sendMessage(text)
    }
}
