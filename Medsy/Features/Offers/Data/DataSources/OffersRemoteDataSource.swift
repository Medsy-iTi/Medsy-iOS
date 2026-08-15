import Foundation

typealias GetOfferResultResponseDTO = APIResponseDTO<OfferResultResponseDTO>
typealias ConfirmOfferResponseDTOContainer = APIResponseDTO<ConfirmOfferResponseDTO>

struct OfferResultResponseDTO: Decodable, Equatable {
    let items: [OfferResultItemDTO]
    let totalPrice: Double
    let prescriptionUrl: String?
    let paymentMethod: String?

    private enum CodingKeys: String, CodingKey {
        case items = "medicineRequestResultItemList"
        case fallbackItems = "items"
        case totalPrice
        case prescriptionUrl
        case paymentMethod
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let itemsList = try container.decodeIfPresent([OfferResultItemDTO].self, forKey: .items) {
            items = itemsList
        } else if let fallback = try container.decodeIfPresent([OfferResultItemDTO].self, forKey: .fallbackItems) {
            items = fallback
        } else {
            items = []
        }
        totalPrice = try container.decodeIfPresent(Double.self, forKey: .totalPrice) ?? 0.0
        prescriptionUrl = try container.decodeIfPresent(String.self, forKey: .prescriptionUrl)
        paymentMethod = try container.decodeIfPresent(String.self, forKey: .paymentMethod)
    }

    init(items: [OfferResultItemDTO], totalPrice: Double, prescriptionUrl: String? = nil, paymentMethod: String? = nil) {
        self.items = items
        self.totalPrice = totalPrice
        self.prescriptionUrl = prescriptionUrl
        self.paymentMethod = paymentMethod
    }
}

struct ProductNestedDTO: Codable, Equatable, Hashable, Sendable {
    let id: Int?
    let name: String?
    let productName: String?
    let price: Double?
    let imageUrl: String?
    let form: String?
    let strength: String?
    let company: String?
    let description: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case productName
        case price
        case imageUrl
        case imageURL
        case image
        case form
        case strength
        case company
        case description
    }

    init(
        id: Int? = nil,
        name: String? = nil,
        productName: String? = nil,
        price: Double? = nil,
        imageUrl: String? = nil,
        form: String? = nil,
        strength: String? = nil,
        company: String? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.productName = productName
        self.price = price
        self.imageUrl = imageUrl
        self.form = form
        self.strength = strength
        self.company = company
        self.description = description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        productName = try container.decodeIfPresent(String.self, forKey: .productName)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
        form = try container.decodeIfPresent(String.self, forKey: .form)
        strength = try container.decodeIfPresent(String.self, forKey: .strength)
        company = try container.decodeIfPresent(String.self, forKey: .company)
        description = try container.decodeIfPresent(String.self, forKey: .description)

        var img = try? container.decodeIfPresent(String.self, forKey: .imageUrl)
        if img == nil || img?.isEmpty == true {
            img = try? container.decodeIfPresent(String.self, forKey: .imageURL)
        }
        if img == nil || img?.isEmpty == true {
            img = try? container.decodeIfPresent(String.self, forKey: .image)
        }
        imageUrl = img
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(productName, forKey: .productName)
        try container.encodeIfPresent(price, forKey: .price)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(form, forKey: .form)
        try container.encodeIfPresent(strength, forKey: .strength)
        try container.encodeIfPresent(company, forKey: .company)
        try container.encodeIfPresent(description, forKey: .description)
    }
}

struct OfferResultItemDTO: Decodable, Equatable {
    let requestItemId: Int
    let productId: Int?
    let productName: String
    let imageUrl: String?
    let unitPrice: Double
    let isAlternative: Bool
    let isAvailable: Bool

    private enum CodingKeys: String, CodingKey {
        case requestItemId
        case productId
        case productName
        case imageUrl
        case imageURL
        case image
        case unitPrice
        case isAlternative
        case alternative
        case isAvailable
        case available
        case product
        case name
        case requestedProductName
        case requestedItemName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nestedProduct = try container.decodeIfPresent(ProductNestedDTO.self, forKey: .product)

        requestItemId = try container.decode(Int.self, forKey: .requestItemId)
        productId = try container.decodeIfPresent(Int.self, forKey: .productId) ?? nestedProduct?.id

        var nameAtTop = try? container.decodeIfPresent(String.self, forKey: .productName)
        if nameAtTop == nil || nameAtTop?.isEmpty == true {
            nameAtTop = try? container.decodeIfPresent(String.self, forKey: .name)
        }
        if nameAtTop == nil || nameAtTop?.isEmpty == true {
            nameAtTop = try? container.decodeIfPresent(String.self, forKey: .requestedProductName)
        }
        if nameAtTop == nil || nameAtTop?.isEmpty == true {
            nameAtTop = try? container.decodeIfPresent(String.self, forKey: .requestedItemName)
        }

        var candidate: String? = nil
        if let top = nameAtTop, !top.isEmpty {
            candidate = top
        } else if let pName = nestedProduct?.name, !pName.isEmpty {
            candidate = pName
        } else if let pName = nestedProduct?.productName, !pName.isEmpty {
            candidate = pName
        }

        if let validName = candidate, !validName.isEmpty {
            productName = validName
        } else {
            productName = "offers.details.unavailableItem".localized
        }

