//
//  PharmacyManagementViewModel.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation
import Observation

enum PharmacyManagementEvent {
    case load
    case retry
    case create
    case update
    case delete(PharmacyManagementDisplayModel)
}

@MainActor
@Observable
final class PharmacyManagementViewModel {
    private(set) var state: PharmacyManagementViewState = .loading
    private(set) var formMode: PharmacyFormMode = .create
    var draft = PharmacyFormDraft()
    private(set) var validationMessage: String?
    private(set) var isSubmitting = false

    private let actions: PharmacyManagementActions
    private var selectedLicense: PharmacyLicenseDocument?
    private var editingPharmacy: PharmacyManagementDisplayModel?

    init(actions: PharmacyManagementActions) {
        self.actions = actions
    }

    var isFormSubmissionDisabled: Bool {
        let nameIsEmpty = draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let phoneIsEmpty = draft.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let addressIsEmpty = draft.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let locationIsMissing = draft.latitude == nil || draft.longitude == nil || addressIsEmpty
        let licenseIsMissing = formMode == .create && selectedLicense == nil
        return isSubmitting || nameIsEmpty || phoneIsEmpty || locationIsMissing || licenseIsMissing
    }

    func handle(_ event: PharmacyManagementEvent) async -> Bool {
        switch event {
        case .load, .retry:
            await loadPharmacy()
            return true
        case .create:
            return await submitCreate()
        case .update:
            return await submitUpdate()
        case let .delete(pharmacy):
            return await delete(pharmacy)
        }
    }

    func prepareForCreation() {
        formMode = .create
        draft = PharmacyFormDraft()
        selectedLicense = nil
        editingPharmacy = nil
        validationMessage = nil
    }

    func prepareForEditing(_ pharmacy: PharmacyManagementDisplayModel) {
        formMode = .edit
        draft = PharmacyFormDraft(
            name: pharmacy.name,
            phoneNumber: pharmacy.phoneNumber,
            address: pharmacy.address,
            latitude: pharmacy.latitude,
            longitude: pharmacy.longitude,
            licenseFileName: nil
        )
        selectedLicense = nil
        editingPharmacy = pharmacy
        validationMessage = nil
    }

    func updateLocation(latitude: Double, longitude: Double) async -> Bool {
        do {
            let address = try await actions.resolveLocation(latitude, longitude)
            draft.latitude = latitude
            draft.longitude = longitude
            draft.address = address
            validationMessage = nil
            return true
        } catch {
            validationMessage = "pharmacy.management.validation.location.resolve".localized
            return false
        }
    }

    func selectLicense(at url: URL) {
        let hasScopedAccess = url.startAccessingSecurityScopedResource()
        defer {
            if hasScopedAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let values = try url.resourceValues(forKeys: [.fileSizeKey, .nameKey])
            guard let fileSize = values.fileSize, fileSize <= 10 * 1_024 * 1_024 else {
                validationMessage = "pharmacy.management.validation.license.size".localized
                return
            }

            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            guard data.starts(with: Data("%PDF".utf8)) else {
                validationMessage = "pharmacy.management.validation.license.pdf".localized
                return
            }

            let fileName = values.name ?? url.lastPathComponent
            selectedLicense = PharmacyLicenseDocument(
                fileName: fileName,
                data: data,
                mimeType: "application/pdf"
            )
            draft.licenseFileName = fileName
            validationMessage = nil
        } catch {
            validationMessage = "pharmacy.management.validation.license.read".localized
        }
    }

    func setDocumentSelectionError() {
        validationMessage = "pharmacy.management.validation.license.read".localized
    }

    private func loadPharmacy() async {
        state = .loading
        do {
            if let pharmacy = try await actions.loadMyPharmacy() {
                state = .assigned(pharmacy)
            } else {
                state = .unassigned
            }
        } catch is CancellationError {
            return
        } catch {
            state = .failure
        }
    }

    private func submitCreate() async -> Bool {
        guard !isSubmitting, let submission = makeSubmission(requiresLicense: true) else {
            return false
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let pharmacy = try await actions.createPharmacy(submission)
            state = .assigned(pharmacy)
            validationMessage = nil
            return true
        } catch is CancellationError {
            return false
        } catch {
            validationMessage = error.localizedDescription
            return false
        }
    }

    private func submitUpdate() async -> Bool {
        guard !isSubmitting, editingPharmacy?.isAdmin == true,
              let submission = makeSubmission(requiresLicense: false) else {
            return false
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let updated = try await actions.updatePharmacy(submission)
            state = .assigned(
                PharmacyManagementDisplayModel(
                    id: updated.id,
                    name: updated.name,
                    address: updated.address,
                    phoneNumber: updated.phoneNumber,
                    latitude: updated.latitude,
                    longitude: updated.longitude,
                    isAdmin: true,
                    pharmacists: editingPharmacy?.pharmacists ?? updated.pharmacists
                )
            )
            validationMessage = nil
            return true
        } catch is CancellationError {
            return false
        } catch {
            validationMessage = error.localizedDescription
            return false
        }
    }

    private func delete(_ pharmacy: PharmacyManagementDisplayModel) async -> Bool {
        guard !isSubmitting, pharmacy.isAdmin else { return false }
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await actions.deletePharmacy(pharmacy.id)
            state = .unassigned
            return true
        } catch is CancellationError {
            return false
        } catch {
            state = .failure
            return false
        }
    }

    private func makeSubmission(requiresLicense: Bool) -> PharmacyFormSubmission? {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            validationMessage = "pharmacy.management.validation.name".localized
            return nil
        }

        let phone = draft.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phone.isEmpty,
              phone.range(of: "^01[0125][0-9]{8}$", options: .regularExpression) != nil else {
            validationMessage = "pharmacy.management.validation.phone".localized
            return nil
        }

        let address = draft.address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let latitude = draft.latitude, let longitude = draft.longitude, !address.isEmpty else {
            validationMessage = "pharmacy.management.validation.location".localized
            return nil
        }

        if requiresLicense && selectedLicense == nil {
            validationMessage = "pharmacy.management.validation.license.required".localized
            return nil
        }

        validationMessage = nil
        return PharmacyFormSubmission(
            pharmacyID: editingPharmacy?.id,
            name: name,
            phoneNumber: phone,
            address: address,
            latitude: latitude,
            longitude: longitude,
            license: requiresLicense ? selectedLicense : nil
        )
    }
}
