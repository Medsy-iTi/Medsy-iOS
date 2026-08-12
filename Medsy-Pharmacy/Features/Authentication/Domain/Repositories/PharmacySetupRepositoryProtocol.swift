protocol PharmacySetupRepositoryProtocol {
    func getCurrentMembership() async throws -> PharmacyMembership
    func createPharmacy(input: CreatePharmacyInput) async throws -> CreatedPharmacy
}
