//
//  DeletePendingPharmacyInvitationUseCase.swift
//  Medsy-Pharmacy
//

import Foundation

protocol DeletePendingPharmacyInvitationUseCaseProtocol {
    func execute(id: Int) async throws
}

struct DeletePendingPharmacyInvitationUseCase: DeletePendingPharmacyInvitationUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws {
        try await repository.deletePendingInvitation(id: id)
    }
}
