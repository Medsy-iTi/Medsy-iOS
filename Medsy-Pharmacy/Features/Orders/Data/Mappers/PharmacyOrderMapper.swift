import Foundation

enum PharmacyOrderMapper {

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let fallbackIsoFormatter = ISO8601DateFormatter()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    static func map(_ dto: PharmacyOrderDTO) -> PharmacyOrder {
        let dateString = dto.createdAt ?? dto.date ?? ""
        let date = isoFormatter.date(from: dateString)
            ?? fallbackIsoFormatter.date(from: dateString)
            ?? dateFormatter.date(from: dateString)
            ?? Date()

        let userId = dto.customerId ?? dto.userId ?? 0

        return PharmacyOrder(
            id: dto.id,
            userId: userId,
            pharmacyId: dto.pharmacyId ?? 0,
            totalPrice: dto.totalPrice ?? 0.0,
            deliveryCoordinate: (dto.deliveryLatitude ?? 0.0, dto.deliveryLongitude ?? 0.0),
            deliveryAddress: dto.deliveryAddress ?? "",
            status: PharmacyOrderAPIStatus(rawValue: dto.status),
            date: date,
            items: dto.items.map {
                PharmacyOrderLineItem(id: $0.id, productId: $0.productId, quantity: $0.quantity, unitPrice: $0.unitPrice ?? 0.0)
            }
        )
    }

    static func map(_ dto: PageResponseDTO<PharmacyOrderDTO>) -> PharmacyOrdersPage {
        PharmacyOrdersPage(
            orders: dto.content.map(map),
            pageNumber: dto.pageNumber,
            totalPages: dto.totalPages,
            isLastPage: dto.last
        )
    }

    static func mapToListItem(_ order: PharmacyOrder) -> PharmacyOrderListItem {
        PharmacyOrderListItem(
            id: String(order.id),
            customerName: "pharmacy.orders.customer.fallback".localized(String(order.userId)),
            phoneNumber: "—",
            address: order.deliveryAddress.isEmpty ? "pharmacy.orders.address.fallback".localized : order.deliveryAddress,
            paymentMethod: .cash,
            amount: Int(order.totalPrice.rounded()),
            minutesAgo: max(0, Int(Date().timeIntervalSince(order.date) / 60)),
            status: mapStatus(order.status)
        )
    }

    private static func mapStatus(_ status: PharmacyOrderAPIStatus) -> PharmacyOrderListStatus {
        switch status {
        case .pending: .new
        case .accepted, .preparing, .outForDelivery: .preparing
        case .delivered: .delivered
        case .cancelled, .unknown: .delivered
        }
    }
}
