import Foundation

struct PendingPharmacyInvitationDTO: Decodable {
    let id: Int
    let pharmacyId: Int
    let pharmacyName: String
    let pharmacistId: Int
    let pharmacistFirstName: String
    let pharmacistLastName: String
    let status: String
    let createdAt: String?

    func toDomain() throws -> PendingPharmacyInvitation {
        guard let status = PharmacyInvitationStatus(rawValue: status) else {
            throw NetworkError.decodingFailed
        }
        return PendingPharmacyInvitation(
            id: id,
            pharmacyID: pharmacyId,
            pharmacyName: pharmacyName,
            pharmacistID: pharmacistId,
            pharmacistFirstName: pharmacistFirstName,
            pharmacistLastName: pharmacistLastName,
            status: status,
            createdAt: createdAt.flatMap(Self.parseDate)
        )
    }

    private static func parseDate(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: value) { return date }
        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter.date(from: value)
    }
}

struct PendingPharmacyInvitationsEnvelopeDTO: Decodable {
    let success: Bool
    let message: String
    let data: [PendingPharmacyInvitationDTO]?
}

struct PendingPharmacyInvitationEnvelopeDTO: Decodable {
    let success: Bool
    let message: String
    let data: PendingPharmacyInvitationDTO?
}
