//
//  PharmacyOrdersRepository.swift
//  Medsy
//
//  Created by Shahudaa on 21/07/2026.
//



final class PharmacyOrdersRepository: PharmacyOrdersRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchOrders(pharmacyId: Int, page: Int, size: Int) async throws -> PharmacyOrdersPage {
        let endpoint = PharmacyOrdersEndpoint.fetchOrders(pharmacyId: pharmacyId, page: page, size: size)

        do {
            let envelope: APIEnvelope<PageResponseDTO<PharmacyRequestAssignmentDTO>> =
                try await networkService.request(endpoint: endpoint)

            guard let pageDTO = envelope.data else {
                throw NetworkError.decodingFailed
            }

            return PharmacyOrderMapper.map(pageDTO)
        } catch {
            let envelope: APIEnvelope<PageResponseDTO<PharmacyOrderDTO>> =
                try await networkService.request(endpoint: endpoint)

            guard let pageDTO = envelope.data else {
                throw NetworkError.decodingFailed
            }

            return PharmacyOrderMapper.map(pageDTO)
        }
    }
}
