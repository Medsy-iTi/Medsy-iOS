//
//  OrderProductImageView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 27/07/2026.
//

import SwiftUI

struct OrderProductImageView: View {
    let imageURL: String?
    var size: CGFloat = 48

    var body: some View {
        MedsyRemoteImage(
            urlString: imageURL,
            contentMode: .fit,
            placeholder: {
                placeholder
                    .redacted(reason: .placeholder)
            },
            failure: {
                placeholder
            }
        )
        .frame(width: size, height: size)
        .padding(4)
        .background(AppColor.card)
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
