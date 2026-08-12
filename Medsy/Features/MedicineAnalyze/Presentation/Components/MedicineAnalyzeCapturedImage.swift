//
//  MedicineAnalyzeCapturedImage.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI
import UIKit

struct MedicineAnalyzeCapturedImage: View {
    let imageData: Data?

    var body: some View {
        Group {
            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(AppColor.green)
            }
        }
        .frame(width: 72, height: 72)
        .background(AppColor.lightGreen.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
    }
}
