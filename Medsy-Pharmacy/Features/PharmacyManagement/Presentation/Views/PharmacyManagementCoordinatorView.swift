//
//  PharmacyManagementCoordinatorView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct PharmacyManagementCoordinatorView: View {
    @State private var coordinator: PharmacyManagementCoordinator
    @State private var isLicenseImporterPresented = false

    init(coordinator: PharmacyManagementCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    var body: some View {
        @Bindable var coordinator = coordinator
        @Bindable var viewModel = coordinator.viewModel

        NavigationStack(path: $coordinator.path) {
            PharmacyManagementView(
                state: viewModel.state,
                onAddPharmacy: coordinator.showAddPharmacy,
                onEditPharmacy: coordinator.showEditPharmacy,
                onDeletePharmacy: coordinator.deletePharmacy,
                onRetry: coordinator.retry
            )
            .task {
                await coordinator.loadIfNeeded()
            }
            .navigationDestination(for: PharmacyManagementRoute.self) { route in
                switch route {
                case let .form(mode):
                    PharmacyFormView(
                        mode: mode,
                        draft: $viewModel.draft,
                        validationMessage: viewModel.validationMessage,
                        isSubmitting: viewModel.isSubmitting,
                        isSubmitDisabled: viewModel.isFormSubmissionDisabled,
                        onBack: coordinator.pop,
                        onSelectLicense: {
                            isLicenseImporterPresented = true
                        },
                        onSelectLocation: coordinator.showLocationPicker,
                        onSubmit: coordinator.submitForm
                    )
                    .navigationBarBackButtonHidden()

                case .locationPicker:
                    PharmacyLocationPickerView(
                        latitude: viewModel.draft.latitude,
                        longitude: viewModel.draft.longitude,
                        onBack: coordinator.pop,
                        onConfirm: coordinator.confirmLocation
                    )
                    .navigationBarBackButtonHidden()
                }
            }
        }
        .tint(PharmacyColor.primary)
        .fileImporter(
            isPresented: $isLicenseImporterPresented,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                if let url = urls.first {
                    coordinator.selectLicense(at: url)
                }
            case let .failure(error):
                if (error as? CocoaError)?.code != .userCancelled {
                    coordinator.documentSelectionFailed()
                }
            }
        }
    }
}
