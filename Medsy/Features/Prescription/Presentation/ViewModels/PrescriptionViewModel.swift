//
//  PrescriptionViewModel.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class PrescriptionViewModel {
    private(set) var state: PrescriptionViewState = .upload
    private(set) var selectedImageData: Data?
    private(set) var medicines: [PrescriptionMedicineDisplay] = []

    private let mockOutcome: PrescriptionMockOutcome
    private var selectedSource: PrescriptionImageSource?
    private var processingTask: Task<Void, Never>?

    init(
        mockOutcome: PrescriptionMockOutcome = .success,
        initialMedicines: [PrescriptionMedicineDisplay] = []
    ) {
        self.mockOutcome = mockOutcome
        medicines = initialMedicines
        if !initialMedicines.isEmpty {
            state = .review
        }
    }

    var canAddToCart: Bool {
        !medicines.isEmpty && medicines.allSatisfy(\.isConfirmed)
    }

    var confirmedMedicineCount: Int {
        medicines.filter(\.isConfirmed).count
    }

    var needsReviewMedicineCount: Int {
        medicines.filter { $0.needsReview && !$0.isConfirmed }.count
    }

    @discardableResult
    func handle(_ event: PrescriptionEvent) -> PrescriptionEffect? {
        switch event {
        case let .imageSelected(data, source):
            selectImage(data, from: source)
        case .continueFromPreview, .retry:
            startProcessing()
        case .changeImage, .deleteImage:
            reset()
        case .cancelReading:
            cancelProcessing()
        case let .confirmMedicine(id):
            confirmMedicine(id: id)
        case let .chooseAlternative(id):
            guard medicines.contains(where: { $0.id == id }) else { break }
            state = .medicineSearch(id)
        case let .replaceMedicine(id, product):
            replaceMedicine(id: id, with: product)
        case .cancelMedicineSearch:
            state = .review
        case let .increaseQuantity(id):
            updateQuantity(for: id, by: 1)
        case let .decreaseQuantity(id):
            updateQuantity(for: id, by: -1)
        case let .deleteMedicine(id):
            deleteMedicine(id: id)
        case .addToCart:
            guard canAddToCart else { break }
            state = .result(.added)
        case .continueWithoutReading:
            break
        case .addMedicineManually:
            break
        case .viewCart:
            break
        case .backHome:
            return .exit
        case .back:
            return goBack()
        }

        return nil
    }

    private func selectImage(_ data: Data, from source: PrescriptionImageSource) {
        processingTask?.cancel()
        selectedImageData = data
        selectedSource = source
        state = .preview
    }

    private func startProcessing() {
        guard selectedSource != nil, selectedImageData != nil else {
            state = .upload
            return
        }

        processingTask?.cancel()
        state = .reading(.uploading)
        processingTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(700))
            guard !Task.isCancelled else { return }
            self?.state = .reading(.analysing)
            try? await Task.sleep(for: .milliseconds(900))
            guard !Task.isCancelled else { return }
            self?.state = .reading(.extracting)
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            self?.completeProcessing()
        }
    }

    private func completeProcessing() {
        switch mockOutcome {
        case .success:
            medicines = PrescriptionMedicineDisplay.samples
            state = .review
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

        if selectedSource != nil {
            state = .preview
        } else {
            state = .upload
        }
    }

    private func reset() {
        processingTask?.cancel()
        processingTask = nil
        selectedSource = nil
        selectedImageData = nil
        medicines = []
        state = .upload
    }

    private func confirmMedicine(id: UUID) {
        guard let index = medicines.firstIndex(where: { $0.id == id }), !medicines[index].isConfirmed else { return }
        medicines[index].isConfirmed = true
        state = .review
    }

    private func replaceMedicine(id: UUID, with product: MedsyProduct) {
        guard let index = medicines.firstIndex(where: { $0.id == id }) else {
            state = .review
            return
        }

        medicines[index].name = product.name
        medicines[index].details = product.dosageInfo.isEmpty ? product.categoryName : product.dosageInfo
        medicines[index].price = String(format: "%.0f EGP", product.price)
        medicines[index].confidence = .identified
        medicines[index].isConfirmed = true
        state = .review
    }

    private func updateQuantity(for id: UUID, by delta: Int) {
        guard let index = medicines.firstIndex(where: { $0.id == id }) else { return }
        medicines[index].quantity = max(1, medicines[index].quantity + delta)
    }

    private func deleteMedicine(id: UUID) {
        medicines.removeAll { $0.id == id }
        if medicines.isEmpty {
            state = .result(.noMedicines)
        }
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
            if selectedSource != nil {
                state = .preview
            } else {
                state = .upload
            }
        case .medicineSearch:
            state = .review
        case let .result(result):
            switch result {
            case .added:
                state = .review
            case .uploadFailed, .readingFailed, .noMedicines:
                if selectedSource != nil {
                    state = .preview
                } else {
                    state = .upload
                }
            }
        }

        return nil
    }
}
