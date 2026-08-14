import Foundation

typealias OrdersPageResponseDTO = APIResponseDTO<PageDTO<MasterOrderDTO>>
typealias OrderDetailResponseDTO = APIResponseDTO<MasterOrderDTO>
typealias OrderRequestDetailResponseDTO = APIResponseDTO<OrderRequestDetailDTO>

struct MasterOrderDTO: Codable, Equatable, Hashable, Sendable {
    let id: Int
    let requestId: Int
    let orderResponses: [MasterOrderPharmacyDTO]
    let paymentMethod: String?
    let paymentStatus: String?
    let fulfillmentMethod: String?
    let deliveryFee: Double?
    let totalPrice: Double
    let orderStatus: String
    let paymentExpiresAt: String?
    let paidAt: String?
}

struct MasterOrderPharmacyDTO: Codable, Equatable, Hashable, Sendable {
    let offerId: Int
    let pharmacyId: Int
    let pharmacyName: String
    let latitude: Double?
    let longitude: Double?
    let items: [MasterOrderItemDTO]
}

struct MasterOrderItemDTO: Codable, Equatable, Hashable, Sendable {
    let id: Int
    let productId: Int?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double?
    let product: MasterOrderProductDTO?
}

struct MasterOrderProductDTO: Codable, Equatable, Hashable, Sendable {
    let id: Int
    let name: String?
    let productName: String?
    let strength: String?
    let packSize: String?
    let form: String?
    let price: Double?
    let scientificName: String?
    let company: String?
    let route: String?
    let description: String?
    let imageUrl: String?
}

struct OrderRequestDetailDTO: Codable, Equatable, Hashable, Sendable {
    let requestId: Int
    let pharmacyName: String
    let address: String
    let deliveryAddress: String
    let deliveryLatitude: Double?
    let deliveryLongitude: Double?
    let deliveryFee: Double
    let paymentMethod: String
    let medicines: [OrderRequestMedicineDTO]
    let pharmacistComment: String?
    let totalPrice: Double
}

struct OrderRequestMedicineDTO: Codable, Equatable, Hashable, Sendable {
    let id: Int
    let name: String
    let dosage: String
    let price: Double
    let isAvailable: Bool
    let isAlternative: Bool
    let image: String?
    let isSelected: Bool
}
