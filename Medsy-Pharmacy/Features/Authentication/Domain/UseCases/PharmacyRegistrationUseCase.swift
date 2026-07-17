//
//  PharmacyRegistrationUseCase.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

protocol PharmacyRegistrationUseCaseProtocol {
    func execute(input: PharmacyRegistrationInput) async throws
}

final class PharmacyRegistrationUseCase: PharmacyRegistrationUseCaseProtocol {
    private let repository: PharmacyAuthenticationRepositoryProtocol

    init(repository: PharmacyAuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: PharmacyRegistrationInput) async throws {
        try await repository.register(input: input)
    }
}
