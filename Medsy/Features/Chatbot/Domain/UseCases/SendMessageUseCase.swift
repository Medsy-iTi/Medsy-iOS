
//
//  SendMessageUseCase.swift
//  Medsy
//


protocol SendMessageUseCaseProtocol: Sendable {

    func execute(text: String, lang: String, limit: Int) async throws -> ChatMessage
}


final class SendMessageUseCase: SendMessageUseCaseProtocol, @unchecked Sendable {

    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(text: String, lang: String, limit: Int) async throws -> ChatMessage {
        try await repository.sendMessage(text, lang: lang, limit: limit)
    }
}
