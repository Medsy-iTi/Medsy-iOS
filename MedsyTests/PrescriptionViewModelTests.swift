import XCTest
@testable import Medsy

@MainActor
final class PrescriptionViewModelTests: XCTestCase {
    func testAnalysisUsesCurrentLanguageAndKeepsAllCandidatesUnconfirmed() async {
        let useCase = PrescriptionUseCaseStub(result: .success(analysis()))
        let imageData = Data([1, 2, 3])
        let viewModel = PrescriptionViewModel(
            analyzePrescriptionUseCase: useCase,
            languageProvider: { "ar" }
        )

        viewModel.handle(.imageSelected(imageData, .gallery))
        viewModel.handle(.continueFromPreview)
        await waitUntil { viewModel.state == .review }

        XCTAssertEqual(useCase.requests.first?.imageData, imageData)
        XCTAssertEqual(useCase.requests.first?.language, "ar")
        XCTAssertEqual(viewModel.medicines.first?.candidates.count, 2)
        XCTAssertEqual(viewModel.confirmedMedicineCount, 0)
        XCTAssertEqual(viewModel.needsReviewMedicineCount, 1)
        XCTAssertFalse(viewModel.canAddToCart)
    }

    func testSelectingCandidateConfirmsMedicineAndCreatesCartItem() {
        let medicine = PrescriptionPresentationMapper.map(analysis().medicines[0])
        let viewModel = PrescriptionViewModel(initialMedicines: [medicine])

        viewModel.handle(.toggleCandidates(medicine.id))
        XCTAssertEqual(viewModel.expandedMedicineID, medicine.id)

        viewModel.handle(.selectCandidate(medicineID: medicine.id, candidateID: 562))

        XCTAssertNil(viewModel.expandedMedicineID)
        XCTAssertEqual(viewModel.medicines.first?.name, "PANADOL ADVANCE 500 MG 24 TABS")
        XCTAssertEqual(viewModel.medicines.first?.price, "46 EGP")
        XCTAssertTrue(viewModel.medicines.first?.isConfirmed == true)
        XCTAssertEqual(viewModel.cartItems.first?.productID, 562)
        XCTAssertTrue(viewModel.canAddToCart)
    }

    func testCatalogSearchIsPrefilledAndConfirmsMedicineWithoutCandidates() {
        let medicine = unresolvedMedicine()
        let viewModel = PrescriptionViewModel(initialMedicines: [medicine])

        viewModel.handle(.searchCatalog(medicine.id))

        XCTAssertEqual(
            viewModel.state,
            .medicineSearch(.replace(medicineID: medicine.id, query: "fusic"))
        )

        viewModel.handle(.selectSearchedMedicine(product(id: "356")))

        XCTAssertEqual(viewModel.state, .review)
        XCTAssertEqual(viewModel.cartItems.first?.productID, 356)
        XCTAssertTrue(viewModel.canAddToCart)
    }

    func testEmptyAnalysisShowsNoMedicinesAndManualSearchAddsRow() async {
        let useCase = PrescriptionUseCaseStub(
            result: .success(PrescriptionAnalysis(medicines: []))
        )
        let viewModel = PrescriptionViewModel(
            analyzePrescriptionUseCase: useCase,
            languageProvider: { "en" }
        )

        viewModel.handle(.imageSelected(Data([1]), .camera))
        viewModel.handle(.continueFromPreview)
        await waitUntil { viewModel.state == .result(.noMedicines) }

        viewModel.handle(.addMedicineManually)
        XCTAssertEqual(viewModel.state, .medicineSearch(.add(query: "")))

        viewModel.handle(.selectSearchedMedicine(product(id: "83")))

        XCTAssertEqual(viewModel.state, .review)
        XCTAssertEqual(viewModel.medicines.count, 1)
        XCTAssertEqual(viewModel.cartItems.first?.productID, 83)
    }

    func testAnalysisFailureKeepsImageAndExposesBackendMessage() async {
        let message = "Gemini rate limit or quota was exceeded. Please try again later"
        let useCase = PrescriptionUseCaseStub(
            result: .failure(NetworkError.validationError(message))
        )
        let imageData = Data([4, 5, 6])
        let viewModel = PrescriptionViewModel(
            analyzePrescriptionUseCase: useCase,
            languageProvider: { "en" }
        )

        viewModel.handle(.imageSelected(imageData, .gallery))
        viewModel.handle(.continueFromPreview)
        await waitUntil { viewModel.state == .result(.analysisFailed(message)) }

        XCTAssertEqual(viewModel.selectedImageData, imageData)
        XCTAssertEqual(viewModel.state, .result(.analysisFailed(message)))
    }

    func testCancelIgnoresLateAnalysisResponse() async {
        let useCase = ControlledPrescriptionUseCase()
        let viewModel = PrescriptionViewModel(
            analyzePrescriptionUseCase: useCase,
            languageProvider: { "en" }
        )

        viewModel.handle(.imageSelected(Data([7]), .camera))
        viewModel.handle(.continueFromPreview)
        await waitUntil { useCase.continuation != nil }

        viewModel.handle(.cancelReading)
        useCase.complete(with: analysis())
        await Task.yield()

        XCTAssertEqual(viewModel.state, .preview)
        XCTAssertTrue(viewModel.medicines.isEmpty)
    }

