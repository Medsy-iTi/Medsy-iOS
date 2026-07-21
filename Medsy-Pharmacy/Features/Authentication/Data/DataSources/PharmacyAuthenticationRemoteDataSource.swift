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
    func getCurrentMembership() async throws -> PharmacyMembership
    func createPharmacy(input: CreatePharmacyInput) async throws -> PharmacyResponseDTO
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

    func getCurrentMembership() async throws -> PharmacyMembership {
        let response: PharmacyProfileEnvelopeDTO = try await networkService.request(
            endpoint: PharmacyAuthenticationEndpoint.currentPharmacist
        )

        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let profile = response.data else {
            throw NetworkError.decodingFailed
        }
        return profile.toDomain()
    }

    func createPharmacy(input: CreatePharmacyInput) async throws -> PharmacyResponseDTO {
        let form = try PharmacyMultipartFormData(
            request: CreatePharmacyRequestDTO(input: input),
            license: input.license
        )
        let response: PharmacyResponseEnvelopeDTO = try await networkService.request(
            endpoint: PharmacyAuthenticationEndpoint.createPharmacy(form)
        )

        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let pharmacy = response.data else {
            throw NetworkError.decodingFailed
        }
        return pharmacy
    }
}
