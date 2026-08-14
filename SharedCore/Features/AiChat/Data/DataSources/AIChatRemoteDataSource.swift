//
//  AIChatRemoteDataSource.swift
//  SharedCore

import Foundation

protocol AIChatRemoteDataSourceProtocol: Sendable {
    func sendTextMessage(text: String, analyticsPreset: String?) async throws -> AIChatMessageResponseDTO
    func sendImageMessage(imageData: Data, mimeType: String, message: String?) async throws -> AIChatMessageResponseDTO
    func loadHistory() async throws -> AIChatHistoryResponseDTO
    func deleteHistory() async throws
    func getCartInteractions() async throws -> AIChatCartInteractionsResponseDTO
}

final class AIChatRemoteDataSource: AIChatRemoteDataSourceProtocol, @unchecked Sendable {
    private let networkService: NetworkServiceProtocol
    /// The AI key is supplied by each app's configuration (e.g. Constants.aiKey / PharmacyConfiguration.aiKey)
    private let aiKey: String

    init(networkService: NetworkServiceProtocol, aiKey: String) {
        self.networkService = networkService
        self.aiKey = aiKey
    }

    func sendTextMessage(text: String, analyticsPreset: String?) async throws -> AIChatMessageResponseDTO {
        let envelope: APIResponseDTO<AIChatMessageResponseDTO> = try await networkService.request(
            endpoint: AIChatEndpoint.sendTextMessage(text: text, analyticsPreset: analyticsPreset)
        )
        guard envelope.success, let data = envelope.data else {
            throw NetworkError.validationError(envelope.message)
        }
        return data
    }

    func sendImageMessage(imageData: Data, mimeType: String, message: String?) async throws -> AIChatMessageResponseDTO {
        let envelope: APIResponseDTO<AIChatMessageResponseDTO> = try await networkService.request(
            endpoint: AIChatEndpoint.sendImageMessage(imageData: imageData, mimeType: mimeType, message: message, aiKey: aiKey)
        )
        guard envelope.success, let data = envelope.data else {
            throw NetworkError.validationError(envelope.message)
        }
        return data
    }

    func loadHistory() async throws -> AIChatHistoryResponseDTO {
        let envelope: APIResponseDTO<AIChatHistoryResponseDTO> = try await networkService.request(
            endpoint: AIChatEndpoint.loadHistory
        )
        guard envelope.success, let data = envelope.data else {
            throw NetworkError.validationError(envelope.message)
        }
        return data
    }

    func deleteHistory() async throws {
        let envelope: APIResponseDTO<EmptyAIChatResponse> = try await networkService.request(
            endpoint: AIChatEndpoint.deleteHistory
        )
        guard envelope.success else {
            throw NetworkError.validationError(envelope.message)
        }
    }

    func getCartInteractions() async throws -> AIChatCartInteractionsResponseDTO {
        let envelope: APIResponseDTO<AIChatCartInteractionsResponseDTO> = try await networkService.request(
            endpoint: AIChatEndpoint.getCartInteractions
        )
        guard envelope.success, let data = envelope.data else {
            throw NetworkError.validationError(envelope.message)
        }
        return data
    }
}

// Minimal helper for DELETE endpoints that return no data
private struct EmptyAIChatResponse: Decodable {}
