//
//  ProfileRemoteDataSource.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

protocol ProfileRemoteDataSourceProtocol {
    func fetchProfile() async throws -> CustomerProfileDTO
    func updateProfile(request: UpdateCustomerProfileRequestDTO) async throws -> CustomerProfileDTO
}

final class ProfileRemoteDataSource: ProfileRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchProfile() async throws -> CustomerProfileDTO {
        let response: CustomerProfileResponseDTO = try await networkService.request(
            endpoint: ProfileEndpoint.fetch
        )
        return try profile(from: response)
    }

    func updateProfile(request: UpdateCustomerProfileRequestDTO) async throws -> CustomerProfileDTO {
        let response: CustomerProfileResponseDTO = try await networkService.request(
            endpoint: ProfileEndpoint.update(request)
        )
        return try profile(from: response)
    }

    private func profile(from response: CustomerProfileResponseDTO) throws -> CustomerProfileDTO {
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let profile = response.data else {
            throw NetworkError.decodingFailed
        }
        return profile
    }
}
