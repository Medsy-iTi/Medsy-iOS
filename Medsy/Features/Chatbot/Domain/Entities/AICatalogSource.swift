
//
//  AICatalogSource.swift
//  Medsy
//


struct AICatalogSource: Identifiable, Sendable {

    var id: Int { product.id }

    let product:       AICatalogProduct
    let score:         Double
    let semanticScore: Double
    let lexicalScore:  Double
    let matchReason:   String
    var scorePercentage: Int { Int((score * 100).rounded()) }
}
