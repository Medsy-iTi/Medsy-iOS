//
//  OrderProductImageView.swift
//  Medsy
//
//  Created by Codex on 27/07/2026.
//

import SwiftUI

struct OrderProductImageView: View {
    let imageURL: String?
    var size: CGFloat = 48

    var body: some View {
        Group {
            if let url = imageURL.flatMap(URL.init(string:)) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                            .redacted(reason: .placeholder)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .background(AppColor.lightGreen)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous))
    }

    private var placeholder: some View {
        ZStack {
            AppColor.lightGreen
            Image(systemName: "pills.fill")
                .font(.system(size: size * 0.42))
                .foregroundStyle(AppColor.green.opacity(0.7))
        }
    }
}
