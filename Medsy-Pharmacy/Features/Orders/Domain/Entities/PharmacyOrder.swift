//
//  PharmacyOrder.swift
//  Medsy
//
//  Created by Shahudaa on 21/07/2026.
//


import Foundation

public final class PharmacySubmittedOffersStore: @unchecked Sendable {
    public static let shared = PharmacySubmittedOffersStore()
    private var submittedIds: Set<Int> = []
    private let lock = NSLock()
    private let userDefaultsKey = "com.medsy.pharmacy.submitted_offer_request_ids"

    private init() {
        if let savedArray = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Int] {
            submittedIds = Set(savedArray)
        }
    }

    public func contains(_ id: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return submittedIds.contains(id)
    }

    public func insert(_ id: Int) {
        lock.lock()
        defer {
            let array = Array(submittedIds)
            UserDefaults.standard.set(array, forKey: userDefaultsKey)
            lock.unlock()
        }
        submittedIds.insert(id)
    }
}

struct PharmacyOrder: Identifiable, Equatable, Sendable, Hashable {
    let id: Int
    let userId: Int
    let pharmacyId: Int
    let totalPrice: Double
    let deliveryCoordinate: (latitude: Double, longitude: Double)
    let status: PharmacyOrderAPIStatus
    let date: Date
    let items: [PharmacyOrderLineItem]
    let deliveryAddress: String
    let prescriptionUrl: String?
    let customerName: String?
    let customerPhone: String?
    let notes: String?
    let assignmentStatus: String?

    init(
        id: Int,
        userId: Int,
        pharmacyId: Int,
        totalPrice: Double,
        deliveryCoordinate: (latitude: Double, longitude: Double),
        status: PharmacyOrderAPIStatus,
        date: Date,
        items: [PharmacyOrderLineItem],
        deliveryAddress: String,
        prescriptionUrl: String? = nil,
        customerName: String? = nil,
        customerPhone: String? = nil,
        notes: String? = nil,
        assignmentStatus: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.pharmacyId = pharmacyId
        self.totalPrice = totalPrice
        self.deliveryCoordinate = deliveryCoordinate
        self.status = status
        self.date = date
        self.items = items
        self.deliveryAddress = deliveryAddress
        self.prescriptionUrl = prescriptionUrl
        self.customerName = customerName
        self.customerPhone = customerPhone
        self.notes = notes
        self.assignmentStatus = assignmentStatus
    }

    static func == (lhs: PharmacyOrder, rhs: PharmacyOrder) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct PharmacyOrderLineItem: Identifiable, Equatable, Sendable, Hashable {
    let id: Int
    let productId: Int
    let quantity: Int
    let unitPrice: Double
    let productName: String?
    let imageUrl: String?
    let form: String?
    let strength: String?
    let packSize: String?

    static func == (lhs: PharmacyOrderLineItem, rhs: PharmacyOrderLineItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


enum PharmacyOrderAPIStatus: Equatable, Sendable, Hashable {
    case pending
    case accepted
    case preparing
    case readyForPickup
    case readyForDelivery
    case outForDelivery
    case delivered
    case cancelled
    case completed
    case expired
    case unknown(String)

    init(rawValue: String) {
        switch rawValue.uppercased() {
        case "PENDING": self = .pending
        case "ACCEPTED": self = .accepted
        case "PREPARING": self = .preparing
        case "READY_FOR_PICKUP": self = .readyForPickup
        case "READY_FOR_DELIVERY": self = .readyForDelivery
        case "OUT_FOR_DELIVERY": self = .outForDelivery
        case "DELIVERED": self = .delivered
        case "CANCELLED", "CANCELED": self = .cancelled
        case "COMPLETED": self = .completed
        case "EXPIRED": self = .expired
        default: self = .unknown(rawValue)
        }
    }
}

struct PharmacyOrdersPage: Sendable {
    let orders: [PharmacyOrder]
    let pageNumber: Int
    let totalPages: Int
    let isLastPage: Bool
}