    func testQuantityStepperNeverDropsBelowOne() {
        let item = confirmedMedicine()
        let viewModel = PrescriptionViewModel(initialMedicines: [item])

        viewModel.handle(.increaseQuantity(item.id))
        viewModel.handle(.decreaseQuantity(item.id))
        viewModel.handle(.decreaseQuantity(item.id))

        XCTAssertEqual(viewModel.medicines.first?.quantity, 1)
    }

    func testDeletingLastMedicineShowsNoMedicinesResult() {
        let item = confirmedMedicine()
        let viewModel = PrescriptionViewModel(initialMedicines: [item])

        viewModel.handle(.deleteMedicine(item.id))

        XCTAssertTrue(viewModel.medicines.isEmpty)
        XCTAssertEqual(viewModel.state, .result(.noMedicines))
    }

    func testAddingToCartOnlyShowsSuccessAfterPersistenceSucceeds() {
        let viewModel = PrescriptionViewModel(initialMedicines: [confirmedMedicine()])

        viewModel.handle(.addToCart)

        XCTAssertTrue(viewModel.isAddingToCart)
        XCTAssertEqual(viewModel.state, .review)

        viewModel.handle(.addToCartSucceeded)

        XCTAssertFalse(viewModel.isAddingToCart)
        XCTAssertEqual(viewModel.state, .result(.added))
    }

    func testAddingPrescriptionReviewPopulatesCartItemsAndAttachment() async throws {
        let medicine = confirmedMedicine()
        let prescriptionData = Data([1, 2, 3])
        let prescriptionViewModel = PrescriptionViewModel(initialMedicines: [medicine])
        let cartViewModel = CartViewModel()

        try await cartViewModel.addPrescriptionReview(
            items: prescriptionViewModel.cartItems,
            prescriptionData: prescriptionData,
            source: .photoLibrary
        )

        guard case let .loaded(items) = cartViewModel.state else {
            return XCTFail("Expected the cart to contain the reviewed medicine")
        }
        XCTAssertEqual(items.first?.productID, 1)
        XCTAssertEqual(items.first?.quantity, 1)
        XCTAssertEqual(cartViewModel.prescriptions.first?.imageData, prescriptionData)
    }

    private func waitUntil(
        _ condition: @escaping @MainActor () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<100 where !condition() {
            await Task.yield()
        }
        XCTAssertTrue(condition(), file: file, line: line)
    }

    private func analysis() -> PrescriptionAnalysis {
        PrescriptionAnalysis(
            medicines: [
                AnalyzedPrescriptionMedicine(
                    id: "medicine-1",
                    rawText: "R/ Panadol",
                    extractedName: "Panadol",
                    extractedStrength: nil,
                    extractedForm: nil,
                    matchStatus: "NOT_FOUND",
                    confidence: 0.95,
                    candidates: [
                        PrescriptionCandidate(
                            id: 561,
                            name: "PANADOL ACUTE HEAD COLD 20 TABS",
                            strength: nil,
                            form: "TABS",
                            price: 62,
                            imageURL: nil
                        ),
                        PrescriptionCandidate(
                            id: 562,
                            name: "PANADOL ADVANCE 500 MG 24 TABS",
                            strength: "500 MG",
                            form: "TABS",
                            price: 46,
                            imageURL: "https://example.com/panadol.jpg"
                        )
                    ]
                )
            ]
        )
    }

    private func unresolvedMedicine() -> PrescriptionMedicineDisplay {
        PrescriptionMedicineDisplay(
            id: "medicine-2",
            rawText: "1 fusic",
            extractedName: "fusic",
            matchStatus: "NOT_FOUND",
            confidence: 0.8,
            candidates: []
        )
    }

    private func confirmedMedicine() -> PrescriptionMedicineDisplay {
        PrescriptionMedicineDisplay(
            id: "confirmed",
            rawText: "Medicine",
            extractedName: "Medicine",
            matchStatus: "MATCHED",
            confidence: 1,
            candidates: [],
            selectedProduct: PrescriptionSelectedProductDisplay(
                productID: 1,
                name: "Medicine",
                details: "20 tablets",
                unitPrice: 20,
                imageURL: nil
            )
        )
    }

    private func product(id: String) -> MedsyProduct {
        MedsyProduct(
            id: id,
            name: "Replacement",
            dosageInfo: "20 tablets",
            scientificName: "Paracetamol",
            price: 55,
            imageUrl: nil,
            badgeText: "Company",
            badgeColor: .green,
            categoryName: "Pain relief"
        )
    }
}

private final class PrescriptionUseCaseStub: AnalyzePrescriptionUseCaseProtocol {
    struct Request {
        let imageData: Data
        let language: String
    }

    private let result: Result<PrescriptionAnalysis, Error>
    private(set) var requests: [Request] = []

    init(result: Result<PrescriptionAnalysis, Error>) {
        self.result = result
    }

    func execute(imageData: Data, language: String) async throws -> PrescriptionAnalysis {
        requests.append(Request(imageData: imageData, language: language))
        return try result.get()
    }
}

private final class ControlledPrescriptionUseCase: AnalyzePrescriptionUseCaseProtocol {
    var continuation: CheckedContinuation<PrescriptionAnalysis, Error>?

    func execute(imageData: Data, language: String) async throws -> PrescriptionAnalysis {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func complete(with analysis: PrescriptionAnalysis) {
        continuation?.resume(returning: analysis)
        continuation = nil
    }
}
