import Foundation

final class PrescriptionRepository: PrescriptionRepositoryProtocol {
    private let remoteDataSource: PrescriptionRemoteDataSourceProtocol

    init(remoteDataSource: PrescriptionRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func analyze(imageData: Data, language: String) async throws -> PrescriptionAnalysis {
        let dto = try await remoteDataSource.analyze(imageData: imageData, language: language)
        return PrescriptionAnalysisMapper.map(dto)
    }
}
