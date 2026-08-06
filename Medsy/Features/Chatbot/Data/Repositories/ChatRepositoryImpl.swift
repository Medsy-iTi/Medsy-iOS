//
//  ChatRepositoryImpl.swift
//  Medsy
//
import Foundation

final class ChatRepositoryImpl: ChatRepositoryProtocol, @unchecked Sendable {
    private let dataSource: CatalogAskDataSourceProtocol

    init(dataSource: CatalogAskDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func sendMessage(_ text: String, lang: String, limit: Int) async throws -> ChatMessage {
        let requestDTO = CatalogAskRequestDTO(question: text, lang: lang, limit: limit)
        let responseDTO = try await dataSource.ask(request: requestDTO)
        return CatalogAskMapper.map(responseDTO, userText: text)
    }

    func fetchChatHistory() async throws -> [ChatMessage] { return [] }
}

// MARK: - New AI Chat repository

final class AIChatRepositoryImpl: AIChatRepositoryProtocol, @unchecked Sendable {
    private let remoteDataSource: AIChatRemoteDataSourceProtocol

    init(remoteDataSource: AIChatRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func sendTextMessage(_ text: String) async throws -> AIChatAssistantResponse {
        let dto = try await remoteDataSource.sendTextMessage(text: text)
        return AIChatContractMapper.map(dto)
    }

    func sendImageMessage(imageData: Data, mimeType: String, message: String?) async throws -> AIChatAssistantResponse {
        let dto = try await remoteDataSource.sendImageMessage(imageData: imageData, mimeType: mimeType, message: message)
        return AIChatContractMapper.map(dto)
    }

    func loadHistory() async throws -> AIChatHistory {
        let dto = try await remoteDataSource.loadHistory()
        return AIChatContractMapper.map(dto)
    }

    func deleteHistory() async throws {
        try await remoteDataSource.deleteHistory()
    }

    func getCartInteractions() async throws -> [AIChatInteractionWarning] {
        let dto = try await remoteDataSource.getCartInteractions()
        return AIChatContractMapper.map(dto)
    }
}
