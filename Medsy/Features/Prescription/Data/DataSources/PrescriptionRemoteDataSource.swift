import Foundation

protocol PrescriptionRemoteDataSourceProtocol {
    func analyze(imageData: Data, language: String) async throws -> PrescriptionAnalysisDataDTO
}

final class PrescriptionRemoteDataSource: PrescriptionRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func analyze(imageData: Data, language: String) async throws -> PrescriptionAnalysisDataDTO {
        let response: PrescriptionAnalysisResponseDTO = try await networkService.request(
            endpoint: PrescriptionEndpoint.analyze(imageData: imageData, language: language)
        )

        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let data = response.data else {
            throw NetworkError.decodingFailed
        }
        return data
    }
}
