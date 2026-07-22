//  PharmacyRequestDetailsRepository.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

final class PharmacyRequestDetailsRepository: PharmacyRequestDetailsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchRequestDetails(requestId: Int) async throws -> PharmacyRequestDetailsEntity {
        let endpoint = PharmacyRequestDetailsEndpoint.fetchRequestDetails(requestId: requestId)
        let envelope: APIEnvelope<PharmacyRequestDetailsDTO> = try await networkService.request(endpoint: endpoint)
        guard let dto = envelope.data else {
            throw NetworkError.decodingFailed
        }
        return PharmacyRequestDetailsMapper.map(dto)
    }

    func fetchPharmacyRequests(pharmacyId: Int, page: Int, size: Int) async throws -> [PharmacyRequestDetailsEntity] {
        let endpoint = PharmacyRequestDetailsEndpoint.fetchPharmacyRequests(pharmacyId: pharmacyId, page: page, size: size)
        let envelope: APIEnvelope<PageResponseDTO<PharmacyRequestDetailsDTO>> = try await networkService.request(endpoint: endpoint)
        guard let pageDTO = envelope.data else {
            throw NetworkError.decodingFailed
        }
        return pageDTO.content.map(PharmacyRequestDetailsMapper.map)
    }
}