        var imgUrl = try? container.decodeIfPresent(String.self, forKey: .imageUrl)
        if imgUrl == nil || imgUrl?.isEmpty == true {
            imgUrl = try? container.decodeIfPresent(String.self, forKey: .imageURL)
        }
        if imgUrl == nil || imgUrl?.isEmpty == true {
            imgUrl = try? container.decodeIfPresent(String.self, forKey: .image)
        }
        if imgUrl == nil || imgUrl?.isEmpty == true {
            imgUrl = nestedProduct?.imageUrl
        }
        imageUrl = imgUrl

        if let price = try container.decodeIfPresent(Double.self, forKey: .unitPrice), price > 0 {
            unitPrice = price
        } else {
            unitPrice = nestedProduct?.price ?? 0.0
        }

        if let alt = try container.decodeIfPresent(Bool.self, forKey: .isAlternative) {
            isAlternative = alt
        } else if let alt = try container.decodeIfPresent(Bool.self, forKey: .alternative) {
            isAlternative = alt
        } else {
            isAlternative = false
        }

        if let avail = try container.decodeIfPresent(Bool.self, forKey: .isAvailable) {
            isAvailable = avail
        } else if let avail = try container.decodeIfPresent(Bool.self, forKey: .available) {
            isAvailable = avail
        } else {
            isAvailable = (nestedProduct != nil)
        }
    }

    init(requestItemId: Int, productId: Int?, productName: String, imageUrl: String?, unitPrice: Double, isAlternative: Bool, isAvailable: Bool) {
        self.requestItemId = requestItemId
        self.productId = productId
        self.productName = productName
        self.imageUrl = imageUrl
        self.unitPrice = unitPrice
        self.isAlternative = isAlternative
        self.isAvailable = isAvailable
    }
}

struct RequestItemUpdatedEventDTO: Decodable, Equatable {
    let requestId: Int?
    let updatedItems: [UpdatedItemDTO]
}

struct UpdatedItemDTO: Decodable, Equatable {
    let requestItemId: Int
    let status: String?
    let product: ProductNestedDTO?
}

struct ConfirmOfferItemDTO: Encodable, Equatable {
    let requestItemId: Int
    let productId: Int?
}

struct ConfirmOfferRequestDTO: Encodable, Equatable {
    let selectedItems: [ConfirmOfferItemDTO]
}

struct ConfirmOfferResponseDTO: Decodable, Equatable {
    let masterOrderId: Int
    let orderStatus: String
    let paymentMethod: String
    let paymentStatus: String?
}

struct ConfirmOfferFulfillmentRequestDTO: Encodable, Equatable {
    let fulfillmentMethod: String
}

struct SelectPharmacyResponseDTO: Codable, Equatable, Hashable, Sendable {
    let requestId: Int
    let offers: [SelectPharmacyOfferDTO]
    let deliveryFees: Double
    let totalPrice: Double
}

struct SelectPharmacyOfferDTO: Codable, Equatable, Hashable, Sendable {
    let offerId: Int
    let pharmacyId: Int
    let pharmacyName: String
    let latitude: Double
    let longitude: Double
    let items: [SelectPharmacyItemDTO]
}

struct SelectPharmacyItemDTO: Codable, Equatable, Hashable, Sendable {
    let id: Int
    let productId: Int?
    let product: ProductNestedDTO?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
}

struct ConfirmOfferOrderDTO: Decodable, Equatable {
    let orderId: Int
    let pharmacyId: Int
    let pharmacyName: String
    let itemIds: [Int]
}

struct MasterOrdersListResponseDTO: Decodable {
    let content: [MasterOrderDTO]?

    private enum CodingKeys: String, CodingKey {
        case content
        case data
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if let items = try? container.decodeIfPresent([MasterOrderDTO].self, forKey: .content) {
                content = items
                return
            }
            if let items = try? container.decodeIfPresent([MasterOrderDTO].self, forKey: .data) {
                content = items
                return
            }
        }
        if let singleContainer = try? decoder.singleValueContainer(), let items = try? singleContainer.decode([MasterOrderDTO].self) {
            content = items
            return
        }
        content = []
    }
}

struct RequestsListResponseDTO: Decodable {
    let content: [CompleteRequestResponseDTO]?

    private enum CodingKeys: String, CodingKey {
        case content
        case data
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if let items = try? container.decodeIfPresent([CompleteRequestResponseDTO].self, forKey: .content) {
                content = items
                return
            }
            if let items = try? container.decodeIfPresent([CompleteRequestResponseDTO].self, forKey: .data) {
                content = items
                return
            }
        }
        if let singleContainer = try? decoder.singleValueContainer(), let items = try? singleContainer.decode([CompleteRequestResponseDTO].self) {
            content = items
            return
        }
        content = []
    }
}

extension String {
    func toBackendDate() -> Date? {
        let formatters: [DateFormatter] = [
            {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                df.locale = Locale(identifier: "en_US_POSIX")
                df.timeZone = TimeZone(secondsFromGMT: 0)
                return df
            }(),
            {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                df.locale = Locale(identifier: "en_US_POSIX")
                df.timeZone = TimeZone(secondsFromGMT: 0)
                return df
            }(),
            {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                df.locale = Locale(identifier: "en_US_POSIX")
                df.timeZone = TimeZone(secondsFromGMT: 0)
                return df
            }()
        ]
        for formatter in formatters {
            if let date = formatter.date(from: self) {
                return date
            }
        }
        if let iso = ISO8601DateFormatter().date(from: self) {
            return iso
        }
        return nil
    }
}
