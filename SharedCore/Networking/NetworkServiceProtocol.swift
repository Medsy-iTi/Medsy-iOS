//
//  NetworkServiceProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: ApiEndpoint) async throws -> T
    func requestData(endpoint: ApiEndpoint) async throws -> Data
    func streamSSE(endpoint: ApiEndpoint) -> AsyncThrowingStream<SSEEvent, Error>
}

protocol TokenStoreProtocol {
    func accessToken() -> String?
    func refreshToken() -> String?
    func save(accessToken: String, refreshToken: String) throws
    func clearTokens() throws
}

protocol TokenRefreshing {
    func refreshTokens() async throws
}

extension NetworkServiceProtocol {
    func streamSSE(endpoint: ApiEndpoint) -> AsyncThrowingStream<SSEEvent, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }
}

