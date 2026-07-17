//
//  GetCustomerProfileUseCase.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

protocol GetCustomerProfileUseCaseProtocol {
    func execute() async throws -> CustomerProfile
}

final class GetCustomerProfileUseCase: GetCustomerProfileUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> CustomerProfile {
        try await repository.fetchProfile()
    }
}
