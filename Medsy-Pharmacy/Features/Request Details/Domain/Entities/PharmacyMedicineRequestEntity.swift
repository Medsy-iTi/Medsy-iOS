import Foundation

struct PharmacyMedicineRequestEntity: Identifiable, Equatable, Sendable {
    let id: Int
    let customerId: Int?
    let customerName: String?
    let customerPhone: String?
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let deliveryAddress: String
    let status: PharmacyOrderAPIStatus
    let createdAt: Date?
    let items: [PharmacyMedicineRequestItemEntity]
    let prescriptionUrl: String?
    let notes: String?
    let distanceKm: Double?
    let assignmentStatus: String?

    var requestStatus: RequestStatus {
        switch status {
        case .completed:
            return .completed
        case .expired:
            return .expired
        case .searching, .pending:
            return .open
        default:
            return .open
        }
    }

    var resolvedAssignmentStatus: AssignmentStatus {
        let reqStatus = requestStatus
        if reqStatus == .completed || reqStatus == .expired {
            return .cannotOffer
        }
        guard let assignmentStatus = assignmentStatus else {
            if PharmacySubmittedOffersStore.shared.contains(id) {
                return .offered
            }
            return .cannotOffer
        }
        let rawStatus = assignmentStatus.uppercased()
        if rawStatus == "OFFER_CREATED" || rawStatus == "OFFER_MADE" || rawStatus == "SUBMITTED" || rawStatus == "OFFERED" {
            return .offered
        }
        if rawStatus == "PENDING" {
            return .canOffer
        }
        return .cannotOffer
    }
}

struct PharmacyMedicineRequestItemEntity: Identifiable, Equatable, Sendable {
    let id: Int
    let productId: Int
    let imageUrl: String?
    let productName: String
    let quantity: Int
    let unitPrice: Double
    let form: String?
    let strength: String?
    let packSize: String?
}
