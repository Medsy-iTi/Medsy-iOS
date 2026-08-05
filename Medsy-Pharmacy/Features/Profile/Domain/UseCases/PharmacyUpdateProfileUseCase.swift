//
//  PharmacyUpdateProfileUseCase.swift
//  Medsy-Pharmacy
//

import Foundation

protocol PharmacyUpdateProfileUseCaseProtocol {
    func execute(id: Int, email: String, firstName: String, lastName: String, homeAddress: String?, dateOfBirth: Date?) async throws
}

final class PharmacyUpdateProfileUseCase: PharmacyUpdateProfileUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int, email: String, firstName: String, lastName: String, homeAddress: String?, dateOfBirth: Date?) async throws {
        try await repository.updateProfile(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            homeAddress: homeAddress,
            dateOfBirth: dateOfBirth
        )
    }
}
