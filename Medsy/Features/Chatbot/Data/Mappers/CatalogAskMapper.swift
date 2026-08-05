
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

        var finalAnswer = dto.answer
        if let data = dto.answer.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let innerAnswer = json["answer"] as? String {
            finalAnswer = innerAnswer
        }

        return ChatMessage(
            id:         UUID().uuidString,
            text:       finalAnswer,
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
