import Foundation

enum RequestStatus: String, Decodable, Equatable, Sendable {
    case open
    case expired
    case completed
}

enum AssignmentStatus: String, Decodable, Equatable, Sendable {
    case offered
    case canOffer
    case cannotOffer
}

struct PharmacyRequestAssignmentDTO: Decodable, Equatable {
    let assignmentStatus: String?
    let distanceKm: Double?
    let request: PharmacyMedicineRequestDTO

    var resolvedAssignmentStatus: AssignmentStatus {
        let reqStatus = request.requestStatus
        if reqStatus == .completed || reqStatus == .expired {
            return .cannotOffer
        }
        guard let statusStr = assignmentStatus else {
            if PharmacySubmittedOffersStore.shared.contains(request.id) {
                return .offered
            }
            return .cannotOffer
        }
        let rawStatus = statusStr.uppercased()
        if rawStatus == "OFFER_CREATED" || rawStatus == "OFFER_MADE" || rawStatus == "SUBMITTED" || rawStatus == "OFFERED" {
            return .offered
        }
        if rawStatus == "PENDING" {
            return .canOffer
        }
        return .cannotOffer
    }
}

struct PharmacyMedicineRequestDTO: Decodable, Equatable {
    let id: Int
    let customerId: Int?
    let customerName: String?
    let customerPhone: String?
    let deliveryLatitude: Double?
    let deliveryLongitude: Double?
    let deliveryAddress: String?
    let status: String
    let createdAt: String?
    let items: [PharmacyMedicineRequestItemDTO]?
    let prescriptionUrl: String?
    let notes: String?

    var requestStatus: RequestStatus {
        switch status.uppercased() {
        case "COMPLETED":
            return .completed
        case "EXPIRED":
            return .expired
        case "SEARCHING", "OPEN":
            return .open
        default:
            return .open
        }
    }
}

struct PharmacyMedicineRequestItemDTO: Decodable, Equatable {
    let id: Int
    let productId: Int?
    let imageUrl: String?
    let productName: String?
    let quantity: Int
    let unitPrice: Double?
    let form: String?
    let strength: String?
    let packSize: String?
    let product: PharmacyProductDTO?
}
