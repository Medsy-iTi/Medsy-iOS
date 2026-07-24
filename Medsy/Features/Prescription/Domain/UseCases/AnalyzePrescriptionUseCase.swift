import Foundation

protocol AnalyzePrescriptionUseCaseProtocol {
    func execute(imageData: Data, language: String) async throws -> PrescriptionAnalysis
}

final class AnalyzePrescriptionUseCase: AnalyzePrescriptionUseCaseProtocol {
    private let repository: PrescriptionRepositoryProtocol

    init(repository: PrescriptionRepositoryProtocol) {
        self.repository = repository
    }

    func execute(imageData: Data, language: String) async throws -> PrescriptionAnalysis {
        try await repository.analyze(imageData: imageData, language: language)
    }
}
