//
//  MedicineAnalyzeViewModelTests.swift
//  MedsyTests
//
//  Created by Ehab Salah on 23/07/2026.
//

import UIKit
import XCTest
@testable import Medsy

@MainActor
final class MedicineAnalyzeViewModelTests: XCTestCase {
    func testAnalysisUsesCurrentLanguageAndKeepsEveryProduct() async {
        let useCase = MedicineAnalyzeUseCaseStub(
            results: [.success([product(id: 564), product(id: 565)])]
        )
        let viewModel = MedicineAnalyzeViewModel(
            analyzeMedicineImageUseCase: useCase,
            languageProvider: { "ar" }
        )

        viewModel.selectCameraImage(jpegData())
        viewModel.analyze()
        await waitUntil { viewModel.state == .results }

        XCTAssertEqual(useCase.requests.first?.language, "ar")
        XCTAssertEqual(
            useCase.requests.first?.imageData,
            viewModel.selectedImageData
        )
        XCTAssertEqual(viewModel.products.map(\.id), ["564", "565"])
    }

    func testEmptyAnalysisShowsNoMatches() async {
        let useCase = MedicineAnalyzeUseCaseStub(results: [.success([])])
        let viewModel = MedicineAnalyzeViewModel(
            analyzeMedicineImageUseCase: useCase,
            languageProvider: { "en" }
        )

        viewModel.selectCameraImage(jpegData())
        viewModel.analyze()
        await waitUntil { viewModel.state == .noMatches }

        XCTAssertTrue(viewModel.products.isEmpty)
        XCTAssertNotNil(viewModel.selectedImageData)
    }

    func testBackendFailureIsShownAndRetryReusesImage() async {
        let message = "Gemini rate limit or quota was exceeded. Please try again later"
        let useCase = MedicineAnalyzeUseCaseStub(
            results: [
                .failure(NetworkError.validationError(message)),
                .success([product(id: 564)])
            ]
        )
        let viewModel = MedicineAnalyzeViewModel(
            analyzeMedicineImageUseCase: useCase,
            languageProvider: { "en" }
        )

        viewModel.selectCameraImage(jpegData())
        viewModel.analyze()
        await waitUntil { viewModel.state == .failure(message) }
        let retainedImage = viewModel.selectedImageData

        viewModel.retry()
        await waitUntil { viewModel.state == .results }

        XCTAssertEqual(useCase.requests.count, 2)
        XCTAssertEqual(useCase.requests[0].imageData, retainedImage)
        XCTAssertEqual(useCase.requests[1].imageData, retainedImage)
    }

    func testCancellationIgnoresLateResponseAndReturnsToPreview() async {
        let useCase = ControlledMedicineAnalyzeUseCase()
        let viewModel = MedicineAnalyzeViewModel(
            analyzeMedicineImageUseCase: useCase,
            languageProvider: { "en" }
        )

        viewModel.selectCameraImage(jpegData())
        viewModel.analyze()
        await waitUntil { useCase.continuation != nil }

        viewModel.cancelAnalysis()
        useCase.complete(with: [product(id: 564)])
        await Task.yield()

        XCTAssertEqual(viewModel.state, .preview)
        XCTAssertTrue(viewModel.products.isEmpty)
    }

    private func waitUntil(
        _ condition: @escaping @MainActor () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<200 where !condition() {
            await Task.yield()
        }
        XCTAssertTrue(condition(), file: file, line: line)
    }

    private func jpegData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8))
        let image = renderer.image { context in
            UIColor.green.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 8, height: 8))
        }
        return image.jpegData(compressionQuality: 1) ?? Data()
    }

    private func product(id: Int) -> AnalyzedMedicineProduct {
        AnalyzedMedicineProduct(
            id: id,
            name: "PANADOL EXTRA 24 TABS",
            productName: "PANADOL EXTRA",
            strength: nil,
            packSize: "24",
            form: "TABS",
            price: 54,
            scientificName: "CAFFEINE+PARACETAMOL",
            scientificCategory: "MILD ANALGESIC",
            categoryID: 2,
            consumerCategory: "PAIN RELIEF",
            company: "GLAXO SMITHKLINE",
            route: "ORAL.SOLID",
            description: "Relieves mild pain.",
            imageURL: nil
        )
    }
}

private final class MedicineAnalyzeUseCaseStub: AnalyzeMedicineImageUseCaseProtocol {
    struct Request {
        let imageData: Data
        let language: String
    }

    private var results: [Result<[AnalyzedMedicineProduct], Error>]
    private(set) var requests: [Request] = []

    init(results: [Result<[AnalyzedMedicineProduct], Error>]) {
        self.results = results
    }

    func execute(
        imageData: Data,
        language: String
    ) async throws -> [AnalyzedMedicineProduct] {
        requests.append(Request(imageData: imageData, language: language))
        return try results.removeFirst().get()
    }
}

private final class ControlledMedicineAnalyzeUseCase: AnalyzeMedicineImageUseCaseProtocol {
    var continuation: CheckedContinuation<[AnalyzedMedicineProduct], Error>?

    func execute(
        imageData: Data,
        language: String
    ) async throws -> [AnalyzedMedicineProduct] {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func complete(with products: [AnalyzedMedicineProduct]) {
        continuation?.resume(returning: products)
        continuation = nil
    }
}
