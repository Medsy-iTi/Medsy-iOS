//
//  MedicineAnalyzeView.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

@MainActor
struct MedicineAnalyzeView: View {
    @Environment(CartViewModel.self) private var cartViewModel
    @State private var viewModel: MedicineAnalyzeViewModelProtocol

    private let onBack: () -> Void
    private let onProductSelected: (String) -> Void

    init(
        onBack: @escaping () -> Void,
        onProductSelected: @escaping (String) -> Void
    ) {
        self.init(
            viewModel: DIContainer.shared.resolve(MedicineAnalyzeViewModelProtocol.self),
            onBack: onBack,
            onProductSelected: onProductSelected
        )
    }

    init(
        viewModel: MedicineAnalyzeViewModelProtocol,
        onBack: @escaping () -> Void,
        onProductSelected: @escaping (String) -> Void = { _ in }
    ) {
        self.onBack = onBack
        self.onProductSelected = onProductSelected
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        MedicineAnalyzePage(onBack: handleBack) {
            switch viewModel.state {
            case .sourceSelection:
                SourceSelection(viewModel: viewModel)
            case .preview:
                if let selectedImageData = viewModel.selectedImageData {
                    MedicineAnalyzeImagePreview(
                        imageData: selectedImageData,
                        onChangeImage: viewModel.clearSelection,
                        onAnalyze: viewModel.analyze
                    )
                } else {
                    SourceSelection(viewModel: viewModel)
                }
            case .analyzing:
                MedicineAnalyzeLoadingView(onCancel: viewModel.cancelAnalysis)
            case .results:
                MedicineAnalyzeResultsView(
                    imageData: viewModel.selectedImageData,
                    products: viewModel.products,
                    quantity: {
                        cartViewModel.quantity(forProductID: Int64($0.id))
                    },
                    onProductSelected: onProductSelected,
                    onAdd: addToCart,
                    onIncrement: addToCart,
                    onDecrement: decreaseCartQuantity
                )
            case .noMatches:
                MedicineAnalyzeEmptyView(
                    onRetry: viewModel.retry,
                    onChangeImage: viewModel.clearSelection
                )
            case let .failure(message):
                MedicineAnalyzeFailureView(
                    message: message,
                    onRetry: viewModel.retry,
                    onChangeImage: viewModel.clearSelection
                )
            }
        }
        .photosPicker(
            isPresented: $viewModel.showsPhotoPicker,
            selection: $viewModel.selectedPhotoItem,
            matching: .images
        )
        .onChange(of: viewModel.selectedPhotoItem) { _, item in
            viewModel.selectPhoto(item)
        }
        .sheet(isPresented: $viewModel.showsCamera) {
            MedicineAnalyzeCameraPicker(onImageSelected: viewModel.selectCameraImage)
                .ignoresSafeArea()
        }
        .alert(
            "medicineAnalyze.cameraUnavailable.title".localized,
            isPresented: Binding(
                get: { viewModel.showsCameraUnavailable },
                set: { _ in viewModel.dismissCameraUnavailable() }
            )
        ) {
            Button("common.ok".localized, role: .cancel) {}
        } message: {
            Text("medicineAnalyze.cameraUnavailable.message".localized)
        }
    }

    private func handleBack() {
        guard let effect = viewModel.handleBack() else { return }
        switch effect {
        case .exit:
            onBack()
        }
    }

    private func addToCart(_ product: MedicineAnalyzeProductDisplay) {
        cartViewModel.handle(.addItem(product.cartItem))
    }

    private func decreaseCartQuantity(_ product: MedicineAnalyzeProductDisplay) {
        guard let productID = Int64(product.id),
              let itemID = cartViewModel.itemID(forProductID: productID) else {
            return
        }
        cartViewModel.handle(.decreaseQuantity(itemID: itemID))
    }
}
