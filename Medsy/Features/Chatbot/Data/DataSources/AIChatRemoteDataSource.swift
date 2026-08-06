import Foundation

protocol AIChatRemoteDataSourceProtocol: Sendable {
    func sendTextMessage(text: String) async throws -> AIChatMessageResponseDTO
    func sendImageMessage(imageData: Data, mimeType: String, message: String?) async throws -> AIChatMessageResponseDTO
    func loadHistory() async throws -> AIChatHistoryResponseDTO
    func deleteHistory() async throws
    func getCartInteractions() async throws -> AIChatCartInteractionsResponseDTO
}

final class AIChatRemoteDataSource: AIChatRemoteDataSourceProtocol, @unchecked Sendable {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func sendTextMessage(text: String) async throws -> AIChatMessageResponseDTO {
        let envelope: APIResponseDTO<AIChatMessageResponseDTO> = try await networkService.request(
            endpoint: AIChatEndpoint.sendTextMessage(text: text)
        )
        guard envelope.success, let data = envelope.data else {
            throw NetworkError.validationError(envelope.message)
        }
        return data
    }

    func sendImageMessage(imageData: Data, mimeType: String, message: String?) async throws -> AIChatMessageResponseDTO {
        let envelope: APIResponseDTO<AIChatMessageResponseDTO> = try await networkService.request(
            endpoint: AIChatEndpoint.sendImageMessage(imageData: imageData, mimeType: mimeType, message: message)
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
        let envelope: APIResponseDTO<EmptyResponse> = try await networkService.request(
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
private struct EmptyResponse: Decodable {}
