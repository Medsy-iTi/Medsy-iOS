//
//  CompleteRequestRemoteDataSource.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

protocol CompleteRequestRemoteDataSourceProtocol {
    func submit(request: CompleteRequestDTO) async throws -> CompleteRequestResponseDTO
}

final class CompleteRequestRemoteDataSource: CompleteRequestRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func submit(request: CompleteRequestDTO) async throws -> CompleteRequestResponseDTO {
        
        print("")
        let response: SubmitCompleteRequestResponseDTO = try await networkService.request(
            endpoint: CompleteRequestEndpoint.submit(request)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let request = response.data else {
            throw NetworkError.decodingFailed
        }
        return request
    }
}
