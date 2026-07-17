//
//  AuthNetworkDataSource.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

protocol AuthNetworkDataSourceProtocol {
    func register(request: SignupRequestDTO) async throws
}

final class AuthNetworkDataSource: AuthNetworkDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func register(request: SignupRequestDTO) async throws {
        let response: SignupResponseDTO = try await networkService.request(
            endpoint: AuthEndpoint.register(request)
        )

        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
    }
}
