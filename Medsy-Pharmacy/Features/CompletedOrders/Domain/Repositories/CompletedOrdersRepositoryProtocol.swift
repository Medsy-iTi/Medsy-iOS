//
//  CompletedOrdersRepositoryProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//

import Foundation

protocol CompletedOrdersRepositoryProtocol {
    func fetchOrders(
        pharmacyId: Int,
        page: Int,
        size: Int,
        sort: [String]
    ) async throws -> PaginatedResult<CompletedOrder>
}
