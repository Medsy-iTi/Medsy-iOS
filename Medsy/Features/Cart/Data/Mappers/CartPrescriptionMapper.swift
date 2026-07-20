//
//  CartPrescriptionMapper.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

enum CartPrescriptionMapper {
    static func map(_ dto: CachedCartPrescriptionDTO) -> CartPrescription {
        CartPrescription(
            id: dto.id,
            data: dto.data,
            source: dto.source,
            createdAt: dto.createdAt
        )
    }

    static func map(_ prescription: CartPrescription) -> CachedCartPrescriptionDTO {
        CachedCartPrescriptionDTO(
            id: prescription.id,
            data: prescription.data,
            source: prescription.source,
            createdAt: prescription.createdAt
        )
    }
}
