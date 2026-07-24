import Foundation

struct PrescriptionCandidateDisplay: Identifiable, Equatable {
    let id: Int
    let name: String
    let strength: String?
    let form: String?
    let price: Double
    let imageURL: String?

    var details: String {
        [strength, form]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: " • ")
    }

    var formattedPrice: String {
        PrescriptionPriceFormatter.format(price)
    }
}

struct PrescriptionSelectedProductDisplay: Equatable {
    let productID: Int64
    let name: String
    let details: String
    let unitPrice: Double
    let imageURL: String?
}

struct PrescriptionMedicineDisplay: Identifiable, Equatable {
    let id: String
    let rawText: String
    let extractedName: String
    let extractedStrength: String?
    let extractedForm: String?
    let matchStatus: String
    let confidence: Double
    let candidates: [PrescriptionCandidateDisplay]
    var selectedProduct: PrescriptionSelectedProductDisplay?
    var quantity: Int

    init(
        id: String,
        rawText: String,
        extractedName: String,
        extractedStrength: String? = nil,
        extractedForm: String? = nil,
        matchStatus: String,
        confidence: Double,
        candidates: [PrescriptionCandidateDisplay],
        selectedProduct: PrescriptionSelectedProductDisplay? = nil,
        quantity: Int = 1
    ) {
        self.id = id
        self.rawText = rawText
        self.extractedName = extractedName
        self.extractedStrength = extractedStrength
        self.extractedForm = extractedForm
        self.matchStatus = matchStatus
        self.confidence = confidence
        self.candidates = candidates
        self.selectedProduct = selectedProduct
        self.quantity = quantity
    }

    var name: String {
        selectedProduct?.name ?? extractedName
    }

    var details: String {
        if let selectedProduct, !selectedProduct.details.isEmpty {
            return selectedProduct.details
        }

        let extractedDetails = [extractedStrength, extractedForm]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: " • ")
        return extractedDetails.isEmpty ? rawText : extractedDetails
    }

    var price: String? {
        selectedProduct.map { PrescriptionPriceFormatter.format($0.unitPrice) }
    }

    var imageURL: String? {
        selectedProduct?.imageURL
    }

    var isConfirmed: Bool {
        selectedProduct != nil
    }

    var needsReview: Bool {
        !isConfirmed
    }

    var cartItem: CartDisplayItem? {
        guard let selectedProduct else { return nil }
        return CartDisplayItem(
            id: String(selectedProduct.productID),
            productID: selectedProduct.productID,
            name: selectedProduct.name,
            dosageInfo: selectedProduct.details,
            unitPrice: selectedProduct.unitPrice,
            quantity: quantity,
            imageUrl: selectedProduct.imageURL
        )
    }
}

enum PrescriptionPriceFormatter {
    static func format(_ price: Double) -> String {
        let value: String
        if price.rounded() == price {
            value = String(format: "%.0f", price)
        } else {
            value = String(format: "%.2f", price)
                .replacingOccurrences(of: "0$", with: "", options: .regularExpression)
        }
        return "\(value) EGP"
    }
}
