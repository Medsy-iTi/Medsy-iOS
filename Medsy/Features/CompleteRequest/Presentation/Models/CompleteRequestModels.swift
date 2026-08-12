//
//  CompleteRequestModels.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Foundation

enum CompleteRequestPaymentMethod: String, CaseIterable, Equatable {
    case cash = "CASH"
    case visa = "VISA"
}

struct CompleteRequestLocation: Equatable {
    let address: String
    let latitude: Double
    let longitude: Double

    var hasValidCoordinate: Bool {
        (-90...90).contains(latitude)
            && (-180...180).contains(longitude)
            && !(latitude == 0 && longitude == 0)
    }
}

struct CompleteRequestItem: Identifiable, Equatable {
    let id: String
    let name: String
    let dosageInfo: String
    let imageURL: String?
    let unitPrice: Double
    let quantity: Int

    init(
        id: String,
        name: String,
        dosageInfo: String,
        imageURL: String? = nil,
        unitPrice: Double,
        quantity: Int
    ) {
        self.id = id
        self.name = name
        self.dosageInfo = dosageInfo
        self.imageURL = imageURL
        self.unitPrice = unitPrice
        self.quantity = quantity
    }

    var lineTotal: Double {
        unitPrice * Double(quantity)
    }
}

struct CompleteRequestDraft: Equatable {
    let items: [CompleteRequestItem]
    let prescriptionCount: Int
    let prescriptionData: Data?
    let pharmacistNote: String

    init(
        items: [CompleteRequestItem],
        prescriptionCount: Int,
        prescriptionData: Data? = nil,
        pharmacistNote: String = ""
    ) {
        self.items = items
        self.prescriptionCount = prescriptionCount
        self.prescriptionData = prescriptionData
        self.pharmacistNote = pharmacistNote
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var estimatedTotal: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    var summaryCount: Int {
        itemCount + prescriptionCount
    }
}

struct CompleteRequestSubmission: Equatable {
    let deliveryLocation: CompleteRequestLocation?
    let paymentMethod: CompleteRequestPaymentMethod
    let itemCount: Int
    let prescriptionCount: Int
    let estimatedTotal: Double
}

enum CompleteRequestValidationError: Hashable {
    case locationRequired

    var localizedMessage: String {
        switch self {
        case .locationRequired:
            "complete_request.validation.location".localized
        }
    }
}
