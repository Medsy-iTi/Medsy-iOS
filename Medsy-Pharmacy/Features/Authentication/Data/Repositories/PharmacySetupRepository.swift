final class PharmacySetupRepository: PharmacySetupRepositoryProtocol {
    private let remoteDataSource: PharmacyAuthenticationRemoteDataSourceProtocol

    init(remoteDataSource: PharmacyAuthenticationRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    func getCurrentMembership() async throws -> PharmacyMembership {
        try await remoteDataSource.getCurrentMembership()
    }

    func createPharmacy(input: CreatePharmacyInput) async throws -> CreatedPharmacy {
        try await remoteDataSource.createPharmacy(input: input).toDomain()
    }
}
