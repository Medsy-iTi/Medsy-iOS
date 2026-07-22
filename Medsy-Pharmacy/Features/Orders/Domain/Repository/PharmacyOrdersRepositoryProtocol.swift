//
//  PharmacyOrdersRepositoryProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 21/07/2026.
//

protocol PharmacyOrdersRepositoryProtocol {
    func fetchOrders(pharmacyId: Int, page: Int, size: Int) async throws -> PharmacyOrdersPage
}
