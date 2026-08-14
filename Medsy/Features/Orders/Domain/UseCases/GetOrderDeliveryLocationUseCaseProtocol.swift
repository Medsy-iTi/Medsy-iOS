//
//  GetOrderDeliveryLocationUseCaseProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 12/08/2026.
//

import Foundation

protocol GetOrderDeliveryLocationUseCaseProtocol: AnyObject {
    func execute(requestID: Int) async throws -> OrderCoordinateEntity
}

final class GetOrderDeliveryLocationUseCase: GetOrderDeliveryLocationUseCaseProtocol {
    private let repository: OrdersRepositoryProtocol

    init(repository: OrdersRepositoryProtocol) {
        self.repository = repository
    }

    func execute(requestID: Int) async throws -> OrderCoordinateEntity {
        try await repository.fetchOrderDeliveryLocation(requestID: requestID)
    }
}
