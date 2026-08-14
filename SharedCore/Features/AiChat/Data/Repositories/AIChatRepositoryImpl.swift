//
//  AIChatRepositoryImpl.swift
//  SharedCore

import Foundation

final class AIChatRepositoryImpl: AIChatRepositoryProtocol, @unchecked Sendable {
    private let remoteDataSource: AIChatRemoteDataSourceProtocol

    init(remoteDataSource: AIChatRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func sendTextMessage(text: String, analyticsPreset: String?) async throws -> AIChatAssistantResponse {
        let dto = try await remoteDataSource.sendTextMessage(text: text, analyticsPreset: analyticsPreset)
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
