//
//  MedicineAnalyzeView.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

@MainActor
struct MedicineAnalyzeView: View {
    @State private var viewModel: MedicineAnalyzeViewModelProtocol
    
    let onBack: () -> Void
    
    init(onBack: @escaping () -> Void) {
        self.init(onBack: onBack, viewModel: MedicineAnalyzeViewModel())
    }
    
    init(onBack: @escaping () -> Void, viewModel: MedicineAnalyzeViewModelProtocol) {
        self.onBack = onBack
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        MedicineAnalyzePage(onBack: onBack) {
            Group {
                if let selectedImageData = viewModel.selectedImageData {
                    MedicineAnalyzeImagePreview(
                        imageData: selectedImageData,
                        onChangeImage: viewModel.clearSelection,
                        onAnalyze: viewModel.analyze
                    )
                } else {
                    SourceSelection(viewModel: viewModel)
                }
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
}
