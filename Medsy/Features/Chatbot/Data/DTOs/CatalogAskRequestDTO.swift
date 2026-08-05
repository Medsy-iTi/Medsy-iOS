
//
//  CatalogAskRequestDTO.swift
//  Medsy
//

struct CatalogAskRequestDTO: Encodable {

    let question: String
    let lang: String
    let limit: Int
}
