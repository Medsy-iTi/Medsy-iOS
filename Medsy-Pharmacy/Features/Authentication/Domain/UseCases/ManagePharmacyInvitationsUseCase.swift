protocol ManagePharmacyInvitationsUseCaseProtocol {
    func getPendingInvitations() async throws -> [PendingPharmacyInvitation]
    func acceptInvitation(id: Int) async throws -> PendingPharmacyInvitation
    func declineInvitation(id: Int) async throws -> PendingPharmacyInvitation
}

final class ManagePharmacyInvitationsUseCase: ManagePharmacyInvitationsUseCaseProtocol {
    private let repository: PharmacyInvitationRepositoryProtocol

    init(repository: PharmacyInvitationRepositoryProtocol) {
        self.repository = repository
    }

    func getPendingInvitations() async throws -> [PendingPharmacyInvitation] {
        try await repository.getPendingInvitations()
    }

    func acceptInvitation(id: Int) async throws -> PendingPharmacyInvitation {
        try await repository.acceptInvitation(id: id)
    }

    func declineInvitation(id: Int) async throws -> PendingPharmacyInvitation {
        try await repository.declineInvitation(id: id)
    }
}
