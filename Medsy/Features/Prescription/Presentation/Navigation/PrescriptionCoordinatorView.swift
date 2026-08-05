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
    @Environment(CartViewModel.self) private var cartViewModel
    @State private var viewModel: PrescriptionViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showsPhotoPicker = false
    @State private var showsCamera = false
    @State private var showsCameraUnavailable = false

    private let onExit: () -> Void
    private let onViewCart: () -> Void

    init(
        viewModel: PrescriptionViewModel = DIContainer.shared.resolve(PrescriptionViewModel.self),
        onExit: @escaping () -> Void,
        onViewCart: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onExit = onExit
        self.onViewCart = onViewCart
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
            case .reading:
                PrescriptionReadingView(onCancel: { send(.cancelReading) })
            case .review:
                PrescriptionReviewView(
                    imageData: viewModel.selectedImageData,
                    medicines: viewModel.medicines,
                    confirmedCount: viewModel.confirmedMedicineCount,
                    needsReviewCount: viewModel.needsReviewMedicineCount,
                    canAddToCart: viewModel.canAddToCart,
                    isAddingToCart: viewModel.isAddingToCart,
                    cartErrorMessage: viewModel.cartErrorMessage,
                    expandedMedicineID: viewModel.expandedMedicineID,
                    onToggleCandidates: { send(.toggleCandidates($0)) },
                    onSelectCandidate: { send(.selectCandidate(medicineID: $0, candidateID: $1)) },
                    onSearchCatalog: { send(.searchCatalog($0)) },
                    onIncreaseQuantity: { send(.increaseQuantity($0)) },
                    onDecreaseQuantity: { send(.decreaseQuantity($0)) },
                    onDelete: { send(.deleteMedicine($0)) },
                    onAddToCart: addToCart,
                    onBack: { send(.back) }
                )
            case let .medicineSearch(context):
                SearchCoordinatorView(
                    query: context.query,
                    onBack: { send(.cancelMedicineSearch) },
                    onPush: { _ in },
                    onSelect: { send(.selectSearchedMedicine($0)) }
                )
            case let .result(result):
                PrescriptionResultView(
                    result: result,
                    primaryAction: { performPrimaryAction(for: result) },
                    secondaryAction: { send(secondaryEvent(for: result)) },
                    isPrimaryDisabled: false,
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
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data),
                  let jpegData = image.jpegData(compressionQuality: 0.85) else {
                selectedPhotoItem = nil
                return
            }
            send(.imageSelected(jpegData, .gallery))
            selectedPhotoItem = nil
        }
    }

    private func send(_ event: PrescriptionEvent) {
        guard let effect = viewModel.handle(event) else { return }

        switch effect {
        case .exit:
            onExit()
        }
    }

    private func addToCart() {
        send(.addToCart)
        guard viewModel.isAddingToCart else { return }

        let source: CartPrescriptionSource?
        switch viewModel.selectedImageSource {
        case .camera:
            source = .camera
        case .gallery:
            source = .photoLibrary
        case nil:
            source = nil
        }

        Task {
            do {
                try await cartViewModel.addPrescriptionReview(
                    items: viewModel.cartItems,
                    prescriptionData: viewModel.selectedImageData,
                    source: source
                )
                send(.addToCartSucceeded)
            } catch {
                send(.addToCartFailed(error.localizedDescription))
            }
        }
    }

    private func performPrimaryAction(for result: PrescriptionFlowResult) {
        if result == .added {
            onViewCart()
        } else {
            send(primaryEvent(for: result))
        }
    }

    private func primaryEvent(for result: PrescriptionFlowResult) -> PrescriptionEvent {
        switch result {
        case .added:
            .backHome
        case .analysisFailed:
            .retry
        case .noMedicines:
            .changeImage
        }
    }

    private func secondaryEvent(for result: PrescriptionFlowResult) -> PrescriptionEvent {
        switch result {
        case .added:
            .backHome
        case .analysisFailed:
            .changeImage
        case .noMedicines:
            .addMedicineManually
        }
    }
}
