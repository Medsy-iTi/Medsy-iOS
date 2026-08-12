import Foundation
import Observation

@MainActor
@Observable
final class PrescriptionViewModel {
    private(set) var state: PrescriptionViewState = .upload
    private(set) var selectedImageData: Data?
    private(set) var medicines: [PrescriptionMedicineDisplay] = []
    private(set) var expandedMedicineID: String?
    private(set) var isAddingToCart = false
    private(set) var cartErrorMessage: String?

    private let analyzePrescriptionUseCase: AnalyzePrescriptionUseCaseProtocol?
    private let languageProvider: () -> String
    private var selectedSource: PrescriptionImageSource?
    private var processingTask: Task<Void, Never>?
    private var analysisRequestID: UUID?

    init(
        analyzePrescriptionUseCase: AnalyzePrescriptionUseCaseProtocol? = nil,
        languageProvider: @escaping () -> String = { "en" },
        initialMedicines: [PrescriptionMedicineDisplay] = []
    ) {
        self.analyzePrescriptionUseCase = analyzePrescriptionUseCase
        self.languageProvider = languageProvider
        medicines = initialMedicines
        if !initialMedicines.isEmpty {
            state = .review
        }
    }

    var canAddToCart: Bool {
        !isAddingToCart
            && !medicines.isEmpty
            && medicines.allSatisfy { $0.cartItem != nil }
    }

    var cartItems: [CartDisplayItem] {
        medicines.compactMap(\.cartItem)
    }

    var selectedImageSource: PrescriptionImageSource? {
        selectedSource
    }

    var confirmedMedicineCount: Int {
        medicines.filter(\.isConfirmed).count
    }

    var needsReviewMedicineCount: Int {
        medicines.filter(\.needsReview).count
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
        case let .toggleCandidates(id):
            toggleCandidates(for: id)
        case let .selectCandidate(medicineID, candidateID):
            selectCandidate(medicineID: medicineID, candidateID: candidateID)
        case let .searchCatalog(id):
            openCatalogSearch(for: id)
        case let .selectSearchedMedicine(product):
            selectSearchedMedicine(product)
        case .cancelMedicineSearch:
            cancelMedicineSearch()
        case let .increaseQuantity(id):
            updateQuantity(for: id, by: 1)
        case let .decreaseQuantity(id):
            updateQuantity(for: id, by: -1)
        case let .deleteMedicine(id):
            deleteMedicine(id: id)
        case .addToCart:
            guard canAddToCart else { break }
            cartErrorMessage = nil
            isAddingToCart = true
        case .addToCartSucceeded:
            guard isAddingToCart else { break }
            isAddingToCart = false
            state = .result(.added)
        case let .addToCartFailed(message):
            isAddingToCart = false
            cartErrorMessage = message
        case .addMedicineManually:
            state = .medicineSearch(.add(query: ""))
        case .backHome:
            return .exit
        case .back:
            return goBack()
        }

