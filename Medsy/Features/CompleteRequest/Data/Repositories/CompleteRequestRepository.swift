//
//  CompleteRequestRepository.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

final class CompleteRequestRepository: CompleteRequestRepositoryProtocol {
    private let remoteDataSource: CompleteRequestRemoteDataSourceProtocol

    init(remoteDataSource: CompleteRequestRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func submit(input: SubmitCompleteRequestInput) async throws -> SubmittedMedicineRequest {
        let dto = try await remoteDataSource.submit(
            request: CompleteRequestDTO(input: input)
        )
        return try CompleteRequestMapper.map(dto)
    }
}
