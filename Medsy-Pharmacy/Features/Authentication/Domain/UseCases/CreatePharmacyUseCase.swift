import Foundation

protocol CreatePharmacyUseCaseProtocol {
    func execute(input: CreatePharmacyInput) async throws -> CreatedPharmacy
}

final class CreatePharmacyUseCase: CreatePharmacyUseCaseProtocol {
    private let repository: PharmacySetupRepositoryProtocol

    init(repository: PharmacySetupRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: CreatePharmacyInput) async throws -> CreatedPharmacy {
        let name = input.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = input.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty, !input.location.city.isEmpty, !input.location.province.isEmpty else {
            throw PharmacySetupValidationError.missingRequiredFields
        }
        guard phone.range(of: "^01[0125][0-9]{8}$", options: .regularExpression) != nil else {
            throw PharmacySetupValidationError.invalidPhoneNumber
        }
        guard (-90...90).contains(input.location.latitude),
              (-180...180).contains(input.location.longitude) else {
            throw PharmacySetupValidationError.invalidCoordinates
        }
        guard input.license.data.count <= PharmacyLicenseDocument.maximumByteCount else {
            throw PharmacySetupValidationError.licenseTooLarge
        }
        guard input.license.data.starts(with: Data("%PDF".utf8)),
              input.license.fileName.lowercased().hasSuffix(".pdf") else {
            throw PharmacySetupValidationError.licenseMustBePDF
        }

        return try await repository.createPharmacy(
            input: CreatePharmacyInput(
                name: name,
                phoneNumber: phone,
                location: input.location,
                license: input.license
            )
        )
    }
}
