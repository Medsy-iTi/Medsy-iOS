//
//  InvitePharmacistUseCase.swift
//  Medsy-Pharmacy
//

import Foundation

protocol InvitePharmacistUseCaseProtocol {
    func execute(pharmacyId: Int, email: String) async throws -> PharmacyInvitation
}

struct InvitePharmacistUseCase: InvitePharmacistUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pharmacyId: Int, email: String) async throws -> PharmacyInvitation {
        try await repository.invitePharmacist(pharmacyId: pharmacyId, email: email)
    }
}
