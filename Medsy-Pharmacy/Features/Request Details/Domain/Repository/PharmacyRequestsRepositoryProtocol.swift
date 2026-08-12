// PharmacyRequestsRepositoryProtocol.swift

import Foundation

protocol PharmacyRequestsRepositoryProtocol: Sendable {
    func fetchRequests(page: Int, size: Int) async throws -> [PharmacyMedicineRequestEntity]
    func fetchRequestById(requestId: Int) async throws -> PharmacyMedicineRequestEntity
    func sendOffer(requestId: Int, items: [(requestItemId: Int, productId: Int)]) async throws -> Bool
    func searchProducts(keyword: String, page: Int, size: Int) async throws -> [PharmacyProductDTO]
}
