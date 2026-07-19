//
//  PharmacyManagementActions.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

struct PharmacyManagementActions {
    let loadMyPharmacy: () async throws -> PharmacyManagementDisplayModel?
    let createPharmacy: (PharmacyFormSubmission) async throws -> PharmacyManagementDisplayModel
    let updatePharmacy: (PharmacyFormSubmission) async throws -> PharmacyManagementDisplayModel
    let deletePharmacy: (Int) async throws -> Void

    static let placeholder = PharmacyManagementActions(
        loadMyPharmacy: { nil },
        createPharmacy: { submission in
            PharmacyManagementDisplayModel(
                id: 1,
                name: submission.name,
                address: submission.address ?? "",
                phoneNumber: submission.phoneNumber ?? "",
                latitude: submission.latitude,
                longitude: submission.longitude,
                isAdmin: true,
                pharmacists: []
            )
        },
        updatePharmacy: { submission in
            PharmacyManagementDisplayModel(
                id: submission.pharmacyID ?? 1,
                name: submission.name,
                address: submission.address ?? "",
                phoneNumber: submission.phoneNumber ?? "",
                latitude: submission.latitude,
                longitude: submission.longitude,
                isAdmin: true,
                pharmacists: []
            )
        },
        deletePharmacy: { _ in }
    )
}
