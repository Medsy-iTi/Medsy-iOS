//
//  CompletedOrdersRemoteDataSourceProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//



import Foundation

protocol CompletedOrdersRemoteDataSourceProtocol {
    func fetchOrders(
        pharmacyId: Int,
        page: Int,
        size: Int,
        sort: [String]
    ) async throws -> PaginatedResponseDTO<CompletedOrderDTO>
}

struct CompletedOrdersRemoteDataSource: CompletedOrdersRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchOrders(
        pharmacyId: Int,
        page: Int,
        size: Int,
        sort: [String]
    ) async throws -> PaginatedResponseDTO<CompletedOrderDTO> {
        let endpoint = CompletedOrdersEndpoint.getCompletedOrders(
            pharmacyId: pharmacyId,
            page: page,
            size: size,
            sort: sort
        )

      
        let envelope: APIResponseDTO<PaginatedResponseDTO<CompletedOrderDTO>> =
            try await networkService.request(endpoint: endpoint)

        guard let data = envelope.data else {
            throw NetworkError.validationError(envelope.message)
        }

        return data
    }
}
