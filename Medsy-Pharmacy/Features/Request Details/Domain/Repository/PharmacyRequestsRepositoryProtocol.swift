//
//  PharmacyRequestsRepositoryProtocol.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

protocol PharmacyRequestsRepositoryProtocol: Sendable {
    func fetchRequests(page: Int, size: Int) async throws -> [PharmacyMedicineRequestEntity]
    func fetchRequestById(requestId: Int) async throws -> PharmacyMedicineRequestEntity
    func sendOffer(requestId: Int, items: [(requestItemId: Int, productId: Int)]) async throws -> Bool
}
