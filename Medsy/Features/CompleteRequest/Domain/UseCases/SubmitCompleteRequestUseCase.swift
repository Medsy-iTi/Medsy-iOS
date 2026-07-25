//
//  SubmitCompleteRequestUseCase.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

protocol SubmitCompleteRequestUseCaseProtocol {
    func execute(input: SubmitCompleteRequestInput) async throws -> SubmittedMedicineRequest
}

final class SubmitCompleteRequestUseCase: SubmitCompleteRequestUseCaseProtocol {
    private let repository: CompleteRequestRepositoryProtocol

    init(repository: CompleteRequestRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: SubmitCompleteRequestInput) async throws -> SubmittedMedicineRequest {
        try await repository.submit(input: input)
    }
}
