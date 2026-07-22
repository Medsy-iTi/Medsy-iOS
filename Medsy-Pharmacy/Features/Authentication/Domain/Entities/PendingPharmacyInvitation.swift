import Foundation

enum PharmacyInvitationStatus: String, Equatable, Sendable {
    case pending = "PENDING"
    case accepted = "ACCEPTED"
    case declined = "DECLINED"
    case cancelled = "CANCELLED"
}

struct PendingPharmacyInvitation: Identifiable, Equatable, Sendable {
    let id: Int
    let pharmacyID: Int
    let pharmacyName: String
    let pharmacistID: Int
    let pharmacistFirstName: String
    let pharmacistLastName: String
    let status: PharmacyInvitationStatus
    let createdAt: Date?
}
