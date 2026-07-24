//
//  CompleteRequestDraftMapper.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

enum CompleteRequestDraftMapper {
    static func map(_ draft: CartRequestDraft) -> CompleteRequestDraft {
        CompleteRequestDraft(
            items: draft.items.map { item in
                CompleteRequestItem(
                    id: item.id,
                    name: item.name,
                    dosageInfo: item.dosageInfo,
                    unitPrice: item.unitPrice,
                    quantity: item.quantity
                )
            },
            prescriptionCount: draft.prescriptions.count
        )
    }
}
