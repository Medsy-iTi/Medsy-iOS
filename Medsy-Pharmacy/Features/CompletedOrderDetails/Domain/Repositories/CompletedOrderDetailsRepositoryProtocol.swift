//
//  CompletedOrderDetailsRepositoryProtocol.swift
//  Medsy
//

import Foundation

protocol CompletedOrderDetailsRepositoryProtocol {
    func fetchCompletedOrder(id: Int) async throws -> CompletedOrderDetailsEntity
    func markOrderReady(id: Int) async throws
    func markOrderOutForDelivery(id: Int) async throws
    func markOrderDelivered(id: Int) async throws
}
