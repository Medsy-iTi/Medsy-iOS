
//
//  CatalogAskResponseDTO.swift
//  Medsy
//


struct CatalogAskResponseDTO: Decodable {

    let question:            String
    let answer:              String
    let language:            String
    let generationProvider:  String
    let generationModel:     String
    let semanticSearchUsed:  Bool
    let sources:             [CatalogSourceDTO]
}



struct CatalogSourceDTO: Decodable {

    let product:       CatalogProductDTO
    let score:         Double
    let semanticScore: Double
    let lexicalScore:  Double
    let matchReason:   String
}


struct CatalogProductDTO: Decodable {

    let id:                 Int
    let name:               String
    let productName:        String?
    let strength:           String?
    let packSize:           String?
    let form:               String?
    let price:              Double
    let scientificName:     String?
    let scientificCategory: String?
    let categoryId:         Int?
    let consumerCategory:   String?
    let company:            String?
    let route:              String?
    let description:        String?
    let imageUrl:           String?
}
