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
        print("[PharmacyRequestDetailsRepository] 🌐 Sending GET request to path: \(endpoint.path)")
        let envelope: APIEnvelope<PharmacyRequestDetailsDTO> = try await networkService.request(endpoint: endpoint)
        guard let dto = envelope.data else {
            print("[PharmacyRequestDetailsRepository] ❌ Envelope data was nil for requestId: \(requestId)")
            throw NetworkError.decodingFailed
        }
        print("[PharmacyRequestDetailsRepository] 📥 Received response DTO for requestId: \(dto.id)")
        return PharmacyRequestDetailsMapper.map(dto)
    }

    func fetchPharmacyRequests(pharmacyId: Int, page: Int, size: Int) async throws -> [PharmacyRequestDetailsEntity] {
        let endpoint = PharmacyRequestDetailsEndpoint.fetchPharmacyRequests(pharmacyId: pharmacyId, page: page, size: size)
        print("[PharmacyRequestDetailsRepository] 🌐 Sending GET request to path: \(endpoint.path)")
        let envelope: APIEnvelope<PageResponseDTO<PharmacyRequestDetailsDTO>> = try await networkService.request(endpoint: endpoint)
        guard let pageDTO = envelope.data else {
            print("[PharmacyRequestDetailsRepository] ❌ Envelope data was nil for pharmacyId: \(pharmacyId)")
            throw NetworkError.decodingFailed
        }
        print("[PharmacyRequestDetailsRepository] 📥 Received page response with \(pageDTO.content.count) items")
        return pageDTO.content.map(PharmacyRequestDetailsMapper.map)
    }
}
