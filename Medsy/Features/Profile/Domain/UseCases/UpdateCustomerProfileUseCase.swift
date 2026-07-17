//
//  UpdateCustomerProfileUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

protocol UpdateCustomerProfileUseCaseProtocol {
    func execute(input: UpdateCustomerProfileInput) async throws -> CustomerProfile
}

final class UpdateCustomerProfileUseCase: UpdateCustomerProfileUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: UpdateCustomerProfileInput) async throws -> CustomerProfile {
        try await repository.updateProfile(input: input)
    }
}
