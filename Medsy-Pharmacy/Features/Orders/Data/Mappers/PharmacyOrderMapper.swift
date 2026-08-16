//
//  PharmacyOrderMapper.swift
//  Medsy
//
//  Created by Shahudaa on 21/07/2026.
//


import Foundation

enum PharmacyOrderMapper {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    static func map(_ dto: PharmacyOrderDTO) -> PharmacyOrder {
        PharmacyOrder(
            id: dto.id,
            userId: dto.userId,
            pharmacyId: dto.pharmacyId,
            totalPrice: dto.totalPrice,
            deliveryCoordinate: (dto.deliveryLatitude, dto.deliveryLongitude),
            status: PharmacyOrderAPIStatus(rawValue: dto.status),
            date: dateFormatter.date(from: dto.date) ?? Date(),
            items: dto.items.map {
                PharmacyOrderLineItem(
                    id: $0.id,
                    productId: $0.productId,
                    quantity: $0.quantity,
                    unitPrice: $0.unitPrice,
                    productName: nil,
                    imageUrl: nil,
                    form: nil,
                    strength: nil,
                    packSize: nil
                )
            },
            deliveryAddress: "pharmacy.orders.address.fallback".localized,
            prescriptionUrl: nil,
            customerName: nil,
            customerPhone: nil,
            notes: nil,
            paymentMethod: dto.paymentMethod
        )
    }

