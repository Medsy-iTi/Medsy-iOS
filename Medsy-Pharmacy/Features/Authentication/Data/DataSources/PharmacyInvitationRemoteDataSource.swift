protocol PharmacyInvitationRemoteDataSourceProtocol {
    func getPendingInvitations() async throws -> [PendingPharmacyInvitationDTO]
    func acceptInvitation(id: Int) async throws -> PendingPharmacyInvitationDTO
    func declineInvitation(id: Int) async throws -> PendingPharmacyInvitationDTO
}

final class PharmacyInvitationRemoteDataSource: PharmacyInvitationRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getPendingInvitations() async throws -> [PendingPharmacyInvitationDTO] {
        let response: PendingPharmacyInvitationsEnvelopeDTO = try await networkService.request(
            endpoint: PharmacyInvitationEndpoint.pending
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        return response.data ?? []
    }

    func acceptInvitation(id: Int) async throws -> PendingPharmacyInvitationDTO {
        try await updateInvitation(endpoint: PharmacyInvitationEndpoint.accept(id: id))
    }

    func declineInvitation(id: Int) async throws -> PendingPharmacyInvitationDTO {
        try await updateInvitation(endpoint: PharmacyInvitationEndpoint.decline(id: id))
    }

    private func updateInvitation(endpoint: PharmacyInvitationEndpoint) async throws -> PendingPharmacyInvitationDTO {
        let response: PendingPharmacyInvitationEnvelopeDTO = try await networkService.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let invitation = response.data else {
            throw NetworkError.decodingFailed
        }
        return invitation
    }
}
