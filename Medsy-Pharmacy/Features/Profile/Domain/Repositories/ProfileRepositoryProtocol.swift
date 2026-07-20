//
//  ProfileRepositoryProtocol.swift
//  Medsy-Pharmacy
//

import Foundation

protocol ProfileRepositoryProtocol {
    // Fetch
    func fetchProfile() async throws -> PharmacyProfile

    // Personal Profile
    func updateProfile(
        id: Int,
        email: String,
        firstName: String,
        lastName: String,
        homeAddress: String?,
        dateOfBirth: Date?
    ) async throws

    // Pharmacy
    func leavePharmacy(pharmacyId: Int) async throws
    func updatePharmacy(id: Int, name: String?, address: String?, phoneNumber: String?) async throws
    func deletePharmacy(id: Int) async throws
    func removePharmacist(pharmacistId: Int, pharmacyId: Int) async throws
    func invitePharmacist(pharmacyId: Int, email: String) async throws -> PharmacyInvitation

    // Admin pharmacist management
    func updatePharmacist(
        id: Int,
        email: String?,
        firstName: String?,
        lastName: String?,
        homeAddress: String?,
        dateOfBirth: Date?
    ) async throws

    // Auth
    func logout() async throws
}
