//
//  MedicineAnalyzeResultThumbnail.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeResultThumbnail: View {
    let imageURL: String?
    var size: CGFloat = 72

    var body: some View {
        AsyncImage(url: imageURL.flatMap(URL.init(string:))) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .scaledToFit()
                    .padding(5)
            case .empty:
                ProgressView()
                    .tint(AppColor.green)
            default:
                Image(systemName: "pills.fill")
                    .font(.system(size: size * 0.3, weight: .semibold))
                    .foregroundStyle(AppColor.green)
            }
        }
        .frame(width: size, height: size)
        .background(AppColor.lightGreen.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
    }
}
