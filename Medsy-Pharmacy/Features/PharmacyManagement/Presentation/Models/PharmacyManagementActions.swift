//
//  PharmacyManagementActions.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

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

    static func live(
        getMyPharmacyUseCase: GetMyPharmacyUseCaseProtocol,
        createPharmacyUseCase: CreatePharmacyUseCaseProtocol,
        updatePharmacyUseCase: UpdatePharmacyUseCaseProtocol,
        deletePharmacyUseCase: DeletePharmacyUseCaseProtocol
    ) -> PharmacyManagementActions {
        PharmacyManagementActions(
            loadMyPharmacy: {
                let pharmacy = try await getMyPharmacyUseCase.execute()
                return pharmacy?.toDisplayModel()
            },
            createPharmacy: { submission in
                guard let license = submission.license else {
                    throw PharmacyManagementActionError.missingLicense
                }
                let pharmacy = try await createPharmacyUseCase.execute(
                    input: CreatePharmacyInput(
                        name: submission.name,
                        latitude: submission.latitude,
                        longitude: submission.longitude,
                        address: submission.address,
                        phoneNumber: submission.phoneNumber,
                        license: PharmacyLicenseFile(
                            fileName: license.fileName,
                            data: license.data,
                            mimeType: license.mimeType
                        )
                    )
                )
                return pharmacy.toDisplayModel()
            },
            updatePharmacy: { submission in
                guard let pharmacyID = submission.pharmacyID else {
                    throw PharmacyManagementActionError.missingPharmacyID
                }
                let pharmacy = try await updatePharmacyUseCase.execute(
                    input: UpdatePharmacyInput(
                        id: pharmacyID,
                        name: submission.name,
                        latitude: submission.latitude,
                        longitude: submission.longitude,
                        address: submission.address,
                        phoneNumber: submission.phoneNumber
                    )
                )
                return pharmacy.toDisplayModel()
            },
            deletePharmacy: { id in
                try await deletePharmacyUseCase.execute(id: id)
            }
        )
    }
}

private enum PharmacyManagementActionError: LocalizedError {
    case missingLicense
    case missingPharmacyID

    var errorDescription: String? {
        switch self {
        case .missingLicense:
            "pharmacy.management.validation.license.required".localized
        case .missingPharmacyID:
            "pharmacy.management.error.message".localized
        }
    }
}

private extension ManagedPharmacy {
    func toDisplayModel() -> PharmacyManagementDisplayModel {
        PharmacyManagementDisplayModel(
            id: id,
            name: name,
            address: address ?? "",
            phoneNumber: phoneNumber ?? "",
            latitude: latitude,
            longitude: longitude,
            isAdmin: isAdmin,
            pharmacists: pharmacists.map { member in
                PharmacyTeamMemberDisplayModel(
                    id: member.id,
                    fullName: "\(member.firstName) \(member.lastName)"
                        .trimmingCharacters(in: .whitespacesAndNewlines),
                    phoneNumber: member.phoneNumber,
                    email: member.email,
                    isAdmin: member.isAdmin
                )
            }
        )
    }
}
