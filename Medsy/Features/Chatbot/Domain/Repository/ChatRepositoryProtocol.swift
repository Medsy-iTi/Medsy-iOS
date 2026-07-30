
//
//  ChatRepositoryProtocol.swift
//  Medsy
//

protocol ChatRepositoryProtocol: Sendable {

    func sendMessage(_ text: String, lang: String, limit: Int) async throws -> ChatMessage

    func fetchChatHistory() async throws -> [ChatMessage]
}
