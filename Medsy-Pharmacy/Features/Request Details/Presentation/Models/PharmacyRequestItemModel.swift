import SwiftUI

struct PharmacyOrderItem: Identifiable {
    let id: String
    let name: String
    let spec: String
    let quantity: Int
    var price: Double
    let imageName: String?
    var isAvailable: Bool = true
    var alternativeMedicine: String? = nil
}

struct PharmacyCustomerInfo {
    let name: String
    let phone: String
    let address: String
}

struct PharmacyRequestDetailsModel {
    let id: String
    let statusTitle: String
    let customer: PharmacyCustomerInfo
    var items: [PharmacyOrderItem]
    let deliveryFee: Double
    let notes: String
    var prescriptionImageUrl: String? = nil
    
    var subtotal: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var total: Double {
        subtotal + deliveryFee
    }
}

extension PharmacyRequestDetailsModel {
    init(order: PharmacyOrderListItem) {
        self.init(
            id: order.id,
            statusTitle: order.status == .new ? "pharmacy.home.order_new".localized : (order.status == .preparing ? "pharmacy.home.order_preparing".localized : "pharmacy.home.order_delivered".localized),
            customer: PharmacyCustomerInfo(
                name: order.customerName,
                phone: order.phoneNumber,
                address: order.address
            ),
            items: [],
            deliveryFee: 15.0,
            notes: ""
        )
    }

    init(order: PharmacyOrder) {
        self.init(
            id: String(order.id),
            statusTitle: order.status == .pending ? "pharmacy.home.order_new".localized : (order.status == .delivered ? "pharmacy.home.order_delivered".localized : "pharmacy.home.order_preparing".localized),
            customer: PharmacyCustomerInfo(
                name: "pharmacy.orders.customer.fallback".localized(String(order.userId)),
                phone: "—",
                address: order.deliveryAddress.isEmpty ? "pharmacy.orders.address.fallback".localized : order.deliveryAddress
            ),
            items: order.items.map { item in
                PharmacyOrderItem(
                    id: String(item.id),
                    name: "Product #\(item.productId)",
                    spec: "\(item.quantity) pcs",
                    quantity: item.quantity,
                    price: item.unitPrice,
                    imageName: nil
                )
            },
            deliveryFee: 15.0,
            notes: ""
        )
    }

    init(homeOrder: PharmacyHomeOrder) {
        self.init(
            id: homeOrder.id,
            statusTitle: homeOrder.status.titleKey.localized,
            customer: PharmacyCustomerInfo(
                name: homeOrder.customerNameKey.localized,
                phone: "010 1234 5678",
                address: homeOrder.addressKey.localized
            ),
            items: [
                PharmacyOrderItem(id: "1", name: "بانادول اكسترا", spec: "500 مجم - 24 قرص", quantity: 1, price: 68.0, imageName: nil),
                PharmacyOrderItem(id: "2", name: "رينادول سينوس", spec: "20 قرص", quantity: 1, price: 52.0, imageName: nil)
            ],
            deliveryFee: 15.0,
            notes: ""
        )
    }
}
