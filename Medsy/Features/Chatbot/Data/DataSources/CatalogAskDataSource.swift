
//
//  CatalogAskDataSource.swift
//  Medsy
//

protocol CatalogAskDataSourceProtocol: Sendable {

	func ask(request: CatalogAskRequestDTO) async throws -> CatalogAskResponseDTO
}

final class CatalogAskDataSource: CatalogAskDataSourceProtocol, @unchecked Sendable {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }



    func ask(request: CatalogAskRequestDTO) async throws -> CatalogAskResponseDTO {
        let envelope: APIResponseDTO<CatalogAskResponseDTO> = try await networkService.request(
            endpoint: CatalogAskEndpoint.ask(request: request)
        )

        guard envelope.success, let data = envelope.data else {
            throw NetworkError.validationError(envelope.message)
        }

        return data
    }
}
