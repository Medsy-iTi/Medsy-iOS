//
//  CompleteRequestDraftMapper.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Foundation
import UIKit

enum CompleteRequestDraftMapper {
    private static let maximumPrescriptionDimension: CGFloat = 1_280
    private static let maximumPrescriptionBytes = 1_024 * 1_024

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
            ),
            pharmacistNote: draft.pharmacistNote
        )
    }

    private static func normalizedPrescriptionData(from data: Data?) -> Data? {
        guard let data,
              let image = UIImage(data: data) else {
            return nil
        }

        let normalizedImage = resizedImageIfNeeded(image)
        let compressionQualities: [CGFloat] = [0.75, 0.6, 0.45, 0.35]

        for quality in compressionQualities {
            guard let compressedData = normalizedImage.jpegData(compressionQuality: quality) else {
                continue
            }
            if compressedData.count <= maximumPrescriptionBytes {
                return compressedData
            }
        }

        return normalizedImage.jpegData(compressionQuality: 0.25)
    }

    private static func resizedImageIfNeeded(_ image: UIImage) -> UIImage {
        let longestDimension = max(image.size.width, image.size.height)
        guard longestDimension > maximumPrescriptionDimension else {
            return image
        }

        let scale = maximumPrescriptionDimension / longestDimension
        let targetSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1

        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
