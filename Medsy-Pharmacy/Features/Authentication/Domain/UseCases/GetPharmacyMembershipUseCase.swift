protocol GetPharmacyMembershipUseCaseProtocol {
    func execute() async throws -> PharmacyMembership
}

final class GetPharmacyMembershipUseCase: GetPharmacyMembershipUseCaseProtocol {
    private let repository: PharmacySetupRepositoryProtocol

    init(repository: PharmacySetupRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> PharmacyMembership {
        try await repository.getCurrentMembership()
    }
}
