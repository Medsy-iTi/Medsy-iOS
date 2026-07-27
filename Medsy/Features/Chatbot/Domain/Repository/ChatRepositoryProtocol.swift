//
//  ChatRepositoryProtocol.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


protocol ChatRepositoryProtocol: Sendable {
    func sendMessage(_ text: String) async throws -> ChatMessage
    func fetchChatHistory() async throws -> [ChatMessage]
}
