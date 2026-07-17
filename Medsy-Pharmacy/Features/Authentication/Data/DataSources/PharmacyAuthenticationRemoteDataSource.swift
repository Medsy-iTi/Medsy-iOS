//
//  PharmacyAuthenticationRemoteDataSource.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

protocol PharmacyAuthenticationRemoteDataSourceProtocol {
    func login(request: PharmacyLoginRequestDTO) async throws -> PharmacyAuthenticationSessionDTO
    func register(request: PharmacyRegistrationRequestDTO) async throws
    func verify(request: PharmacyVerificationRequestDTO) async throws -> PharmacyAuthenticationSessionDTO
}

final class PharmacyAuthenticationRemoteDataSource: PharmacyAuthenticationRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func login(request: PharmacyLoginRequestDTO) async throws -> PharmacyAuthenticationSessionDTO {
        let response: PharmacyAuthenticationSessionResponseDTO = try await networkService.request(
            endpoint: PharmacyAuthenticationEndpoint.login(request)
        )

        guard response.success else {
            throw NetworkError.validationError(response.message)
        }

        guard let session = response.data else {
            throw NetworkError.decodingFailed
        }

        return session
    }

    func register(request: PharmacyRegistrationRequestDTO) async throws {
        let response: PharmacyRegistrationResponseDTO = try await networkService.request(
            endpoint: PharmacyAuthenticationEndpoint.register(request)
        )

        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
    }

    func verify(request: PharmacyVerificationRequestDTO) async throws -> PharmacyAuthenticationSessionDTO {
        let response: PharmacyAuthenticationSessionResponseDTO = try await networkService.request(
            endpoint: PharmacyAuthenticationEndpoint.verify(request)
        )

        guard response.success else {
            throw NetworkError.validationError(response.message)
        }

        guard let session = response.data else {
            throw NetworkError.decodingFailed
        }

        return session
    }
}
