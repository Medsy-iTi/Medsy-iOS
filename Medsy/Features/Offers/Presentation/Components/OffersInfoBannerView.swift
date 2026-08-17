//
//  OffersInfoBannerView.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import SwiftUI

struct OffersInfoBannerView: View {
    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(AppColor.green)

            VStack(alignment: .trailing, spacing: 4) {
                Text("offers.list.info.title".localized)
                    .font(AppColor.sans(14, .bold))
                    .foregroundStyle(AppColor.textPrim)
                    .multilineTextAlignment(.trailing)

                Text("offers.list.info.desc".localized)
                    .font(AppColor.sans(12))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.trailing)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColor.warningBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColor.warningBorder, lineWidth: 1)
                )
        )
    }
}
