//
//  PrescriptionViewModel.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import Observation

@MainActor
@Observable
final class PrescriptionViewModel {
    private(set) var state: PrescriptionViewState = .upload

    private let mockOutcome: PrescriptionMockOutcome
    private var selectedSource: PrescriptionImageSource?
    private var processingTask: Task<Void, Never>?

    init(mockOutcome: PrescriptionMockOutcome = .success) {
        self.mockOutcome = mockOutcome
    }

    @discardableResult
    func handle(_ event: PrescriptionEvent) -> PrescriptionEffect? {
        switch event {
        case .selectCamera:
            selectImage(from: .camera)
        case .selectGallery:
            selectImage(from: .gallery)
        case .continueFromPreview, .retry:
            startProcessing()
        case .changeImage, .deleteImage:
            reset()
        case .cancelReading:
            cancelProcessing()
        case .addToCart, .continueWithoutReading:
            state = .result(.added)
        case .addMedicineManually:
            return .openSearch
        case .viewCart:
            return .openCart
        case .backHome:
            return .exit
        case .back:
            return goBack()
        }

        return nil
    }

    private func selectImage(from source: PrescriptionImageSource) {
        processingTask?.cancel()
        selectedSource = source
        state = .preview(source)
    }

    private func startProcessing() {
        guard selectedSource != nil else {
            state = .upload
            return
        }

        processingTask?.cancel()
        state = .reading
        processingTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            self?.completeProcessing()
        }
    }

    private func completeProcessing() {
        switch mockOutcome {
        case .success:
            state = .review(PrescriptionMedicineDisplay.samples)
        case .uploadFailed:
            state = .result(.uploadFailed)
        case .readingFailed:
            state = .result(.readingFailed)
        case .noMedicines:
            state = .result(.noMedicines)
        }
        processingTask = nil
    }

    private func cancelProcessing() {
        processingTask?.cancel()
        processingTask = nil

        if let selectedSource {
            state = .preview(selectedSource)
        } else {
            state = .upload
        }
    }

    private func reset() {
        processingTask?.cancel()
        processingTask = nil
        selectedSource = nil
        state = .upload
    }

    private func goBack() -> PrescriptionEffect? {
        switch state {
        case .upload:
            return .exit
        case .preview:
            reset()
        case .reading:
            cancelProcessing()
        case .review:
            if let selectedSource {
                state = .preview(selectedSource)
            } else {
                state = .upload
            }
        case let .result(result):
            switch result {
            case .added:
                state = .review(PrescriptionMedicineDisplay.samples)
            case .uploadFailed, .readingFailed, .noMedicines:
                if let selectedSource {
                    state = .preview(selectedSource)
                } else {
                    state = .upload
                }
            }
        }

        return nil
    }
}
