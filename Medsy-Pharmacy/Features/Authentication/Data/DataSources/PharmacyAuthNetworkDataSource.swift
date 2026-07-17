//  PharmacyAuthNetworkDataSource.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation

protocol PharmacyAuthNetworkDataSourceProtocol {
    func login(request: LoginRequestDTO) async throws -> AuthSessionDTO
}

final class PharmacyAuthNetworkDataSource: PharmacyAuthNetworkDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func login(request: LoginRequestDTO) async throws -> AuthSessionDTO {
        let response: AuthSessionResponseDTO = try await networkService.request(
            endpoint: PharmacyAuthEndpoint.login(request)
        )
        guard response.success else { throw NetworkError.validationError(response.message) }
        guard let session = response.data else { throw NetworkError.decodingFailed }
        return session
    }
}
