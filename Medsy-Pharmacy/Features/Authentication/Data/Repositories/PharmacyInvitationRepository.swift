final class PharmacyInvitationRepository: PharmacyInvitationRepositoryProtocol {
    private let remoteDataSource: PharmacyInvitationRemoteDataSourceProtocol

    init(remoteDataSource: PharmacyInvitationRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func getPendingInvitations() async throws -> [PendingPharmacyInvitation] {
        try (await remoteDataSource.getPendingInvitations()).map { try $0.toDomain() }
    }

    func acceptInvitation(id: Int) async throws -> PendingPharmacyInvitation {
        try (await remoteDataSource.acceptInvitation(id: id)).toDomain()
    }

    func declineInvitation(id: Int) async throws -> PendingPharmacyInvitation {
        try (await remoteDataSource.declineInvitation(id: id)).toDomain()
    }
}
