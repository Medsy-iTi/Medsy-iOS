//
//  NetworkSevice.swift
//  Medsy
//
//  Created by Ehab Salah on 14/07/2026.
//

import Foundation

final class NetworkService: NetworkServiceProtocol {
    private let transport: NetworkTransportProtocol
    private let requestBuilder: NetworkRequestBuilder
    private let tokenStore: TokenStoreProtocol?
    private let tokenRefresher: TokenRefreshing?

    init(
        transport: NetworkTransportProtocol,
        requestBuilder: NetworkRequestBuilder,
        tokenStore: TokenStoreProtocol? = nil,
        tokenRefresher: TokenRefreshing? = nil
    ) {
        self.transport = transport
        self.requestBuilder = requestBuilder
        self.tokenStore = tokenStore
        self.tokenRefresher = tokenRefresher
    }

    func request<T: Decodable>(endpoint: ApiEndpoint) async throws -> T {
        try await execute(endpoint: endpoint, hasRetriedAfterRefresh: false)
    }

    func requestData(endpoint: ApiEndpoint) async throws -> Data {
        let urlRequest = try requestBuilder.makeRequest(
            for: endpoint,
            accessToken: endpoint.requiresAuthentication ? tokenStore?.accessToken() : nil
        )
        print("[Network] \(endpoint.method.rawValue) \(urlRequest.url?.absoluteString ?? endpoint.path)")
        let response: NetworkResponse
        do {
            response = try await transport.execute(urlRequest)
        } catch {
            throw NetworkErrorHandler.map(error: error, statusCode: nil, data: nil)
        }
        print("[Network] Status: \(response.statusCode ?? 0), bytes: \(response.data?.count ?? 0)")
        guard let statusCode = response.statusCode, (200...299).contains(statusCode),
              let data = response.data else {
            throw NetworkErrorHandler.map(
                error: NetworkError.unacceptableStatusCode(response.statusCode ?? 0),
                statusCode: response.statusCode,
                data: response.data
            )
        }
        return data
    }

    private func execute<T: Decodable>(
        endpoint: ApiEndpoint,
        hasRetriedAfterRefresh: Bool
    ) async throws -> T {
        let request = try requestBuilder.makeRequest(
            for: endpoint,
            accessToken: endpoint.requiresAuthentication ? tokenStore?.accessToken() : nil
        )

        let response: NetworkResponse
        do {
            response = try await transport.execute(request)
        } catch {
            throw NetworkErrorHandler.map(error: error, statusCode: nil, data: nil)
        }

        logResponse(response.data, statusCode: response.statusCode, endpoint: endpoint)

        if response.statusCode == 401, endpoint.requiresAuthentication {
            guard let tokenStore, let tokenRefresher else {
                throw NetworkError.unauthorized
            }

            guard !hasRetriedAfterRefresh else {
                try? tokenStore.clearTokens()
                throw NetworkError.unauthorized
            }

            do {
                try await tokenRefresher.refreshTokens()
            } catch {
                try? tokenStore.clearTokens()
                throw NetworkError.unauthorized
            }

            return try await execute(endpoint: endpoint, hasRetriedAfterRefresh: true)
        }

        if let apiError = NetworkErrorHandler.apiEnvelopeError(from: response.data) {
            throw apiError
        }

        guard let statusCode = response.statusCode, (200...299).contains(statusCode),
              let data = response.data else {
            throw NetworkErrorHandler.map(
                error: NetworkError.unacceptableStatusCode(response.statusCode ?? 0),
                statusCode: response.statusCode,
                data: response.data
            )
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    private func logResponse(_ data: Data?, statusCode: Int?, endpoint: ApiEndpoint) {
        guard endpoint.allowsResponseLogging, let data else { return }
        print("[Network] \(endpoint.method.rawValue) \(endpoint.path) [Status: \(statusCode ?? 0)]")
        print(JsonHelper.prettyJSON(data))
    }
}
