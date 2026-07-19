//
//  ProfileRepository.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Foundation

final class ProfileRepository: ProfileRepositoryProtocol {
	private let networkService: NetworkServiceProtocol
    private let tokenStore: TokenStoreProtocol

	init(networkService: NetworkServiceProtocol, tokenStore: TokenStoreProtocol) {
		self.networkService = networkService
        self.tokenStore = tokenStore
	}

	func fetchProfile() async throws -> PharmacyProfile {
		let pharmacistEnvelope: PharmacistMeResponseEnvelope = try await networkService.request(endpoint: ProfileEndpoint.fetchPharmacistMe)
        
        var pharmacyData: PharmacyMineResponseDTO?
        do {
            let pharmacyEnvelope: PharmacyMineEnvelope = try await networkService.request(endpoint: ProfileEndpoint.fetchPharmacyMine)
            pharmacyData = pharmacyEnvelope.data
        } catch {
            // Ignore 404 or validation errors if the pharmacist is not assigned to a pharmacy yet
            switch error {
            case NetworkError.notFound, NetworkError.validationError:
                pharmacyData = nil
            default:
                throw error
            }
        }
        
		return PharmacyProfileMapper.toDomain(pharmacist: pharmacistEnvelope.data, pharmacy: pharmacyData)
	}



	func logout() async throws {
        guard let refreshToken = tokenStore.refreshToken() else { return }
		let _: EmptyResponse = try await networkService.request(endpoint: ProfileEndpoint.logout(refreshToken: refreshToken))
	}
}


struct EmptyResponse: Decodable {}
