enum CartInteractionSeverity: Equatable {
    case high
    case moderate
}

struct CartInteractionProduct: Identifiable, Equatable {
    let productID: Int64
    let productName: String
    let ingredient: String

    var id: Int64 {
        productID
    }
}

struct CartInteractionWarning: Identifiable, Equatable {
    let severity: CartInteractionSeverity
    let title: String
    let advice: String
    let involvedProducts: [CartInteractionProduct]

    var id: String {
        let productIDs = involvedProducts.map { String($0.productID) }.joined(separator: ",")
        return "\(severity)-\(title)-\(productIDs)"
    }
}
