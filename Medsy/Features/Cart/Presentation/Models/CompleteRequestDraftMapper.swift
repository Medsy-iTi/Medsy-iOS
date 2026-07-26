//
//  CompleteRequestDraftMapper.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Foundation
import UIKit

enum CompleteRequestDraftMapper {
    static func map(_ draft: CartRequestDraft) -> CompleteRequestDraft {
        CompleteRequestDraft(
            items: draft.items.map { item in
                CompleteRequestItem(
                    id: item.id,
                    name: item.name,
                    dosageInfo: item.dosageInfo,
                    imageURL: item.imageUrl,
                    unitPrice: item.unitPrice,
                    quantity: item.quantity
                )
            },
            prescriptionCount: draft.prescriptions.count,
            prescriptionData: normalizedPrescriptionData(
                from: draft.prescriptions.first?.imageData
            )
        )
    }

    private static func normalizedPrescriptionData(from data: Data?) -> Data? {
        guard let data,
              let image = UIImage(data: data) else {
            return nil
        }
        return image.jpegData(compressionQuality: 0.85)
    }
}
