
//
//  AICatalogProduct.swift
//  Medsy
//

struct AICatalogProduct: Identifiable, Sendable {

    let id:             Int
    let name:           String
    let productName:    String?
    let strength:       String?
    let packSize:       String?
    let form:           String?
    let price:          Double
    let scientificName: String?
    let company:        String?
    let description:    String?
    let imageUrl:       String?

    var displayName: String { productName ?? name }
    var detailLine: String {
        [strength, packSize, form].compactMap { $0 }.joined(separator: " · ")
    }

    var formattedPrice: String {
        let formatted = price.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(price))
            : String(format: "%.2f", price)
        return "EGP \(formatted)"
    }
}
