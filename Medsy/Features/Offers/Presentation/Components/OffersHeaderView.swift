//  OffersHeaderView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OffersHeaderView: View {
    @Environment(LanguageManager.self) private var languageManager
    let subtitleText: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 2) {
                Text("offers.list.title".localized)
                    .font(AppColor.sans(20, .bold))
                    .foregroundStyle(AppColor.textPrim)

                if !subtitleText.isEmpty {
                    Text(subtitleText)
                        .font(AppColor.sans(13))
                        .foregroundStyle(AppColor.textSec)
                }
            }
            .frame(maxWidth: .infinity)

            HStack {
                MedsyNavBarBackButton(action: onBack)
                Spacer()
            }
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
