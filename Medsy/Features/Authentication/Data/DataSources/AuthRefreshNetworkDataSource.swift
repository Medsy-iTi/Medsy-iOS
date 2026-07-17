//
//  AuthRefreshNetworkDataSource.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import Foundation

protocol AuthRefreshNetworkDataSourceProtocol {
    func refresh(request: RefreshTokenRequestDTO) async throws -> AuthSessionDTO
}

final class AuthRefreshNetworkDataSource: AuthRefreshNetworkDataSourceProtocol {
    private let transport: NetworkTransportProtocol
    private let requestBuilder: NetworkRequestBuilder

    init(transport: NetworkTransportProtocol, requestBuilder: NetworkRequestBuilder) {
        self.transport = transport
        self.requestBuilder = requestBuilder
    }

    func refresh(request: RefreshTokenRequestDTO) async throws -> AuthSessionDTO {
        let urlRequest = try requestBuilder.makeRequest(for: AuthEndpoint.refresh(request), accessToken: nil)
        let response: NetworkResponse
        do {
            response = try await transport.execute(urlRequest)
        } catch {
            throw NetworkErrorHandler.map(error: error, statusCode: nil, data: nil)
        }

        if let data = response.data {
            print("[Network] POST auth/refresh [Status: \(response.statusCode ?? 0)]")
             print(JsonHelper.prettyJSON(data))
        }
        
        if let apiError = NetworkErrorHandler.apiEnvelopeError(from: response.data) { throw apiError }
        guard let statusCode = response.statusCode, (200...299).contains(statusCode), let data = response.data else {
            throw NetworkErrorHandler.map(error: NetworkError.unacceptableStatusCode(response.statusCode ?? 0), statusCode: response.statusCode, data: response.data)
        }

        do {
            let response = try JSONDecoder().decode(AuthSessionResponseDTO.self, from: data)
            guard response.success, let session = response.data else {
                throw NetworkError.validationError(response.message)
            }
            return session
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
