protocol PharmacyInvitationRepositoryProtocol {
    func getPendingInvitations() async throws -> [PendingPharmacyInvitation]
    func acceptInvitation(id: Int) async throws -> PendingPharmacyInvitation
    func declineInvitation(id: Int) async throws -> PendingPharmacyInvitation
}
