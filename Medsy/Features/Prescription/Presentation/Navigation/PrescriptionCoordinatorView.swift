//
//  PrescriptionCoordinatorView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import PhotosUI
import SwiftUI
import UIKit

@MainActor
struct PrescriptionCoordinatorView: View {
    @State private var viewModel: PrescriptionViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showsPhotoPicker = false
    @State private var showsCamera = false
    @State private var showsCameraUnavailable = false

    private let onExit: () -> Void
    private let onOpenSearch: () -> Void
    private let onOpenCart: () -> Void

    init(
        mockOutcome: PrescriptionMockOutcome = .success,
        onExit: @escaping () -> Void,
        onOpenSearch: @escaping () -> Void,
        onOpenCart: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: PrescriptionViewModel(mockOutcome: mockOutcome))
        self.onExit = onExit
        self.onOpenSearch = onOpenSearch
        self.onOpenCart = onOpenCart
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .upload:
                PrescriptionUploadView(
                    onCamera: openCamera,
                    onGallery: { showsPhotoPicker = true },
                    onBack: { send(.back) }
                )
            case .preview:
                PrescriptionPreviewView(
                    imageData: viewModel.selectedImageData,
                    onContinue: { send(.continueFromPreview) },
                    onChangeImage: { send(.changeImage) },
                    onDelete: { send(.deleteImage) },
                    onBack: { send(.back) }
                )
            case let .reading(stage):
                PrescriptionReadingView(stage: stage, onCancel: { send(.cancelReading) })
            case .review:
                PrescriptionReviewView(
                    medicines: viewModel.medicines,
                    onAddToCart: { send(.addToCart) },
                    onBack: { send(.back) }
                )
            case .medicineSearch:
                EmptyView()
            case let .result(result):
                PrescriptionResultView(
                    result: result,
                    primaryAction: { send(primaryEvent(for: result)) },
                    secondaryAction: { send(secondaryEvent(for: result)) },
                    onBack: { send(.back) }
                )
            }
        }
        .photosPicker(isPresented: $showsPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, item in
            loadPhoto(item)
        }
        .sheet(isPresented: $showsCamera) {
            PrescriptionCameraPicker { data in
                send(.imageSelected(data, .camera))
            }
            .ignoresSafeArea()
        }
        .alert("prescription.camera.unavailable.title".localized, isPresented: $showsCameraUnavailable) {
            Button("common.ok".localized, role: .cancel) {}
        } message: {
            Text("prescription.camera.unavailable.message".localized)
        }
    }

    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showsCamera = true
        } else {
            showsCameraUnavailable = true
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            send(.imageSelected(data, .gallery))
            selectedPhotoItem = nil
        }
    }

    private func send(_ event: PrescriptionEvent) {
        guard let effect = viewModel.handle(event) else { return }

        switch effect {
        case .exit:
            onExit()
        case .openSearch:
            onOpenSearch()
        case .openCart:
            onOpenCart()
        }
    }

    private func primaryEvent(for result: PrescriptionFlowResult) -> PrescriptionEvent {
        switch result {
        case .added:
            .viewCart
        case .uploadFailed:
            .retry
        case .readingFailed, .noMedicines:
            .changeImage
        }
    }

    private func secondaryEvent(for result: PrescriptionFlowResult) -> PrescriptionEvent {
        switch result {
        case .added:
            .backHome
        case .uploadFailed:
            .changeImage
        case .readingFailed:
            .continueWithoutReading
        case .noMedicines:
            .addMedicineManually
        }
    }
}