        return nil
    }

    private func selectImage(_ data: Data, from source: PrescriptionImageSource) {
        cancelActiveRequest()
        selectedImageData = data
        selectedSource = source
        medicines = []
        expandedMedicineID = nil
        cartErrorMessage = nil
        state = .preview
    }

    private func startProcessing() {
        guard let selectedImageData, selectedSource != nil else {
            state = .upload
            return
        }
        guard let analyzePrescriptionUseCase else {
            state = .result(.analysisFailed("Prescription analysis is unavailable."))
            return
        }

        cancelActiveRequest()
        let requestID = UUID()
        analysisRequestID = requestID
        state = .reading
        cartErrorMessage = nil

        let language = languageProvider()
        processingTask = Task { [weak self] in
            do {
                let analysis = try await analyzePrescriptionUseCase.execute(
                    imageData: selectedImageData,
                    language: language
                )
                guard !Task.isCancelled else { return }
                self?.completeAnalysis(analysis, requestID: requestID)
            } catch {
                guard !Task.isCancelled else { return }
                self?.failAnalysis(with: error, requestID: requestID)
            }
        }
    }

    private func completeAnalysis(_ analysis: PrescriptionAnalysis, requestID: UUID) {
        guard analysisRequestID == requestID else { return }
        medicines = PrescriptionPresentationMapper.map(analysis)
        expandedMedicineID = nil
        state = medicines.isEmpty ? .result(.noMedicines) : .review
        finishRequest(requestID)
    }

    private func failAnalysis(with error: Error, requestID: UUID) {
        guard analysisRequestID == requestID else { return }
        state = .result(.analysisFailed(error.localizedDescription))
        finishRequest(requestID)
    }

    private func finishRequest(_ requestID: UUID) {
        guard analysisRequestID == requestID else { return }
        analysisRequestID = nil
        processingTask = nil
    }

    private func cancelProcessing() {
        cancelActiveRequest()
        state = selectedSource == nil ? .upload : .preview
    }

    private func cancelActiveRequest() {
        processingTask?.cancel()
        processingTask = nil
        analysisRequestID = nil
    }

    private func reset() {
        cancelActiveRequest()
        selectedSource = nil
        selectedImageData = nil
        medicines = []
        expandedMedicineID = nil
        isAddingToCart = false
        cartErrorMessage = nil
        state = .upload
    }

    private func toggleCandidates(for id: String) {
        guard medicines.contains(where: { $0.id == id }) else { return }
        expandedMedicineID = expandedMedicineID == id ? nil : id
    }

    private func selectCandidate(medicineID: String, candidateID: Int) {
        guard let medicineIndex = medicines.firstIndex(where: { $0.id == medicineID }),
              let candidate = medicines[medicineIndex].candidates.first(where: { $0.id == candidateID }) else {
            return
        }

        medicines[medicineIndex].selectedProduct = PrescriptionPresentationMapper.selectedProduct(from: candidate)
        expandedMedicineID = nil
        cartErrorMessage = nil
        state = .review
    }

    private func openCatalogSearch(for id: String) {
        guard let medicine = medicines.first(where: { $0.id == id }) else { return }
        expandedMedicineID = nil
        state = .medicineSearch(.replace(medicineID: id, query: medicine.extractedName))
    }

    private func selectSearchedMedicine(_ product: MedsyProduct) {
        guard case let .medicineSearch(context) = state,
              let selectedProduct = PrescriptionPresentationMapper.selectedProduct(from: product) else {
            return
        }

        switch context {
        case let .replace(medicineID, _):
            guard let index = medicines.firstIndex(where: { $0.id == medicineID }) else {
                state = .review
                return
            }
            medicines[index].selectedProduct = selectedProduct
        case .add:
            medicines.append(
                PrescriptionMedicineDisplay(
                    id: "manual-\(UUID().uuidString)",
                    rawText: product.name,
                    extractedName: product.name,
                    extractedStrength: nil,
                    extractedForm: nil,
                    matchStatus: "MANUAL",
                    confidence: 1,
                    candidates: [],
                    selectedProduct: selectedProduct
                )
            )
        }

        cartErrorMessage = nil
        state = .review
    }

    private func cancelMedicineSearch() {
        guard case let .medicineSearch(context) = state else { return }
        switch context {
        case .replace:
            state = .review
        case .add:
            state = medicines.isEmpty ? .result(.noMedicines) : .review
        }
    }

    private func updateQuantity(for id: String, by delta: Int) {
        guard let index = medicines.firstIndex(where: { $0.id == id }) else { return }
        medicines[index].quantity = max(1, medicines[index].quantity + delta)
        cartErrorMessage = nil
    }

    private func deleteMedicine(id: String) {
        medicines.removeAll { $0.id == id }
        if expandedMedicineID == id {
            expandedMedicineID = nil
        }
        cartErrorMessage = nil
        if medicines.isEmpty {
            state = .result(.noMedicines)
        }
    }

    private func goBack() -> PrescriptionEffect? {
        guard !isAddingToCart else { return nil }
        switch state {
        case .upload:
            return .exit
        case .preview:
            reset()
        case .reading:
            cancelProcessing()
        case .review:
            state = selectedSource == nil ? .upload : .preview
        case .medicineSearch:
            cancelMedicineSearch()
        case let .result(result):
            switch result {
            case .added:
                state = .review
            case .analysisFailed, .noMedicines:
                state = selectedSource == nil ? .upload : .preview
            }
        }

        return nil
    }
}
