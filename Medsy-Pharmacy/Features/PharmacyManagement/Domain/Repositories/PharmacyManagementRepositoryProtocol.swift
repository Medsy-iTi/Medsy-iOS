//
//  PharmacyManagementRepositoryProtocol.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

protocol PharmacyManagementRepositoryProtocol {
    func getMyPharmacy() async throws -> ManagedPharmacy?
    func createPharmacy(input: CreatePharmacyInput) async throws -> ManagedPharmacy
    func updatePharmacy(input: UpdatePharmacyInput) async throws -> ManagedPharmacy
    func deletePharmacy(id: Int) async throws
}
