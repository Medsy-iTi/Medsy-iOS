
//
//  CatalogAskMapper.swift
//  Medsy
//

import Foundation

enum CatalogAskMapper {

    // MARK: - DTO → Domain

    static func map(_ dto: CatalogAskResponseDTO, userText: String) -> ChatMessage {
        let sources = dto.sources.map(mapSource)
        let customCard: CustomCardType = sources.isEmpty
            ? .none
            : .catalogResult(sources: sources)

        return ChatMessage(
            id:         UUID().uuidString,
            text:       dto.answer,
            sender:     .ai,
            timestamp:  Date(),
            customCard: customCard
        )
    }

    // MARK: - Source

    static func mapSource(_ dto: CatalogSourceDTO) -> AICatalogSource {
        AICatalogSource(
            product:       mapProduct(dto.product),
            score:         dto.score,
            semanticScore: dto.semanticScore,
            lexicalScore:  dto.lexicalScore,
            matchReason:   dto.matchReason
        )
    }

    // MARK: - Product

    static func mapProduct(_ dto: CatalogProductDTO) -> AICatalogProduct {
        AICatalogProduct(
            id:             dto.id,
            name:           dto.name,
            productName:    dto.productName,
            strength:       dto.strength,
            packSize:       dto.packSize,
            form:           dto.form,
            price:          dto.price,
            scientificName: dto.scientificName,
            company:        dto.company,
            description:    dto.description,
            imageUrl:       dto.imageUrl
        )
    }
}
