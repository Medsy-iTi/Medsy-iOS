//
//  ProfileRepository.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import Foundation

final class ProfileRepository: ProfileRepositoryProtocol {
	private let networkService: NetworkServiceProtocol

	init(networkService: NetworkServiceProtocol) {
		self.networkService = networkService
	}

	func fetchProfile() async throws -> PharmacyProfile {
		let dto: PharmacyProfileDTO = try await networkService.request(endpoint: ProfileEndpoint.fetchProfile)
		return PharmacyProfileMapper.toDomain(dto)
	}

	@discardableResult
	func updateOrderReceivingStatus(isOpen: Bool) async throws -> Bool {
		let response: UpdateOrderReceivingStatusResponseDTO = try await networkService.request(
			endpoint: ProfileEndpoint.updateOrderReceivingStatus(isOpen: isOpen)
		)
		return response.isAcceptingOrders
	}

	func logout() async throws {
			
		let _: EmptyResponse = try await networkService.request(endpoint: ProfileEndpoint.logout)
	}
}


struct EmptyResponse: Decodable {}
