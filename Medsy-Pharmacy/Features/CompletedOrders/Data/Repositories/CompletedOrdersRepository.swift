//
//  CompletedOrdersRepository.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//



import Foundation

struct CompletedOrdersRepository: CompletedOrdersRepositoryProtocol {
    private let remoteDataSource: CompletedOrdersRemoteDataSourceProtocol

    init(remoteDataSource: CompletedOrdersRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchOrders(
        pharmacyId: Int,
        page: Int,
        size: Int,
        sort: [String]
    ) async throws -> PaginatedResult<CompletedOrder> {
        let dto = try await remoteDataSource.fetchOrders(
            pharmacyId: pharmacyId,
            page: page,
            size: size,
            sort: sort
        )
        return CompletedOrderMapper.map(dto)
    }
}
