//
//  MedicineAnalyzePreviewImage.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI
import UIKit

struct MedicineAnalyzePreviewImage: View {
    let imageData: Data

    var body: some View {
        Group {
            if let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "pills")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(AppColor.green)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 420)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        }
    }
}
