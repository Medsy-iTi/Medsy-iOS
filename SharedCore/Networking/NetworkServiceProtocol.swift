//
//  NetworkServiceProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: ApiEndpoint) async throws -> T
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
