import Foundation

struct PharmacyLocation: Equatable, Sendable {
    let latitude: Double
    let longitude: Double
    let city: String
    let province: String

    var address: String {
        [city, province]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: ", ")
    }
}

struct PharmacyLicenseDocument: Equatable, Sendable {
    static let maximumByteCount = 10 * 1024 * 1024

    let fileName: String
    let data: Data

    var byteCount: Int { data.count }
}

struct CreatePharmacyInput: Equatable, Sendable {
    let name: String
    let phoneNumber: String
    let location: PharmacyLocation
    let license: PharmacyLicenseDocument
}

struct PharmacyMembership: Equatable, Sendable {
    let pharmacyID: Int?
    let isAdmin: Bool

    var isAssigned: Bool { pharmacyID != nil }
}

struct CreatedPharmacy: Equatable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String?
    let phoneNumber: String?
}

enum PharmacySetupValidationError: LocalizedError, Equatable {
    case missingRequiredFields
    case invalidPhoneNumber
    case invalidCoordinates
    case licenseMustBePDF
    case licenseTooLarge
    case unreadableLicense

    var errorDescription: String? {
        switch self {
        case .missingRequiredFields:
            "pharmacy.setup.validation.required".localized
        case .invalidPhoneNumber:
            "pharmacy.setup.validation.phone".localized
        case .invalidCoordinates:
            "pharmacy.setup.validation.location".localized
        case .licenseMustBePDF:
            "pharmacy.setup.validation.pdf".localized
        case .licenseTooLarge:
            "pharmacy.setup.validation.size".localized
        case .unreadableLicense:
            "pharmacy.setup.validation.unreadable".localized
        }
    }
}
