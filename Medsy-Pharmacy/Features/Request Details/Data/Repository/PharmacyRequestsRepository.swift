//
//  PharmacyRequestsRepository.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

final class PharmacyRequestsRepository: PharmacyRequestsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchRequests(page: Int, size: Int) async throws -> [PharmacyMedicineRequestEntity] {
        let endpoint = PharmacyRequestsEndpoint.fetchRequests(page: page, size: size)
        let response: APIEnvelope<PageResponseDTO<PharmacyMedicineRequestDTO>> = try await networkService.request(endpoint: endpoint)
        guard response.success, let data = response.data else {
            throw NetworkError.validationError(response.message)
        }
        return data.content.map { PharmacyMedicineRequestMapper.map($0) }
    }

    func fetchRequestById(requestId: Int) async throws -> PharmacyMedicineRequestEntity {
        let endpoint = PharmacyRequestsEndpoint.fetchRequestById(requestId: requestId)
        let response: APIEnvelope<PharmacyMedicineRequestDTO> = try await networkService.request(endpoint: endpoint)
        guard response.success, let data = response.data else {
            throw NetworkError.validationError(response.message)
        }
        return PharmacyMedicineRequestMapper.map(data)
    }

    func sendOffer(requestId: Int, items: [(requestItemId: Int, productId: Int)]) async throws -> Bool {
        let itemDTOs = items.map { SendOfferItemDTO(requestItemId: $0.requestItemId, productId: $0.productId) }
        let body = SendOfferRequestDTO(items: itemDTOs)
        let endpoint = PharmacyRequestsEndpoint.sendOffer(requestId: requestId, body: body)
        let response: APIEnvelope<SendOfferResponseDTO> = try await networkService.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        return true
    }
}
