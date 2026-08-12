import Foundation

protocol PrescriptionRepositoryProtocol {
    func analyze(imageData: Data, language: String) async throws -> PrescriptionAnalysis
}