    static func map(_ dto: PharmacyMedicineRequestDTO) -> PharmacyOrder {
        var total = 0.0
        if let items = dto.items {
            for item in items {
                let unitPrice = item.product?.price ?? item.unitPrice ?? 0.0
                total += unitPrice * Double(item.quantity)
            }
        }
        let parsedDate = parseDate(from: dto.createdAt)

        let items = (dto.items ?? []).map { item -> PharmacyOrderLineItem in
            let unitPrice = item.product?.price ?? item.unitPrice ?? 0.0
            let productName = item.product?.name ?? item.product?.productName ?? item.productName
            let imageUrl = item.product?.imageUrl ?? item.imageUrl
            let form = item.product?.form ?? item.form
            let strength = item.product?.strength ?? item.strength
            let packSize = item.product?.packSize ?? item.packSize

            return PharmacyOrderLineItem(
                id: item.id,
                productId: item.product?.id ?? item.productId ?? 0,
                quantity: item.quantity,
                unitPrice: unitPrice,
                productName: productName,
                imageUrl: imageUrl,
                form: form,
                strength: strength,
                packSize: packSize
            )
        }

        return PharmacyOrder(
            id: dto.id,
            userId: dto.customerId ?? 0,
            pharmacyId: 0,
            totalPrice: total,
            deliveryCoordinate: (dto.deliveryLatitude ?? 0.0, dto.deliveryLongitude ?? 0.0),
            status: PharmacyOrderAPIStatus(rawValue: dto.status),
            date: parsedDate,
            items: items,
            deliveryAddress: dto.deliveryAddress ?? "pharmacy.orders.address.fallback".localized,
            prescriptionUrl: dto.prescriptionUrl,
            customerName: dto.customerName,
            customerPhone: dto.customerPhone,
            notes: dto.notes,
            paymentMethod: dto.paymentMethod
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

    static func map(_ dto: PharmacyRequestAssignmentDTO) -> PharmacyOrder {
        var total = 0.0
        if let items = dto.request.items {
            for item in items {
                let unitPrice = item.product?.price ?? item.unitPrice ?? 0.0
                total += unitPrice * Double(item.quantity)
            }
        }
        let parsedDate = parseDate(from: dto.request.createdAt)

        let items = (dto.request.items ?? []).map { item -> PharmacyOrderLineItem in
            let unitPrice = item.product?.price ?? item.unitPrice ?? 0.0
            let productName = item.product?.name ?? item.product?.productName ?? item.productName
            let imageUrl = item.product?.imageUrl ?? item.imageUrl
            let form = item.product?.form ?? item.form
            let strength = item.product?.strength ?? item.strength
            let packSize = item.product?.packSize ?? item.packSize

            return PharmacyOrderLineItem(
                id: item.id,
                productId: item.product?.id ?? item.productId ?? 0,
                quantity: item.quantity,
                unitPrice: unitPrice,
                productName: productName,
                imageUrl: imageUrl,
                form: form,
                strength: strength,
                packSize: packSize
            )
        }

        return PharmacyOrder(
            id: dto.request.id,
            userId: dto.request.customerId ?? 0,
            pharmacyId: 0,
            totalPrice: total,
            deliveryCoordinate: (dto.request.deliveryLatitude ?? 0.0, dto.request.deliveryLongitude ?? 0.0),
            status: PharmacyOrderAPIStatus(rawValue: dto.request.status),
            date: parsedDate,
            items: items,
            deliveryAddress: dto.request.deliveryAddress ?? "pharmacy.orders.address.fallback".localized,
            prescriptionUrl: dto.request.prescriptionUrl,
            customerName: dto.request.customerName,
            customerPhone: dto.request.customerPhone,
            notes: dto.request.notes,
            assignmentStatus: dto.assignmentStatus,
            paymentMethod: dto.request.paymentMethod
        )
    }

    static func map(_ dto: PageResponseDTO<PharmacyRequestAssignmentDTO>) -> PharmacyOrdersPage {
        PharmacyOrdersPage(
            orders: dto.content.map { map($0) },
            pageNumber: dto.pageNumber,
            totalPages: dto.totalPages,
            isLastPage: dto.last
        )
    }

    static func map(_ dto: PageResponseDTO<PharmacyMedicineRequestDTO>) -> PharmacyOrdersPage {
        PharmacyOrdersPage(
            orders: dto.content.map { map($0) },
            pageNumber: dto.pageNumber,
            totalPages: dto.totalPages,
            isLastPage: dto.last
        )
    }

    static func mapToListItem(_ order: PharmacyOrder) -> PharmacyOrderListItem {
        let rawPayment = order.paymentMethod?.uppercased()
        let paymentMethod: PharmacyOrderPaymentMethod = (rawPayment == "CARD" || rawPayment == "ONLINE" || rawPayment == "VISA") ? .visa(lastFourDigits: "") : .cash
        return PharmacyOrderListItem(
            id: String(order.id),
            customerName: order.customerName ?? "pharmacy.orders.customer.fallback".localized(String(order.userId)),
            phoneNumber: order.customerPhone ?? "—",
            address: order.deliveryAddress.isEmpty ? "pharmacy.orders.address.fallback".localized : order.deliveryAddress,
            paymentMethod: paymentMethod,
            amount: Int(order.totalPrice.rounded()),
            createdAt: order.date,
            status: mapStatus(order.status, assignmentStatus: order.assignmentStatus, orderId: order.id)
        )
    }

    private static func mapStatus(_ status: PharmacyOrderAPIStatus, assignmentStatus: String?, orderId: Int) -> PharmacyOrderListStatus {
        switch status {
        case .accepted, .preparing, .readyForPickup, .readyForDelivery, .outForDelivery:
            return .preparing
        case .delivered:
            return .delivered
        case .completed:
            return .completed
        case .expired:
            return .expired
        case .cancelled:
            return .expired
        case .pending, .searching, .unknown:
            if let rawAssignment = assignmentStatus?.uppercased() {
                if rawAssignment == "OFFER_CREATED" || rawAssignment == "OFFER_MADE" || rawAssignment == "SUBMITTED" || rawAssignment == "OFFERED" {
                    return .pendingApproval
                } else if rawAssignment == "PENDING" {
                    return .new
                } else {
                    return .expired
                }
            } else {
                if PharmacySubmittedOffersStore.shared.contains(orderId) {
                    return .pendingApproval
                }
                return .new
            }
        }
    }

    static func mapToDetailsPresentationModel(_ order: PharmacyOrder) -> PharmacyRequestDetailsModel {
        let presentationItems = order.items.map { item in
            PharmacyOrderItem(
                id: String(item.id),
                requestItemId: item.id,
                productId: item.productId,
                name: item.productName ?? "pharmacy.request.product_label".localized(String(item.productId)),
                spec: "pharmacy.orders.item_pieces".localized(String(item.quantity)),
                quantity: item.quantity,
                price: item.unitPrice,
                imageName: nil,
                imageUrl: makeFullImageUrl(item.imageUrl),
                isAvailable: true,
                selectedOfferProductId: item.productId,
                form: item.form,
                strength: item.strength,
                packSize: item.packSize
            )
        }

        return PharmacyRequestDetailsModel(
            id: String(order.id),
            minutesAgo: Int(Date().timeIntervalSince(order.date) / 60),
            statusTitle: mapStatusTitle(order.status),
            customer: PharmacyCustomerInfo(
                name: order.customerName ?? "pharmacy.request.customer_id_label".localized(String(order.userId)),
                phone: order.customerPhone ?? "—",
                address: order.deliveryAddress
            ),
            items: presentationItems,
            deliveryFee: 0.0,
            notes: order.notes ?? "",
            prescriptionImageUrl: makeFullImageUrl(order.prescriptionUrl),
            deliveryLatitude: order.deliveryCoordinate.latitude,
            deliveryLongitude: order.deliveryCoordinate.longitude,
            createdAt: order.date,
            paymentMethod: order.paymentMethod
        )
    }

    private static func makeFullImageUrl(_ urlString: String?) -> String? {
        guard let urlString = urlString, !urlString.isEmpty else { return nil }
        if urlString.hasPrefix("http") { return urlString }
        let rootUrl = PharmacyConfiguration.apiBaseURL
        let path = urlString.hasPrefix("/") ? String(urlString.dropFirst()) : urlString
        return rootUrl + path
    }

    private static func mapStatusTitle(_ status: PharmacyOrderAPIStatus) -> String {
        switch status {
        case .pending, .searching: return "pharmacy.home.order_new".localized
        case .accepted, .preparing, .readyForPickup, .readyForDelivery, .outForDelivery: return "pharmacy.home.order_preparing".localized
        case .delivered: return "pharmacy.home.order_delivered".localized
        case .completed: return "pharmacy.orders.status.completed".localized
        case .expired: return "pharmacy.orders.status.expired".localized
        case .cancelled: return "pharmacy.home.order_delivered".localized
        case .unknown(let val): return val
        }
    }

    private static func parseDate(from dateStr: String?) -> Date {
        guard let dateStr = dateStr else { return Date() }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateStr) {
            return date
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateStr) {
                return date
            }
        }
        
        if !dateStr.hasSuffix("Z") && !dateStr.contains("+") && !dateStr.contains("-") {
            let withZ = dateStr + "Z"
            if let date = isoFormatter.date(from: withZ) {
                return date
            }
        }
        
        return Date()
    }
}
