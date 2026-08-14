import Foundation

enum OfferResultMapper {
    static func map(_ dto: OfferResultResponseDTO) -> OfferResult {
        let items = dto.items.map { itemDTO in
            OfferResultItem(
                requestItemId: itemDTO.requestItemId,
                productId: itemDTO.productId,
                productName: itemDTO.productName,
                imageUrl: itemDTO.imageUrl,
                unitPrice: itemDTO.unitPrice,
                isAlternative: itemDTO.isAlternative,
                isAvailable: itemDTO.isAvailable
            )
        }
        let calculatedTotal = items.reduce(0.0) { $0 + ($1.isAvailable ? $1.unitPrice : 0.0) }
        let total = dto.totalPrice > 0 ? dto.totalPrice : calculatedTotal

        return OfferResult(
            items: items,
            totalPrice: total,
            prescriptionUrl: dto.prescriptionUrl,
            paymentMethod: dto.paymentMethod
        )
    }

    static func map(_ dto: ConfirmOfferResponseDTO, requestId: Int) -> ConfirmOfferResult {
        let orders = [
            ConfirmOfferOrder(
                orderId: dto.masterOrderId,
                pharmacyId: 0,
                pharmacyName: "",
                itemIds: []
            )
        ]
        return ConfirmOfferResult(
            requestId: requestId,
            orders: orders,
            masterOrderId: dto.masterOrderId,
            orderStatus: MasterOrderStatus(rawValue: dto.orderStatus.uppercased()) ?? .unknown,
            paymentMethod: MasterOrderPaymentMethod(rawValue: dto.paymentMethod.uppercased()) ?? .unknown,
            paymentStatus: dto.paymentStatus.flatMap {
                MasterOrderPaymentStatus(rawValue: $0.uppercased()) ?? .unknown
            }
        )
    }
}
