//
//  FetchPendingPharmacyInvitationsUseCase.swift
//  Medsy-Pharmacy
//

import Foundation

protocol FetchPendingPharmacyInvitationsUseCaseProtocol {
    func execute(pharmacyId: Int) async throws -> [PharmacyInvitation]
}

struct FetchPendingPharmacyInvitationsUseCase: FetchPendingPharmacyInvitationsUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pharmacyId: Int) async throws -> [PharmacyInvitation] {
        try await repository.fetchPendingInvitations(pharmacyId: pharmacyId)
    }
}
