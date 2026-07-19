//
//  PharmacyManagementCoordinator.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class PharmacyManagementCoordinator {
    var path: [PharmacyManagementRoute] = []
    let viewModel: PharmacyManagementViewModel
    private var hasLoaded = false

    init(actions: PharmacyManagementActions) {
        viewModel = PharmacyManagementViewModel(actions: actions)
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await viewModel.handle(.load)
    }

    func retry() {
        Task {
            await viewModel.handle(.retry)
        }
    }

    func showAddPharmacy() {
        viewModel.prepareForCreation()
        path.append(.form(.create))
    }

    func showEditPharmacy(_ pharmacy: PharmacyManagementDisplayModel) {
        guard pharmacy.isAdmin else { return }
        viewModel.prepareForEditing(pharmacy)
        path.append(.form(.edit))
    }

    func showLocationPicker() {
        path.append(.locationPicker)
    }

    func confirmLocation(latitude: Double, longitude: Double) {
        viewModel.updateLocation(latitude: latitude, longitude: longitude)
        pop()
    }

    func selectLicense(at url: URL) {
        viewModel.selectLicense(at: url)
    }

    func documentSelectionFailed() {
        viewModel.setDocumentSelectionError()
    }

    func submitForm() {
        Task {
            let event: PharmacyManagementEvent = viewModel.formMode == .create ? .create : .update
            if await viewModel.handle(event) {
                path.removeAll()
            }
        }
    }

    func deletePharmacy(_ pharmacy: PharmacyManagementDisplayModel) {
        Task {
            _ = await viewModel.handle(.delete(pharmacy))
        }
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
