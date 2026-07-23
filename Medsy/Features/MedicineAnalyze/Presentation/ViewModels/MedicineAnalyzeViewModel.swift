//
//  MedicineAnalyzeViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import Observation
import PhotosUI
import SwiftUI
import UIKit

@MainActor
@Observable
final class MedicineAnalyzeViewModel: MedicineAnalyzeViewModelProtocol {
    private(set) var state: MedicineAnalyzeViewState = .sourceSelection
    var selectedPhotoItem: PhotosPickerItem?
    private(set) var selectedImageData: Data?
    private(set) var products: [MedicineAnalyzeProductDisplay] = []
    var showsPhotoPicker = false
    var showsCamera = false
    private(set) var showsCameraUnavailable = false

    private let analyzeMedicineImageUseCase: AnalyzeMedicineImageUseCaseProtocol
    private let languageProvider: () -> String
    private var analysisTask: Task<Void, Never>?
    private var imageLoadingTask: Task<Void, Never>?
    private var analysisRequestID: UUID?

    init(
        analyzeMedicineImageUseCase: AnalyzeMedicineImageUseCaseProtocol,
        languageProvider: @escaping () -> String
    ) {
        self.analyzeMedicineImageUseCase = analyzeMedicineImageUseCase
        self.languageProvider = languageProvider
    }
}

// MARK: - Image Selection

extension MedicineAnalyzeViewModel {
    func selectPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }

        imageLoadingTask?.cancel()
        imageLoadingTask = Task { [weak self] in
            defer { self?.selectedPhotoItem = nil }
            guard let self,
                  let imageData = try? await item.loadTransferable(type: Data.self),
                  !Task.isCancelled else {
                return
            }
            selectImage(imageData)
        }
    }

    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showsCameraUnavailable = true
            return
        }
        showsCamera = true
    }

    func dismissCamera() {
        showsCamera = false
    }

    func dismissCameraUnavailable() {
        showsCameraUnavailable = false
    }

    func selectCameraImage(_ imageData: Data) {
        showsCamera = false
        selectImage(imageData)
    }

    private func selectImage(_ imageData: Data) {
        guard let image = UIImage(data: imageData),
              let jpegData = image.jpegData(compressionQuality: 0.85) else {
            state = .failure("medicineAnalyze.imageError.message".localized)
            return
        }

        cancelActiveAnalysis()
        selectedImageData = jpegData
        products = []
        state = .preview
    }
}

// MARK: - Analysis

extension MedicineAnalyzeViewModel {
    func analyze() {
        guard state != .analyzing, let selectedImageData else { return }

        cancelActiveAnalysis()
        let requestID = UUID()
        analysisRequestID = requestID
        products = []
        state = .analyzing
        let language = languageProvider()

        analysisTask = Task { [weak self] in
            guard let self else { return }
            do {
                let analyzedProducts = try await analyzeMedicineImageUseCase.execute(
                    imageData: selectedImageData,
                    language: language
                )
                guard !Task.isCancelled else { return }
                completeAnalysis(analyzedProducts, requestID: requestID)
            } catch {
                guard !Task.isCancelled else { return }
                failAnalysis(error, requestID: requestID)
            }
        }
    }

    func retry() {
        guard selectedImageData != nil else {
            reset()
            return
        }
        analyze()
    }

    func cancelAnalysis() {
        guard state == .analyzing else { return }
        cancelActiveAnalysis()
        state = selectedImageData == nil ? .sourceSelection : .preview
    }

    private func completeAnalysis(
        _ analyzedProducts: [AnalyzedMedicineProduct],
        requestID: UUID
    ) {
        guard analysisRequestID == requestID else { return }
        products = analyzedProducts.map(MedicineAnalyzePresentationMapper.map)
        state = products.isEmpty ? .noMatches : .results
        finishAnalysis(requestID: requestID)
    }

    private func failAnalysis(_ error: Error, requestID: UUID) {
        guard analysisRequestID == requestID else { return }
        let message: String
        if case let NetworkError.validationError(backendMessage) = error {
            message = backendMessage
        } else {
            message = "error.no_connection_subtitle".localized
        }
        state = .failure(message)
        finishAnalysis(requestID: requestID)
    }

    private func finishAnalysis(requestID: UUID) {
        guard analysisRequestID == requestID else { return }
        analysisRequestID = nil
        analysisTask = nil
    }

    private func cancelActiveAnalysis() {
        analysisTask?.cancel()
        analysisTask = nil
        analysisRequestID = nil
    }
}

// MARK: - Navigation and Reset

extension MedicineAnalyzeViewModel {
    func clearSelection() {
        reset()
    }

    func handleBack() -> MedicineAnalyzeEffect? {
        switch state {
        case .sourceSelection:
            return .exit
        case .preview:
            reset()
        case .analyzing:
            cancelAnalysis()
        case .results, .noMatches, .failure:
            state = selectedImageData == nil ? .sourceSelection : .preview
            products = []
        }
        return nil
    }

    private func reset() {
        cancelActiveAnalysis()
        imageLoadingTask?.cancel()
        imageLoadingTask = nil
        selectedPhotoItem = nil
        selectedImageData = nil
        products = []
        state = .sourceSelection
    }
}
